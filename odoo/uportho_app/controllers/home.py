import hashlib
import logging

from odoo import fields, http
from odoo.exceptions import AccessError, MissingError
from odoo.http import request

from .base import API_PREFIX, ApiError, app_route, json_ok

_logger = logging.getLogger(__name__)

WEBSITE_PARAM = 'uportho_app.website_id'


def _bind_website_context(website):
    """Leaga website-ul rezolvat de contextul cererii (`website_id`) si il intoarce.

    Rutele acestui modul sunt `type='http'` simple, nu rute de website: dispecerul
    din `website/models/ir_http.py` (care pentru paginile de site face exact
    `request.update_context(website_id=website.id)`) nu trece pe langa ele, deci
    cererea nu spune nimanui despre ce website e vorba. Orice cod Odoo chemat mai
    jos care intreaba `self.env['website'].get_current_website()` - inclusiv
    `product.template._get_combination_info` din `website_sale` si override-urile
    de tema din el - ar rezolva atunci din header-ul HTTP `Host` si ar putea nimeri
    alt website decat magazinul (sau, pe staging, unul in care randarea unui
    template de website cade cu 500).

    `website_id` in context e chiar cheia pe care `get_current_website()` o citeste
    prima, dupa `force_website_id` din sesiune - de aceea legarea se face asa si nu
    prin altceva.

    Inregistrarea intoarsa e RE-LEGATA la mediul nou (`with_env(request.env)`).
    `request.update_context` construieste un `request.env` nou; recordul citit inainte
    ramane insa pe mediul vechi, fara `website_id`. Cine primeste website-ul si cheama
    mai departe cod Odoo pe `website.env` - `website.sale_get_order()`, care ajunge la
    cautarea curierilor dupa `website_published` - ar lucra atunci intr-un context fara
    website si ar vedea curierii publicati pe ORICE website al bazei. S-a intamplat:
    checkout-ul aplicatiei arata si un curier al altui site."""
    if not website:
        return website
    if request.env.context.get('website_id') != website.id:
        request.update_context(website_id=website.id)
    # `sudo` se pastreaza asa cum era: `with_env` schimba mediul cu totul, iar
    # apelantii primesc website-ul in sudo (campurile lui nu sunt neaparat citibile
    # de un utilizator portal). `su` nu schimba utilizatorul cererii, doar sare peste
    # verificarile de acces - de aceea cosul creat mai jos ramane al clientului.
    return website.with_env(request.env).sudo(website.env.su)


def _current_website():
    """Website-ul al carui continut il serveste API-ul aplicatiei.

    Sursa preferata e parametrul de sistem `uportho_app.website_id` (Setari →
    Tehnic → Parametri de sistem). Fara el cadem pe `get_current_website()`, care
    rezolva din header-ul HTTP `Host` contra domeniilor configurate ale
    website-urilor si, daca nu potriveste, ia primul website din baza. Pe instanta
    reala magazinul e un anume website (11) si e foarte probabil ca host-ul prin
    care intra aplicatia sa nu fie domeniul lui: atunci `_search_active_now` si
    `_search_app_home` nu ar returna nimic, iar userul ar vedea "Nu exista continut
    inca." - un bug care arata ca o problema de continut. De aceea fallback-ul
    logheaza un warning, ca esecul sa fie vizibil in loguri.

    Website-ul rezolvat se leaga si de contextul cererii - vezi
    `_bind_website_context`; e singurul loc din modul in care se rezolva un website,
    deci legarea aici acopera toate rutele deodata."""
    Website = request.env['website'].sudo()
    raw = request.env['ir.config_parameter'].sudo().get_param(WEBSITE_PARAM)
    if raw:
        try:
            website = Website.browse(int(raw)).exists()
        except (TypeError, ValueError):
            website = Website.browse()
        if website:
            return _bind_website_context(website)
        _logger.warning(
            'Parametrul de sistem %s = %r nu indica un website existent; '
            'cad pe get_current_website().', WEBSITE_PARAM, raw)
    else:
        _logger.warning(
            'Parametrul de sistem %s nu e setat; cad pe get_current_website(), '
            'care rezolva din header-ul Host si poate alege alt website decat magazinul. '
            'Seteaza-l la id-ul website-ului magazinului.', WEBSITE_PARAM)
    return _bind_website_context(request.env['website'].get_current_website())


def image_unique(record):
    """Token de versiune pentru URL-ul unei imagini, ca sa poata fi invalidata din cache.

    `cached_network_image` din aplicatie isi cheie cache-ul de disc dupa URL si ar
    servi zile la rand imaginea veche dupa ce un editor o schimba in Odoo. Token-ul
    se calculeaza ca in Odoo pentru `/web/image/...?unique=` (`website.image_url`):
    primele 7 caractere din sha512 al lui `write_date`. Se schimba la orice scriere
    pe inregistrare, deci URL-ul devine altul si cache-ul se reincarca."""
    return hashlib.sha512(str(record.sudo().write_date).encode('utf-8')).hexdigest()[:7]


