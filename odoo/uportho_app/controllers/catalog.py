import logging

from odoo import http
from odoo.http import request
from odoo.tools.sql import escape_psql

from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, is_signed_in, json_ok
from .home import _current_website, _image_response, image_unique

_logger = logging.getLogger(__name__)

CLUB_PRICELIST_PARAM = 'uportho_app.club_pricelist_id'
CLUB_PRICELIST_FLAG = 'is_compare_pricelist'
DEFAULT_LIMIT = 20
MAX_LIMIT = 100

# Sortarea implicita a magazinului, asa cum o tine Odoo: campul `shop_default_sort` de
# pe `website` (Website → Configurare → Magazin, sau bara de sortare a magazinului).
# Pe instanta reala e 'website_sequence asc' - ordinea manuala din spatele sortarii
# "Recomandate", cu 603 valori distincte pe 619 produse publicate, deci o ordonare
# chiar facuta de om, nu ramasa pe implicit.
SHOP_SORT_FIELD = 'shop_default_sort'
# Ordinea de rezerva cand setarea lipseste sau nu e valida: aceeasi intentie
# (ordonarea manuala a magazinului), doar fara sa depinda de configurare.
PRODUCTS_ORDER_FALLBACK = 'website_sequence, id desc'
# Criteriul stabil de la finalul oricarei ordini. Fara el, doua produse cu acelasi
# `website_sequence` pot veni in ordine diferita de la doua interogari succesive, iar
# paginarea aplicatiei ar arata unul de doua ori si l-ar sari complet pe celalalt -
# tacut, fara nicio eroare.
#
# `id desc`, nu `id asc`: magazinul insusi departajeaza descrescator
# (`website_sale.WebsiteSale._get_search_order` construieste
# `'is_published desc, %s, id desc'`). La produsele cu acelasi `website_sequence` -
# 16 din 619 pe instanta reala - o departajare crescatoare le-ar aseza exact invers
# fata de site, adica exact ce trebuia sa reparam.
PRODUCTS_ORDER_TIEBREAKER = 'id desc'
ORDER_DIRECTIONS = ('asc', 'desc')

# Sortarile pe care le poate cere aplicatia. Cheia e ce trimite telefonul, a doua
# valoare e ordinea ceruta lui Odoo, a treia e eticheta pe care o afiseaza ecranul -
# tinuta aici, nu in aplicatie, ca o traducere sa nu ceara release in App Store.
#
# `recommended` nu are ordine proprie: cade pe sortarea configurata a magazinului
# (`_products_order`), deci ramane implicitul si urmeaza orice schimbare facuta in
# Odoo. Pretul se sorteaza dupa `list_price`, acelasi camp pe care filtreaza si bara
# de pret a magazinului - vezi comentariul din `_products_domain`.
SORT_OPTIONS = (
    ('recommended', None, 'Recomandate'),
    ('price_asc', 'list_price asc', 'Pret crescator'),
    ('price_desc', 'list_price desc', 'Pret descrescator'),
    ('name_asc', 'name asc', 'Nume A-Z'),
)
DEFAULT_SORT = SORT_OPTIONS[0][0]


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


