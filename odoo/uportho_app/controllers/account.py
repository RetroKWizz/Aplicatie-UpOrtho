import logging

from odoo import fields, http
from odoo.http import request

from ..pricing import serialize_price
from .base import API_PREFIX, ApiError, app_route, json_ok
from .cart import _delivery_amount, serialize_cart_line
from .checkout import serialize_address

_logger = logging.getLogger(__name__)

DEFAULT_LIMIT = 20
MAX_LIMIT = 100

# Starile comenzii, in cuvintele clientului. Odoo tine 'draft'/'sent'/'sale'/'cancel';
# in magazin o comanda trimisa dar neconfirmata inca ("sent") e o comanda in asteptare,
# nu o "oferta". Traducerea sta aici, nu in aplicatie: cand se schimba vocabularul, se
# schimba pe server, fara release in store.
ORDER_STATE_LABELS = {
    'draft': 'In pregatire',
    'sent': 'In asteptare',
    'sale': 'Confirmata',
    'cancel': 'Anulata',
}
INVOICE_STATE_LABELS = {
    'draft': 'Ciorna',
    'posted': 'Emisa',
    'cancel': 'Anulata',
}
INVOICE_PAYMENT_LABELS = {
    'not_paid': 'Neplatita',
    'in_payment': 'In curs de plata',
    'paid': 'Platita',
    'partial': 'Platita partial',
    'reversed': 'Stornata',
    'blocked': 'Blocata',
}


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


def _parse_offset(raw):
    if raw in (None, ''):
        return 0
    try:
        value = int(raw)
    except (TypeError, ValueError):
        raise ApiError(422, 'validation_error', 'offset trebuie sa fie numeric.')
    return value if value > 0 else 0


def _order_domain():
    """Comenzile contului: cele ale partenerului comercial, cosurile inca nefinalizate
    excluse.

    Domeniul e pe `partner_id` din arborele clientului, nu pe utilizator: intr-o clinica
    mai multi utilizatori impart acelasi client si trebuie sa vada aceleasi comenzi -
    exact ce arata si portalul. Regulile de acces Odoo raman peste: ce nu are voie sa
    citeasca utilizatorul, ORM-ul refuza oricum.

    `state != 'draft'` scoate cosul in lucru: el are ecranul lui si nu e o comanda."""
    commercial = request.env.user.partner_id.commercial_partner_id
    partners = commercial | commercial.child_ids
    return [('partner_id', 'in', partners.ids), ('state', '!=', 'draft')]


def _invoice_domain():
    commercial = request.env.user.partner_id.commercial_partner_id
    partners = commercial | commercial.child_ids
    return [
        ('partner_id', 'in', partners.ids),
        ('move_type', 'in', ('out_invoice', 'out_refund')),
        ('state', '=', 'posted'),
    ]


def serialize_order_summary(order):
    currency = order.currency_id
    return {
        'id': order.id,
        'name': order.name,
        'date': fields.Date.to_string(fields.Datetime.context_timestamp(order, order.date_order).date())
                if order.date_order else None,
        'state': order.state,
        'state_label': ORDER_STATE_LABELS.get(order.state, order.state),
        'total': serialize_price(order.amount_total, None, currency),
        'line_count': len(order.order_line.filtered(lambda l: l._show_in_cart())),
        'delivery_method': order.carrier_id.name or None,
        'invoice_count': len(order.invoice_ids.filtered(lambda m: m.state == 'posted')),
    }


def serialize_order_detail(order):
    currency = order.currency_id
    lines = order.order_line.filtered(lambda l: l._show_in_cart())
    data = serialize_order_summary(order)
    data.update({
        'lines': [serialize_cart_line(line, currency) for line in lines],
        'amounts': {
            'untaxed': serialize_price(order.amount_untaxed, None, currency),
            'tax': serialize_price(order.amount_tax, None, currency),
            'delivery': serialize_price(_delivery_amount(order), None, currency),
            'total': serialize_price(order.amount_total, None, currency),
        },
        'delivery_address': serialize_address(order.partner_shipping_id) if order.partner_shipping_id else None,
        'invoice_address': serialize_address(order.partner_invoice_id) if order.partner_invoice_id else None,
        'client_order_ref': order.client_order_ref or None,
        'invoices': [serialize_invoice(move) for move in
                     order.invoice_ids.filtered(lambda m: m.state == 'posted')],
        'payments': [
            {
                'reference': tx.reference,
                'provider': tx.provider_id.name,
                'state': tx.state,
                'amount': serialize_price(tx.amount, None, tx.currency_id),
            }
            for tx in order.transaction_ids.sudo()
        ],
    })
    return data


