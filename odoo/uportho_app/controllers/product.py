import logging

from odoo import http
from odoo.addons.website_sale.models.product_template import (
    ProductTemplate as WebsiteSaleProductTemplate,
)
from odoo.http import request

from ..models.product_template import UPORTHO_BRAND_LOGO_FIELD
from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, json_ok, read_json_body
from .catalog import (
    _club_prices_by_template,
    _current_club_pricelist,
    _customer_pricelist,
    _ids_with_image,
    _prices_by_template,
    _products_domain,
    _warn_if_tax_display_mismatch,
    club_pricelist_comparable,
    serialize_product,
)
from .home import _current_website, _image_response, image_unique

_logger = logging.getLogger(__name__)

MAX_SIMILAR = 10
MAX_REVIEWS = 20
# Produsele pentru care `_get_combination_info` (cu tot cu override-urile de tema) a
# cazut deja o data in acest proces. Multimea face doua lucruri deodata, pentru ca e
# vorba de acelasi fapt:
#
# 1. **Nu se mai plateste apelul care cade.** Pe serverul clientului override-ul temei
#    arunca la FIECARE cerere de produs, deci a-l chema din nou inseamna doar munca
#    aruncata; dupa prima cadere se merge direct pe implementarea din `website_sale`.
# 2. **Nu se mai scrie traceback-ul.** E mereu acelasi traceback; scris la fiecare
#    cerere ar face logurile de productie nefolosibile. Primul esec al unui produs il
#    scrie intreg, urmatoarele doar o linie scurta de avertizare.
#
# Multimea creste cel mult cu numarul de produse din catalog si traieste doar cat
# procesul: un deploy sau o repornire de worker reincearca apelul normal. Deci in ziua
# in care tema isi repara sablonul, adaugirile magazinului se intorc singure in raspuns,
# fara nicio schimbare de cod si fara release de aplicatie.
_COMBINATION_INFO_BROKEN = set()
# Produsele pentru care a cazut si implementarea standard din `website_sale` (calea de
# rezerva). Exista din acelasi motiv de volum ca multimea de mai sus: daca vreodata se
# strica si aia, ar cadea tot la fiecare cerere. Nu opreste apelul - acolo chiar nu mai
# avem alta sursa de adevar de incercat - doar traceback-ul repetat.
_CORE_COMBINATION_INFO_LOGGED = set()
# Cate linii accepta `POST /products/<id>/prices` intr-o cerere. Tabelul are cate un
# rand per varianta si cel mai variat produs real are cateva zeci; plafonul e doar ca
# o cerere absurda sa nu ceara mii de pretuiri.
MAX_PRICE_LINES = 200
# Id-ul de galerie al imaginii principale a produsului (`image_1920` de pe template
# sau de pe varianta). Restul intrarilor din galerie sunt `product.image`, cu id-ul
# lor real; 0 nu e niciodata un id valid in Odoo, deci nu se poate ciocni cu ele si
# lasa aplicatiei un singur tip de intrare, cu id intreg, pentru toata galeria.
MAIN_IMAGE_ID = 0


def _visible_product(product_id):
    """Produsul cerut, doar daca e publicat si apartine website-ului configurat;
    altfel 404. Foloseste exact domeniul cu care `/products` listeaza catalogul, ca
    sa nu poata exista un produs vizibil in lista dar 404 la deschidere (sau invers)."""
    website = _current_website()
    template = request.env['product.template'].search(
        _products_domain(website, None, None) + [('id', '=', product_id)], limit=1)
    if not template:
        raise ApiError(404, 'not_found', 'Produsul nu exista.')
    return website, template


def _parse_variant(template, raw):
    """Varianta ceruta prin `variant_id`, validata contra produsului. O varianta care
    nu apartine produsului e o cerere gresita, nu o eroare interna: 422, niciodata
    500. Verificarea de apartenenta se face in sudo, ca o varianta a unui produs
    nepublicat sa dea tot 422 (cerere gresita), nu 403 din regulile de acces."""
    if raw in (None, ''):
        return request.env['product.product'].browse()
    try:
        variant_id = int(raw)
    except (TypeError, ValueError):
        raise ApiError(422, 'validation_error', 'variant_id trebuie sa fie numeric.')
    variant = request.env['product.product'].sudo().browse(variant_id).exists()
    if not variant or variant.product_tmpl_id != template.sudo():
        raise ApiError(422, 'validation_error', 'variant_id nu apartine acestui produs.')
    return request.env['product.product'].browse(variant.id)


