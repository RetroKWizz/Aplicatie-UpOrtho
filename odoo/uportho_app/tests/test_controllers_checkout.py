from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract


@tagged('post_install', '-at_install')
class TestControllersCheckout(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.website = cls.env['website'].search([], limit=1)
        cls.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(cls.website.id))

        cls.product = cls.env['product.template'].create({
            'name': 'Bracket checkout test', 'is_published': True, 'list_price': 200.0})
        cls.variant = cls.product.product_variant_id

        # Fiecare curier cu produsul LUI de transport: pe `delivery.carrier`,
        # `fixed_price` sta de fapt pe pretul produsului. Doua curiere cu acelasi produs
        # isi suprascriu tacit tariful unul altuia - s-a intamplat chiar aici, la
        # scrierea acestor teste.
        delivery_product = cls.env['product.template'].create({
            'name': 'Transport checkout test', 'type': 'service', 'list_price': 0.0})
        foreign_delivery_product = cls.env['product.template'].create({
            'name': 'Transport alt site test', 'type': 'service', 'list_price': 0.0})
        cls.carrier = cls.env['delivery.carrier'].create({
            'name': 'Curier checkout test',
            'delivery_type': 'fixed',
            'fixed_price': 25.0,
            'is_published': True,
            'website_id': cls.website.id,
            'product_id': delivery_product.product_variant_id.id,
        })
        # Al doilea curier, publicat pe ALT website: nu are voie sa apara in checkout-ul
        # aplicatiei. Fara `website_id` in contextul cererii, cautarea dupa
        # `website_published` intoarce tot ce e publicat oriunde - exact bug-ul pe care
        # il prinde acest fixture.
        cls.other_website = cls.env['website'].create({'name': 'Alt site checkout test'})
        cls.foreign_carrier = cls.env['delivery.carrier'].create({
            'name': 'Curier de pe alt site',
            'delivery_type': 'fixed', 'fixed_price': 9.0,
            'is_published': True, 'website_id': cls.other_website.id,
            'product_id': foreign_delivery_product.product_variant_id.id,
        })

        cls.provider = cls.env.ref('payment.payment_provider_transfer')
        cls.provider.write({
            'state': 'test',
            'is_published': True,
            'company_id': cls.env.company.id,
            'pending_msg': '<p>Plateste prin transfer bancar.</p>',
        })

    def _fill_cart(self, qty=1):
        self.api_post('/cart/lines', {'lines': [{'variant_id': self.variant.id, 'add_qty': qty}]})

    def _checkout(self):
        return self.api_get('/checkout')

    def _offered_method(self):
        self.api_login()
        self._fill_cart()
        return next(m for m in self._checkout().json()['delivery_methods']
                    if m['id'] == self.carrier.id)

    def test_checkout_requires_login(self):
        self.assertEqual(self.api_get('/checkout').status_code, 401)

    def test_checkout_without_cart_is_409_not_500(self):
        self.api_login()
        response = self._checkout()
        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['error']['code'], 'empty_cart')

    def test_delivery_methods_are_filtered_by_website(self):
        self.api_login()
        self._fill_cart()
        body = self._checkout().json()
        ids = {m['id'] for m in body['delivery_methods']}
        self.assertIn(self.carrier.id, ids)
        self.assertNotIn(self.foreign_carrier.id, ids)

    def test_delivery_price_comes_formatted(self):
        method = self._offered_method()
        self.assertGreaterEqual(method['price']['amount'], 25.0)
        self.assertTrue(method['price']['formatted'])
        self.assertTrue(method['available'])
        self.assertFalse(method['free'])

    def test_the_advertised_delivery_price_is_what_the_total_grows_by(self):
        """Pretul aratat langa curier si cresterea totalului trebuie sa fie acelasi
        numar. Nu se compara cu tariful configurat (25): produsul de transport are TVA,
        iar un pret afisat fara TVA langa un total cu TVA e chiar felul in care clientul
        ajunge sa plateasca alta suma decat a vazut."""
        advertised = self._offered_method()['price']['amount']
        before = self._checkout().json()['cart']['amounts']['total']['amount']

        body = self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id}).json()
        self.assertEqual(body['selected_delivery_method_id'], self.carrier.id)
        self.assertEqual(body['cart']['amounts']['delivery']['amount'], advertised)
        self.assertEqual(body['cart']['amounts']['total']['amount'], before + advertised)
        # Linia de transport nu se numara ca produs in cos.
        self.assertEqual(len(body['cart']['lines']), 1)

    def test_a_carrier_from_another_website_cannot_be_chosen(self):
        self.api_login()
        self._fill_cart()
        response = self.api_post('/checkout/delivery', {'carrier_id': self.foreign_carrier.id})
        self.assertEqual(response.status_code, 422)

    def test_delivery_needs_a_numeric_carrier(self):
        self.api_login()
        self._fill_cart()
        self.assertEqual(self.api_post('/checkout/delivery', {'carrier_id': 'x'}).status_code, 422)
        self.assertEqual(self.api_post('/checkout/delivery', {}).status_code, 422)

    def test_blockers_say_what_is_missing(self):
        self.api_login()
        self._fill_cart()
        codes = {b['code'] for b in self._checkout().json()['blockers']}
        self.assertIn('no_carrier_selected', codes)
        self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id})
        self.assertEqual(self._checkout().json()['blockers'], [])

    def test_addresses_are_limited_to_the_account(self):
        self.api_login()
        self._fill_cart()
        stranger = self.env['res.partner'].create({'name': 'Partener strain checkout'})
        body = self._checkout().json()
        ids = {a['id'] for a in body['addresses']['available']}
        self.assertIn(self.portal_user.partner_id.id, ids)
        self.assertNotIn(stranger.id, ids)
        response = self.api_post('/checkout/address', {'delivery_id': stranger.id})
        self.assertEqual(response.status_code, 422)

    def test_choosing_a_child_address_moves_the_delivery(self):
        self.api_login()
        self._fill_cart()
        child = self.env['res.partner'].create({
            'name': 'Cabinet secundar', 'type': 'delivery',
            'parent_id': self.portal_user.partner_id.commercial_partner_id.id})
        body = self.api_post('/checkout/address', {'delivery_id': child.id}).json()
        self.assertEqual(body['addresses']['delivery_id'], child.id)

    def test_payment_options_list_the_configured_provider(self):
        self.api_login()
        self._fill_cart()
        self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id})
        options = self._checkout().json()['payment_options']
        self.assertTrue(options)
        transfer = next(o for o in options if o['provider_id'] == self.provider.id)
        self.assertEqual(transfer['kind'], 'offline')
        # Instructiunile vin ca blocuri, nu ca HTML: aplicatia nu are motor HTML.
        self.assertEqual(transfer['instructions'][0]['type'], 'paragraph')
        self.assertIn('transfer bancar', transfer['instructions'][0]['spans'][0]['text'])

    def test_checkout_shape_matches_contract(self):
        self.api_login()
        self._fill_cart()
        self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id})
        body = self._checkout().json()
        contract = load_contract('checkout.json')
        self.assertEqual(set(body), set(contract))
        self.assertEqual(set(body['addresses']), set(contract['addresses']))
        self.assertEqual(set(body['addresses']['available'][0]), set(contract['addresses']['available'][0]))
        self.assertEqual(set(body['delivery_methods'][0]), set(contract['delivery_methods'][0]))
        self.assertEqual(set(body['payment_options'][0]), set(contract['payment_options'][0]))

    def test_confirm_without_a_delivery_method_is_refused(self):
        self.api_login()
        self._fill_cart()
        options = self._checkout().json()['payment_options']
        response = self.api_post('/checkout/confirm', {
            'payment_method_id': options[0]['payment_method_id'],
            'provider_id': options[0]['provider_id']})
        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['error']['code'], 'cart_not_ready')

    def test_offline_confirm_sends_the_order(self):
        """Plata offline se incheie in aplicatie: se creeaza tranzactia, comanda iese
        din ciorna si raspunsul aduce instructiunile providerului."""
        self.api_login()
        self._fill_cart(2)
        self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id})
        checkout = self._checkout().json()
        option = next(o for o in checkout['payment_options'] if o['provider_id'] == self.provider.id)

        response = self.api_post('/checkout/confirm', {
            'payment_method_id': option['payment_method_id'],
            'provider_id': option['provider_id']})
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertEqual(body['payment']['kind'], 'offline')
        self.assertTrue(body['payment']['reference'])
        self.assertIn('transfer bancar', body['payment']['instructions'][0]['spans'][0]['text'])

        contract = load_contract('checkout_confirm_offline.json')
        self.assertEqual(set(body), set(contract))
        self.assertEqual(set(body['payment']), set(contract['payment']))

        order = self.env['sale.order'].browse(body['order_id'])
        self.assertNotEqual(order.state, 'draft')
        self.assertTrue(order.transaction_ids)

    def test_confirm_refuses_a_payment_method_that_is_not_offered(self):
        self.api_login()
        self._fill_cart()
        self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id})
        response = self.api_post('/checkout/confirm', {
            'payment_method_id': 0, 'provider_id': 0})
        self.assertEqual(response.status_code, 422)

    def test_the_confirmed_order_is_no_longer_the_cart(self):
        """Dupa trimitere, cosul aplicatiei porneste de la zero - altfel clientul ar
        continua sa adauge produse intr-o comanda deja plasata."""
        self.api_login()
        self._fill_cart()
        self.api_post('/checkout/delivery', {'carrier_id': self.carrier.id})
        option = next(o for o in self._checkout().json()['payment_options']
                      if o['provider_id'] == self.provider.id)
        confirmed_id = self.api_post('/checkout/confirm', {
            'payment_method_id': option['payment_method_id'],
            'provider_id': option['provider_id']}).json()['order_id']

        body = self.api_post('/cart/lines', {
            'lines': [{'variant_id': self.variant.id, 'add_qty': 1}]}).json()
        self.assertNotEqual(body['order_id'], confirmed_id)
        self.assertEqual(body['quantity'], 1)
