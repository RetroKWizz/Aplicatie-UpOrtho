from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestControllersFavorite(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.website = cls.env['website'].search([], limit=1)
        cls.env['ir.config_parameter'].sudo().set_param(
            'uportho_app.website_id', str(cls.website.id))
        cls.product = cls.env['product.template'].create({
            'name': 'Produs favorit test', 'is_published': True, 'list_price': 30.0})
        cls.other = cls.env['product.template'].create({
            'name': 'Al doilea favorit test', 'is_published': True, 'list_price': 40.0})
        cls.unpublished = cls.env['product.template'].create({
            'name': 'Produs nepublicat favorit test', 'is_published': False, 'list_price': 50.0})

    def setUp(self):
        super().setUp()
        self.addCleanup(self.registry.clear_cache)

    def test_favorites_require_login(self):
        self.assertEqual(self.api_get('/favorites').status_code, 401)
        self.assertEqual(
            self.api_post('/favorites', {'product_id': self.product.id}).status_code, 401)

    def test_a_new_account_has_no_favorites(self):
        self.api_login()
        body = self.api_get('/favorites').json()
        self.assertEqual(body['ids'], [])
        self.assertEqual(body['products'], [])

    def test_adding_and_removing_a_favorite(self):
        self.api_login()
        added = self.api_post('/favorites', {'product_id': self.product.id})
        self.assertEqual(added.status_code, 200, added.text)
        self.assertTrue(added.json()['favorite'])
        self.assertIn(self.product.id, added.json()['ids'])

        listed = self.api_get('/favorites').json()
        self.assertIn(self.product.id, listed['ids'])
        self.assertEqual(
            [p['name'] for p in listed['products']], ['Produs favorit test'])
        # Produsul din lista are pretul contului, ca in catalog.
        self.assertTrue(listed['products'][0]['price']['formatted'])

        removed = self.api_delete(f'/favorites/{self.product.id}')
        self.assertEqual(removed.status_code, 200)
        self.assertFalse(removed.json()['favorite'])
        self.assertEqual(self.api_get('/favorites').json()['ids'], [])

    def test_adding_twice_does_not_duplicate(self):
        """Ecranul poate trimite acelasi produs de doua ori (dublu tap, retrimitere dupa
        o retea proasta); rezultatul cerut de client e acelasi, deci nu e eroare."""
        self.api_login()
        self.api_post('/favorites', {'product_id': self.product.id})
        second = self.api_post('/favorites', {'product_id': self.product.id})

        self.assertEqual(second.status_code, 200)
        self.assertEqual(second.json()['ids'].count(self.product.id), 1)

    def test_removing_something_that_is_not_there_is_not_an_error(self):
        self.api_login()
        self.assertEqual(self.api_delete(f'/favorites/{self.other.id}').status_code, 200)

    def test_a_product_outside_the_shop_cannot_be_favorited(self):
        self.api_login()
        response = self.api_post('/favorites', {'product_id': self.unpublished.id})
        self.assertEqual(response.status_code, 404)
        self.assertEqual(self.api_post('/favorites', {'product_id': 0}).status_code, 404)

    def test_an_unpublished_favorite_disappears_from_the_list(self):
        """Daca magazinul depublica un produs, el nu mai poate fi deschis - deci nici
        aratat la favorite. Filtrul e chiar domeniul catalogului."""
        self.api_login()
        self.api_post('/favorites', {'product_id': self.product.id})
        self.product.is_published = False

        self.assertEqual(self.api_get('/favorites').json()['ids'], [])

    def test_bad_body_is_422_never_500(self):
        self.api_login()
        self.assertEqual(self.api_post('/favorites', {}).status_code, 422)
        self.assertEqual(self.api_post('/favorites', {'product_id': 'x'}).status_code, 422)

    def test_favorites_require_the_app_header(self):
        self.api_login()
        response = self.api_post(
            '/favorites', {'product_id': self.product.id}, with_header=False)
        self.assertEqual(response.status_code, 403)

    def test_favorites_belong_to_the_account_not_to_one_user(self):
        """Doi utilizatori ai aceluiasi cabinet vad aceeasi lista, ca la comenzi."""
        self.api_login()
        self.api_post('/favorites', {'product_id': self.product.id})

        commercial = self.portal_user.partner_id.commercial_partner_id
        colleague = self.env['res.users'].create({
            'name': 'Coleg favorite test',
            'login': 'coleg.favorite@uportho.ro',
            'password': 'ColegTest123!',
            'groups_id': [(6, 0, [self.env.ref('base.group_portal').id])],
        })
        colleague.partner_id.parent_id = commercial.id

        self.authenticate('coleg.favorite@uportho.ro', 'ColegTest123!')
        self.assertIn(self.product.id, self.api_get('/favorites').json()['ids'])
