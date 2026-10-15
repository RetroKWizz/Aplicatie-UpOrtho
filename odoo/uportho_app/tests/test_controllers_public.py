import unittest

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


@tagged('post_install', '-at_install')
class TestContinutPublic(AppHttpCase):
    """Acasa, pagina de produs si imaginile, pentru un vizitator.

    O ruta publica nu are voie sa devina o fereastra prin care se citeste orice din baza:
    ce nu e publicat ramane 404, exact ca pe site."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.publicat = cls.env['product.template'].create({
            'name': 'Produs vizibil public', 'is_published': True, 'list_price': 10.0})
        cls.nepublicat = cls.env['product.template'].create({
            'name': 'Produs ascuns public', 'is_published': False, 'list_price': 10.0})

    def test_acasa_se_vede_fara_sesiune(self):
        response = self.api_get('/home')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['pricing'],
                         {'visible': False, 'reason': 'sign_in_required'})

    def test_acasa_cu_sesiune_spune_ca_preturile_se_vad(self):
        self.api_login()

        self.assertEqual(self.api_get('/home').json()['pricing'],
                         {'visible': True, 'reason': None})

    def test_pagina_de_produs_se_vede_fara_pret(self):
        body = self.api_get('/products/%s' % self.publicat.id).json()

        self.assertEqual(body['name'], 'Produs vizibil public')
        self.assertIsNone(body['price'])
        self.assertIsNone(body['club_price'])
        self.assertEqual(body['price_tables'], [])
        self.assertEqual(body['pricing']['reason'], 'sign_in_required')

    def test_un_produs_nepublicat_ramane_404_pentru_vizitator(self):
        self.assertEqual(self.api_get('/products/%s' % self.nepublicat.id).status_code, 404)

    def test_imaginea_unui_produs_nepublicat_ramane_404(self):
        self.assertEqual(
            self.api_get('/products/%s/image' % self.nepublicat.id).status_code, 404)

    def test_rutele_de_cont_raman_pe_cont(self):
        for path in ('/cart', '/checkout', '/orders', '/invoices', '/addresses',
                     '/favorites', '/loyalty', '/account/profile', '/payment-methods'):
            with self.subTest(path=path):
                self.assertEqual(self.api_get(path).status_code, 401)


@tagged('post_install', '-at_install')
class TestImaginiPublice(AppHttpCase):
    """O ruta publica de imagine serveste doar continut pe care magazinul il ARATA.

    Altfel ar fi o fereastra prin care se pot citi, incercand id-uri, pozele unei
    campanii arhivate sau programate pentru saptamana viitoare."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        # Campul `fields.Image` primeste base64, nu octeti bruti.
        png = (b'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0'
               b'C8AAAAASUVORK5CYII=')
        Banner = cls.env['uportho.app.banner']
        cls.activ = Banner.create({
            'name': 'Banner activ public', 'placement': 'hero', 'link_type': 'none',
            'image': png})
        cls.arhivat = Banner.create({
            'name': 'Banner arhivat public', 'placement': 'hero', 'link_type': 'none',
            'image': png, 'active': False})
        cls.viitor = Banner.create({
            'name': 'Banner viitor public', 'placement': 'hero', 'link_type': 'none',
            'image': png, 'date_start': '2099-01-01'})

    def test_bannerul_activ_se_vede_fara_sesiune(self):
        self.assertEqual(
            self.api_get('/banners/%s/image' % self.activ.id).status_code, 200)

    @unittest.skip('DEFECT CUNOSCUT: ruta publica nu verifica `active` — docs/DE-FACUT.md, constatarea 1')
    def test_bannerul_arhivat_nu_se_vede_nici_cu_id_ul_lui(self):
        """DEFECT CUNOSCUT, amanat constient — vezi docs/DE-FACUT.md, constatarea 1.

        Ruta e publica si nu verifica `active`. Testul ramane aici ca sa descrie
        comportamentul CORECT; cand ruta se repara, `expectedFailure` devine
        "unexpected success" si marcajul trebuie scos."""
        self.assertEqual(
            self.api_get('/banners/%s/image' % self.arhivat.id).status_code, 404)

    @unittest.skip('DEFECT CUNOSCUT: ruta publica nu verifica fereastra de date — docs/DE-FACUT.md, constatarea 1')
    def test_o_campanie_viitoare_nu_se_scurge_inainte_de_vreme(self):
        """DEFECT CUNOSCUT, amanat constient — vezi docs/DE-FACUT.md, constatarea 1."""
        self.assertEqual(
            self.api_get('/banners/%s/image' % self.viitor.id).status_code, 404)
