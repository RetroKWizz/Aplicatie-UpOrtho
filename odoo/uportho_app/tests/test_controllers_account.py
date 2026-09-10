from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract


@tagged('post_install', '-at_install')
class TestControllersAccount(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.partner = cls.portal_user.partner_id
        cls.product = cls.env['product.template'].create({
            'name': 'Produs comenzi test', 'is_published': True, 'list_price': 120.0})
        cls.order = cls.env['sale.order'].create({
            'partner_id': cls.partner.id,
            'order_line': [(0, 0, {
                'product_id': cls.product.product_variant_id.id,
                'product_uom_qty': 3,
            })],
        })
        cls.order.action_confirm()

        cls.stranger = cls.env['res.partner'].create({'name': 'Alt client comenzi test'})
        cls.stranger_order = cls.env['sale.order'].create({
            'partner_id': cls.stranger.id,
            'order_line': [(0, 0, {
                'product_id': cls.product.product_variant_id.id, 'product_uom_qty': 1})],
        })
        cls.stranger_order.action_confirm()

    def test_orders_require_login(self):
        self.assertEqual(self.api_get('/orders').status_code, 401)
        self.assertEqual(self.api_get('/invoices').status_code, 401)

    def test_orders_list_only_the_account_orders(self):
        self.api_login()
        body = self.api_get('/orders').json()
        ids = {o['id'] for o in body['orders']}
        self.assertIn(self.order.id, ids)
        self.assertNotIn(self.stranger_order.id, ids)
        self.assertGreaterEqual(body['total'], 1)

    def test_order_summary_has_formatted_money_and_a_label(self):
        self.api_login()
        summary = next(o for o in self.api_get('/orders').json()['orders']
                       if o['id'] == self.order.id)
        self.assertEqual(summary['name'], self.order.name)
        self.assertEqual(summary['state'], 'sale')
        self.assertEqual(summary['state_label'], 'Confirmata')
        self.assertTrue(summary['total']['formatted'])
        self.assertEqual(summary['line_count'], 1)

    def test_order_detail_has_lines_and_amounts(self):
        self.api_login()
        body = self.api_get(f'/orders/{self.order.id}').json()
        self.assertEqual(len(body['lines']), 1)
        self.assertEqual(body['lines'][0]['quantity'], 3)
        self.assertTrue(body['amounts']['total']['formatted'])
        self.assertEqual(body['amounts']['total']['amount'], self.order.amount_total)

    def test_order_shapes_match_contract(self):
        self.api_login()
        listing = self.api_get('/orders').json()
        contract_list = load_contract('orders.json')
        self.assertEqual(set(listing), set(contract_list))
        summary = next(o for o in listing['orders'] if o['id'] == self.order.id)
        self.assertEqual(set(summary), set(contract_list['orders'][0]))

        detail = self.api_get(f'/orders/{self.order.id}').json()
        contract_detail = load_contract('order.json')
        self.assertEqual(set(detail), set(contract_detail))
        self.assertEqual(set(detail['amounts']), set(contract_detail['amounts']))

    def test_another_customers_order_is_404_not_403(self):
        """Comanda altui client nu exista, din punctul de vedere al acestui cont: 404,
        nu 403. Un 403 ar confirma ca acel id exista."""
        self.api_login()
        self.assertEqual(self.api_get(f'/orders/{self.stranger_order.id}').status_code, 404)

    def test_a_cart_in_progress_is_not_an_order(self):
        """Cosul in lucru ramane ciorna si are ecranul lui; in lista de comenzi n-are ce
        cauta - altfel clientul ar vedea o "comanda" pe care inca o completeaza."""
        self.api_login()
        self.api_post('/cart/lines', {
            'lines': [{'variant_id': self.product.product_variant_id.id, 'add_qty': 1}]})
        cart_id = self.api_get('/cart').json()['order_id']
        ids = {o['id'] for o in self.api_get('/orders').json()['orders']}
        self.assertNotIn(cart_id, ids)

    def test_invoices_list_is_empty_but_well_formed(self):
        self.api_login()
        body = self.api_get('/invoices').json()
        self.assertIn('invoices', body)
        self.assertEqual(body['offset'], 0)
        self.assertIsInstance(body['total'], int)

    def test_invoice_of_another_customer_is_404(self):
        self.api_login()
        invoice = self.env['account.move'].create({
            'move_type': 'out_invoice',
            'partner_id': self.stranger.id,
            'invoice_line_ids': [(0, 0, {
                'product_id': self.product.product_variant_id.id,
                'quantity': 1, 'price_unit': 100.0})],
        })
        invoice.action_post()
        self.assertEqual(self.api_get(f'/invoices/{invoice.id}/pdf').status_code, 404)

    def test_own_invoice_is_listed_and_downloads_as_pdf(self):
        self.api_login()
        invoice = self.env['account.move'].create({
            'move_type': 'out_invoice',
            'partner_id': self.partner.id,
            'invoice_line_ids': [(0, 0, {
                'product_id': self.product.product_variant_id.id,
                'quantity': 2, 'price_unit': 120.0})],
        })
        invoice.action_post()

        listed = next(i for i in self.api_get('/invoices').json()['invoices']
                      if i['id'] == invoice.id)
        self.assertEqual(listed['name'], invoice.name)
        self.assertEqual(listed['state_label'], 'Emisa')
        self.assertTrue(listed['total']['formatted'])
        self.assertEqual(listed['pdf_url'], f'/api/app/v1/invoices/{invoice.id}/pdf')
        self.assertEqual(set(listed), set(load_contract('invoices.json')['invoices'][0]))

        response = self.api_get(listed['pdf_url'].replace('/api/app/v1', ''))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers['Content-Type'], 'application/pdf')
        self.assertTrue(response.content)
        # Continutul e chiar raportul Odoo. Nu se verifica semnatura `%PDF`: fara
        # wkhtmltopdf instalat in imagine (cazul containerului de dezvoltare), Odoo
        # intoarce HTML in loc de PDF si testul ar pica dintr-un motiv care n-are
        # legatura cu modulul. Pe odoo.sh wkhtmltopdf exista.

    def test_addresses_are_the_account_addresses(self):
        self.api_login()
        body = self.api_get('/addresses').json()
        ids = {a['id'] for a in body}
        self.assertEqual(set(body[0]), set(load_contract('addresses.json')[0]))
        self.assertIn(self.partner.id, ids)
        self.assertNotIn(self.stranger.id, ids)

    def test_paging_parameters_are_validated(self):
        self.api_login()
        self.assertEqual(self.api_get('/orders?limit=abc').status_code, 422)
        self.assertEqual(self.api_get('/orders?offset=abc').status_code, 422)
        body = self.api_get('/orders?limit=1000').json()
        self.assertEqual(body['limit'], 100)
