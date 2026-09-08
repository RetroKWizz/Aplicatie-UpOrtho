import logging

from odoo import http
from odoo.http import request
from odoo.tools.sql import escape_psql

from .base import API_PREFIX, ApiError, app_route, json_ok
from .home import _current_website, _image_response, image_unique

_logger = logging.getLogger(__name__)

CLUB_PRICELIST_PARAM = 'uportho_app.club_pricelist_id'
DEFAULT_LIMIT = 20
MAX_LIMIT = 100


def _current_club_pricelist():
    """Pricelist-ul Ortho Club, pentru al doilea bloc de pret aratat alaturi de cel al
    clientului ('Pret membri Ortho Club' pe site). Identificat printr-un parametru de
    sistem, la fel ca `uportho_app.website_id` in home.py - niciodata printr-un id fix
    in cod: lista se redenumeste in fiecare an ("Ortho Club 2026", anul trecut alt
    nume), deci identitatea ei e configurare de deploy, nu cod. Fara parametru sau cu
    un id care nu (mai) exista -> None, cu warning; niciodata eroare - catalogul tot
    trebuie sa functioneze fara pretul de club."""
    Pricelist = request.env['product.pricelist'].sudo()
    raw = request.env['ir.config_parameter'].sudo().get_param(CLUB_PRICELIST_PARAM)
    if not raw:
        _logger.warning(
            'Parametrul de sistem %s nu e setat; club_price va fi null pentru toate '
            'produsele. Seteaza-l la id-ul listei de preturi Ortho Club curente.',
            CLUB_PRICELIST_PARAM)
        return Pricelist.browse()
    try:
        pricelist = Pricelist.browse(int(raw)).exists().filtered('active')
    except (TypeError, ValueError):
        pricelist = Pricelist.browse()
    if not pricelist:
        _logger.warning(
            'Parametrul de sistem %s = %r nu indica o lista de preturi existenta si activa; '
            'club_price va fi null pentru toate produsele. Odoo nu filtreaza liniile de '
            'pricelist arhivate la calculul pretului, deci o lista arhivata ar da un pret '
            'invechit, nu o eroare.', CLUB_PRICELIST_PARAM, raw)
    return pricelist


def _format_amount(amount, currency):
    """Formatare romaneasca a unei sume monetare: virgula zecimala, punct pentru mii
    ('148,50 lei', '1.234,00 lei'). Nu folosim formatarea de limba din Odoo
    (`formatLang`) ca sa nu depindem de ce limbi/traduceri sunt instalate pe o baza
    anume - separatorii sunt o cerinta de contract, nu o optiune. Numarul de zecimale
    si pozitia simbolului insa NU sunt fixe: modulul are in domeniu si liste de pret
    in alte valute decat RON (ex. "Euro Discount" pe baza reala) - se iau din
    `currency.decimal_places` / `currency.position`, nu se presupun (corect pentru
    RON azi, dar RON nu e singura valuta posibila aici)."""
    rounded = currency.round(amount)
    decimals = currency.decimal_places
    text = f'{rounded:,.{decimals}f}'
    if '.' in text:
        integer_part, decimal_part = text.split('.')
    else:
        integer_part, decimal_part = text, ''
    integer_part = integer_part.replace(',', '.')
    number = f'{integer_part},{decimal_part}' if decimal_part else integer_part
    if currency.position == 'before':
        return f'{currency.symbol}{number}'
    return f'{number} {currency.symbol}'


def serialize_price(amount, list_amount, currency):
    discount_pct = None
    if list_amount is not None and list_amount > amount:
        discount_pct = round((list_amount - amount) / list_amount * 100)
    return {
        'amount': amount,
        'currency': currency.name,
        'formatted': _format_amount(amount, currency),
        'with_vat': True,
        'list_amount': list_amount,
        'list_formatted': _format_amount(list_amount, currency) if list_amount is not None else None,
        'discount_pct': discount_pct,
    }


def _warn_if_tax_display_mismatch(website):
    """Modulul presupune ca site-ul arata preturi cu TVA inclus - cerinta spec-ului
    (sectiunea 6.4), site-ul chiar arata "Taxe incluse", si de-aia
    `_uportho_price_amounts_multi` foloseste `total_included`, iar aici `with_vat` e
    mereu True. Daca website-ul e vreodata reconfigurat pe `tax_excluded`, cifrele
    intoarse ar fi cu TVA mai mari decat in magazin, tacut - de-aia doar logam un
    warning, nu schimbam cifrele intoarse (nu e treaba acestui request sa recalculeze
    dupa alta configurare)."""
    if website.show_line_subtotals_tax_selection != 'tax_included':
        _logger.warning(
            "Website-ul %r (id %s) are show_line_subtotals_tax_selection=%r, nu "
            "'tax_included', dar API-ul aplicatiei arata mereu preturi cu TVA inclus "
            "(with_vat=True, total_included). Verifica daca site-ul chiar mai arata "
            "'Taxe incluse' - altfel preturile din app nu mai corespund magazinului.",
            website.name, website.id, website.show_line_subtotals_tax_selection)