def serialize_invoice(move):
    """O factura. `amount_residual` e cat a mai ramas de plata - suma pe care o cere si
    portalul; formatata pe server, ca orice alta suma."""
    currency = move.currency_id
    return {
        'id': move.id,
        'name': move.name,
        'date': fields.Date.to_string(move.invoice_date) if move.invoice_date else None,
        'due_date': fields.Date.to_string(move.invoice_date_due) if move.invoice_date_due else None,
        'state': move.state,
        'state_label': INVOICE_STATE_LABELS.get(move.state, move.state),
        'payment_state': move.payment_state,
        'payment_state_label': INVOICE_PAYMENT_LABELS.get(move.payment_state, move.payment_state),
        'total': serialize_price(move.amount_total, None, currency),
        'residual': serialize_price(move.amount_residual, None, currency),
        'pdf_url': f'{API_PREFIX}/invoices/{move.id}/pdf',
    }


class AppAccount(http.Controller):
    @app_route('/orders', methods=['GET'])
    def orders(self, **kw):
        limit = _parse_limit(kw.get('limit'))
        offset = _parse_offset(kw.get('offset'))
        Order = request.env['sale.order']
        domain = _order_domain()
        total = Order.search_count(domain)
        orders = Order.search(domain, limit=limit, offset=offset, order='date_order desc, id desc')
        return json_ok({
            'orders': [serialize_order_summary(o) for o in orders.sudo()],
            'total': total,
            'offset': offset,
            'limit': limit,
        })

    @app_route('/orders/<int:order_id>', methods=['GET'])
    def order_detail(self, order_id, **kw):
        order = request.env['sale.order'].search(_order_domain() + [('id', '=', order_id)], limit=1)
        if not order:
            raise ApiError(404, 'not_found', 'Comanda nu exista.')
        # Cautarea de mai sus s-a facut CU utilizatorul, deci apartenenta e deja
        # dovedita: domeniul cere partenerul comercial al contului, iar regulile de
        # acces Odoo au filtrat la randul lor. Serializarea merge apoi in `sudo`
        # pentru ca detaliul citeste si campuri la care un utilizator portal nu are
        # acces (`transaction_ids` - `payment.transaction`), iar un 403 acolo ar
        # inseamna ca proprietarul comenzii nu-si poate deschide propria comanda.
        return json_ok(serialize_order_detail(order.sudo()))

    @app_route('/invoices', methods=['GET'])
    def invoices(self, **kw):
        limit = _parse_limit(kw.get('limit'))
        offset = _parse_offset(kw.get('offset'))
        Move = request.env['account.move']
        domain = _invoice_domain()
        total = Move.search_count(domain)
        moves = Move.search(domain, limit=limit, offset=offset, order='invoice_date desc, id desc')
        return json_ok({
            'invoices': [serialize_invoice(m) for m in moves.sudo()],
            'total': total,
            'offset': offset,
            'limit': limit,
        })

    @app_route('/invoices/<int:invoice_id>/pdf', methods=['GET'])
    def invoice_pdf(self, invoice_id, **kw):
        """Factura in PDF, servita de o ruta a modulului, nu de `/report/pdf/...`.

        Acelasi motiv ca la documentele de produs: aplicatia descarca prin transportul
        ei (cookie de sesiune + header-ul de aplicatie), iar apoi deschide fisierul cu
        vizualizatorul telefonului. Un URL de raport deschis in browserul telefonului
        n-ar avea sesiunea aplicatiei si ar da "Not Found".

        Raportul e chiar cel al Odoo (`account.account_invoices`), deci PDF-ul e
        identic cu cel din portal - inclusiv antetul si eventualele personalizari ale
        clientului."""
        move = request.env['account.move'].search(_invoice_domain() + [('id', '=', invoice_id)], limit=1)
        if not move:
            raise ApiError(404, 'not_found', 'Factura nu exista.')
        pdf, _content_type = request.env['ir.actions.report'].sudo()._render_qweb_pdf(
            'account.account_invoices', res_ids=move.ids)
        filename = (move.name or 'factura').replace('/', '-')
        return request.make_response(pdf, headers=[
            ('Content-Type', 'application/pdf'),
            ('Content-Length', len(pdf)),
            ('Content-Disposition', f'attachment; filename="{filename}.pdf"'),
        ])

    @app_route('/addresses', methods=['GET'])
    def addresses(self, **kw):
        """Adresele contului. Aceeasi multime pe care o arata si checkout-ul; aici e
        doar pentru ecranul de cont, unde clientul isi vede datele de facturare."""
        commercial = request.env.user.partner_id.commercial_partner_id
        partners = commercial | commercial.child_ids.filtered(
            lambda p: p.type in ('delivery', 'invoice', 'other'))
        return json_ok([serialize_address(p) for p in partners])
