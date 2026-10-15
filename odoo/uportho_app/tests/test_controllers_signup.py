from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract


@tagged('post_install', '-at_install')
class TestSignup(AppHttpCase):
    """Inregistrarea trece prin `AuthSignupHome`, deci primim regulile si mesajele lor.

    Signup-ul face `commit()` explicit in Odoo: contul chiar ramane in baza, nu dispare
    la rollback-ul testului. De aceea fiecare test isi curata contul creat."""

    def setUp(self):
        super().setUp()
        # Inregistrarea se deschide PE WEBSITE, nu din parametrul de sistem: modulul
        # `website` suprascrie `_get_signup_invitation_scope` si citeste
        # `auth_signup_uninvited` de pe website-ul curent. Parametrul ramane doar
        # rezerva, pentru bazele fara website.
        self.website = self.env['website'].search([], limit=1)
        self.website.auth_signup_uninvited = 'b2c'
        self.env['ir.config_parameter'].sudo().set_param('recaptcha_private_key', '')
        self.addCleanup(self.registry.clear_cache)
        self.addCleanup(self._sterge_conturile_de_test)

    def _sterge_conturile_de_test(self):
        self.env['res.users'].sudo().search([('login', 'like', 'signup.test')]).unlink()

    def _signup(self, email, **kw):
        payload = {
            'login': email, 'name': kw.get('name', 'Cabinet Test'),
            'password': kw.get('password', 'ParolaBuna123!'),
            'confirm_password': kw.get('confirm_password', kw.get('password', 'ParolaBuna123!')),
        }
        payload.update(kw.get('extra', {}))
        return self.api_post('/auth/signup', payload)

    def test_creeaza_contul_si_deschide_sesiunea(self):
        response = self._signup('signup.test1@uportho.ro')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['user']['email'], 'signup.test1@uportho.ro')
        # Sesiunea e deschisa: o ruta de cont raspunde acum, fara al doilea pas.
        self.assertEqual(self.api_get('/account/profile').status_code, 200)

    def test_un_email_cu_cont_existent_nu_atinge_contul_existent(self):
        existing = self.env['res.users'].sudo().create({
            'name': 'Deja Inregistrat', 'login': 'signup.test2@uportho.ro',
            'password': 'ParolaVeche123!',
            'groups_id': [(6, 0, [self.env.ref('base.group_portal').id])]})

        response = self._signup('signup.test2@uportho.ro', name='Altcineva')

        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['error']['code'], 'email_taken')
        existing.invalidate_recordset()
        self.assertEqual(existing.name, 'Deja Inregistrat')

    def test_parolele_diferite_sunt_oprite_inainte_de_orice_scriere(self):
        response = self._signup('signup.test3@uportho.ro',
                                password='Parola123!', confirm_password='AltaParola123!')

        self.assertEqual(response.status_code, 422)
        self.assertFalse(self.env['res.users'].sudo().search(
            [('login', '=', 'signup.test3@uportho.ro')]))

    def test_cu_inregistrarea_oprita_ruta_refuza(self):
        self.website.auth_signup_uninvited = 'b2b'

        response = self._signup('signup.test4@uportho.ro')

        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json()['error']['code'], 'signup_disabled')
        self.assertFalse(self.env['res.users'].sudo().search(
            [('login', '=', 'signup.test4@uportho.ro')]))

    def test_cu_recaptcha_configurat_ruta_trimite_in_webview(self):
        """Nu ocolim protectia anti-bot a magazinului ca sa ne fie noua mai comod."""
        self.env['ir.config_parameter'].sudo().set_param('recaptcha_private_key', 'cheie-test')

        response = self._signup('signup.test5@uportho.ro')

        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['error']['code'], 'signup_needs_webview')
        self.assertFalse(self.env['res.users'].sudo().search(
            [('login', '=', 'signup.test5@uportho.ro')]))

    def test_campurile_in_plus_sunt_ignorate(self):
        """Un client nu-si poate seta singur grupuri sau alte campuri de utilizator."""
        response = self._signup('signup.test6@uportho.ro',
                                extra={'groups_id': [[6, 0, []]], 'user_id': 2})

        self.assertEqual(response.status_code, 200)
        user = self.env['res.users'].sudo().search([('login', '=', 'signup.test6@uportho.ro')])
        self.assertTrue(user.has_group('base.group_portal'))

    def test_fara_nume_sau_email_ruta_cere_datele(self):
        self.assertEqual(self._signup('').status_code, 422)
        self.assertEqual(self._signup('signup.test7@uportho.ro', name='').status_code, 422)

    def test_contractul_descrie_raspunsul(self):
        contract = load_contract('signup.json')

        self.assertEqual(set(contract['user']), {'id', 'name', 'email', 'partner_id'})
