import logging

from odoo import http
from odoo.exceptions import ValidationError
from odoo.http import request

from ..models.product_template import _uportho_html_blocks
from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, json_ok, read_json_body
from .cart import _cart_order, serialize_cart
from .home import _current_website, _image_response

_logger = logging.getLogger(__name__)

# Codurile de provider pe care aplicatia le poate incheia singura, fara niciun
# formular de card: transferul bancar (`custom`, modulul standard `payment_custom`) si
# plata la livrare (`on_delivery`, modulul clientului). Pentru ele plata nu e o
# tranzactie de card, ci o instructiune ("plateste in cont, referinta X" / "platesti
# curierului"), iar Odoo o marcheaza prin acelasi drum ca site-ul:
# `_handle_notification_data(cod, {'reference': ...})`.
#
# Orice alt provider (azi Stripe) cere datele cardului intr-un formular al lui, care in
# Odoo 18 e **inline** (Stripe Elements, JS in pagina), nu un simplu redirect - deci nu
# poate fi reprodus nativ si nu are ce cauta in aplicatie. Acolo raspunsul trimite
# aplicatia in WebView, pe chiar pagina de plata a magazinului, cu aceeasi sesiune.
#
# Lista se poate schimba fara release de aplicatie prin parametrul de sistem
# `uportho_app.offline_payment_codes` (coduri separate prin virgula) - de exemplu daca
# Terrabit adauga alt provider offline.
OFFLINE_CODES_PARAM = 'uportho_app.offline_payment_codes'
DEFAULT_OFFLINE_CODES = ('custom', 'on_delivery')

# Unde ajunge browserul (WebView-ul) dupa o plata online dusa pana la capat. Aplicatia
# inchide WebView-ul cand URL-ul curent incepe cu asta si cere apoi starea comenzii.
PAYMENT_PAGE_PATH = '/shop/payment'
PAYMENT_RETURN_PREFIX = '/shop/confirmation'


def _offline_codes():
    raw = request.env['ir.config_parameter'].sudo().get_param(OFFLINE_CODES_PARAM)
    if not raw:
        return set(DEFAULT_OFFLINE_CODES)
    codes = {part.strip() for part in raw.split(',') if part.strip()}
    return codes or set(DEFAULT_OFFLINE_CODES)


def _require_cart():
    """Cosul curent, sau 409 daca nu exista / nu mai e modificabil. Checkout-ul nu are
    ce face fara cos, iar un cos deja confirmat (platit intre timp din browser) nu e o
    eroare interna, ci un conflict de stare pe care aplicatia trebuie sa-l poata arata."""
    order = _cart_order()
    if not order or not order.order_line:
        raise ApiError(409, 'empty_cart', 'Cosul este gol.')
    if order.state != 'draft':
        raise ApiError(409, 'cart_not_editable',
                       'Comanda a fost deja trimisa. Reincarca cosul.')
    return order


def _carrier_rate(carrier, order):
    """Pretul de transport al unui curier pentru comanda curenta, cu taxele aplicate -
    aceeasi socoteala pe care o face magazinul in `website_sale.controllers.delivery.
    Delivery._get_rate`.

    Nu se cheama metoda lor direct pentru ca ea citeste `request.website`, atribut pe
    care rutele acestui modul nu il au si nu au voie sa-l primeasca (vezi gotcha 7 din
    CLAUDE.md: prezenta lui schimba lista de preturi a clientului). Website-ul rezolvat
    de modul spune acelasi lucru: cum se afiseaza taxele in magazin.

    Restul e neatins: `carrier.rate_shipment(order)` face calculul curierului (fix, pe
    reguli, sau prin API-ul lui), iar taxele produsului de transport trec prin pozitia
    fiscala a comenzii, exact ca pe site."""
    rate = carrier.rate_shipment(order)
    if not rate.get('success'):
        return rate
    taxes = carrier.product_id.taxes_id.filtered(lambda t: t.company_id == order.company_id)
    if taxes:
        taxes = order.fiscal_position_id.map_tax(taxes)
        computed = taxes.compute_all(
            rate['price'], currency=order.currency_id, quantity=1.0,
            product=carrier.product_id, partner=order.partner_shipping_id)
        # Mereu cu TVA, ca tot restul API-ului (`with_vat: True`): pretul aratat langa
        # curier trebuie sa fie chiar suma cu care creste totalul comenzii cand il alegi.
        rate['price'] = computed['total_included']
    return rate


