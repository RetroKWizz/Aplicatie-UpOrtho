from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract


@tagged('post_install', '-at_install')
class TestControllersCart(AppHttpCase):
    """Cosul aplicatiei e chiar cosul magazinului (aceeasi sesiune, acelasi
    `sale.order`), deci testele verifica efectul in ORM, nu doar forma raspunsului."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.website = cls.env['website'].search([], limit=1)
        cls.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(cls.website.id))
        cls.product = cls.env['product.template'].create({
            'name': 'Bracket cos test',
            'is_published': True,
            'list_price': 100.0,
            'sale_ok': True,
        })
        cls.variant = cls.product.product_variant_id

    def _cart(self):
        return self.api_get('/cart').json()

    def _add(self, qty=1, variant=None):
        return self.api_post('/cart/lines', {
            'lines': [{'variant_id': (variant or self.variant).id, 'add_qty': qty}]})

    def test_cart_requires_login(self):
        self.assertEqual(self.api_get('/cart').status_code, 401)

    def test_cart_lines_requires_app_header(self):
        self.api_login()
        self.assertEqual(self.api_post('/cart/lines', {'lines': []}, with_header=False).status_code, 403)

    def test_empty_cart_is_not_an_error(self):
        """Un cont fara cos primeste aceeasi forma, goala - aplicatia are un singur
        drum de randare, nu unul pentru 200 si altul pentru 404."""
        self.api_login()
        response = self.api_get('/cart')
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertIsNone(body['order_id'])
        self.assertEqual(body['lines'], [])
        self.assertEqual(body['quantity'], 0)
        self.assertEqual(body['amounts']['total']['amount'], 0.0)

    def test_adding_a_product_creates_the_shop_cart(self):
        self.api_login()
        body = self._add(2).json()
        self.assertEqual(len(body['lines']), 1)
        line = body['lines'][0]
        self.assertEqual(line['variant_id'], self.variant.id)
        self.assertEqual(line['product_id'], self.product.id)
        self.assertEqual(line['quantity'], 2)
        self.assertEqual(body['quantity'], 2)

        order = self.env['sale.order'].search([('id', '=', body['order_id'])])
        self.assertEqual(order.partner_id, self.portal_user.partner_id)
        self.assertEqual(order.order_line.product_uom_qty, 2)

    def test_add_qty_accumulates_and_set_qty_replaces(self):
        self.api_login()
        self._add(2)
        self.assertEqual(self._add(3).json()['quantity'], 5)
        body = self.api_post('/cart/lines', {
            'lines': [{'variant_id': self.variant.id, 'set_qty': 1}]}).json()
        self.assertEqual(body['quantity'], 1)

    def test_set_qty_zero_removes_the_line(self):
        """`set_qty = 0` chiar sterge linia. Capcana din `_cart_update`: trimis
        impreuna cu `add_qty = 0` in loc de None, el pastreaza cantitatea existenta si
        stergerea nu se intampla - fara nicio eroare."""
        self.api_login()
        self._add(2)
        body = self.api_post('/cart/lines', {
            'lines': [{'variant_id': self.variant.id, 'set_qty': 0}]}).json()
        self.assertEqual(body['lines'], [])
        self.assertEqual(body['quantity'], 0)

    def test_amounts_come_formatted_from_the_server(self):
        """Aplicatia nu are voie sa inmulteasca pret x cantitate (CLAUDE.md): totalul
        si subtotalul liniei vin gata calculate si gata formatate."""
        self.api_login()
        body = self._add(3).json()
        line = body['lines'][0]
        self.assertEqual(line['subtotal']['amount'], line['unit_price']['amount'] * 3)
        self.assertTrue(line['subtotal']['formatted'])
        self.assertEqual(body['amounts']['total']['amount'], line['subtotal']['amount'])
        self.assertTrue(body['amounts']['total']['formatted'])

    def test_several_variants_in_one_request(self):
        """Tabelul de variante din pagina de produs trimite toate randurile deodata:
        o singura cerere, o singura recalculare de preturi, un singur raspuns."""
        self.api_login()
        product = self.env['product.template'].create({
            'name': 'Produs cu variante cos test', 'is_published': True, 'list_price': 50.0})
        attribute = self.env['product.attribute'].create({
            'name': 'Dinte cos test',
            'value_ids': [(0, 0, {'name': '11'}), (0, 0, {'name': '12'})]})
        self.env['product.template.attribute.line'].create({
            'product_tmpl_id': product.id,
            'attribute_id': attribute.id,
            'value_ids': [(6, 0, attribute.value_ids.ids)]})
        variants = product.product_variant_ids
        self.assertEqual(len(variants), 2)

        body = self.api_post('/cart/lines', {'lines': [
            {'variant_id': variants[0].id, 'add_qty': 2},
            {'variant_id': variants[1].id, 'add_qty': 3},
        ]}).json()
        self.assertEqual(body['quantity'], 5)
        self.assertEqual({l['variant_id'] for l in body['lines']}, set(variants.ids))

    def test_variant_name_tells_the_rows_apart(self):
        self.api_login()
        product = self.env['product.template'].create({
            'name': 'Produs etichete variante', 'is_published': True, 'list_price': 10.0})
        attribute = self.env['product.attribute'].create({
            'name': 'Marime cos test', 'value_ids': [(0, 0, {'name': 'S'}), (0, 0, {'name': 'M'})]})
        self.env['product.template.attribute.line'].create({
            'product_tmpl_id': product.id, 'attribute_id': attribute.id,
            'value_ids': [(6, 0, attribute.value_ids.ids)]})
        variant = product.product_variant_ids[0]
        body = self.api_post('/cart/lines', {
            'lines': [{'variant_id': variant.id, 'add_qty': 1}]}).json()
        line = next(l for l in body['lines'] if l['variant_id'] == variant.id)
        self.assertIn('Marime cos test: ', line['variant_name'])

    def test_bad_requests_are_422_never_500(self):
        self.api_login()
        cases = [
            {'lines': []},
            {'lines': 'nu e lista'},
            {'lines': [{'add_qty': 1}]},
            {'lines': [{'variant_id': self.variant.id}]},
            {'lines': [{'variant_id': self.variant.id, 'add_qty': 1, 'set_qty': 1}]},
            {'lines': [{'variant_id': self.variant.id, 'add_qty': True}]},
            {'lines': [{'variant_id': self.variant.id, 'set_qty': -1}]},
            {'lines': [{'variant_id': True, 'add_qty': 1}]},
        ]
        for body in cases:
            with self.subTest(body=body):
                response = self.api_post('/cart/lines', body)
                self.assertEqual(response.status_code, 422)
                self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_too_many_lines_is_refused(self):
        self.api_login()
        lines = [{'variant_id': self.variant.id, 'add_qty': 1} for _ in range(61)]
        self.assertEqual(self.api_post('/cart/lines', {'lines': lines}).status_code, 422)

    def test_cart_shape_matches_contract(self):
        self.api_login()
        body = self._add(1).json()
        contract = load_contract('cart.json')
        self.assertEqual(set(body) - {'warnings'}, set(contract))
        self.assertEqual(set(body['amounts']), set(contract['amounts']))
        self.assertEqual(set(body['lines'][0]), set(contract['lines'][0]))
        self.assertEqual(set(body['lines'][0]['unit_price']), set(contract['lines'][0]['unit_price']))

    def test_the_cart_survives_a_new_request(self):
        """Cosul e tinut de Odoo in sesiune, nu de aplicatie: a doua cerere il regaseste."""
        self.api_login()
        order_id = self._add(2).json()['order_id']
        self.assertEqual(self._cart()['order_id'], order_id)
