from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestControllersProfile(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.country = cls.env['res.country'].search([('code', '=', 'RO')], limit=1)
        cls.partner = cls.portal_user.partner_id
        # Toate campurile obligatorii ale portalului, completate: fara ele, ORICE
        # modificare e refuzata, pentru ca validarea le cere pe toate deodata. Asa se
        # comporta si formularul de pe site.
        cls.partner.write({
            'email': 'app.test@uportho.ro',
            'phone': '+40700000000',
            'street': 'Str. Veche 1',
            'city': 'Cluj-Napoca',
            'country_id': cls.country.id,
        })

    def test_profile_requires_login(self):
        self.assertEqual(self.api_get('/account/profile').status_code, 401)

    def test_profile_shows_the_account_details(self):
        self.api_login()
        body = self.api_get('/account/profile').json()

        self.assertEqual(body['profile']['name'], self.partner.name)
        self.assertEqual(body['profile']['email'], self.partner.email)
        self.assertEqual(body['profile']['city'], 'Cluj-Napoca')
        self.assertEqual(body['profile']['country'], self.country.name)
        self.assertIn('can_edit_vat', body['profile'])

    def test_required_fields_come_from_the_portal_not_from_our_code(self):
        """Lista se cere portalului, deci include automat si ce adauga modulele
        clientului. `zipcode` din formularul web se traduce in `zip`, numele campului
        de pe partener."""
        self.api_login()
        body = self.api_get('/account/profile').json()

        for field in ('name', 'email', 'phone', 'street', 'city', 'country_id'):
            self.assertIn(field, body['required'])
        self.assertNotIn('zipcode', body['required'])
        self.assertIn('vat', body['editable'])

    def test_changing_the_phone_saves_it(self):
        self.api_login()
        response = self.api_post('/account/profile', {'values': {'phone': '+40799999999'}})
        self.assertEqual(response.status_code, 200)

        self.assertEqual(response.json()['profile']['phone'], '+40799999999')
        self.partner.invalidate_recordset()
        self.assertEqual(self.partner.phone, '+40799999999')

    def test_fields_left_out_keep_their_value(self):
        """O cerere partiala nu goleste restul contului: campurile netrimise raman cum
        erau, altfel validarea le-ar vedea goale si ar cere completarea lor."""
        self.api_login()
        self.api_post('/account/profile', {'values': {'phone': '+40788888888'}})

        self.partner.invalidate_recordset()
        self.assertEqual(self.partner.street, 'Str. Veche 1')
        self.assertEqual(self.partner.city, 'Cluj-Napoca')
        self.assertEqual(self.partner.country_id, self.country)

    def test_mobile_and_function_are_saved_too(self):
        """Nu sunt in formularul web al portalului, dar sunt date de contact ale
        aceleiasi persoane si aplicatia le arata."""
        self.api_login()
        response = self.api_post('/account/profile', {
            'values': {'mobile': '+40733333333', 'function': 'Medic primar'}})
        self.assertEqual(response.status_code, 200, response.text)

        self.partner.invalidate_recordset()
        self.assertEqual(self.partner.mobile, '+40733333333')
        self.assertEqual(self.partner.function, 'Medic primar')

    def test_an_invalid_email_is_refused_and_named(self):
        self.api_login()
        response = self.api_post('/account/profile', {'values': {'email': 'nu-e-email'}})

        self.assertEqual(response.status_code, 422)
        error = response.json()['error']
        self.assertEqual(error['code'], 'invalid_profile')
        self.assertIn('email', error['details']['fields'])
        self.partner.invalidate_recordset()
        self.assertNotEqual(self.partner.email, 'nu-e-email')

    def test_emptying_a_required_field_is_refused(self):
        self.api_login()
        response = self.api_post('/account/profile', {'values': {'street': ''}})

        self.assertEqual(response.status_code, 422)
        self.assertIn('street', response.json()['error']['details']['fields'])
        self.partner.invalidate_recordset()
        self.assertEqual(self.partner.street, 'Str. Veche 1')

    def test_fields_outside_the_list_are_ignored_not_written(self):
        self.api_login()
        other = self.env['res.users'].search([('id', '!=', self.portal_user.id)], limit=1)
        self.api_post('/account/profile', {
            'values': {'phone': '+40777777777', 'user_id': other.id, 'customer_rank': 42}})

        self.partner.invalidate_recordset()
        self.assertNotEqual(self.partner.user_id, other)
        self.assertEqual(self.partner.customer_rank, 0)

    def test_a_missing_required_field_blocks_any_change(self):
        """Daca pe cont lipseste un camp obligatoriu (email, de exemplu), portalul
        refuza salvarea pana e completat - chiar si cand clientul voia sa schimbe cu
        totul altceva. Aplicatia trebuie sa spuna care e campul, nu doar sa esueze."""
        self.api_login()
        self.partner.sudo().write({'email': False})

        response = self.api_post('/account/profile', {'values': {'phone': '+40766666666'}})
        self.assertEqual(response.status_code, 422)
        self.assertIn('email', response.json()['error']['details']['fields'])

    def test_bad_body_is_422(self):
        self.api_login()
        self.assertEqual(self.api_post('/account/profile', {'values': 'x'}).status_code, 422)
        self.assertEqual(self.api_post('/account/profile', {}).status_code, 422)

    def test_update_requires_the_app_header(self):
        self.api_login()
        response = self.api_post(
            '/account/profile', {'values': {'phone': '+4070'}}, with_header=False)
        self.assertEqual(response.status_code, 403)


@tagged('post_install', '-at_install')
class TestControllersLoyalty(AppHttpCase):
    def test_loyalty_requires_login(self):
        self.assertEqual(self.api_get('/loyalty').status_code, 401)

    def test_loyalty_is_a_list_even_without_the_module(self):
        """Pe o baza fara modulul de fidelitate ruta raspunde cu lista goala, nu cu
        eroare: ecranul are un singur drum de randare."""
        self.api_login()
        response = self.api_get('/loyalty')
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)

    def test_a_card_with_points_is_listed(self):
        if 'loyalty.card' not in self.env:
            self.skipTest('baza nu are modulul de fidelitate')
        self.api_login()
        program = self.env['loyalty.program'].create({
            'name': 'Ortho Club Test', 'program_type': 'loyalty'})
        card = self.env['loyalty.card'].create({
            'program_id': program.id,
            'partner_id': self.portal_user.partner_id.commercial_partner_id.id,
            'points': 150.0,
        })

        listed = {c['id']: c for c in self.api_get('/loyalty').json()}
        self.assertIn(card.id, listed)
        self.assertEqual(listed[card.id]['program'], 'Ortho Club Test')
        # Textul punctelor vine de la Odoo; aplicatia nu compune sume.
        self.assertTrue(listed[card.id]['points_display'])

    def test_a_membership_card_is_shown_even_with_zero_points(self):
        """Cardul Ortho Club spune ca esti membru; zero puncte nu inseamna ca nu mai
        esti. Pe staging, cardul lui Mihai chiar are zero - ascuns, contul lui n-ar fi
        aratat nicio urma de Ortho Club."""
        if 'loyalty.card' not in self.env:
            self.skipTest('baza nu are modulul de fidelitate')
        self.api_login()
        program = self.env['loyalty.program'].create({
            'name': 'Ortho Club fara puncte', 'program_type': 'loyalty'})
        card = self.env['loyalty.card'].create({
            'program_id': program.id,
            'partner_id': self.portal_user.partner_id.commercial_partner_id.id,
            'points': 0.0,
        })

        self.assertIn(card.id, [c['id'] for c in self.api_get('/loyalty').json()])

    def test_a_spent_gift_card_is_not_shown(self):
        """La un card cadou, zero chiar inseamna ca nu mai ai ce folosi."""
        if 'loyalty.card' not in self.env:
            self.skipTest('baza nu are modulul de fidelitate')
        self.api_login()
        program = self.env['loyalty.program'].create({
            'name': 'Card cadou golit test', 'program_type': 'gift_card'})
        card = self.env['loyalty.card'].create({
            'program_id': program.id,
            'partner_id': self.portal_user.partner_id.commercial_partner_id.id,
            'points': 0.0,
        })

        self.assertNotIn(card.id, [c['id'] for c in self.api_get('/loyalty').json()])

    def test_another_customers_card_is_not_listed(self):
        if 'loyalty.card' not in self.env:
            self.skipTest('baza nu are modulul de fidelitate')
        self.api_login()
        stranger = self.env['res.partner'].create({'name': 'Alt client fidelitate'})
        program = self.env['loyalty.program'].create({
            'name': 'Program strain test', 'program_type': 'loyalty'})
        card = self.env['loyalty.card'].create({
            'program_id': program.id, 'partner_id': stranger.id, 'points': 99.0})

        self.assertNotIn(card.id, [c['id'] for c in self.api_get('/loyalty').json()])