def _parse_values(template, raw):
    """Combinatia ceruta prin `values`: id-uri de `product.template.attribute.value`
    separate prin virgula, exact ca selectorul de pe site. Aplicatia are in mana doar
    id-uri de valoare (asta trimite `_uportho_variants`), deci asta e singurul mod in
    care poate cere o alta varianta.

    Intoarce None cand parametrul lipseste cu totul (atunci decide `variant_id`), sau
    un recordset - eventual gol - cand e prezent. Un id care nu exista sau care e al
    altui produs e o cerere gresita: 422, aceeasi forma ca la `variant_id`, niciodata
    500. Verificarea de apartenenta se face in sudo, ca o valoare a unui produs
    nepublicat sa dea tot 422, nu 403 din regulile de acces."""
    Ptav = request.env['product.template.attribute.value']
    if raw is None:
        return None
    ids = []
    for part in raw.split(','):
        part = part.strip()
        if not part:
            continue
        try:
            ids.append(int(part))
        except (TypeError, ValueError):
            raise ApiError(
                422, 'validation_error',
                'values trebuie sa fie id-uri numerice separate prin virgula.')
    if not ids:
        return Ptav.browse()
    values = Ptav.sudo().browse(ids).exists()
    if len(values) != len(set(ids)) or any(v.product_tmpl_id != template.sudo() for v in values):
        raise ApiError(422, 'validation_error', 'values nu apartin acestui produs.')
    return Ptav.browse(values.ids)


def _parse_price_lines(template, raw_lines):
    """Liniile din corpul lui `POST /products/<id>/prices`: `[{variant_id, qty}, ...]`.

    Tot ce e gresit in cerere e 422 in forma standard de eroare, niciodata 500: o
    varianta a altui produs (verificata de `_parse_variant`, aceeasi regula ca pe
    ruta de detaliu), o cantitate negativa sau care nu e numar intreg.

    `qty = 0` e valid si inseamna "randul nu e comandat": tabelul din aplicatie
    porneste cu toate cantitatile pe zero si tot are nevoie de un total formatat de
    server. `True` e respins desi in Python e un `int`: un boolean nu e o cantitate."""
    if not isinstance(raw_lines, list):
        raise ApiError(422, 'validation_error', 'lines trebuie sa fie o lista de linii.')
    if len(raw_lines) > MAX_PRICE_LINES:
        raise ApiError(422, 'validation_error',
                       f'Prea multe linii (maxim {MAX_PRICE_LINES}).')

    lines = []
    for raw in raw_lines:
        if not isinstance(raw, dict):
            raise ApiError(422, 'validation_error', 'Fiecare linie trebuie sa fie un obiect JSON.')
        variant = _parse_variant(template, raw.get('variant_id'))
        if not variant:
            raise ApiError(422, 'validation_error', 'Fiecare linie are nevoie de variant_id.')
        qty = raw.get('qty')
        if isinstance(qty, bool) or not isinstance(qty, int) or qty < 0:
            raise ApiError(422, 'validation_error', 'qty trebuie sa fie un numar intreg >= 0.')
        lines.append((variant, qty))
    return lines


def _core_combination_info(template, variant, combination):
    """`_get_combination_info` cerut DIRECT implementarii din `website_sale`, sarind
    peste lantul de override-uri prin care intra tema magazinului.

    Asta e reparatia adevarata a cazului de pe serverul clientului: nu reconstruim noi
    ce ar fi trebuit sa intoarca Odoo, ci chemam chiar codul standard al Odoo, doar
    fara stratul care arunca. Verificat pe staging, pe produsul 14219: apelul normal
    arunca, iar acesta intoarce `price`, `list_price`, `product_id`, `display_name`,
    `is_combination_possible` - aceleasi cifre pe care le arata aplicatia azi.

    Nu se cheama `super()` din vreo parte si nu se atinge `type(template)`: se ia
    functia din clasa `website_sale` si i se da `template` ca `self`. Metodele pe care
    ea le mai cheama pe `self` (`_get_additionnal_combination_info`,
    `_is_combination_possible`) se rezolva normal, deci daca override-ul temei e reparat
    pe ele, tot codul lor ruleaza; se ocoleste doar veriga care cade.

    Apelul e in aceeasi forma ca cel normal (combinatia daca aplicatia a trimis
    `values`, altfel varianta), ca sa nu poata intoarce alta varianta decat cea ceruta.

    Importul clasei se face la incarcarea modulului, nu la fiecare cerere: `website_sale`
    e deja dependinta declarata in manifest, iar daca vreodata Odoo muta clasa
    (migrarea la 19), modulul refuza sa se incarce - eroare zgomotoasa la deploy, nu una
    tacuta pe fiecare cerere de produs."""
    if combination is not None:
        return WebsiteSaleProductTemplate._get_combination_info(
            template, combination=combination)
    return WebsiteSaleProductTemplate._get_combination_info(
        template, product_id=variant.id if variant else False)


