from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestCatalogPublic(AppHttpCase):
    """Catalogul se vede fara cont, dar fara preturi — ca pe site.

    Magazinul arata unui vizitator produsele si categoriile, dar tine preturile pentru
    clienti (regula B2B a temei). Aplicatia face exact la fel: nu inventeaza o lista
    publica si nu ascunde produsele."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.produs = cls.env['product.template'].create({
            'name': 'Produs public test', 'is_published': True, 'list_price': 10.0})

    def test_produsele_se_vad_fara_sesiune(self):
        response = self.api_get('/products?q=Produs+public+test')

        self.assertEqual(response.status_code, 200)
        names = [p['name'] for p in response.json()['products']]
        self.assertIn('Produs public test', names)

    def test_fara_sesiune_pretul_lipseste_si_blocul_spune_de_ce(self):
        body = self.api_get('/products?q=Produs+public+test').json()
        produs = next(p for p in body['products'] if p['name'] == 'Produs public test')

        self.assertIsNone(produs['price'])
        self.assertIsNone(produs['club_price'])
        self.assertEqual(body['pricing'], {'visible': False, 'reason': 'sign_in_required'})

    def test_cu_sesiune_preturile_sunt_cele_de_azi(self):
        """Clientul autentificat nu pierde nimic cand ruta devine publica."""
        self.api_login()
        body = self.api_get('/products?q=Produs+public+test').json()
        produs = next(p for p in body['products'] if p['name'] == 'Produs public test')

        self.assertEqual(body['pricing'], {'visible': True, 'reason': None})
        self.assertIsNotNone(produs['price'])
        self.assertIn('formatted', produs['price'])

    def test_categoriile_se_vad_fara_sesiune(self):
        self.assertEqual(self.api_get('/categories').status_code, 200)