def _address_purposes(partner):
    """(pentru facturare, pentru livrare) - dupa regula magazinului.

    Copiata din `WebsiteSale._prepare_checkout_page_values`: la facturare intra
    contactele de tip `invoice` si `other`, la livrare cele de tip `delivery` si
    `other`, iar partenerul principal al contului si cel al utilizatorului conectat
    intra in amandoua. Pe site adresele sunt doua liste separate; daca aplicatia le-ar
    imparti dupa alta regula, clientul ar vedea o adresa la livrare pe care magazinul
    n-o accepta acolo."""
    commercial = partner.commercial_partner_id
    is_main = partner == commercial or partner == request.env.user.partner_id
    return (
        is_main or partner.type in ('invoice', 'other'),
        is_main or partner.type in ('delivery', 'other'),
    )


def serialize_address(partner):
    """O adresa asa cum o arata aplicatia. `city_id` exista doar pe bazele cu modulul
    de orase al clientului (`deltatech_website_city`, care face orasul un camp legat,
    nu text liber); se citeste doar daca e acolo - pe baza locala campul nu exista si
    o citire oarba ar fi eroare.

    `for_billing` si `for_delivery` spun in care din cele doua liste ale magazinului
    intra adresa; o adresa poate fi in amandoua."""
    partner = partner.sudo()
    for_billing, for_delivery = _address_purposes(partner)
    city = partner.city
    if 'city_id' in partner._fields and partner.city_id:
        city = partner.city_id.name
    return {
        'id': partner.id,
        'name': partner.name,
        'street': partner.street or None,
        'street2': partner.street2 or None,
        'city': city or None,
        'zip': partner.zip or None,
        'state': partner.state_id.name or None,
        'country': partner.country_id.name or None,
        'phone': partner.phone or None,
        'email': partner.email or None,
        'vat': partner.vat or None,
        'type': partner.type,
        'for_billing': for_billing,
        'for_delivery': for_delivery,
    }


def _available_addresses(order):
    """Adresele pe care contul le poate folosi la livrare si la facturare.

    O singura sursa, `address._account_addresses()`, folosita si de `/addresses` si de
    checkout - altfel ecranul de cont si cel de checkout ar putea arata liste diferite
    aceluiasi client. Importul se face aici, nu la inceput de fisier: `address.py` il
    importa pe acesta pentru `serialize_address`."""
    from .address import _account_addresses
    return _account_addresses()


def serialize_delivery_method(carrier, order, rate=None):
    """Un curier, cu pretul lui pentru comanda curenta. Un curier al carui tarif nu se
    poate calcula (API-ul curierului nu raspunde, adresa nu e acoperita) ramane in lista
    cu `available: false` si motivul - exact ca pe site, unde randul apare dar nu se
    poate alege; scos din lista, clientul n-ar afla niciodata de ce lipseste."""
    rate = rate if rate is not None else _carrier_rate(carrier, order)
    success = bool(rate.get('success'))
    price = rate.get('price', 0.0) if success else 0.0
    return {
        'id': carrier.id,
        'name': carrier.name,
        'description': carrier.website_description or None,
        'price': serialize_price(price, None, order.currency_id),
        'free': success and not price,
        'available': success,
        'error': None if success else (rate.get('error_message') or None),
        'logo_url': (f'{API_PREFIX}/delivery-methods/{carrier.id}/logo'
                     if 'logo' in carrier._fields and carrier.logo else None),
    }