def _fallback_combination(template, variant, combination):
    """Ultima plasa de siguranta: combinatia si varianta calculate fara niciun
    `_get_combination_info`, cand cade si implementarea standard din `website_sale`.

    Nu s-a intamplat niciodata pe serverul clientului - acolo cade doar override-ul de
    tema, iar `_core_combination_info` raspunde. Ramane totusi, pentru ca o cerere de
    produs nu are voie sa devina 500 orice s-ar strica deasupra ei.

    Foloseste doar API-ul de baza al Odoo (`product`), nu si pe cel din `website_sale`
    prin care intra tema: `_get_closest_possible_combination` (deja calculat de
    apelant, cand aplicatia a trimis `values`), `_get_first_possible_combination` si
    `_get_variant_for_combination` - exact aceleasi metode pe care le foloseste si
    `_uportho_variants`. Restul raspunsului (pret, praguri, galerie, similare) se
    calculeaza oricum din varianta, pe caile proprii modulului, deci pagina ramane
    intreaga."""
    if combination is None:
        combination = (variant.product_template_attribute_value_ids if variant
                       else template._get_first_possible_combination())
    if not variant:
        variant = template._get_variant_for_combination(combination) or template.product_variant_id
    # Al treilea element e `combination_info`-ul care lipseste. Nimic esential nu
    # depinde de el: tabelele de pret se calculeaza oricum direct din listele
    # magazinului (vezi `_price_tables`), asta e doar sursa lui preferata.
    return combination, variant, {}


def _log_combination_info_failure(template_id):
    """Scrie in loguri esecul lui `_get_combination_info` pentru produsul asta: prima
    data cu traceback complet, apoi doar cu o linie scurta.

    Motivul e volumul, nu discretia: pe serverul clientului apelul cade la fiecare
    cerere de produs, mereu cu acelasi traceback, iar un traceback complet per cerere
    ar face logurile de productie nefolosibile. Prima aparitie ramane intreaga (acolo
    se vede ce tema si ce template au picat), urmatoarele spun doar ca se mai intampla
    si pentru care produs.

    Linia scurta se scrie si atunci cand apelul nici nu s-a mai incercat (produsul e
    deja in `_COMBINATION_INFO_BROKEN`): altfel problema ar disparea complet din loguri
    dupa prima cerere si nimeni n-ar mai vedea ca aplicatia merge pe calea de rezerva."""
    if template_id in _COMBINATION_INFO_BROKEN:
        _logger.warning(
            'product_detail: _get_combination_info nu se mai cheama pentru produsul %s '
            '(a esuat deja o data in acest proces, traceback-ul complet e mai sus). '
            'Raspund cu implementarea standard din website_sale.', template_id)
        return
    _COMBINATION_INFO_BROKEN.add(template_id)
    _logger.exception(
        'product_detail: _get_combination_info a esuat pentru produsul %s '
        '(probabil un override dintr-un modul de tema). Raspund cu implementarea '
        'standard din website_sale, chemata direct; pot lipsi doar adaugirile temei.',
        template_id)


def _log_core_combination_info_failure(template_id):
    """Acelasi tipar de logare (traceback intreg o data, apoi linie scurta) pentru
    cazul in care cade si implementarea standard din `website_sale`."""
    if template_id in _CORE_COMBINATION_INFO_LOGGED:
        _logger.warning(
            'product_detail: implementarea standard website_sale a lui '
            '_get_combination_info esueaza din nou pentru produsul %s '
            '(traceback-ul complet e mai sus). Raspund cu datele pe care le '
            'calculeaza modulul singur.', template_id)
        return
    _CORE_COMBINATION_INFO_LOGGED.add(template_id)
    _logger.exception(
        'product_detail: si implementarea standard website_sale a lui '
        '_get_combination_info a esuat pentru produsul %s. Raspund cu datele pe care '
        'le calculeaza modulul singur (varianta, pret, nume, cod).', template_id)


