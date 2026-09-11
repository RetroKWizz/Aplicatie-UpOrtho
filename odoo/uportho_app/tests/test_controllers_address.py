from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestControllersAddress(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.website = cls.env['website'].search([], limit=1)
        cls.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(cls.website.id))
        cls.country = cls.env['res.country'].search([('code', '=', 'RO')], limit=1)
        cls.state = cls.env['res.country.state'].search(
            [('country_id', '=', cls.country.id)], limit=1)

    def _values(self, **overrides):
        values = {
            'name': 'Cabinet Secundar',
            'street': 'Str. Noua 5',
            'city': 'Cluj-Napoca',
            'zip': '400002',
            'country_id': self.country.id,
            'phone': '+40711111111',
            'email': 'secundar@test.ro',
        }
        if self.state:
            values['state_id'] = self.state.id
        values.update(overrides)
        return values

    def test_options_require_login(self):
        self.assertEqual(self.api_get('/addresses/options').status_code, 401)

    def test_options_list_the_fields_the_shop_itself_requires(self):
        """Campurile obligatorii se cer magazinului, nu se scriu in codul nostru: asa
        intra automat si ce adauga modulele clientului (orasul ca lista, de exemplu)."""
        self.api_login()
        body = self.api_get(f'/addresses/options?country_id={self.country.id}').json()

        self.assertIn('name', body['required']['delivery'])
        self.assertIn('street', body['required']['delivery'])
        self.assertIn('country_id', body['required']['delivery'])
        self.assertIn('phone', body['required']['delivery'])
        # Facturarea cere in plus datele de contact ale portalului.
        self.assertIn('email', body['required']['invoice'])
        self.assertTrue(body['countries'])
        self.assertIn('city_is_list', body)

    def test_options_give_the_states_of_the_chosen_country(self):
        self.api_login()
        body = self.api_get(f'/addresses/options?country_id={self.country.id}').json()
        self.assertTrue(body['states'], 'Romania are judete')
        self.assertEqual(self.api_get('/addresses/options?country_id=0').status_code, 422)

    def test_a_new_delivery_address_belongs_to_the_account(self):
        self.api_login()
        response = self.api_post('/addresses', {'kind': 'delivery', 'values': self._values()})
        self.assertEqual(response.status_code, 200)
        body = response.json()

        self.assertEqual(body['address']['name'], 'Cabinet Secundar')
        self.assertIn(body['address']['id'], [a['id'] for a in body['addresses']])

        partner = self.env['res.partner'].browse(body['address']['id'])
        self.assertEqual(partner.type, 'delivery')
        self.assertEqual(partner.parent_id, self.portal_user.partner_id.commercial_partner_id)

    def test_a_new_billing_address_is_of_type_invoice(self):
        self.api_login()
        body = self.api_post('/addresses', {'kind': 'invoice', 'values': self._values()}).json()
        self.assertEqual(self.env['res.partner'].browse(body['address']['id']).type, 'invoice')

    def test_the_new_address_shows_up_in_checkout_too(self):
        """Ecranul de cont si cel de checkout citesc aceeasi lista; altfel clientul ar
        adauga o adresa si n-ar gasi-o la finalizarea comenzii."""
        self.api_login()
        product = self.env['product.template'].create({
            'name': 'Produs adresa test', 'is_published': True, 'list_price': 10.0})
        self.api_post('/cart/lines', {
            'lines': [{'variant_id': product.product_variant_id.id, 'add_qty': 1}]})

        new_id = self.api_post(
            '/addresses', {'kind': 'delivery', 'values': self._values()}).json()['address']['id']

        listed = {a['id'] for a in self.api_get('/addresses').json()}
        in_checkout = {a['id'] for a in self.api_get('/checkout').json()['addresses']['available']}
        self.assertIn(new_id, listed)
        self.assertIn(new_id, in_checkout)

    def test_the_new_address_can_be_chosen_for_delivery(self):
        self.api_login()
        product = self.env['product.template'].create({
            'name': 'Produs alegere adresa', 'is_published': True, 'list_price': 10.0})
        self.api_post('/cart/lines', {
            'lines': [{'variant_id': product.product_variant_id.id, 'add_qty': 1}]})
        new_id = self.api_post(
            '/addresses', {'kind': 'delivery', 'values': self._values()}).json()['address']['id']

        body = self.api_post('/checkout/address', {'delivery_id': new_id}).json()
        self.assertEqual(body['addresses']['delivery_id'], new_id)

    def test_missing_required_fields_are_named_one_by_one(self):
        """Ecranul trebuie sa poata marca fiecare camp gresit, nu doar sa arate un
        mesaj general - de aceea lista lor vine in `details.fields`."""
        self.api_login()
        response = self.api_post('/addresses', {
            'kind': 'delivery',
            'values': {'name': 'Fara restul', 'country_id': self.country.id},
        })
        self.assertEqual(response.status_code, 422)
        error = response.json()['error']
        self.assertEqual(error['code'], 'invalid_address')
        self.assertIn('street', error['details']['fields'])
        self.assertIn('phone', error['details']['fields'])

    def test_an_invalid_email_is_refused(self):
        self.api_login()
        response = self.api_post('/addresses', {
            'kind': 'invoice', 'values': self._values(email='nu-e-email')})
        self.assertEqual(response.status_code, 422)
        self.assertIn('email', response.json()['error']['details']['fields'])

    def test_bad_requests_are_422_never_500(self):
        self.api_login()
        cases = [
            {'kind': 'altceva', 'values': self._values()},
            {'values': self._values()},
            {'kind': 'delivery', 'values': 'nu e obiect'},
            {'kind': 'delivery', 'values': {'country_id': 'abc'}},
        ]
        for body in cases:
            with self.subTest(body=body):
                self.assertEqual(self.api_post('/addresses', body).status_code, 422)

    def test_fields_outside_the_form_are_ignored_not_written(self):
        """Un client nu are ce cauta in campuri care nu tin de adresa. Ele se ignora in
        tacere: un camp in plus nu merita eroare, dar nici nu se scrie."""
        self.api_login()
        other_user = self.env['res.users'].search([('id', '!=', self.portal_user.id)], limit=1)
        body = self.api_post('/addresses', {
            'kind': 'delivery',
            'values': self._values(user_id=other_user.id, customer_rank=99),
        }).json()

        partner = self.env['res.partner'].browse(body['address']['id'])
        self.assertNotEqual(partner.user_id, other_user)
        self.assertEqual(partner.customer_rank, 0)

    def test_creating_an_address_requires_the_app_header(self):
        self.api_login()
        response = self.api_post(
            '/addresses', {'kind': 'delivery', 'values': self._values()}, with_header=False)
        self.assertEqual(response.status_code, 403)

    # --- editarea unei adrese existente ---------------------------------------

    def _create_address(self, **overrides):
        body = self.api_post(
            '/addresses', {'kind': 'delivery', 'values': self._values(**overrides)}).json()
        return self.env['res.partner'].browse(body['address']['id'])

    def test_reading_one_address_gives_the_ids_the_form_needs(self):
        """Formularul are nevoie de id-uri (tara, judet, oras), nu de nume: altfel
        listele nu pot fi pre-selectate."""
        self.api_login()
        partner = self._create_address()

        body = self.api_get(f'/addresses/{partner.id}').json()['address']
        self.assertEqual(body['name'], 'Cabinet Secundar')
        self.assertEqual(body['country_id'], self.country.id)
        self.assertEqual(body['kind'], 'delivery')
        self.assertIn('can_edit_vat', body)
        self.assertIn('can_edit_name', body)

    def test_editing_an_address_saves_the_change(self):
        self.api_login()
        partner = self._create_address()

        response = self.api_post(
            f'/addresses/{partner.id}',
            {'values': self._values(name='Cabinet Secundar', street='Str. Modificata 7')})
        self.assertEqual(response.status_code, 200, response.text)
        self.assertEqual(response.json()['address']['street'], 'Str. Modificata 7')

        partner.invalidate_recordset()
        self.assertEqual(partner.street, 'Str. Modificata 7')
        self.assertEqual(partner.type, 'delivery', 'tipul adresei ramane cel de dinainte')

    def test_editing_refuses_what_the_shop_refuses(self):
        """Validarea e a magazinului, chemata cu partenerul existent - deci si erorile
        sunt ale lui, pe campurile lui."""
        self.api_login()
        partner = self._create_address()

        response = self.api_post(f'/addresses/{partner.id}', {'values': {'street': ''}})
        self.assertEqual(response.status_code, 422)
        self.assertIn('street', response.json()['error']['details']['fields'])
        partner.invalidate_recordset()
        self.assertEqual(partner.street, 'Str. Noua 5')

    def test_an_address_of_another_account_cannot_be_read_or_written(self):
        self.api_login()
        stranger = self.env['res.partner'].sudo().create({
            'name': 'Adresa strain test', 'type': 'delivery', 'street': 'Str. Straina 1'})

        self.assertEqual(self.api_get(f'/addresses/{stranger.id}').status_code, 404)
        self.assertEqual(
            self.api_post(f'/addresses/{stranger.id}', {'values': {'street': 'X'}}).status_code,
            404)
        stranger.invalidate_recordset()
        self.assertEqual(stranger.street, 'Str. Straina 1')

    def test_editing_requires_the_app_header(self):
        self.api_login()
        partner = self._create_address()
        response = self.api_post(
            f'/addresses/{partner.id}', {'values': {'street': 'Str. X 1'}}, with_header=False)
        self.assertEqual(response.status_code, 403)

    def test_addresses_say_where_the_shop_accepts_them(self):
        """Site-ul are doua liste, facturare si livrare; aplicatia trebuie sa le poata
        imparti la fel. Regula e a magazinului: `invoice` si `other` merg la facturare,
        `delivery` si `other` la livrare, iar partenerul principal intra in amandoua."""
        self.api_login()
        delivery = self._create_address()
        billing = self.env['res.partner'].browse(self.api_post(
            '/addresses', {'kind': 'invoice', 'values': self._values(
                name='Firma de facturare test', email='facturi@test.ro')}).json()['address']['id'])

        listed = {a['id']: a for a in self.api_get('/addresses').json()}
        main = listed[self.portal_user.partner_id.commercial_partner_id.id]
        self.assertTrue(main['for_billing'])
        self.assertTrue(main['for_delivery'], 'partenerul principal e in amandoua listele')
        self.assertTrue(listed[delivery.id]['for_delivery'])
        self.assertFalse(listed[delivery.id]['for_billing'])
        self.assertTrue(listed[billing.id]['for_billing'])
        self.assertFalse(listed[billing.id]['for_delivery'])