def _payment_options(order):
    """Metodele de plata pe care le-ar arata magazinul pentru aceasta comanda, cerute
    pe exact acelasi drum ca pagina de plata (`sale.controllers.portal.
    CustomerPortal._get_payment_values`): intai providerii compatibili, apoi metodele
    compatibile cu ei.

    Prin `_get_compatible_providers` trec si regulile clientului din
    `deltatech_website_delivery_and_payment`: providerii permisi de curierul ales
    (`acquirer_allowed_ids`), plafonul de valoare al providerului (`value_limit`) si
    restrictiile pe etichete de partener. Rescrise aici, o schimbare facuta de ei in
    Odoo n-ar ajunge niciodata in aplicatie."""
    partner = order.partner_invoice_id.sudo() or request.env.user.partner_id
    amount = order.amount_total - order.amount_paid
    providers = request.env['payment.provider'].sudo()._get_compatible_providers(
        order.company_id.id, partner.id, amount,
        currency_id=order.currency_id.id, sale_order_id=order.id,
        website_id=_current_website().id)
    methods = request.env['payment.method'].sudo()._get_compatible_payment_methods(
        providers.ids, partner.id,
        currency_id=order.currency_id.id, sale_order_id=order.id)

    offline = _offline_codes()
    tokens = request.env['payment.token'].sudo()._get_available_tokens(
        providers.ids, partner.id)

    options = []
    # Cardurile deja salvate vin primele: pe site clientul plateste cu ele dintr-o
    # apasare, fara sa mai treaca prin formularul de card. Pe uportho sunt peste o mie
    # de astfel de carduri si zeci de plati pe luna facute asa.
    for token in tokens:
        provider = token.provider_id
        if provider not in providers:
            continue
        options.append({
            'payment_method_id': token.payment_method_id.id,
            'provider_id': provider.id,
            'token_id': token.id,
            'name': token.display_name,
            'provider_name': provider.name,
            'code': provider.code,
            'kind': 'token',
            'instructions': [],
            'is_test': provider.state == 'test',
        })

    for method in methods:
        provider = method.provider_ids.filtered(lambda p: p in providers)[:1]
        if not provider:
            continue
        is_offline = provider.code in offline
        options.append({
            'payment_method_id': method.id,
            'provider_id': provider.id,
            'token_id': None,
            'name': method.name,
            'provider_name': provider.name,
            'code': provider.code,
            'kind': 'offline' if is_offline else 'webview',
            # Textul pe care magazinul il arata inainte de plata (datele contului
            # bancar la transfer, conditiile de ramburs). Vine din configurarea
            # providerului, nu din codul aplicatiei.
            #
            # Trece prin acelasi convertor de HTML ca descrierile de produs: aplicatia
            # nu are motor HTML, iar `pending_msg` e un camp HTML editat in Odoo -
            # trimis ca atare, s-ar fi vazut cu tot cu etichete.
            'instructions': _uportho_html_blocks(provider.pending_msg),
            'is_test': provider.state == 'test',
        })
    return options


def serialize_checkout(order):
    addresses = _available_addresses(order)
    methods = order._get_delivery_methods()
    return {
        'order_id': order.id,
        'cart': serialize_cart(order),
        'addresses': {
            'delivery_id': order.partner_shipping_id.id or None,
            'invoice_id': order.partner_invoice_id.id or None,
            'available': [serialize_address(p) for p in addresses],
        },
        'delivery_methods': [serialize_delivery_method(c, order) for c in methods],
        'selected_delivery_method_id': order.carrier_id.id or None,
        # Comanda de servicii (fara produse de livrat) nu cere curier - pe site pasul
        # de livrare lipseste cu totul atunci.
        'delivery_required': order._has_deliverable_products(),
        'payment_options': _payment_options(order),
        'blockers': _blockers(order),
    }


def _blockers(order):
    """De ce nu se poate plati inca, in aceeasi ordine in care blocheaza si site-ul.
    Lista goala inseamna ca `POST /checkout/confirm` are sanse sa treaca."""
    blockers = []
    if not order.partner_shipping_id:
        blockers.append({'code': 'no_delivery_address', 'message': 'Alege o adresa de livrare.'})
    if order._has_deliverable_products():
        if not order._get_delivery_methods():
            blockers.append({
                'code': 'no_delivery_method',
                'message': 'Nu exista metoda de livrare pentru aceasta adresa. Contacteaza-ne.'})
        elif not order.carrier_id:
            blockers.append({'code': 'no_carrier_selected', 'message': 'Alege metoda de livrare.'})
    # Fara nicio metoda de plata ecranul ar arata o sectiune goala si clientul n-ar
    # sti de ce nu poate continua. Se intampla cand magazinul n-are niciun provider
    # activ (pe staging Odoo ii dezactiveaza pe toti) sau cand regulile clientului nu
    # lasa niciunul pentru curierul ales.
    if not _payment_options(order):
        blockers.append({
            'code': 'no_payment_method',
            'message': 'Nu exista metoda de plata disponibila pentru aceasta comanda. '
                       'Contacteaza-ne.'})
    return blockers