def _resolve_combination(template, variant, values=None):
    """Combinatia curenta si varianta ei, cerute de la Odoo prin `_get_combination_info`
    - acelasi API pe care il foloseste pagina de produs de pe site. Fara `variant_id`
    Odoo alege singur prima combinatie posibila (nu o alegem noi); cu `variant_id`,
    combinatia e cea a variantei cerute.

    Cu `values` (combinatia ceruta de aplicatie) intrebam intai
    `_get_closest_possible_combination`, tot ca site-ul: o lista partiala (utilizatorul
    a apasat doar pe marime) e completata de Odoo, iar una imposibila (exclusa prin
    `exclude_for`) e adusa la cea mai apropiata combinatie posibila. Asa nu ajunge
    niciodata sa fie o eroare ceva ce pe site e doar o alta selectie.

    Din raspunsul lui folosim combinatia si varianta (pretul lui principal vine de pe
    `website.pricelist_id`, lista rezolvata din sesiune/geoip, nu de pe lista
    clientului si a Ortho Club, care sunt cele doua de care are nevoie aplicatia).

    `_get_combination_info` e insa punctul in care intra cod strain: pe instanta
    reala, tema magazinului il suprascrie si randeaza in interiorul lui un template
    QWeb de website. Cauza verificata pe serverul lor: `droggol_theme_common` pune in
    `combination_info['tp_extra_fields']` randarea lui `theme_prime.product_extra_fields`,
    iar acel sablon contine
    `t-value="product_variant.all_product_tag_ids.filtered(lambda x: x.visible_on_ecommerce)"`
    - un `lambda` pe care QWeb nu-l poate evalua, deci randarea arunca
    `TypeError: 'NoneType' object is not callable`. Se intampla la FIECARE cerere si
    pentru ORICE produs (verificat pe staging si cu, si fara etichete de ecommerce);
    `uportho_app.website_id` pus in contextul mediului nu are nicio legatura si nu ajuta.

    O tema nu are voie sa doboare API-ul, deci esecul se prinde. Ce se raspunde in loc
    NU mai e o reconstructie de-a noastra: se cheama direct implementarea din
    `website_sale` (`_core_combination_info`), adica exact acelasi cod al Odoo, doar
    fara veriga de tema care arunca - deci aplicatia primeste datele Odoo, nu o copie.
    `_fallback_combination` a ramas ultima plasa, pentru cazul in care ar cadea si
    aceea. Tabelele de pret nu mai trec pe aici deloc - se calculeaza direct din
    listele magazinului, vezi `_price_tables`."""
    combination = template._get_closest_possible_combination(values) if values is not None else None
    combination_info = None
    if template.id in _COMBINATION_INFO_BROKEN:
        # Stim deja din acest proces ca lantul de override-uri cade pentru produsul
        # asta: nu se mai plateste apelul, doar se noteaza in loguri (linie scurta).
        _log_combination_info_failure(template.id)
    else:
        try:
            if combination is not None:
                combination_info = template._get_combination_info(combination=combination)
            else:
                combination_info = template._get_combination_info(
                    product_id=variant.id if variant else False)
        except Exception:
            # Deliberat larg: nu stim ce arunca un override de tema (pe staging a fost
            # un TypeError dintr-un template QWeb). Nu se inghite nimic tacut - se
            # scrie in loguri, cu id-ul produsului, ca sa se vada ce a picat.
            _log_combination_info_failure(template.id)
    if combination_info is None:
        try:
            combination_info = _core_combination_info(template, variant, combination)
        except Exception:
            # Ar insemna ca e stricat chiar codul standard al Odoo. Nu s-a intamplat,
            # dar o cerere de produs tot nu are voie sa devina 500: se raspunde cu ce
            # calculeaza modulul singur.
            _log_core_combination_info_failure(template.id)
            return _fallback_combination(template, variant, combination)
    resolved_id = combination_info.get('product_id')
    if resolved_id:
        variant = request.env['product.product'].browse(resolved_id)
    elif not variant:
        variant = template.product_variant_id
    return combination_info.get('combination'), variant, combination_info


# Titlurile tabelelor calculate de modul, folosite doar cand magazinul nu are listele
# lui marcate pentru pagina de produs (baza locala, sau o instanta fara modulele
# clientului - vezi `_uportho_site_pricelists`).
# Titlul e mereu un camp de raspuns: aplicatia nu stie niciun titlu de tabel, pentru
# ca pe productie al doilea tabel poarta un nume de campanie, imposibil de ghicit.
OWN_TABLE_TITLE = 'Pret pe cantitate'
CLUB_TABLE_TITLE = 'Pret Ortho Club'


def _worth_showing(table, price):
    """Un tabel cu un singur rand egal cu pretul deja afisat deasupra lui nu spune
    nimic nou - nu se trimite deloc. Regula veche (era in aplicatie, unde compara
    siruri formatate); aici, unde sunt si sumele si valutele, comparatia e pe
    (suma, valuta), aceeasi ca la pretul de club."""
    entries = table['entries']
    if len(entries) != 1:
        return bool(entries)
    only = entries[0]['price']
    return (only['amount'], only['currency']) != (price['amount'], price['currency'])