def _sanitized_order(raw, Template):
    """`raw` transformat intr-un `order` sigur pentru `search()`, sau None daca nu e.

    `shop_default_sort` e o Selection, dar continutul lui ajunge in baza si pe alte
    cai decat interfata (un modul care extinde selectia, o scriere directa) - e text
    liber, nu o valoare in care sa avem incredere. Interpolat orbeste in `order`, un
    camp inexistent ar da 500 la fiecare listare de catalog, iar restul ajunge in
    `ORDER BY`.

    Se accepta doar forma pe care o produce Odoo: termeni separati prin virgula, fiecare
    un nume de camp existent SI stocat pe `product.template` (un camp calculat nestocat
    n-are coloana dupa care sa se sorteze), optional urmat de `asc`/`desc`. Orice
    altceva - inclusiv un termen gol sau al doilea cuvant necunoscut - intoarce None,
    iar apelantul cade pe ordinea sigura.

    La final se adauga `id` daca ordinea configurata nu se termina deja pe el: vezi
    PRODUCTS_ORDER_TIEBREAKER."""
    if not raw or not raw.strip():
        return None
    terms = []
    last_field = None
    for part in raw.split(','):
        tokens = part.split()
        if not tokens or len(tokens) > 2:
            return None
        field = Template._fields.get(tokens[0])
        if field is None or not field.store:
            return None
        if len(tokens) == 2 and tokens[1].lower() not in ORDER_DIRECTIONS:
            return None
        last_field = tokens[0]
        terms.append(' '.join(tokens))
    # Comparam pe nume de camp, nu pe termenul intreg: o ordine care se termina deja
    # in `id` (indiferent de directie) e stabila, nu mai are nevoie de departajare.
    if last_field != PRODUCTS_ORDER_TIEBREAKER.split()[0]:
        terms.append(PRODUCTS_ORDER_TIEBREAKER)
    return ', '.join(terms)


def _products_order(website):
    """Ordinea in care API-ul listeaza produsele: chiar sortarea implicita configurata a
    magazinului (`website.shop_default_sort`), nu o constanta scrisa in codul nostru.

    Aplicatia lista produsele in ordinea implicita a modelului
    ('is_favorite desc, name'), adica alfabetic - dar magazinul isi ordoneaza rafturile
    dupa setarea website-ului, implicit 'website_sequence asc'. Doua liste diferite
    pentru acelasi catalog. Citita de aici, o schimbare de sortare facuta in Odoo se
    vede in aplicatie fara release in App Store - acelasi motiv pentru care exista tot
    modulul.

    Nu se reproduce restul ordinii magazinului ('is_published desc, ..., id desc' din
    `website_sale.WebsiteSale._get_search_order`): `is_published desc` n-ar face nimic,
    domeniul nostru contine oricum doar produse publicate.

    Niciodata eroare: setare lipsa, goala sau invalida dau ordinea de rezerva plus un
    warning care spune ce anume lipsea, ca o configurare gresita sa se diagnosticheze
    din log (acelasi stil ca warning-urile pentru website si pentru lista de club)."""
    Template = website.env['product.template']
    fallback = _sanitized_order(PRODUCTS_ORDER_FALLBACK, Template) or PRODUCTS_ORDER_TIEBREAKER
    if SHOP_SORT_FIELD not in website._fields:
        _logger.warning(
            'Campul %s nu exista pe website (baza fara website_sale sau camp redenumit '
            'intr-o versiune viitoare de Odoo); produsele se listeaza dupa %r, nu dupa '
            'sortarea configurata a magazinului.', SHOP_SORT_FIELD, fallback)
        return fallback
    raw = website.sudo()[SHOP_SORT_FIELD]
    order = _sanitized_order(raw, Template)
    if order:
        return order
    _logger.warning(
        'Website-ul %r (id %s) are %s = %r, care nu e o sortare folosibila (camp '
        'inexistent sau nestocat pe product.template, ori directie diferita de '
        'asc/desc); produsele se listeaza dupa %r. Verifica sortarea implicita a '
        'magazinului in Odoo.',
        website.name, website.id, SHOP_SORT_FIELD, raw, fallback)
    return fallback


def _attribute_domain(pairs):
    """Domeniul filtrului pe atribute, cu intelesul magazinului.

    SI intre atribute diferite, SAU intre valorile aceluiasi atribut: "Dynaflex SAU
    Ormco" dar "si slot .022". Un singur termen `in` per atribut face exact asta,
    fiindca `attribute_line_ids.value_ids` e un many2many - potrivirea e pe oricare
    din valorile date.

    Campul e acelasi pe care il filtreaza si magazinul, deci un produs care apare in
    `/shop?attribute_value=95-1234` apare si aici."""
    by_attribute = {}
    for attribute_id, value_id in pairs:
        by_attribute.setdefault(attribute_id, []).append(value_id)
    return [
        ('attribute_line_ids.value_ids', 'in', value_ids)
        for value_ids in by_attribute.values()
    ]