def _prices_by_template(templates, pricelist, partner, fiscal_position):
    """Preturile serializate (obiectul intreg cu formatted/discount_pct) pentru tot
    recordset-ul `templates` pe `pricelist`, intr-o singura trecere prin varianta
    batch a calculului de pret (`_uportho_price_amounts_multi`) - vezi acolo de ce
    conteaza (N interogari de reguli de pricelist -> 1)."""
    amounts = templates._uportho_price_amounts_multi(pricelist, partner, fiscal_position=fiscal_position)
    currency = pricelist.currency_id
    return {
        template_id: serialize_price(amount, list_amount, currency)
        for template_id, (amount, list_amount) in amounts.items()
    }


def _club_prices_by_template(templates, club_pricelist, customer_pricelist, partner, fiscal_position,
                              price_by_template):
    """club_price per produs; None (fara alt calcul) cand:
    - nu exista pricelist de club configurat;
    - valuta lui difera de a clientului - altfel am arata doua preturi in valute
      diferite ca si cum ar fi comparabile ("148,50 lei" langa "133,65 EUR"), desi
      niciun calcul din spate nu le face echivalente (docs/STAGING.md confirma o
      lista "Euro Discount" printre cele active pe baza reala);
    - rezultatul e identic cu pretul clientului - spec 6.4: club_price se arata "cand
      difera", nu mereu."""
    if not club_pricelist:
        return {}
    if club_pricelist.currency_id != customer_pricelist.currency_id:
        _logger.warning(
            'Pricelist-ul Ortho Club (id %s, valuta %s) e intr-o valuta diferita de cea '
            'a clientului (%s); club_price va fi null pentru toate produsele din acest '
            'raspuns ca sa nu aratam doua preturi necomparabile.',
            club_pricelist.id, club_pricelist.currency_id.name, customer_pricelist.currency_id.name)
        return {}

    amounts = templates._uportho_price_amounts_multi(club_pricelist, partner, fiscal_position=fiscal_position)
    currency = club_pricelist.currency_id
    result = {}
    for template_id, (amount, list_amount) in amounts.items():
        club_price = serialize_price(amount, list_amount, currency)
        price = price_by_template.get(template_id)
        if price and price['amount'] == club_price['amount'] and price['currency'] == club_price['currency']:
            continue
        result[template_id] = club_price
    return result


def _products_domain(website, category_id, query):
    domain = [
        ('is_published', '=', True),
        '|', ('website_id', '=', False), ('website_id', '=', website.id),
    ]
    if category_id is not None:
        domain = domain + [('public_categ_ids', 'child_of', category_id)]
    if query:
        # escape_psql scapa '%' si '_' (wildcard-uri LIKE/ILIKE) si '\' - altfel
        # q=% s-ar potrivi cu orice si ar lista tot catalogul in loc sa caute literal
        # caracterul '%'.
        domain = domain + [
            '|', ('name', 'ilike', escape_psql(query)), ('default_code', 'ilike', escape_psql(query))]
    return domain


def _product_counts_by_category(categories, website):
    """Numarul de produse per categorie, recursiv (echivalent cu search_count pe
    ('public_categ_ids', 'child_of', category.id) pentru fiecare categorie), dar
    intr-o singura interogare grupata in loc de una per categorie (78 de categorii
    pe baza reala ar insemna 78 de query-uri separate pe ecranul de cold-start al
    aplicatiei).

    `_read_group` grupat pe un camp many2many da, per categorie, multimea produselor
    prinse DIRECT in ea (agregat 'id:recordset'). Insumarea directa a acestor multimi
    pe un subarbore ar duplica un produs prins in mai multe categorii ale aceluiasi
    subarbore (parinte + copil) - exact eroarea pe care 'child_of' o evita numarand
    fiecare produs o singura data. De aceea facem reuniunea (set union) multimilor de
    id-uri ale descendentilor, nu suma cardinalelor lor."""
    base_domain = [
        ('is_published', '=', True),
        '|', ('website_id', '=', False), ('website_id', '=', website.id),
    ]
    groups = request.env['product.template']._read_group(
        base_domain, ['public_categ_ids'], ['id:recordset'])
    direct_ids_by_category = {category.id: set(ids.ids) for category, ids in groups}

    counts = {}
    for category in categories:
        prefix = category.parent_path or ''
        descendant_ids = [c.id for c in categories if (c.parent_path or '').startswith(prefix)]
        union_ids = set()
        for descendant_id in descendant_ids:
            union_ids |= direct_ids_by_category.get(descendant_id, set())
        counts[category.id] = len(union_ids)
    return counts


def serialize_category(category, website, product_count):
    return {
        'id': category.id,
        'name': category.name,
        'parent_id': category.parent_id.id or None,
        'icon_url': (f'{API_PREFIX}/categories/{category.id}/icon?unique={image_unique(category)}'
                     if category.app_home_icon else None),
        'product_count': product_count,
    }


