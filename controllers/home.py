import hashlib
import logging

from odoo import http
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
    prin altceva."""
    if website and request.env.context.get('website_id') != website.id:
        request.update_context(website_id=website.id)
    return website


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
        'image_url': f'{API_PREFIX}/banners/{banner.id}/image?unique={image_unique(banner)}'
                     if banner.image else None,
        'link': {
            'type': banner.link_type,
            'category_id': banner.category_id.id if banner.link_type == 'category' else None,
            'url': banner.external_url if banner.link_type == 'url' else None,
        },
    }


def serialize_quick_category(category):
    return {
        'id': category.id,
        'name': category.name,
        'icon_url': f'{API_PREFIX}/categories/{category.id}/icon?unique={image_unique(category)}'
                    if category.app_home_icon else None,
    }


def _image_response(record, field_name):
    if not record.exists() or not record[field_name]:
        raise ApiError(404, 'not_found', 'Imaginea nu exista.')
    stream = request.env['ir.binary']._get_image_stream_from(record, field_name=field_name)
    return stream.get_response()


class AppHome(http.Controller):
    @app_route('/home', methods=['GET'])
    def home(self, **kw):
        website = _current_website()
        banners = request.env['uportho.app.banner']._search_active_now(website)
        categories = request.env['product.public.category']._search_app_home(website)
        return json_ok({
            'banners': [serialize_banner(b) for b in banners],
            'quick_categories': [serialize_quick_category(c) for c in categories],
        })

    @app_route('/banners/<int:banner_id>/image', methods=['GET'])
    def banner_image(self, banner_id, **kw):
        return _image_response(request.env['uportho.app.banner'].browse(banner_id), 'image')

    @app_route('/categories/<int:category_id>/icon', methods=['GET'])
    def category_icon(self, category_id, **kw):
        return _image_response(request.env['product.public.category'].browse(category_id), 'app_home_icon')
