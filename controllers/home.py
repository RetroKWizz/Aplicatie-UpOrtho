import hashlib

from odoo import http
from odoo.http import request

from .base import API_PREFIX, ApiError, app_route, json_ok


def _current_website():
    return request.env['website'].get_current_website()


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
