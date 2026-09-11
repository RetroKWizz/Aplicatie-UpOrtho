import logging

from odoo import http
from odoo.http import request

from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, json_ok, read_json_body
from .catalog import _warn_if_tax_display_mismatch
from .home import _current_website, image_unique

_logger = logging.getLogger(__name__)

# Cate linii poate atinge o singura cerere. Tabelul de variante din pagina de produs
# are cel mult cateva zeci de randuri (dintii unei arcade); limita opreste o cerere
# construita gresit inainte sa tina o tranzactie deschisa minute intregi.
MAX_CART_LINES = 60


def _cart_order(force_create=False):
    """Cosul curent, cerut Odoo-ului pe exact aceeasi cale ca magazinul:
    `website.sale_get_order()`.

    Nu se cauta `sale.order` cu domeniu propriu si nu se creeaza comanda cu `create`.
    Metoda lor tine minte cosul in sesiune (`sale_order_id`), il regaseste dupa
    `partner.last_website_so_id` la o sesiune noua, il abandoneaza cand lista de
    preturi sau pozitia fiscala s-a schimbat intre timp si refuza sa-l reincarce cand
    o plata a fost deja initiata. Toate astea sunt reguli de magazin, nu detalii de
    transport - reproduse aici, aplicatia si site-ul ar ajunge sa arate doua cosuri
    diferite aceluiasi client.

    Sesiunea aplicatiei e chiar sesiunea Odoo (acelasi cookie), deci **cosul e comun
    cu site-ul**: ce adaugi in aplicatie vezi in browser si invers.

    `_current_website()` leaga `website_id` de contextul cererii (vezi acolo), de care
    depind mai departe filtrarea curierilor publicati si regulile de tema."""
    website = _current_website()
    return website.sale_get_order(force_create=force_create)


def _display_currency(order):
    """Valuta in care se formateaza sumele cosului. Comanda are `currency_id` doar
    dupa ce exista; pe un cos inca inexistent cadem pe valuta listei de preturi a
    clientului, ca raspunsul sa aiba aceeasi forma si cand cosul e gol."""
    if order and order.currency_id:
        return order.currency_id
    partner = request.env.user.partner_id
    pricelist = partner.property_product_pricelist
    return pricelist.currency_id or request.env.company.currency_id


def _line_image_url(line):
    template = line.product_id.product_tmpl_id
    if not template:
        return None
    return f'{API_PREFIX}/products/{template.id}/image?unique={image_unique(template)}'


def _variant_label(line):
    """Ce distinge varianta de produsul-parinte ("Tooth: 11"), sau None la un produs
    fara variante. Se citesc valorile de atribut chiar de pe linie
    (`product_no_variant_attribute_value_ids` include si atributele care nu creeaza
    variante, alese la adaugarea in cos), nu se reconstruieste numele din display_name."""
    values = line.product_id.product_template_attribute_value_ids | line.product_no_variant_attribute_value_ids
    if not values:
        return None
    return ', '.join(f'{v.attribute_id.name}: {v.name}' for v in values)


def _line_unit_prices(line):
    """Pretul unitar al liniei CU TVA, si pretul dinainte de reducere cand exista.

    Intoarce `(pret, pret_taiat_sau_None)`.

    Pretul de baza e aceeasi socoteala ca `sale.order.line._get_displayed_unit_price()`
    din `website_sale` (taxele liniei aplicate pe o bucata, cu tratarea separata a
    produselor combo), cu o singura diferenta deliberata: acolo alegerea intre
    `total_included` si `total_excluded` urmeaza configurarea website-ului, aici e
    mereu `total_included` - tot API-ul acestui modul intoarce preturi cu TVA si le
    marcheaza asa (`with_vat: True`). Altfel acelasi produs ar avea doua preturi in
    aceeasi aplicatie: unul in catalog, altul in cos.

    **Reducerea liniei se aplica.** `_get_displayed_unit_price()` o ignora: pe o
    comanda reala de pe staging el intorcea 330,00 lei pe bucata, in timp ce comanda
    incasa 264,00 (272,73 fara TVA, minus 20%, plus TVA). Magazinul arata amandoua
    cifrele - sablonul `website_sale.cart_lines` taie pretul nereduse si scrie langa
    el pretul cu reducere aplicata - asa ca aplicatia trebuie sa le primeasca pe
    amandoua, nu doar pe cel taiat.

    Inmultirea cu `(1 - discount/100)` e chiar formula lui Odoo pentru totalul liniei;
    facuta aici, pe server, nu in aplicatie (CLAUDE.md: aplicatia nu face aritmetica pe
    bani)."""
    base = line._get_display_price_ignore_combo() if line.product_type == 'combo' else line.price_unit
    taxed = line.tax_id.compute_all(
        price_unit=base, currency=line.currency_id, quantity=1.0,
        product=line.product_id, partner=line.order_partner_id)['total_included']
    discount = line.discount or 0.0
    if not discount:
        return taxed, None
    return line.currency_id.round(taxed * (1.0 - discount / 100.0)), taxed