def _pay_with_token(order, option):
    """Plata cu un card deja salvat, exact ca pe site.

    Nicio informatie de card nu trece prin aplicatie: tokenul e o referinta pastrata de
    provider, iar cererea de plata o face serverul
    (`payment.transaction._send_payment_request`) - acelasi apel pe care il face si
    `payment.controllers.portal._create_transaction` cu `flow='token'`.

    Rezultatul nu e presupus: se citeste starea reala a tranzactiei dupa apel. Un card
    care cere autentificare 3-D Secure esueaza la o plata facuta fara clientul in fata
    ecranului, iar atunci raspunsul spune asta si aplicatia trimite clientul catre
    pagina de plata a magazinului, unde poate confirma."""
    token = request.env['payment.token'].sudo().browse(option['token_id'])
    partner = order.partner_invoice_id.sudo()
    # Aceeasi verificare pe care o face si portalul: un token al altui client nu are ce
    # cauta pe comanda asta, oricat de valid ar fi id-ul trimis.
    if partner.commercial_partner_id != token.partner_id.commercial_partner_id:
        raise ApiError(403, 'forbidden', 'Cardul nu apartine acestui cont.')

    amount = order.amount_total - order.amount_paid
    reference = request.env['payment.transaction']._compute_reference(
        token.provider_id.code, sale_order_ids=[(6, 0, order.ids)])
    tx = request.env['payment.transaction'].sudo().create({
        'provider_id': token.provider_id.id,
        'payment_method_id': token.payment_method_id.id,
        'token_id': token.id,
        'reference': reference,
        'amount': amount,
        'currency_id': order.currency_id.id,
        'partner_id': partner.id,
        'operation': 'online_token',
        'sale_order_ids': [(6, 0, order.ids)],
    })
    tx._send_payment_request()
    tx._post_process()
    order.invalidate_recordset()

    paid = tx.state in ('authorized', 'done', 'pending')
    return {
        'order_id': order.id,
        'order_ref': order.name,
        'payment': {
            'kind': 'token' if paid else 'webview',
            'method': option['name'],
            'instructions': [],
            'reference': tx.reference,
            'state': tx.state,
            'message': tx.state_message or None,
            # Cand plata cu cardul salvat nu trece (3-D Secure, fonduri, card expirat),
            # clientul trebuie sa poata incerca in pagina magazinului.
            'url': None if paid else PAYMENT_PAGE_PATH,
            'return_url_prefix': None if paid else PAYMENT_RETURN_PREFIX,
        },
    }


def _own_partner(partner_id):
    """Un id de partener validat contra contului: doar partenerul comercial al
    clientului si adresele lui. Fara verificare, un id strain ar muta livrarea unei
    comenzi la adresa altcuiva - de aceea nu se cauta partenerul direct dupa id."""
    order = _cart_order()
    allowed = _available_addresses(order) if order else request.env['res.partner']
    partner = allowed.filtered(lambda p: p.id == partner_id)
    if not partner:
        raise ApiError(422, 'validation_error', 'Adresa nu apartine acestui cont.')
    return partner


