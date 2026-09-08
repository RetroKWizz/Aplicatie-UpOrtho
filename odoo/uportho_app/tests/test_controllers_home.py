import base64
import hashlib

from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract

# PNG 1x1 valid, pentru campuri Image
PNG_1PX = base64.b64decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=')
# PNG 1x1 diferit (rosu), ca sa putem scrie o imagine noua peste cea existenta
PNG_1PX_RED = base64.b64decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==')


def expected_unique(record):
    """Acelasi calcul ca in Odoo pentru `/web/image/...?unique=` (`website.image_url`):
    primele 7 caractere din sha512 al lui write_date. Calculat aici independent de
    controller, ca testul sa fie un oracol real, nu o repetare a implementarii."""
    return hashlib.sha512(str(record.sudo().write_date).encode('utf-8')).hexdigest()[:7]


@tagged('post_install', '-at_install')
class TestControllersHome(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.category = cls.env['product.public.category'].create({
            'name': 'Bracketi', 'app_home_visible': True, 'app_home_sequence': 1,
            'app_home_icon': base64.b64encode(PNG_1PX)})
        cls.category_no_icon = cls.env['product.public.category'].create({
            'name': 'Arcuri', 'app_home_visible': True, 'app_home_sequence': 2})
        cls.env['product.public.category'].create({'name': 'Ascunsa', 'app_home_visible': False})
        cls.hero = cls.env['uportho.app.banner'].create({
            'name': 'Hero', 'subtitle': 'Sub', 'placement': 'hero', 'sequence': 1,
            'link_type': 'category', 'category_id': cls.category.id,
            'image': base64.b64encode(PNG_1PX)})
        cls.promo = cls.env['uportho.app.banner'].create({
            'name': 'Promo', 'placement': 'promo', 'sequence': 2, 'link_type': 'url',
            'external_url': 'https://uportho.ro/promo'})
        cls.env['uportho.app.banner'].create({'name': 'Arhivat', 'placement': 'hero', 'active': False})

    def test_home_requires_login(self):
        self.assertEqual(self.api_get('/home').status_code, 401)

    def test_home_shape_matches_contract(self):
        self.api_login()
        body = self.api_get('/home').json()
        contract = load_contract('home.json')
        self.assertEqual(set(body.keys()), set(contract.keys()))
        self.assertEqual(set(body['banners'][0].keys()), set(contract['banners'][0].keys()))
        self.assertEqual(set(body['banners'][0]['link'].keys()), set(contract['banners'][0]['link'].keys()))
        self.assertEqual(set(body['quick_categories'][0].keys()), set(contract['quick_categories'][0].keys()))

    def test_home_banners_active_only_in_order_with_links(self):
        # Filtram pe id-urile proprii: pot exista bannere reziduale in baza locala
        # (ex. dintr-o verificare manuala anterioara), iar testul nu trebuie sa presupuna
        # ca lista globala contine EXACT cele doua bannere create aici.
        self.api_login()
        own_ids = {self.hero.id, self.promo.id}
        banners = [b for b in self.api_get('/home').json()['banners'] if b['id'] in own_ids]
        self.assertEqual([b['title'] for b in banners], ['Hero', 'Promo'])
        hero, promo = banners
        self.assertEqual(hero['link'], {'type': 'category', 'category_id': self.category.id, 'url': None})
        self.assertEqual(
            hero['image_url'],
            f'/api/app/v1/banners/{self.hero.id}/image?unique={expected_unique(self.hero)}')
        self.assertEqual(promo['link'], {'type': 'url', 'category_id': None, 'url': 'https://uportho.ro/promo'})
        self.assertIsNone(promo['image_url'])

    def test_home_quick_categories_visible_only_in_order(self):
        # Ca si la bannere: nu presupunem ca baza contine EXACT categoriile create aici
        # (o baza locala poate avea categorii vizibile ramase dintr-o verificare manuala).
        # Filtram pe id-urile proprii si ne cream singuri inregistrarea care interfereaza -
        # dovada de robustete trebuie sa fie in test, nu in starea unei anume baze de date.
        self.api_login()
        intruder = self.env['product.public.category'].create({
            'name': 'Intrus', 'app_home_visible': True, 'app_home_sequence': 0})
        own_ids = {self.category.id, self.category_no_icon.id, intruder.id}
        categories = [c for c in self.api_get('/home').json()['quick_categories'] if c['id'] in own_ids]
        self.assertEqual([c['name'] for c in categories], ['Intrus', 'Bracketi', 'Arcuri'])
        by_id = {c['id']: c for c in categories}
        self.assertEqual(
            by_id[self.category.id]['icon_url'],
            f'/api/app/v1/categories/{self.category.id}/icon?unique={expected_unique(self.category)}')
        self.assertIsNone(by_id[self.category_no_icon.id]['icon_url'])

    def _home_urls(self):
        body = self.api_get('/home').json()
        banner = next(b for b in body['banners'] if b['id'] == self.hero.id)
        category = next(c for c in body['quick_categories'] if c['id'] == self.category.id)
        return banner['image_url'], category['icon_url']

    def _touch(self, record):
        """Muta write_date-ul inregistrarii cu o secunda inainte.

        Intr-un test, un `write()` obisnuit NU misca write_date: Odoo il seteaza din
        `cr.now()`, care e timestamp-ul tranzactiei, constant, iar tot testul ruleaza
        intr-o singura tranzactie. In productie fiecare cerere e alta tranzactie, deci
        write_date chiar avanseaza. Impingem write_date direct in SQL ca sa reproducem
        situatia reala."""
        record.flush_recordset()
        self.env.cr.execute(
            f"UPDATE {record._table} SET write_date = write_date + interval '1 second' WHERE id = %s",
            (record.id,))
        record.invalidate_recordset(['write_date'])

    def test_image_urls_change_when_the_record_is_written(self):
        """Token-ul `?unique=` face imaginea invalidabila din cache-ul aplicatiei:
        dupa ce un editor schimba imaginea in Odoo, URL-ul emis trebuie sa fie altul,
        altfel `cached_network_image` serveste zile la rand imaginea veche."""
        self.api_login()
        banner_url_before, category_url_before = self._home_urls()

        # Editorul schimba efectiv imaginea...
        self.hero.write({'image': base64.b64encode(PNG_1PX_RED)})
        self.category.write({'app_home_icon': base64.b64encode(PNG_1PX_RED)})
        # ...iar scrierea avanseaza write_date (vezi _touch pentru de ce e nevoie de SQL).
        self._touch(self.hero)
        self._touch(self.category)

        banner_url_after, category_url_after = self._home_urls()
        self.assertNotEqual(banner_url_before, banner_url_after)
        self.assertNotEqual(category_url_before, category_url_after)
        # Doar token-ul se schimba; calea ramane aceeasi ruta.
        self.assertTrue(banner_url_after.startswith(f'/api/app/v1/banners/{self.hero.id}/image?unique='))
        self.assertTrue(category_url_after.startswith(f'/api/app/v1/categories/{self.category.id}/icon?unique='))

    def test_banner_image_is_served_for_logged_user(self):
        self.api_login()
        response = self.api_get(f'/banners/{self.hero.id}/image')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.headers['Content-Type'].startswith('image/'))

    def test_banner_image_requires_login(self):
        self.assertEqual(self.api_get(f'/banners/{self.hero.id}/image').status_code, 401)

    def test_missing_banner_image_is_404(self):
        self.api_login()
        self.assertEqual(self.api_get(f'/banners/{self.promo.id}/image').status_code, 404)
        self.assertEqual(self.api_get('/banners/999999/image').status_code, 404)

    def test_category_icon_is_served(self):
        self.api_login()
        self.assertEqual(self.api_get(f'/categories/{self.category.id}/icon').status_code, 200)
        self.assertEqual(self.api_get(f'/categories/{self.category_no_icon.id}/icon').status_code, 404)