def serialize_cart_line(line, currency):
    """O linie de cos, cu banii deja formatati de server.

    Subtotalul e `price_total` (cu TVA), campul pe care il aduna si comanda - asa randul
    si totalul nu pot sa nu fie de acord, iar pretul unitar e calculat cu aceeasi taxa
    si cu aceeasi reducere (vezi `_line_unit_prices`).

    `warning` e avertismentul de magazin al liniei (stoc insuficient, cantitate ajustata).
    Se citeste fara sa se stearga: o cerere `GET` nu are voie sa consume un mesaj pe
    care aplicatia poate inca nu l-a aratat."""
    return {
        'id': line.id,
        'product_id': line.product_id.product_tmpl_id.id,
        'variant_id': line.product_id.id,
        'name': line.name_short or line.product_id.display_name,
        'variant_name': _variant_label(line),
        'default_code': line.product_id.default_code or None,
        'image_url': _line_image_url(line),
        'quantity': line._get_displayed_quantity(),
        'unit_price': serialize_price(*_line_unit_prices(line), currency=currency),
        'subtotal': serialize_price(line.price_total, None, currency),
        'warning': line.shop_warning or None,
    }


def _free_delivery(order, currency):
    """Progresul catre livrarea gratuita, exact cum il calculeaza tema magazinului
    (`droggol_theme_common.sale_order._get_free_delivery_details`): pragul celui mai
    ieftin curier cu `free_over`, cat s-a strans si cat mai lipseste.

    Se cheama metoda lor, nu se recalculeaza: pragul depinde de ce curieri sunt
    publicati azi pe website si de `free_over`/`amount`, adica de configurare care se
    schimba fara release de aplicatie. Pe o baza fara tema (dezvoltare locala, teste)
    metoda nu exista - atunci blocul lipseste din raspuns, nu se inventeaza altul."""
    if not order or not hasattr(order, '_get_free_delivery_details'):
        return None
    details = order._get_free_delivery_details()
    if not details:
        return None
    remaining = max(details['remaining_amount'], 0.0)
    return {
        'free_over': serialize_price(details['free_over'], None, currency),
        'order_amount': serialize_price(details['order_amount'], None, currency),
        'remaining': serialize_price(remaining, None, currency),
        'reached': remaining <= 0,
    }


def _delivery_amount(order):
    """Cat costa transportul in aceasta comanda, CU TVA.

    Nu se citeste `order.amount_delivery`: acel camp urmeaza configurarea website-ului
    ("Tax included or excluded depending on the website configuration", spune chiar
    ajutorul lui), pe cand tot API-ul acestui modul intoarce sume cu TVA. Pe o baza
    configurata pe TVA exclus, transportul ar fi aparut mai mic decat e in totalul de
    plata - iar `untaxed + tax + delivery` n-ar mai fi dat `total`.

    Se aduna `price_total` al liniilor de transport, adica exact liniile pe care le
    numara si campul lor."""
    lines = order.order_line.filtered('is_delivery') if order else []
    return sum(lines.mapped('price_total')) if lines else 0.0


def serialize_cart(order):
    """Raspunsul complet al cosului. Un cos inexistent nu e o eroare: se raspunde cu
    aceeasi forma, goala, ca aplicatia sa aiba un singur drum de randare."""
    _warn_if_tax_display_mismatch(_current_website())
    currency = _display_currency(order)
    lines = order.order_line.filtered(lambda l: l._show_in_cart()) if order else []
    zero = serialize_price(0.0, None, currency)
    data = {
        'order_id': order.id if order else None,
        'quantity': int(order.cart_quantity) if order else 0,
        'lines': [serialize_cart_line(line, currency) for line in lines],
        'amounts': {
            'untaxed': serialize_price(order.amount_untaxed, None, currency) if order else zero,
            'tax': serialize_price(order.amount_tax, None, currency) if order else zero,
            'delivery': serialize_price(_delivery_amount(order), None, currency) if order else zero,
            'total': serialize_price(order.amount_total, None, currency) if order else zero,
        },
        'free_delivery': _free_delivery(order, currency),
        'warning': (order.shop_warning or None) if order else None,
    }
    return data


