import logging

from odoo import http
from odoo.http import request
from odoo.tools.sql import escape_psql

from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, json_ok
from .home import _current_website, _image_response, image_unique

_logger = logging.getLogger(__name__)

CLUB_PRICELIST_PARAM = 'uportho_app.club_pricelist_id'
CLUB_PRICELIST_FLAG = 'is_compare_pricelist'
DEFAULT_LIMIT = 20
MAX_LIMIT = 100


def _flagged_club_pricelist():
    """Lista Ortho Club asa cum o marcheaza clientul: prima lista de preturi activa
    bifata `is_compare_pricelist`, camp adaugat de modulul lor
    (`terrabit_prime_extension`) pe `product.pricelist`.

    E chiar cautarea dupa care se construieste al doilea tabel de pret al paginii de
    produs (`product.template._uportho_site_pricelist_for`) - se cheama acea metoda, nu
    se rescrie cautarea aici: doua cautari separate ar putea sa nu fie de acord. Exact
    asta s-a scos din modul - pretul de club venea dintr-un parametru de sistem, iar
    tabelul din bifa; la trecerea pe lista anului urmator, cine uita parametrul obtinea
    tabelul listei noi langa pretul celei vechi, fara nicio eroare.

    Doua rezultate diferite, deliberat:
    - `None` = mecanismul clientului nu exista pe baza asta (campul lipseste - cazul
      bazei locale de dezvoltare, care n-are modulele lor). Apelantul cade atunci pe
      parametrul de sistem. Prezenta campului se VERIFICA, nu se presupune: o cautare
      pe un camp inexistent ar fi eroare (aceeasi regula ca in `_uportho_availability`).
    - recordset gol = mecanismul exista, dar nicio lista nu e bifata. Aici NU se cade pe
      parametru: pe o instanta reala bifa e singura sursa de adevar, iar o rezerva
      tacuta ar reintroduce a doua sursa care poate sa nu fie de acord cu ea.

    `sudo`: listele de pret nu sunt neaparat citibile de un utilizator portal."""
    Pricelist = request.env['product.pricelist'].sudo()
    if CLUB_PRICELIST_FLAG not in Pricelist._fields:
        return None
    return request.env['product.template'].sudo()._uportho_site_pricelist_for(CLUB_PRICELIST_FLAG)


def _club_pricelist_from_param():
    """Rezerva pentru bazele fara modulele clientului (dezvoltare locala, teste): lista
    de club data prin parametrul de sistem `uportho_app.club_pricelist_id`, la fel ca
    `uportho_app.website_id` in home.py. Niciodata un id fix in cod - lista se
    redenumeste in fiecare an ("Ortho Club 2026", anul trecut alt nume).

    Warning-ul spune explicit ca s-a consultat parametrul, ca o configurare gresita sa
    se poata diagnostica din log."""
    Pricelist = request.env['product.pricelist'].sudo()
    raw = request.env['ir.config_parameter'].sudo().get_param(CLUB_PRICELIST_PARAM)
    if not raw:
        _logger.warning(
            'Campul %s nu exista pe product.pricelist (baza fara modulele clientului), '
            'iar parametrul de sistem de rezerva %s nu e setat; club_price va fi null '
            'pentru toate produsele. Seteaza-l la id-ul listei de preturi Ortho Club '
            'curente.', CLUB_PRICELIST_FLAG, CLUB_PRICELIST_PARAM)
        return Pricelist.browse()
    try:
        pricelist = Pricelist.browse(int(raw)).exists().filtered('active')
    except (TypeError, ValueError):
        pricelist = Pricelist.browse()
    if not pricelist:
        _logger.warning(
            'Parametrul de sistem de rezerva %s = %r (consultat pentru ca %s nu exista pe '
            'product.pricelist) nu indica o lista de preturi existenta si activa; '
            'club_price va fi null pentru toate produsele. Odoo nu filtreaza liniile de '
            'pricelist arhivate la calculul pretului, deci o lista arhivata ar da un pret '
            'invechit, nu o eroare.', CLUB_PRICELIST_PARAM, raw, CLUB_PRICELIST_FLAG)
    return pricelist