def _products_domain(website, category_id, query, pairs=(), min_price=None, max_price=None):
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
    domain = domain + _attribute_domain(pairs)
    # `list_price`, nu pretul clientului: exact campul pe care filtreaza bara de pret a
    # magazinului (`COALESCE(MIN(list_price), 0) * conversion_rate` in
    # `website_sale.WebsiteSale.shop`). E un pret de catalog, deci poate diferi de ce
    # plateste un client cu lista proprie - dar asa se comporta si site-ul, iar o
    # filtrare pe pretul fiecarui client ar cere calcularea in Python a preturilor
    # intregului set la fiecare cerere.
    if min_price is not None:
        domain = domain + [('list_price', '>=', min_price)]
    if max_price is not None:
        domain = domain + [('list_price', '<=', max_price)]
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


def _ratings_by_template(templates):
    """Media si numarul recenziilor pentru fiecare produs din pagina, intr-o singura
    interogare.

    Aceleasi recenzii pe care le numara si magazinul: tema cheama
    `product.sudo().rating_get_stats()` si arata pastila cu nota doar cand exista cel
    putin una. Domeniul e cel al detaliului de produs (`_serialize_reviews`), ca nota
    de pe card si nota din pagina produsului sa nu poata arata cifre diferite.
    `rating.rating` nu e citibil de portal, de aceea sudo."""
    if not templates:
        return {}
    groups = request.env['rating.rating'].sudo()._read_group(
        [
            ('res_model', '=', 'product.template'), ('res_id', 'in', templates.ids),
            ('consumed', '=', True), ('is_internal', '=', False),
        ],
        ['res_id'],
        ['__count', 'rating:avg'],
    )
    return {
        res_id: {'average': round(average or 0.0, 1), 'count': count}
        for res_id, count, average in groups
        if count
    }


def serialize_product(template, price, club_price, has_image, rating=None):
    return {
        'id': template.id,
        'name': template.name,
        'default_code': template.default_code or None,
        'image_url': (f'{API_PREFIX}/products/{template.id}/image?unique={image_unique(template)}'
                      if has_image else None),
        'price': price,
        'club_price': club_price,
        'badge': template._app_badge_active(),
        # null cand produsul n-are nicio recenzie - la fel ca pe site, unde pastila cu
        # nota nici nu se deseneaza atunci.
        'rating': rating,
    }