def serialize_banner(banner):
    return {
        'id': banner.id,
        'title': banner.name,
        'subtitle': banner.subtitle or None,
        'cta_text': banner.cta_text or None,
        'placement': banner.placement,
        # Cand imaginea poarta deja textul, aplicatia nu mai deseneaza nimic peste ea.
        # Titlul tot se trimite: ramane eticheta citita de cititoarele de ecran.
        'image_only': bool(banner.image_only and banner.image),
        'image_url': f'{API_PREFIX}/banners/{banner.id}/image?unique={image_unique(banner)}'
                     if banner.image else None,
        'link': {
            'type': banner.link_type,
            'category_id': banner.category_id.id if banner.link_type == 'category' else None,
            'url': banner.external_url if banner.link_type == 'url' else None,
        },
    }


def category_icon_field(category):
    """Din ce camp se serveste iconita categoriei, sau `None` daca n-are nicio poza.

    Intai iconita scrisa pentru aplicatie (`app_home_icon`), apoi **poza categoriei
    din magazin** (`image_1920`). Pe instanta reala toate categoriile de pe Acasa au
    deja poza de pe site si niciuna n-avea iconita de aplicatie, deci fara rezerva
    asta Acasa arata acelasi patrat generic la toate - desi pozele existau la un camp
    distanta. Iconita proprie ramane pentru cand poza din magazin nu e buna pe un
    patrat mic."""
    if category.app_home_icon:
        return 'app_home_icon'
    return 'image_1920' if category.image_1920 else None


def serialize_quick_category(category, product_count):
    has_icon = category_icon_field(category) is not None
    return {
        'id': category.id,
        'name': category.name,
        # Cate produse sunt acolo, ca pe pagina de start a site-ului ("Instrumentar,
        # 208 produse"). Numarul e recursiv, ca in catalog: un produs prins intr-o
        # subcategorie se numara o singura data.
        'product_count': product_count,
        'icon_url': f'{API_PREFIX}/categories/{category.id}/icon?unique={image_unique(category)}'
                    if has_icon else None,
    }


# Campurile de brand ale magazinului (`droggol_theme_common`): valoarea de atribut care
# poarta brandul, si logoul de pe ea. Lipsesc pe o baza fara tema.
BRAND_FIELD = 'dr_brand_value_id'
BRAND_LOGO_FIELD = 'dr_image'
BRANDS_ON_HOME = 12


def serialize_brands(website):
    """Brandurile din catalog, cu cate produse are fiecare, in ordinea marimii.

    Pagina de start a site-ului are un rand "Shop By Brands"; multe cabinete cumpara
    pe marca, nu pe categorie. Brandul NU e o lista configurata undeva: e chiar
    valoarea de atribut dupa care filtreaza si catalogul, deci apasarea pe un brand
    deschide aceeasi filtrare pe care clientul ar fi facut-o de mana.

    Se numara doar produsele pe care le-ar da si `/products` (publicate, pe website-ul
    potrivit). Pe o baza fara modulele magazinului campul nu exista si randul lipseste
    cu totul - nu se inventeaza alt inteles pentru "brand"."""
    from .catalog import _products_domain

    Template = request.env['product.template']
    if BRAND_FIELD not in Template._fields:
        return []
    domain = _products_domain(website, None, None) + [(BRAND_FIELD, '!=', False)]
    groups = Template.sudo()._read_group(domain, [BRAND_FIELD], ['__count'])
    brands = []
    for value, count in sorted(groups, key=lambda group: -group[1]):
        name = (value.name or '').strip()
        if not name:
            continue
        has_logo = BRAND_LOGO_FIELD in value._fields and value[BRAND_LOGO_FIELD]
        brands.append({
            'id': value.id,
            # Atributul e necesar ca aplicatia sa poata cere chiar filtrul magazinului
            # (`attribute_value=<atribut>-<valoare>`), nu o cautare dupa nume.
            'attribute_id': value.attribute_id.id,
            'name': name,
            'product_count': count,
            'logo_url': f'{API_PREFIX}/brands/{value.id}/logo?unique={image_unique(value)}'
                        if has_logo else None,
        })
        if len(brands) >= BRANDS_ON_HOME:
            break
    return brands


def _category_counts(categories, website):
    """Cate produse are fiecare categorie de pe Acasa. Se cheama numaratoarea
    catalogului, nu alta: numarul de sub iconita trebuie sa fie acelasi cu cel din
    chipul de categorie din catalog."""
    if not categories:
        return {}
    from .catalog import _product_counts_by_category

    return _product_counts_by_category(
        request.env['product.public.category'].sudo().search([]), website)