def _current_club_pricelist():
    """Pricelist-ul Ortho Club, pentru al doilea bloc de pret aratat alaturi de cel al
    clientului ('Pret membri Ortho Club' pe site).

    O SINGURA sursa de adevar: bifa clientului `is_compare_pricelist`, aceeasi dupa
    care magazinul isi alege lista de comparatie pe pagina de produs. Parametrul de
    sistem ramane doar acolo unde bifa nu exista deloc (baza locala de dezvoltare,
    testele) - altfel pretul de club si tabelul de club ar putea arata liste diferite,
    tacut, la fiecare schimbare anuala de lista.

    Niciodata eroare: lipsa configurarii, o lista stearsa sau una arhivata dau recordset
    gol (deci `club_price` null) plus un warning care spune ce mecanism s-a consultat -
    catalogul trebuie sa functioneze si fara pretul de club. Listele arhivate se
    filtreaza explicit: Odoo nu exclude liniile de pricelist arhivate la calculul
    pretului, deci o lista arhivata ar da preturi invechite, nu o eroare vizibila."""
    flagged = _flagged_club_pricelist()
    if flagged is None:
        return _club_pricelist_from_param()
    pricelist = flagged.exists().filtered('active')
    if not pricelist:
        _logger.warning(
            'Nicio lista de preturi activa nu e bifata %s (bifa clientului, sursa unica '
            'pentru lista Ortho Club); club_price va fi null pentru toate produsele. '
            'Bifeaza lista Ortho Club curenta - parametrul de sistem %s nu se mai '
            'consulta pe o baza care are campul clientului.',
            CLUB_PRICELIST_FLAG, CLUB_PRICELIST_PARAM)
    return pricelist


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


def _customer_pricelist(partner):
    """Lista de preturi a contului. `property_product_pricelist` e un camp
    calculat/configurat; daca vreodata nu rezolva nimic pentru cont, `currency.round`
    din calculul de pret ar arunca `ensure_one()` si ar iesi ca 500 generic - preferam
    un raspuns clar, de configurare, nu o eroare interna opaca."""
    pricelist = partner.property_product_pricelist
    if not pricelist:
        raise ApiError(
            503, 'pricelist_unavailable',
            'Lista de preturi a contului nu este configurata. Incearca din nou mai tarziu.')
    return pricelist


def club_pricelist_comparable(club_pricelist, customer_pricelist):
    """Daca pretul de club poate fi aratat alaturi de cel al clientului. Fals (fara
    alt calcul) cand nu exista pricelist de club configurat sau cand valuta lui difera
    de a clientului - altfel am arata doua preturi in valute diferite ca si cum ar fi
    comparabile ("148,50 lei" langa "133,65 EUR"), desi niciun calcul din spate nu le
    face echivalente (docs/STAGING.md confirma o lista "Euro Discount" printre cele
    active pe baza reala)."""
    if not club_pricelist:
        return False
    if club_pricelist.currency_id != customer_pricelist.currency_id:
        _logger.warning(
            'Pricelist-ul Ortho Club (id %s, valuta %s) e intr-o valuta diferita de cea '
            'a clientului (%s); club_price va fi null ca sa nu aratam doua preturi '
            'necomparabile.',
            club_pricelist.id, club_pricelist.currency_id.name, customer_pricelist.currency_id.name)
        return False
    return True


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
    """club_price per produs; None (fara alt calcul) cand `club_pricelist_comparable`
    spune nu (lipsa parametru sau valuta diferita) sau cand rezultatul e identic cu
    pretul clientului - spec 6.4: club_price se arata "cand difera", nu mereu."""
    if not club_pricelist_comparable(club_pricelist, customer_pricelist):
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


def _ids_with_image(records, field_name='image_1920'):
    """Id-urile din `records` care au efectiv imagine pe `field_name`, aflate printr-o
    singura interogare pe `ir.attachment` in loc sa se citeasca fiecare `image_1920`
    (camp `fields.Image` cu `attachment=True`: o citire = acces la filestore +
    encodare base64 a unei imagini de pana la 1920px, per produs de pe pagina - pana
    la 100 de imagini incarcate integral doar ca sa fie aruncate).

    Merge pentru orice model cu imagini (`product.template`, `product.image`) -
    modelul se ia din recordset, nu se scrie in cod."""
    if not records:
        return set()
    attachments = request.env['ir.attachment'].sudo().search([
        ('res_model', '=', records._name),
        ('res_field', '=', field_name),
        ('res_id', 'in', records.ids),
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
        pricelist = _customer_pricelist(partner)
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