def pricing_block(signed_in):
    """De ce lipsesc preturile, spus de server.

    Aplicatia nu ghiceste din `price: null`: ar insemna doua adevaruri (starea ei de
    autentificare si raspunsul serverului), iar ele se pot despica - o sesiune expirata
    arata inca "autentificat" in aplicatie cat timp nu cere nimic. Blocul asta e singura
    sursa pentru banda de invitatie si pentru textele de pe carduri. Daca magazinul
    opreste intr-o zi regula B2B a temei, se schimba aici si preturile apar in aplicatie
    fara release."""
    return {
        'visible': bool(signed_in),
        'reason': None if signed_in else 'sign_in_required',
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


def _parse_attribute_values(raw):
    """Perechile cerute, in formatul magazinului: `attribute_value=<atribut>-<valoare>`.

    Acelasi nume de parametru si acelasi format ca pe site (`theme_prime` citeste
    `request.httprequest.args.getlist('attribute_value')` si sparge fiecare valoare pe
    '-'), ca un filtru sa insemne acelasi lucru in amandoua. Se accepta si repetat, si
    separat prin virgula, fiindca un client HTTP le poate trimite oricum."""
    if raw in (None, ''):
        return []
    items = raw if isinstance(raw, (list, tuple)) else [raw]
    pairs = []
    for item in items:
        for chunk in str(item).split(','):
            chunk = chunk.strip()
            if not chunk:
                continue
            parts = chunk.split('-')
            if len(parts) != 2 or not all(p.isdigit() for p in parts):
                raise ApiError(
                    422, 'validation_error',
                    "attribute_value trebuie sa fie perechi 'id_atribut-id_valoare'.")
            pairs.append((int(parts[0]), int(parts[1])))
    return pairs


def _parse_price(raw, name):
    """Capatul unui interval de pret. Lipsa inseamna "fara limita"; o valoare negativa
    sau zero inseamna tot "fara limita", ca pe site, unde glisorul nu poate cobori sub
    minimul disponibil."""
    if raw in (None, ''):
        return None
    try:
        value = float(raw)
    except (TypeError, ValueError):
        raise ApiError(422, 'validation_error', '%s trebuie sa fie numeric.' % name)
    return value if value > 0 else None


def _parse_sort(raw):
    """Cheia de sortare ceruta de aplicatie, validata contra listei de mai sus.

    O cheie necunoscuta e 422, nu o cadere tacuta pe implicit: altfel o greseala de
    scriere in aplicatie ar arata produsele in alta ordine decat a cerut clientul,
    fara ca nimeni sa afle."""
    if raw in (None, ''):
        return DEFAULT_SORT
    key = str(raw)
    if key not in {option[0] for option in SORT_OPTIONS}:
        raise ApiError(
            422, 'validation_error',
            'sort trebuie sa fie una din: %s.' % ', '.join(o[0] for o in SORT_OPTIONS))
    return key


def _order_for_sort(sort_key, website):
    """Ordinea trimisa lui Odoo, cu acelasi criteriu stabil la final ca ordinea implicita.

    Fara departajarea stabila, doua produse cu acelasi pret pot veni in ordine diferita
    la doua pagini succesive, iar scroll-ul infinit ar dubla unul si l-ar sari pe
    celalalt - exact bug-ul pentru care exista PRODUCTS_ORDER_TIEBREAKER."""
    raw = dict((o[0], o[1]) for o in SORT_OPTIONS)[sort_key]
    if raw is None:
        return _products_order(website)
    Template = website.env['product.template']
    order = _sanitized_order(raw, Template)
    return order or _products_order(website)


def _price_bounds(domain):
    """Pretul minim si maxim disponibil in rezultat, intr-o singura interogare.

    Aceeasi forma ca in `website_sale.WebsiteSale.shop`: MIN/MAX peste `list_price`,
    pe domeniul filtrat, cu regulile de acces aplicate. Fara asta, aplicatia ar trebui
    sa citeasca toate produsele doar ca sa afle capetele glisorului."""
    Template = request.env['product.template']
    query = Template._where_calc(domain)
    Template._apply_ir_rules(query, 'read')
    sql = query.select(
        'COALESCE(MIN("product_template"."list_price"), 0)',
        'COALESCE(MAX("product_template"."list_price"), 0)',
    )
    row = request.env.execute_query(sql)[0]
    return {'min': row[0] or 0.0, 'max': row[1] or 0.0}


def _attribute_facets(website, category_id, query, pairs, min_price, max_price):
    """Atributele care chiar exista in rezultatul curent, cu numarul de produse per valoare.

    Nu exista o lista configurata de filtre: ce apare se calculeaza din rezultat, deci
    in Bracketi ies Prescriptie si Slot, iar in Adezivi Tip polimerizare, fara ca
    nimeni sa bifeze ceva in Odoo.

    Pentru fiecare atribut, numaratorile se calculeaza ignorand selectia facuta CHIAR
    pe acel atribut, dar pastrand restul filtrelor. Altfel, dupa ce alegi un brand,
    lista de branduri ar ramane cu un singur rand si nu ai mai putea alege al doilea."""
    by_attribute = {}
    for attribute_id, value_id in pairs:
        by_attribute.setdefault(attribute_id, []).append(value_id)

    Template = request.env['product.template']
    Line = request.env['product.template.attribute.line'].sudo()

    def template_ids(active_pairs):
        return Template.search(_products_domain(
            website, category_id, query, active_pairs, min_price, max_price)).ids

    full_ids = template_ids(pairs)
    # Atributele de aratat: cele prezente in rezultatul complet, plus cele deja alese
    # (o alegere care nu mai are niciun produs trebuie sa ramana vizibila, altfel
    # clientul nu o mai poate anula).
    present = set(Line.search([('product_tmpl_id', 'in', full_ids)]).mapped('attribute_id').ids)
    present |= set(by_attribute)
    if not present:
        return []

    facets = []
    for attribute in request.env['product.attribute'].sudo().browse(sorted(present)).exists():
        if attribute.id in by_attribute:
            ids = template_ids([(a, v) for a, v in pairs if a != attribute.id])
        else:
            ids = full_ids
        counts = {}
        covered = set()
        for line in Line.search([('product_tmpl_id', 'in', ids), ('attribute_id', '=', attribute.id)]):
            covered.add(line.product_tmpl_id.id)
            for value in line.value_ids:
                counts[value.id] = counts.get(value.id, 0) + 1
        selected = set(by_attribute.get(attribute.id, ()))
        values = [
            {
                'id': value.id,
                'name': value.name,
                'color': value.html_color or None,
                'count': counts.get(value.id, 0),
                'selected': value.id in selected,
            }
            for value in attribute.value_ids
            if counts.get(value.id) or value.id in selected
        ]
        if not values:
            continue
        facets.append((
            # Ordinea sectiunilor: intai cele care spun ceva despre cele mai multe
            # produse din rezultat. Pe catalogul real, ordonate dupa id-ul atributului,
            # "Tooth" (zeci de valori, cate 1-15 produse fiecare) ajungea inaintea
            # Brandului si a Prescriptiei, adica filtrul rar inaintea celui folosit de
            # toata lumea. Numaram produse ACOPERITE, nu suma valorilor: un produs cu
            # trei valori ale aceluiasi atribut e tot un produs.
            -len(covered),
            attribute.sequence,
            attribute.name or '',
            {
                'id': attribute.id,
                'name': attribute.name,
                'display_type': attribute.display_type,
                'values': values,
            },
        ))
    facets.sort(key=lambda facet: facet[:3])
    return [facet[3] for facet in facets]


def _serialize_templates_without_prices(templates):
    """Cardurile unui vizitator: tot ce arata si site-ul, fara niciun pret.

    Nu se cheama `_customer_pricelist` (ar arunca 503 pe partenerul public) si nu se
    alege o lista publica in locul lui: magazinul nu arata preturi unui vizitator, deci
    nici aplicatia. Restul cardului - poza, eticheta, nota - ramane, fiindca pe site se
    vede."""
    ids_with_image = _ids_with_image(templates)
    rating_by_template = _ratings_by_template(templates)
    return [
        serialize_product(t, None, None, t.id in ids_with_image, rating_by_template.get(t.id))
        for t in templates
    ]


def _products_with_prices(templates, website):
    """Cardurile unui client: preturile lui, pretul de club si restul, intr-un singur
    drum. Extrasa din ruta ca sa poata fi sarita cu totul pentru un vizitator."""
    partner = request.env.user.partner_id
    pricelist = _customer_pricelist(partner)
    club_pricelist = _current_club_pricelist()
    _warn_if_tax_display_mismatch(website)
    # Pozitia fiscala depinde doar de partener, nu de produs sau de pricelist -
    # calculata o singura data aici, nu per produs.
    fiscal_position = request.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)
    price_by_template = _prices_by_template(templates, pricelist, partner, fiscal_position)
    club_price_by_template = _club_prices_by_template(
        templates, club_pricelist, pricelist, partner, fiscal_position, price_by_template)
    ids_with_image = _ids_with_image(templates)
    rating_by_template = _ratings_by_template(templates)
    return [
        serialize_product(
            t, price_by_template[t.id], club_price_by_template.get(t.id),
            t.id in ids_with_image, rating_by_template.get(t.id))
        for t in templates
    ]