class AppCheckout(http.Controller):
    @app_route('/checkout', methods=['GET'])
    def checkout(self, **kw):
        return json_ok(serialize_checkout(_require_cart()))

    @app_route('/checkout/address', methods=['POST'])
    def checkout_address(self, **kw):
        """Alege adresa de livrare si/sau de facturare dintre adresele contului.

        Scrierea se face prin `sale.order._update_address`, metoda magazinului: ea nu
        doar seteaza campul, ci declanseaza si recalcularea pozitiei fiscale si a
        taxelor, plus stergerea liniei de transport daca noul judet schimba tariful.
        Un `write` direct ar lasa comanda cu TVA calculat pentru vechea adresa.

        Adrese NOI nu se creeaza de aici: pe instanta reala formularul de adresa e
        modificat de client (`terrabit_website_invoice_address`, `deltatech_website_city`
        - CUI validat, oras ca lista, nu text). Aplicatia alege dintre adresele
        existente ale contului; adaugarea unei adrese noi ramane in browser, ca sa nu
        avem doua validari care se pot contrazice."""
        body = read_json_body()
        order = _require_cart()

        updates = []
        for key, field in (('delivery_id', 'partner_shipping_id'), ('invoice_id', 'partner_invoice_id')):
            raw = body.get(key)
            if raw is None:
                continue
            if isinstance(raw, bool) or not isinstance(raw, int):
                raise ApiError(422, 'validation_error', f'{key} trebuie sa fie numeric.')
            updates.append((field, _own_partner(raw)))
        if not updates:
            raise ApiError(422, 'validation_error',
                           'Trimite delivery_id si/sau invoice_id.')
        for field, partner in updates:
            order._update_address(partner.id, [field])

        # Curierul ales poate sa nu mai fie valabil pentru noua adresa (alt judet, alt
        # tarif): magazinul il scoate atunci, ca sa nu se plateasca un transport care
        # nu se mai poate face. Acelasi lucru aici.
        if order.carrier_id and order.carrier_id not in order._get_delivery_methods():
            order._remove_delivery_line()
            order.carrier_id = False
        return json_ok(serialize_checkout(order))

    @app_route('/checkout/delivery', methods=['POST'])
    def checkout_delivery(self, **kw):
        """Alege curierul. `sale.order._set_delivery_method` e metoda magazinului: ea
        sterge linia de transport veche, cere tariful si adauga linia noua. Totalurile
        din raspuns sunt deja recalculate."""
        body = read_json_body()
        raw = body.get('carrier_id')
        if isinstance(raw, bool) or not isinstance(raw, int):
            raise ApiError(422, 'validation_error', 'carrier_id trebuie sa fie numeric.')

        order = _require_cart()
        carrier = order._get_delivery_methods().filtered(lambda c: c.id == raw)
        if not carrier:
            raise ApiError(422, 'validation_error',
                           'Metoda de livrare nu e disponibila pentru aceasta adresa.')
        # O plata deja pornita inseamna ca suma e in curs de autorizare: magazinul
        # refuza atunci schimbarea transportului, pentru ca totalul s-ar schimba sub
        # plata. Aceeasi regula, cu 409.
        if any(tx.state not in ('draft', 'cancel', 'error') for tx in order.transaction_ids):
            raise ApiError(409, 'payment_in_progress',
                           'Exista deja o plata pornita pentru aceasta comanda.')

        rate = _carrier_rate(carrier, order)
        if not rate.get('success'):
            raise ApiError(422, 'delivery_unavailable',
                           rate.get('error_message') or 'Tariful de livrare nu s-a putut calcula.')
        # Tariful calculat mai sus e cel de AFISAT (cu TVA). Nu se da mai departe lui
        # `_set_delivery_method`: acolo pretul devine `price_unit` pe linia de transport,
        # peste care Odoo aplica din nou taxa produsului - transportul ar fi facturat cu
        # TVA de doua ori. Magazinul face la fel: `shop_set_delivery_method` cheama
        # `_set_delivery_method(dm)` fara tarif si lasa metoda sa-l ceara singura.
        order._set_delivery_method(carrier)
        return json_ok(serialize_checkout(order))

    @app_route('/checkout/confirm', methods=['POST'])
    def checkout_confirm(self, **kw):
        """Trimite comanda.

        Doua raspunsuri, dupa cum e providerul ales:

        - `kind: "offline"` (transfer bancar, plata la livrare) - tranzactia se creeaza
          si se marcheaza aici, prin acelasi drum ca pe site
          (`_handle_notification_data`), deci trec si override-urile clientului (COD
          scoate oferta din ciorna, transferul pune referinta de plata pe comanda).
          Raspunsul aduce referinta comenzii si instructiunile providerului.

        - `kind: "webview"` (card) - aplicatia deschide pagina de plata a magazinului
          in WebView, cu aceeasi sesiune. In Odoo 18 formularul de card al providerului
          (Stripe) e **inline**, adica JavaScript in pagina, nu o simpla redirectionare
          catre o adresa externa: nu exista URL de plata care sa poata fi deschis
          direct, si nici nu vrem sa treaca date de card prin aplicatie. Pagina
          magazinului e chiar formularul real, deci raman valabile toate regulile lor.

        Verificarile dinainte sunt ale magazinului: `_check_cart_is_ready_to_be_paid`
        (curier ales si compatibil cu adresa) si compararea sumei cu totalul comenzii."""
        body = read_json_body()
        order = _require_cart()

        try:
            order._check_cart_is_ready_to_be_paid()
        except ValidationError as error:
            raise ApiError(409, 'cart_not_ready', str(error.args[0]) if error.args else str(error))

        method_id = body.get('payment_method_id')
        provider_id = body.get('provider_id')
        token_id = body.get('token_id')
        if isinstance(method_id, bool) or not isinstance(method_id, int):
            raise ApiError(422, 'validation_error', 'payment_method_id trebuie sa fie numeric.')
        if isinstance(provider_id, bool) or not isinstance(provider_id, int):
            raise ApiError(422, 'validation_error', 'provider_id trebuie sa fie numeric.')
        if token_id is not None and (isinstance(token_id, bool) or not isinstance(token_id, int)):
            raise ApiError(422, 'validation_error', 'token_id trebuie sa fie numeric.')

        # Optiunea ceruta trebuie sa fie una din cele pe care magazinul chiar le ofera
        # pentru ACEASTA comanda - inclusiv cardul salvat, care se identifica si prin
        # `token_id`, nu doar prin metoda si provider.
        options = {
            (o['payment_method_id'], o['provider_id'], o['token_id']): o
            for o in _payment_options(order)
        }
        option = options.get((method_id, provider_id, token_id))
        if not option:
            raise ApiError(422, 'validation_error',
                           'Metoda de plata nu e disponibila pentru aceasta comanda.')

        if option['kind'] == 'token':
            return json_ok(_pay_with_token(order, option))

        if option['kind'] == 'webview':
            return json_ok({
                'order_id': order.id,
                'order_ref': order.name,
                'payment': {
                    'kind': 'webview',
                    'method': option['name'],
                    'instructions': [],
                    'reference': None,
                    'state': None,
                    'message': None,
                    'url': PAYMENT_PAGE_PATH,
                    'return_url_prefix': PAYMENT_RETURN_PREFIX,
                },
            })

        provider = request.env['payment.provider'].sudo().browse(provider_id)
        amount = order.amount_total - order.amount_paid
        reference = request.env['payment.transaction']._compute_reference(
            provider.code, sale_order_ids=[(6, 0, order.ids)])
        request.env['payment.transaction'].sudo().create({
            'provider_id': provider.id,
            'payment_method_id': method_id,
            'reference': reference,
            'amount': amount,
            'currency_id': order.currency_id.id,
            'partner_id': order.partner_invoice_id.id,
            'operation': 'online_direct',
            'sale_order_ids': [(6, 0, order.ids)],
        })
        # Acelasi apel pe care il face si ruta de proces a providerului offline
        # (`/payment/custom/process`, `/payment/on_delivery/payment`): trece prin
        # `_process_notification_data` al modulului lor, care decide starea (in asteptare
        # sau autorizata) si duce mai departe comanda.
        tx = request.env['payment.transaction'].sudo()._handle_notification_data(
            provider.code, {'reference': reference})
        # Post-procesarea nu vine de la sine: pe site o declanseaza pagina `/payment/status`,
        # care intreaba serverul pana cand tranzactia e prelucrata (altfel o face tarziu
        # cron-ul `payment.cron_post_process_payment_tx`). Aplicatia nu are acea pagina,
        # deci apelam noi acelasi lucru - fara el comanda ar ramane ciorna, iar clientul
        # ar vedea "trimis" in aplicatie si nimeni n-ar vedea comanda in Odoo.
        # `is_post_processed` face apelul idempotent.
        tx.sudo()._post_process()

        order.invalidate_recordset()
        return json_ok({
            'order_id': order.id,
            'order_ref': order.name,
            'payment': {
                'kind': 'offline',
                'method': option['name'],
                'instructions': option['instructions'],
                'reference': tx.reference,
                'state': tx.state,
                'message': None,
                'url': None,
                'return_url_prefix': None,
            },
        })

    @app_route('/delivery-methods/<int:carrier_id>/logo', methods=['GET'])
    def delivery_logo(self, carrier_id, **kw):
        """Sigla curierului (`logo`, camp adaugat de modulul clientului). Ruta e
        autentificata ca toate rutele de imagine ale modulului."""
        carrier = request.env['delivery.carrier'].sudo().browse(carrier_id)
        if 'logo' not in carrier._fields:
            raise ApiError(404, 'not_found', 'Resursa nu exista.')
        return _image_response(carrier, 'logo')
