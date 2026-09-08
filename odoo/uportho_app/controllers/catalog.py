import logging

from odoo import http
from odoo.http import request

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
        pricelist = Pricelist.browse(int(raw)).exists()
    except (TypeError, ValueError):
        pricelist = Pricelist.browse()
    if not pricelist:
        _logger.warning(
            'Parametrul de sistem %s = %r nu indica o lista de preturi existenta; '
            'club_price va fi null pentru toate produsele.', CLUB_PRICELIST_PARAM, raw)
    return pricelist


def _format_amount(amount, currency):
    """Formatare romaneasca a unei sume monetare: virgula zecimala, punct pentru
    miile, simbolul valutei dupa ('148,50 lei', '1.234,00 lei'). Nu folosim
    formatarea de limba din Odoo (`formatLang`) ca sa nu depindem de ce limbi/traduceri
    sunt instalate pe o baza anume - formatul e o cerinta de contract, nu o optiune."""
    rounded = currency.round(amount)
    text = f'{rounded:,.2f}'
    integer_part, decimal_part = text.split('.')
    integer_part = integer_part.replace(',', '.')
    return f'{integer_part},{decimal_part} {currency.symbol}'


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
        'discount_pct': discount_pct,
    }


def _price_for(template, pricelist, partner):
    amount, list_amount = template._uportho_price_amounts(pricelist, partner)
    return serialize_price(amount, list_amount, pricelist.currency_id)


def _products_domain(website, category_id, query):
    domain = [
        ('is_published', '=', True),
        '|', ('website_id', '=', False), ('website_id', '=', website.id),
    ]
    if category_id is not None:
        domain = domain + [('public_categ_ids', 'child_of', category_id)]
    if query:
        domain = domain + ['|', ('name', 'ilike', query), ('default_code', 'ilike', query)]
    return domain


def _product_count(category, website):
    return request.env['product.template'].search_count([
        ('is_published', '=', True),
        '|', ('website_id', '=', False), ('website_id', '=', website.id),
        ('public_categ_ids', '=', category.id),
    ])


def serialize_category(category, website):
    return {
        'id': category.id,
        'name': category.name,
        'parent_id': category.parent_id.id or None,
        'icon_url': (f'{API_PREFIX}/categories/{category.id}/icon?unique={image_unique(category)}'
                     if category.app_home_icon else None),
        'product_count': _product_count(category, website),
    }


def serialize_product(template, partner, pricelist, club_pricelist):
    club_price = _price_for(template, club_pricelist, partner) if club_pricelist else None
    return {
        'id': template.id,
        'name': template.name,
        'default_code': template.default_code or None,
        'image_url': (f'{API_PREFIX}/products/{template.id}/image?unique={image_unique(template)}'
                      if template.image_1920 else None),
        'price': _price_for(template, pricelist, partner),
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
    try:
        value = int(raw)
    except (TypeError, ValueError):
        return 0
    return value if value > 0 else 0


def _parse_limit(raw):
    try:
        value = int(raw)
    except (TypeError, ValueError):
        return DEFAULT_LIMIT
    if value <= 0:
        return DEFAULT_LIMIT
    return min(value, MAX_LIMIT)


class AppCatalog(http.Controller):
    @app_route('/categories', methods=['GET'])
    def categories(self, **kw):
        website = _current_website()
        domain = ['|', ('website_id', '=', False), ('website_id', '=', website.id)]
        categories = request.env['product.public.category'].search(domain)
        return json_ok([serialize_category(c, website) for c in categories])

    @app_route('/products', methods=['GET'])
    def products(self, **kw):
        website = _current_website()
        category_id = _parse_category_id(kw.get('category_id'))
        domain = _products_domain(website, category_id, kw.get('q'))
        offset = _parse_offset(kw.get('offset'))
        limit = _parse_limit(kw.get('limit'))

        Template = request.env['product.template']
        total = Template.search_count(domain)
        templates = Template.search(domain, offset=offset, limit=limit)

        partner = request.env.user.partner_id
        pricelist = partner.property_product_pricelist
        club_pricelist = _current_club_pricelist()

        return json_ok({
            'products': [serialize_product(t, partner, pricelist, club_pricelist) for t in templates],
            'total': total,
            'offset': offset,
            'limit': limit,
        })

    @app_route('/products/<int:product_id>/image', methods=['GET'])
    def product_image(self, product_id, **kw):
        return _image_response(request.env['product.template'].browse(product_id), 'image_1920')
