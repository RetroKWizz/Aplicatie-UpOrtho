import logging

from odoo import http
from odoo.http import request

from .base import ApiError, app_route, json_ok, read_json_body
from .catalog import _products_domain, _serialize_templates
from .home import _current_website

_logger = logging.getLogger(__name__)


def _favorites_partner():
    """Favoritele apartin contului, nu utilizatorului: intr-un cabinet cu mai multi
    utilizatori pe acelasi client, toti vad aceeasi lista - ca la comenzi si adrese."""
    return request.env.user.partner_id.commercial_partner_id


def _favorite_templates(website):
    """Produsele favorite care mai sunt de vazut in magazin.

    Filtrul e chiar domeniul catalogului (`_products_domain`), deci un produs
    depublicat sau scos de pe acest website dispare si din favorite, fara sa fie nevoie
    sa stergem ceva: lista nu poate arata un produs pe care clientul nu-l poate deschide."""
    favorites = request.env['uportho.app.favorite'].sudo().search([
        ('partner_id', '=', _favorites_partner().id),
    ])
    if not favorites:
        return request.env['product.template'].browse()
    domain = _products_domain(website, None, None) + [('id', 'in', favorites.product_tmpl_id.ids)]
    return request.env['product.template'].search(domain)


def _favorites_payload():
    """Raspunsul tuturor rutelor de favorite: lista intreaga plus id-urile ei.

    Aceeasi forma peste tot, dinadins. Cand adaugarea raspundea doar cu id-urile,
    ecranul primea o stare fara produse si lista de favorite aparea goala imediat dupa
    ce apasai inimioara - desi serverul le avea. Un singur drum de serializare inseamna
    ca asa ceva nu se mai poate intampla."""
    website = _current_website()
    templates = _favorite_templates(website)
    return {'products': _serialize_templates(templates, website), 'ids': templates.ids}


def _product_of_request(product_id):
    """Produsul pe care clientul chiar il poate vedea in magazin. Un id din afara
    catalogului nu se poate pune la favorite."""
    website = _current_website()
    domain = _products_domain(website, None, None) + [('id', '=', product_id)]
    template = request.env['product.template'].search(domain, limit=1)
    if not template:
        raise ApiError(404, 'not_found', 'Produsul nu exista.')
    return template


class AppFavorites(http.Controller):
    """Produsele favorite ale contului.

    **Magazinul nu are lista de favorite** (`website_sale_wishlist` nu e instalat), deci
    nu exista o lista a lor cu care sa se sincronizeze; vezi comentariul modelului
    `uportho.app.favorite`."""

    @app_route('/favorites', methods=['GET'])
    def favorites(self, **kw):
        return json_ok(_favorites_payload())

    @app_route('/favorites', methods=['POST'])
    def add_favorite(self, **kw):
        """Pune un produs la favorite: `{"product_id": 123}`. Apelul e idempotent -
        acelasi produs trimis de doua ori nu e o eroare si nu creeaza doua randuri."""
        body = read_json_body()
        product_id = body.get('product_id')
        if not isinstance(product_id, int) or isinstance(product_id, bool):
            raise ApiError(422, 'validation_error', 'product_id trebuie sa fie numeric.')
        template = _product_of_request(product_id)

        Favorite = request.env['uportho.app.favorite'].sudo()
        partner = _favorites_partner()
        existing = Favorite.search(
            [('partner_id', '=', partner.id), ('product_tmpl_id', '=', template.id)], limit=1)
        if not existing:
            Favorite.create({'partner_id': partner.id, 'product_tmpl_id': template.id})
        return json_ok({'favorite': True, **_favorites_payload()})

    @app_route('/favorites/<int:product_id>', methods=['DELETE'])
    def remove_favorite(self, product_id, **kw):
        """Scoate un produs de la favorite. Si aceasta e idempotenta: un produs care nu
        era acolo nu e o eroare, rezultatul cerut de client e acelasi."""
        Favorite = request.env['uportho.app.favorite'].sudo()
        Favorite.search([
            ('partner_id', '=', _favorites_partner().id),
            ('product_tmpl_id', '=', product_id),
        ]).unlink()
        return json_ok({'favorite': False, **_favorites_payload()})