def _price_tables(template, combination_info, price, pricelist, club_pricelist,
                  partner, fiscal_position, variant):
    """Tabelele de pret ale paginii, in ordinea in care se deseneaza. Trei surse,
    incercate in ordine; prima care da ceva castiga.

    1. `other_bulk_prices` din `_get_combination_info` - exact ce a calculat magazinul
       pentru pagina lui. Ramane prima alegere, dar pe serverul clientului nu se poate
       citi niciodata: acolo `_get_combination_info` randeaza inauntrul lui un template
       QWeb de website al temei si arunca la fiecare cerere (vezi `_resolve_combination`).
    2. Listele de pret ale magazinului, luate direct (`_uportho_site_pricelists` +
       `_uportho_site_price_tables`) - aceeasi selectie ca a modulului clientului
       (`is_public_pricelist`, apoi `is_compare_pricelist`), doar fara sa treaca prin
       apelul care cade. ASTA e calea care functioneaza azi pe serverul lor.
    3. Tabelele calculate de modul, pe o instanta care n-are modulele clientului (baza
       locala de dezvoltare): praguri de cantitate pe lista clientului si, cand
       `club_pricelist` e data (adica pretul de club chiar difera), pe cea Ortho Club.
       Doar aici titlurile sunt ale noastre.

    Preturile se cer de la Odoo doar pe ramura care ajunge sa fie folosita: un tabel
    care oricum n-ar fi afisat nu costa nicio pretuire."""
    tables = template._uportho_price_tables_from_theme(combination_info, pricelist.currency_id)
    if not tables:
        tables = template._uportho_site_price_tables(
            template._uportho_site_pricelists(), partner,
            fiscal_position=fiscal_position, variant=variant)
    if not tables:
        own = template._uportho_price_tiers(
            pricelist, partner, fiscal_position=fiscal_position, variant=variant)
        if own:
            tables.append({'title': OWN_TABLE_TITLE, 'note': [], 'entries': own})
        club_tiers = template._uportho_price_tiers(
            club_pricelist, partner, fiscal_position=fiscal_position,
            variant=variant) if club_pricelist else []
        if club_tiers:
            tables.append({'title': CLUB_TABLE_TITLE, 'note': [], 'entries': club_tiers})
    return [table for table in tables if _worth_showing(table, price)]


def _gallery_url(template, image_id, record, variant=None):
    # `unique` din write_date, ca in celelalte rute de imagine: cache-ul de disc al
    # aplicatiei isi cheie intrarile dupa URL si altfel ar servi zile la rand poza
    # veche dupa ce un editor o schimba in Odoo.
    url = f'{API_PREFIX}/products/{template.id}/gallery/{image_id}?unique={image_unique(record)}'
    return f'{url}&variant_id={variant.id}' if variant else url


def _serialize_gallery(template, variant):
    """Galeria: imaginea principala, apoi pozele suplimentare ale variantei, apoi cele
    ale template-ului - aceeasi ordine ca `product.product._get_images()` din
    website_sale.

    Existenta unei imagini se afla din `ir.attachment` (o interogare), nu citind
    campul binar - vezi `_ids_with_image`. O intrare de tip video fara poza ramane in
    lista cu `url: null`: aplicatia tot are ce deschide (`video_url`)."""
    images = []
    if template.id in _ids_with_image(template):
        # Cand exista varianta, URL-ul principal o poarta cu el: `product.product.
        # image_1920` cade automat pe imaginea template-ului daca varianta n-are una
        # proprie, deci un singur URL acopera ambele cazuri.
        images.append({
            'id': MAIN_IMAGE_ID,
            'url': _gallery_url(template, MAIN_IMAGE_ID, variant or template, variant=variant),
            'kind': 'image',
            'video_url': None,
        })

    extra = template.product_template_image_ids
    if variant:
        extra = variant.product_variant_image_ids + extra
    ids_with_image = _ids_with_image(extra)
    for image in extra:
        images.append({
            'id': image.id,
            'url': _gallery_url(template, image.id, image) if image.id in ids_with_image else None,
            'kind': 'video' if image.video_url else 'image',
            'video_url': image.video_url or None,
        })
    return images