def _ids_with_image(templates):
    """Id-urile din `templates` care au efectiv imagine pe `image_1920`, aflate
    printr-o singura interogare pe `ir.attachment` in loc sa se citeasca fiecare
    `image_1920` (camp `fields.Image` cu `attachment=True`: o citire = acces la
    filestore + encodare base64 a unei imagini de pana la 1920px, per produs de pe
    pagina - pana la 100 de imagini incarcate integral doar ca sa fie aruncate)."""
    if not templates:
        return set()
    attachments = request.env['ir.attachment'].sudo().search([
        ('res_model', '=', 'product.template'),
        ('res_field', '=', 'image_1920'),
        ('res_id', 'in', templates.ids),
    ])
    return set(attachments.mapped('res_id'))


def serialize_product(template, price, club_price, has_image):
    return {
        'id': template.id,
        'name': template.name,
        'default_code': template.default_code or None,
        'image_url': (f'{API_PREFIX}/products/{template.id}/image?unique={image_unique(template)}'
                      if has_image else None),
        'price': price,
        'club_price': club_price,
        'badge': template._app_badge_active(),
    }


def _parse_category_id(raw):
    if raw in (None, ''):
        return None
    try:
        return int(raw)
    except (TypeError, ValueError):
        raise ApiError(422, 'validation_error', 'category_id trebuie sa fie numeric.')


def _parse_offset(raw):
    # Consistent cu _parse_category_id: lipsa parametrului e un caz normal (valoare
    # implicita), dar o valoare data care nu e numerica e "gunoi" de intrare si merita
    # 422, nu o cadere tacuta pe implicit - altfel un client cu un bug de encodare a
    # query string-ului nu ar afla niciodata.
    if raw in (None, ''):
        return 0
    try:
        value = int(raw)
    except (TypeError, ValueError):
        raise ApiError(422, 'validation_error', 'offset trebuie sa fie numeric.')
    return value if value > 0 else 0


def _parse_limit(raw):
    if raw in (None, ''):
        return DEFAULT_LIMIT
    try:
        value = int(raw)
    except (TypeError, ValueError):
        raise ApiError(422, 'validation_error', 'limit trebuie sa fie numeric.')
    if value <= 0:
        return DEFAULT_LIMIT
    return min(value, MAX_LIMIT)


class AppCatalog(http.Controller):
    @app_route('/categories', methods=['GET'])
    def categories(self, **kw):
        website = _current_website()
        domain = ['|', ('website_id', '=', False), ('website_id', '=', website.id)]
        categories = request.env['product.public.category'].search(domain)
        counts = _product_counts_by_category(categories, website)
        return json_ok([serialize_category(c, website, counts[c.id]) for c in categories])

    @app_route('/products', methods=['GET'])
    def products(self, **kw):
        website = _current_website()
        category_id = _parse_category_id(kw.get('category_id'))
        domain = _products_domain(website, category_id, kw.get('q'))
        offset = _parse_offset(kw.get('offset'))
        limit = _parse_limit(kw.get('limit'))

        Template = request.env['product.template']
        total = Template.search_count(domain)
        # Ordine explicita cu 'id' la final: ordinea implicita a modelului
        # ('is_favorite desc, name') nu include 'id', deci doua produse cu acelasi
        # nume pot schimba ordinea intre doua pagini succesive - pe 925 de produse,
        # orice doua cu acelasi nume ar duplica un produs pe doua pagini si l-ar
        # sari complet pe altul intr-un catalog cu scroll infinit.
        templates = Template.search(domain, offset=offset, limit=limit, order='is_favorite desc, name, id')

        partner = request.env.user.partner_id
        pricelist = partner.property_product_pricelist
        if not pricelist:
            # property_product_pricelist e un camp calculat/configurat; daca vreodata
            # nu rezolva nimic pentru cont, currency.round din calculul de pret ar
            # arunca ensure_one() si ar iesi ca 500 generic - preferam un raspuns clar,
            # de configurare, nu o eroare interna opaca.
            raise ApiError(
                503, 'pricelist_unavailable',
                'Lista de preturi a contului nu este configurata. Incearca din nou mai tarziu.')
        club_pricelist = _current_club_pricelist()
        _warn_if_tax_display_mismatch(website)

        # Pozitia fiscala depinde doar de partener, nu de produs sau de pricelist -
        # calculata o singura data aici, nu per produs (era chemata de doua ori per
        # produs prin _uportho_price_amounts inainte de aceasta trecere pe batch).
        fiscal_position = request.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)
        price_by_template = _prices_by_template(templates, pricelist, partner, fiscal_position)
        club_price_by_template = _club_prices_by_template(
            templates, club_pricelist, pricelist, partner, fiscal_position, price_by_template)
        ids_with_image = _ids_with_image(templates)

        products = [
            serialize_product(
                t, price_by_template[t.id], club_price_by_template.get(t.id), t.id in ids_with_image)
            for t in templates
        ]
        return json_ok({
            'products': products,
            'total': total,
            'offset': offset,
            'limit': limit,
        })

    @app_route('/products/<int:product_id>/image', methods=['GET'])
    def product_image(self, product_id, **kw):
        return _image_response(request.env['product.template'].browse(product_id), 'image_1920')
