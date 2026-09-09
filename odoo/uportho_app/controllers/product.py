from odoo import http
from odoo.http import request

from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, json_ok
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

MAX_SIMILAR = 10
MAX_REVIEWS = 20
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


def _resolve_combination(template, variant):
    """Combinatia curenta si varianta ei, cerute de la Odoo prin `_get_combination_info`
    - acelasi API pe care il foloseste pagina de produs de pe site. Fara `variant_id`
    Odoo alege singur prima combinatie posibila (nu o alegem noi); cu `variant_id`,
    combinatia e cea a variantei cerute.

    Din raspunsul lui folosim doar combinatia si varianta: preturile lui vin de pe
    `website.pricelist_id` (lista rezolvata din sesiune/geoip), nu de pe lista
    clientului si a Ortho Club, care sunt cele doua de care are nevoie aplicatia."""
    combination_info = template._get_combination_info(product_id=variant.id if variant else False)
    resolved_id = combination_info.get('product_id')
    if resolved_id:
        variant = request.env['product.product'].browse(resolved_id)
    elif not variant:
        variant = template.product_variant_id
    return combination_info.get('combination'), variant


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
        variant = _parse_variant(template, kw.get('variant_id'))
        combination, variant = _resolve_combination(template, variant)

        partner = request.env.user.partner_id
        pricelist = _customer_pricelist(partner)
        club_pricelist = _current_club_pricelist()
        _warn_if_tax_display_mismatch(website)
        fiscal_position = request.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)

        amount, list_amount = template._uportho_price_amounts_for(
            pricelist, partner, fiscal_position=fiscal_position, variant=variant)
        price = serialize_price(amount, list_amount, pricelist.currency_id)

        club_price, club_tiers = None, []
        if club_pricelist_comparable(club_pricelist, pricelist):
            club_amount, club_list_amount = template._uportho_price_amounts_for(
                club_pricelist, partner, fiscal_position=fiscal_position, variant=variant)
            candidate = serialize_price(club_amount, club_list_amount, club_pricelist.currency_id)
            # Spec 6.4: pretul de club se arata "cand difera". Cand e identic cu al
            # clientului nu se arata nici pretul, nici tabelul lui de praguri - ar fi
            # acelasi tabel de doua ori pe acelasi ecran.
            if (candidate['amount'], candidate['currency']) != (price['amount'], price['currency']):
                club_price = candidate
                club_tiers = template._uportho_price_tiers(
                    club_pricelist, partner, fiscal_position=fiscal_position, variant=variant)
        else:
            club_pricelist = request.env['product.pricelist'].browse()

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
            'tiers': template._uportho_price_tiers(
                pricelist, partner, fiscal_position=fiscal_position, variant=variant),
            'club_tiers': club_tiers,
            'variants': template._uportho_variants(variant=variant, combination=combination),
            'specs': template._uportho_specs(),
            'description': template._uportho_description_blocks(),
            'availability': template._uportho_availability(variant=variant),
            'rating': rating,
            'reviews': reviews,
            'similar': _serialize_similar(
                template, website, pricelist, club_pricelist, partner, fiscal_position),
            'benefits': [serialize_benefit(b) for b in request.env['uportho.app.benefit']._search_active()],
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