def _serialize_brand(template):
    """Blocul de brand al paginii de produs: logo, nume, descriere. None cand produsul
    n-are brand sau cand campurile magazinului nu exista pe baza asta.

    Logoul e o ruta de imagine autentificata, ca toate imaginile modulului - el chiar
    se deseneaza in aplicatie, spre deosebire de documente, care se deschid in
    exterior. Existenta pozei se afla din `ir.attachment`, ca la pozele de produs
    (`_ids_with_image`), fara sa se citeasca campul binar; pe o baza fara modulele lor
    campul nici nu exista, deci nu exista nici atasamentul si raspunsul e natural
    None."""
    brand = template._uportho_brand()
    if brand is None:
        return None
    value = brand['value']
    logo_url = None
    if value.id in _ids_with_image(value, field_name=UPORTHO_BRAND_LOGO_FIELD):
        logo_url = (f'{API_PREFIX}/products/{template.id}/brand/logo'
                    f'?unique={image_unique(value)}')
    return {'name': brand['name'], 'description': brand['description'], 'logo_url': logo_url}


def _similar_templates(template, website):
    """Produsele similare: `alternative_product_ids` daca sunt setate (485 din 619
    produse reale le au), altfel produsele din aceleasi categorii publice. In ambele
    cazuri doar publicate pe website-ul configurat (altfel apasarea pe card ar duce
    la un 404) si fara produsul curent."""
    Template = request.env['product.template']
    domain = _products_domain(website, None, None) + [('id', '!=', template.id)]
    alternative_ids = template.sudo().alternative_product_ids.ids
    if alternative_ids:
        return Template.search(domain + [('id', 'in', alternative_ids)], limit=MAX_SIMILAR)
    category_ids = template.sudo().public_categ_ids.ids
    if not category_ids:
        return Template.browse()
    return Template.search(
        domain + [('public_categ_ids', 'in', category_ids)],
        limit=MAX_SIMILAR, order='is_favorite desc, name, id')


def _serialize_similar(template, website, pricelist, club_pricelist, partner, fiscal_position):
    """Produsele similare, serializate cu EXACT acelasi serializator ca `/products`
    (`serialize_product`), ca aplicatia sa refoloseasca ProductCard fara nicio
    conversie."""
    similar = _similar_templates(template, website)
    if not similar:
        return []
    price_by_template = _prices_by_template(similar, pricelist, partner, fiscal_position)
    club_price_by_template = _club_prices_by_template(
        similar, club_pricelist, pricelist, partner, fiscal_position, price_by_template)
    ids_with_image = _ids_with_image(similar)
    return [
        serialize_product(
            t, price_by_template[t.id], club_price_by_template.get(t.id), t.id in ids_with_image)
        for t in similar
    ]


def _serialize_reviews(template):
    """(rating, reviews) din `rating.rating`, cele mai noi primele, cel mult
    MAX_REVIEWS. Media si numarul se calculeaza in baza de date, pe TOATE recenziile,
    nu doar pe cele intoarse. `rating.rating` nu e citibil de portal, de aceea sudo;
    recenziile interne (`is_internal`) nu se arata niciodata."""
    Rating = request.env['rating.rating'].sudo()
    domain = [
        ('res_model', '=', 'product.template'), ('res_id', '=', template.id),
        ('consumed', '=', True), ('is_internal', '=', False),
    ]
    [(count, average)] = Rating._read_group(domain, [], ['__count', 'rating:avg'])
    reviews = [
        {
            'author': rating.partner_id.name or None,
            'rating': int(round(rating.rating)),
            'date': rating.create_date.date().isoformat() if rating.create_date else None,
            'text': rating.feedback or '',
        }
        for rating in Rating.search(domain, order='create_date desc, id desc', limit=MAX_REVIEWS)
    ]
    return {'average': round(average or 0.0, 1), 'count': count}, reviews


def serialize_benefit(benefit):
    return {'icon': benefit.icon, 'title': benefit.name, 'text': benefit.text or None}