def serialize_section(section, website):
    """Un rand de produse de pe Acasa, sau `None` cand n-are ce arata.

    Produsele trec prin ACELASI domeniu ca `/products` (publicat, pe website-ul
    potrivit) si prin aceeasi ordine a magazinului: un rand de pe Acasa nu poate arata
    produse pe care catalogul nu le-ar da, nici intr-o ordine proprie. Un produs
    depublicat dispare din rand fara sa stearga nimeni nimic.

    Un rand ramas fara produse nu se trimite deloc - un titlu peste un rand gol e mai
    rau decat lipsa lui."""
    # Importul sta aici, nu sus: `catalog` importa la randul lui din acest modul
    # (`_current_website`, `_image_response`), iar la nivel de fisier cele doua s-ar
    # astepta una pe alta si modulul n-ar mai porni.
    from .catalog import _products_domain, _products_order, _serialize_templates

    extra = section._extra_domain()
    if extra is None:
        return None
    domain = _products_domain(website, None, None) + extra
    templates = request.env['product.template'].search(
        domain, limit=section.limit, order=_products_order(website))
    if not templates:
        return None
    return {
        'id': section.id,
        'title': section.name,
        'category_id': section.category_id.id if section.source == 'category' else None,
        'products': _serialize_templates(templates, website),
    }


def _image_response(record, field_name):
    """Serveste un camp binar al unei inregistrari ca raspuns HTTP.

    Ajutorul din `ir.binary` se alege dupa **clasa** campului, nu dupa `field.type`:
    si `fields.Image`, si `fields.Binary` raporteaza `type == 'binary'`, deci tipul nu
    le deosebeste. `_get_image_stream_from` e scris pentru campuri `Image` (redimen-
    sionare dupa numele campului, inlocuire cu poza de rezerva, mimetype implicit de
    imagine); pe un `Binary` simplu prelucrarile acelea nu au ce cauta si ne-au si
    stricat deja o ruta: logoul de brand se ia din `product.attribute.value.dr_image`,
    un `fields.Binary` simplu al modulelor magazinului, iar ruta raspundea 200 cu corp
    gol, deci aplicatia desena un chenar gol in loc de logo.

    Campurile modulului (`uportho.app.banner.image`, `product.public.category.
    app_home_icon`, `uportho.app.benefit.image`, pozele de produs si de galerie) sunt
    `Image` si raman pe drumul de imagine, cu tot cu 404-ul lor pentru poza lipsa.

    Pe drumul de Binary simplu, o inregistrare la care nu se poate ajunge (atasament
    disparut, camp fara drept de citire) intoarce tot 404, nu 500: `_get_image_stream_from`
    inghitea astfel de erori si servea poza de rezerva, iar o ruta care incepe sa cada
    cu 500 dupa aceasta schimbare ar fi o inrautatire, nu o reparatie."""
    if not record.exists() or not record[field_name]:
        raise ApiError(404, 'not_found', 'Imaginea nu exista.')
    binary = request.env['ir.binary']
    if isinstance(record._fields[field_name], fields.Image):
        stream = binary._get_image_stream_from(record, field_name=field_name)
    else:
        try:
            stream = binary._get_stream_from(record, field_name=field_name)
        except (AccessError, MissingError) as error:
            raise ApiError(404, 'not_found', 'Imaginea nu exista.') from error
    return stream.get_response()


class AppHome(http.Controller):
    @app_route('/home', methods=['GET'])
    def home(self, **kw):
        website = _current_website()
        banners = request.env['uportho.app.banner']._search_active_now(website)
        categories = request.env['product.public.category']._search_app_home(website)
        sections = request.env['uportho.app.section']._search_active_now(website)
        counts = _category_counts(categories, website)
        return json_ok({
            'banners': [serialize_banner(b) for b in banners],
            'quick_categories': [
                serialize_quick_category(c, counts.get(c.id, 0)) for c in categories
            ],
            'brands': serialize_brands(website),
            'sections': [
                block for block in (serialize_section(s, website) for s in sections)
                if block is not None
            ],
        })

    @app_route('/brands/<int:value_id>/logo', methods=['GET'])
    def brand_logo(self, value_id, **kw):
        """Logoul unui brand.

        Se serveste doar pentru o valoare care chiar apare pe un produs publicat al
        website-ului: altfel ruta ar fi o fereastra prin care se pot citi, una cate
        una, toate imaginile de pe valorile de atribut din baza."""
        from .catalog import _products_domain

        Template = request.env['product.template']
        value = request.env['product.attribute.value'].sudo().browse(value_id).exists()
        in_catalog = value and BRAND_FIELD in Template._fields and Template.sudo().search_count(
            _products_domain(_current_website(), None, None) + [(BRAND_FIELD, '=', value.id)],
            limit=1)
        if not in_catalog:
            raise ApiError(404, 'not_found', 'Imaginea nu exista.')
        return _image_response(value, BRAND_LOGO_FIELD)

    @app_route('/banners/<int:banner_id>/image', methods=['GET'])
    def banner_image(self, banner_id, **kw):
        return _image_response(request.env['uportho.app.banner'].browse(banner_id), 'image')

    @app_route('/categories/<int:category_id>/icon', methods=['GET'])
    def category_icon(self, category_id, **kw):
        """Iconita categoriei: campul de aplicatie daca exista, altfel poza din
        magazin. Aceeasi alegere ca in `/home`, ca ruta sa nu dea 404 pentru un URL
        pe care tot noi l-am trimis."""
        category = request.env['product.public.category'].browse(category_id)
        field_name = category_icon_field(category.sudo().exists())
        if field_name is None:
            raise ApiError(404, 'not_found', 'Imaginea nu exista.')
        return _image_response(category, field_name)