def _serialize_templates(templates, website):
    """Produsele in forma de card, cu preturile contului: acelasi drum ca `/products`,
    ca o lista de favorite sa nu poata arata alte preturi decat catalogul."""
    if not templates:
        return []
    if not is_signed_in():
        return _serialize_templates_without_prices(templates)
    partner = request.env.user.partner_id
    pricelist = _customer_pricelist(partner)
    club_pricelist = _current_club_pricelist()
    fiscal_position = request.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)
    price_by_template = _prices_by_template(templates, pricelist, partner, fiscal_position)
    club_price_by_template = _club_prices_by_template(
        templates, club_pricelist, pricelist, partner, fiscal_position, price_by_template)
    ids_with_image = _ids_with_image(templates)
    rating_by_template = _ratings_by_template(templates)
    return [
        serialize_product(
            t, price_by_template[t.id], club_price_by_template.get(t.id), t.id in ids_with_image,
            rating_by_template.get(t.id))
        for t in templates
    ]



class AppCatalog(http.Controller):
    @app_route('/categories', methods=['GET'], auth='public')
    def categories(self, **kw):
        website = _current_website()
        domain = ['|', ('website_id', '=', False), ('website_id', '=', website.id)]
        categories = request.env['product.public.category'].search(domain)
        counts = _product_counts_by_category(categories, website)
        return json_ok([serialize_category(c, website, counts[c.id]) for c in categories])

    @app_route('/products', methods=['GET'], auth='public')
    def products(self, **kw):
        website = _current_website()
        category_id = _parse_category_id(kw.get('category_id'))
        query = kw.get('q')
        # `attribute_value` poate veni repetat; Odoo aduna repetitiile intr-o lista doar
        # prin httprequest.args, nu prin **kw, care pastreaza ultima valoare.
        pairs = _parse_attribute_values(
            request.httprequest.args.getlist('attribute_value') or kw.get('attribute_value'))
        min_price = _parse_price(kw.get('min_price'), 'min_price')
        max_price = _parse_price(kw.get('max_price'), 'max_price')
        sort = _parse_sort(kw.get('sort'))
        domain = _products_domain(website, category_id, query, pairs, min_price, max_price)
        offset = _parse_offset(kw.get('offset'))
        limit = _parse_limit(kw.get('limit'))

        Template = request.env['product.template']
        total = Template.search_count(domain)
        # Aceeasi ordine ca in magazin, citita din setarea website-ului si cu un
        # criteriu stabil la final - vezi _products_order. Se aplica identic listei
        # nefiltrate, celei filtrate pe categorie si cautarii: domeniul difera,
        # ordinea nu. Clientul o poate schimba doar cu una din cheile din SORT_OPTIONS,
        # iar implicitul ramane sortarea magazinului.
        order = _order_for_sort(sort, website)
        templates = Template.search(domain, offset=offset, limit=limit, order=order)

        signed_in = is_signed_in()
        if not signed_in:
            products = _serialize_templates_without_prices(templates)
        else:
            products = _products_with_prices(templates, website)
        return json_ok({
            'products': products,
            'pricing': pricing_block(signed_in),
            'total': total,
            'offset': offset,
            'limit': limit,
            # Filtrele vin in acelasi raspuns cu produsele, ca bannerul si categoriile
            # in `/home`: un singur apel, deci ecranul nu arata produse fara filtre
            # pentru o clipa. Capetele de pret se calculeaza pe domeniul FARA filtrul
            # de pret, altfel glisorul s-ar strange la fiecare miscare si nu ar mai
            # putea fi largit inapoi.
            'filters': {
                'attributes': _attribute_facets(
                    website, category_id, query, pairs, min_price, max_price),
                'price': dict(
                    _price_bounds(_products_domain(website, category_id, query, pairs)),
                    selected_min=min_price, selected_max=max_price),
                'sorts': [
                    {'key': key, 'name': label, 'selected': key == sort}
                    for key, _order, label in SORT_OPTIONS
                ],
            },
        })

    @app_route('/products/<int:product_id>/image', methods=['GET'], auth='public')
    def product_image(self, product_id, **kw):
        return _image_response(request.env['product.template'].browse(product_id), 'image_1920')