def _parse_cart_lines(raw_lines):
    """Liniile din corpul lui `POST /cart/lines`.

    Fiecare linie are `variant_id` (un `product.product`, ce trimite tabelul de
    variante al paginii de produs) si exact una din:
    - `add_qty` - adauga peste ce e deja in cos (butonul "Adauga in cos");
    - `set_qty` - fixeaza cantitatea liniei (pasii +/- din ecranul de cos, si 0 =
      sterge linia).

    Cele doua nu se amesteca intr-un singur camp `quantity`: acelasi numar ar insemna
    lucruri diferite in cele doua ecrane, iar o confuzie de partea aplicatiei ar dubla
    tacut cantitatile comandate. `line_id` e optional si tinteste o linie anume - fara
    el, Odoo isi cauta singur linia potrivita produsului.

    Orice e gresit e 422 in forma standard, niciodata 500. `True` e respins desi in
    Python e un `int`: un boolean nu e o cantitate."""
    if not isinstance(raw_lines, list) or not raw_lines:
        raise ApiError(422, 'validation_error', 'lines trebuie sa fie o lista cu cel putin o linie.')
    if len(raw_lines) > MAX_CART_LINES:
        raise ApiError(422, 'validation_error', f'Prea multe linii (maxim {MAX_CART_LINES}).')

    parsed = []
    for raw in raw_lines:
        if not isinstance(raw, dict):
            raise ApiError(422, 'validation_error', 'Fiecare linie trebuie sa fie un obiect JSON.')
        variant_id = raw.get('variant_id')
        if isinstance(variant_id, bool) or not isinstance(variant_id, int):
            raise ApiError(422, 'validation_error', 'Fiecare linie are nevoie de variant_id numeric.')
        has_add = 'add_qty' in raw
        has_set = 'set_qty' in raw
        if has_add == has_set:
            raise ApiError(422, 'validation_error',
                           'Fiecare linie are nevoie de exact una din add_qty sau set_qty.')
        key = 'add_qty' if has_add else 'set_qty'
        qty = raw[key]
        if isinstance(qty, bool) or not isinstance(qty, int):
            raise ApiError(422, 'validation_error', f'{key} trebuie sa fie un numar intreg.')
        if key == 'set_qty' and qty < 0:
            raise ApiError(422, 'validation_error', 'set_qty trebuie sa fie >= 0.')
        line_id = raw.get('line_id')
        if line_id is not None and (isinstance(line_id, bool) or not isinstance(line_id, int)):
            raise ApiError(422, 'validation_error', 'line_id trebuie sa fie numeric.')
        parsed.append({'variant_id': variant_id, key: qty, 'line_id': line_id})
    return parsed


class AppCart(http.Controller):
    @app_route('/cart', methods=['GET'])
    def cart(self, **kw):
        return json_ok(serialize_cart(_cart_order()))

    @app_route('/cart/lines', methods=['POST'])
    def cart_lines(self, **kw):
        """Adauga, schimba sau sterge linii din cos si intoarce cosul intreg.

        Se cheama `sale.order._cart_update` al magazinului, o data pe linie - metoda
        prin care trece si `/shop/cart/update_json`. Ea verifica ce produs are voie sa
        intre in cos, ajusteaza cantitatea dupa stoc (`_verify_updated_quantity`),
        refuza produsele fara pret cand website-ul e configurat asa si recalculeaza
        transportul cand exista deja un curier ales. Peste ea vin si regulile temei
        (accesul B2B), fara sa le stim aici.

        Raspunsul e intreg cosul, nu doar linia atinsa: o singura cantitate schimbata
        poate trece un prag de pret al listei si rescrie subtotalurile TUTUROR liniilor
        aceluiasi produs, plus taxa de transport si progresul catre livrarea gratuita.
        Un raspuns partial ar lasa aplicatia sa afiseze cifre vechi langa cifre noi.

        Avertismentele stranse pe linii (`shop_warning`) se intorc in `warnings` si se
        sterg, ca sa nu reapara la fiecare `GET /cart` de dupa."""
        lines = _parse_cart_lines(read_json_body().get('lines'))
        order = _cart_order(force_create=True)
        # Cosul din sesiune poate fi o comanda deja confirmata (s-a platit intre timp,
        # din aplicatie sau din browser): `_cart_update` ar arunca "It is forbidden to
        # modify a sales order which is not in draft status". Magazinul uita cosul si
        # incepe altul - la fel aici, altfel clientul ramane blocat pana la logout.
        if order.state != 'draft':
            _current_website().sale_reset()
            order = _cart_order(force_create=True)

        warnings = []
        for line in lines:
            result = order._cart_update(
                product_id=line['variant_id'],
                line_id=line['line_id'],
                # `add_qty` si `set_qty` se trimit exact cum le trimite magazinul:
                # LIPSA inseamna None, nu 0. `set_qty=0` cu `add_qty=0` nu sterge linia
                # - `_cart_update` citeste `elif add_qty is not None` si pastreaza
                # cantitatea existenta. Stergerea e `set_qty=0` cu `add_qty=None`.
                add_qty=line.get('add_qty'),
                set_qty=line.get('set_qty'),
            )
            if result.get('warning'):
                warnings.append(result['warning'])

        payload = serialize_cart(order)
        # Avertismentele de linie se consuma o singura data: le citim (si le stergem)
        # aici, dupa serializare, ca sa ajunga in raspunsul in care s-au produs.
        for cart_line in order.order_line:
            warning = cart_line._get_shop_warning()
            if warning:
                warnings.append(warning)
        payload['warnings'] = list(dict.fromkeys(warnings))
        return json_ok(payload)