class AppProduct(http.Controller):
    @app_route('/products/<int:product_id>', methods=['GET'])
    def product_detail(self, product_id, **kw):
        website, template = _visible_product(product_id)
        # `values` bate `variant_id`: aplicatia trimite combinatia, iar `variant_id`
        # ramane doar pentru cine il foloseste deja (si pentru rutele de galerie).
        values = _parse_values(template, kw.get('values'))
        variant = (request.env['product.product'].browse() if values is not None
                   else _parse_variant(template, kw.get('variant_id')))
        combination, variant, combination_info = _resolve_combination(
            template, variant, values=values)

        partner = request.env.user.partner_id
        pricelist = _customer_pricelist(partner)
        club_pricelist = _current_club_pricelist()
        _warn_if_tax_display_mismatch(website)
        fiscal_position = request.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)

        amount, list_amount = template._uportho_price_amounts_for(
            pricelist, partner, fiscal_position=fiscal_position, variant=variant)
        price = serialize_price(amount, list_amount, pricelist.currency_id)

        club_price = None
        # Lista de club din care se face tabelul de club: goala cat timp pretul de club
        # nu difera de al clientului (vezi mai jos).
        club_pricelist_for_tables = request.env['product.pricelist'].browse()
        if club_pricelist_comparable(club_pricelist, pricelist):
            club_amount, club_list_amount = template._uportho_price_amounts_for(
                club_pricelist, partner, fiscal_position=fiscal_position, variant=variant)
            candidate = serialize_price(club_amount, club_list_amount, club_pricelist.currency_id)
            # Spec 6.4: pretul de club se arata "cand difera". Cand e identic cu al
            # clientului nu se arata nici pretul, nici tabelul lui de praguri - ar fi
            # acelasi tabel de doua ori pe acelasi ecran.
            if (candidate['amount'], candidate['currency']) != (price['amount'], price['currency']):
                club_price = candidate
                club_pricelist_for_tables = club_pricelist
        else:
            club_pricelist = request.env['product.pricelist'].browse()

        variant_rows = template._uportho_variant_rows(
            pricelist, partner, fiscal_position=fiscal_position)
        rating, reviews = _serialize_reviews(template)
        return json_ok({
            'id': template.id,
            'variant_id': variant.id or None,
            'name': template.name,
            'default_code': (variant.default_code if variant else None) or template.default_code or None,
            'badge': template._app_badge_active(),
            'images': _serialize_gallery(template, variant),
            'price': price,
            'club_price': club_price,
            # Cate un tabel per lista de pret aratata, cu titlul lui - unul, doua sau
            # niciunul. Aplicatia le deseneaza in ordinea primita si nu presupune
            # niciodata cate sunt sau cum le cheama.
            'price_tables': _price_tables(
                template, combination_info, price, pricelist, club_pricelist_for_tables,
                partner, fiscal_position, variant),
            'variants': template._uportho_variants(variant=variant, combination=combination),
            # Tabelul de comanda pe variante (Atribute | Pret | Cantitate | Subtotal),
            # ca pe site. Gol pentru un produs cu o singura varianta - atunci ecranul
            # ramane cum era. Cand exista randuri, ele inlocuiesc selectorul
            # `variants`: fiecare varianta isi are deja randul ei.
            'variant_rows': variant_rows,
            # Totalul de pornire al tabelului de variante: toate cantitatile sunt zero
            # cand ecranul se deschide, iar aplicatia nu are voie sa scrie ea "0,00 lei"
            # (nu formateaza bani). Fara el, Totalul ar arata "—" pana la prima apasare
            # pe plus. Null cand nu exista tabel - atunci nu exista nici total.
            'variant_total': (template._uportho_zero_amount(pricelist.currency_id)
                              if variant_rows else None),
            'specs': template._uportho_specs(),
            # Chenarul de brand de pe site (logo + nume + descriere). Brandul ramane
            # si in `specs`, unde intra ca atribut: site-ul il arata in amandoua
            # locurile. Null cand produsul n-are brand - atunci sectiunea lipseste.
            'brand': _serialize_brand(template),
            # Tabul "Documente" al site-ului: fise tehnice, certificate, cataloage.
            # URL-urile sunt cele standard ale Odoo (`/web/content/...`), pentru ca
            # documentul se deschide in afara aplicatiei - vezi `_uportho_documents`.
            # Lista goala pentru produsele fara documente: atunci sectiunea lipseste
            # complet din ecran, ca toate celelalte.
            'documents': template._uportho_documents(),
            'description': template._uportho_description_blocks(),
            'availability': template._uportho_availability(variant=variant),
            'rating': rating,
            'reviews': reviews,
            'similar': _serialize_similar(
                template, website, pricelist, club_pricelist, partner, fiscal_position),
            'benefits': [serialize_benefit(b) for b in request.env['uportho.app.benefit']._search_active()],
        })

    @app_route('/products/<int:product_id>/prices', methods=['POST'])
    def product_prices(self, product_id, **kw):
        """Preturile tabelului de variante pentru cantitatile alese in aplicatie:
        `{"lines": [{"variant_id": 1, "qty": 2}, ...]}` -> pret unitar, subtotal pe
        linie si total.

        De ce exista ruta: aplicatia nu are voie sa faca aritmetica pe bani
        (CLAUDE.md), si nici n-ar putea. O cantitate mai mare poate trece un prag de
        pret al listei clientului (pe baza de test: 5 bucati -> -20%), deci subtotalul
        NU e pretul afisat inmultit cu cantitatea. Un total inmultit local ar arata
        alta suma decat comanda reala, tacut.

        **Pragurile se aplica pe cantitatea CUMULATA a tuturor liniilor**, nu pe
        fiecare linie in parte. Asa face magazinul: modulul clientului
        (`website_variant_cart`) insumeaza `total_qty` peste toate randurile tabelului
        si abia apoi cere pretul fiecarei variante cu `_get_combination_info_variant(
        add_qty=total_qty)` - la fel in controller, in JS-ul de pe pagina si in
        template-ul QWeb. Cu praguri 1+ 98 / 4+ 77 / 10+ 70, o comanda de 4 pe o
        varianta si 7 pe alta se pretuieste 70 pe ambele randuri (4 + 7 = 11), nu 77.
        Pretuirea per linie - ce facea ruta inainte - arata in aplicatie alt pret decat
        incaseaza site-ul.

        Pretul unitar se cere de la Odoo la cantitatea cumulata, pe aceeasi cale ca tot
        restul modulului (`_uportho_price_amounts_for`, care duce la
        `pricelist._compute_price_rule` + taxele). Cu totalul 0 (tabel proaspat deschis)
        se pretuieste la 1, exact ca `add_qty=total_qty or 1` din template-ul lor:
        pretuit chiar la 0, Odoo nu aplica regulile listei si ar intoarce pretul
        nereduse - aceeasi capcana ca `min_quantity = 0` din `_uportho_price_tiers`.
        Singura inmultire e `pret unitar x cantitate`, aici pe server, cu rotunjirea
        monetara a valutei; toate sumele ies prin `serialize_price`, deci formatarea e
        identica cu a restului API-ului."""
        _website, template = _visible_product(product_id)
        lines = _parse_price_lines(template, read_json_body().get('lines'))

        partner = request.env.user.partner_id
        pricelist = _customer_pricelist(partner)
        fiscal_position = request.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)
        currency = pricelist.currency_id

        # Cantitatea la care se pretuieste TOT tabelul: suma cantitatilor cerute, sau 1
        # cand nu s-a comandat inca nimic.
        priced_qty = sum(qty for _variant, qty in lines) or 1

        serialized = []
        total = 0.0
        for variant, qty in lines:
            amount, list_amount = template._uportho_price_amounts_for(
                pricelist, partner, fiscal_position=fiscal_position,
                quantity=priced_qty, variant=variant)
            subtotal = currency.round(amount * qty)
            list_subtotal = currency.round(list_amount * qty) if list_amount and qty else None
            serialized.append({
                'variant_id': variant.id,
                'qty': qty,
                'price': serialize_price(amount, list_amount, currency),
                'subtotal': serialize_price(subtotal, list_subtotal, currency),
            })
            total += subtotal

        return json_ok({
            'lines': serialized,
            # Totalul nu poarta pret taiat: suma preturilor de lista ale unor linii
            # care nu au toate reducere n-ar fi un pret pe care sa-l fi aratat vreodata
            # magazinul.
            'total': serialize_price(currency.round(total), None, currency),
        })

    @app_route('/products/<int:product_id>/gallery/<int:image_id>', methods=['GET'])
    def product_gallery_image(self, product_id, image_id, **kw):
        """Imaginile din galerie, autentificate ca si celelalte rute de imagine. Vizi-
        bilitatea produsului se verifica intai (404 pentru produs nepublicat sau de pe
        alt website), ca sa nu se poata scoate o poza a unui produs ascuns ghicind
        id-uri de `product.image`."""
        _website, template = _visible_product(product_id)
        if image_id == MAIN_IMAGE_ID:
            variant = _parse_variant(template, kw.get('variant_id'))
            return _image_response(variant or template, 'image_1920')

        image = request.env['product.image'].sudo().browse(image_id).exists()
        if not image or (image.product_tmpl_id | image.product_variant_id.product_tmpl_id) != template.sudo():
            raise ApiError(404, 'not_found', 'Imaginea nu exista.')
        return _image_response(request.env['product.image'].browse(image.id), 'image_1920')

    @app_route('/products/<int:product_id>/brand/logo', methods=['GET'])
    def product_brand_logo(self, product_id, **kw):
        """Logoul de brand, autentificat ca si celelalte rute de imagine. Vizibilitatea
        produsului se verifica intai (404 pentru produs nepublicat sau de pe alt
        website), apoi se ia brandul CHIAR de pe acel produs - nu se accepta un id de
        valoare de atribut din cerere, deci nu se poate scoate logoul altui brand.

        Lipsa campului de logo (baza fara modulele magazinului) e tot 404: nicio poza
        de aratat, nu o eroare."""
        _website, template = _visible_product(product_id)
        value = template._uportho_brand_value()
        if not value or UPORTHO_BRAND_LOGO_FIELD not in value._fields:
            raise ApiError(404, 'not_found', 'Imaginea nu exista.')
        return _image_response(value, UPORTHO_BRAND_LOGO_FIELD)
