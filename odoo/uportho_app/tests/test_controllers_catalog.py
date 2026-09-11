import base64
from unittest.mock import patch

from odoo.addons.uportho_app.controllers import catalog as catalog_controller
from odoo.http import request
from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract

# PNG 1x1 valid, pentru campul Image al categoriei/produsului.
PNG_1PX = base64.b64decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=')


@tagged('post_install', '-at_install')
class TestControllersCategories(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.parent = cls.env['product.public.category'].create({'name': 'Bracketi Test'})
        cls.child = cls.env['product.public.category'].create({
            'name': 'Bracketi metalici Test', 'parent_id': cls.parent.id,
            'app_home_icon': base64.b64encode(PNG_1PX)})
        cls.other_website = cls.env['website'].create({'name': 'Alt site categorii test'})
        cls.foreign = cls.env['product.public.category'].create({
            'name': 'Doar pe alt site test', 'website_id': cls.other_website.id})

    def test_categories_requires_login(self):
        self.assertEqual(self.api_get('/categories').status_code, 401)

    def test_categories_shape_matches_contract(self):
        self.api_login()
        body = self.api_get('/categories').json()
        self.assertIsInstance(body, list)
        contract = load_contract('categories.json')
        self.assertEqual(set(body[0].keys()), set(contract[0].keys()))

    def test_categories_filtered_by_configured_or_no_website(self):
        # Fara parametrul de sistem setat, /categories cade pe get_current_website()
        # (acelasi mecanism ca /home) - vezi TestHomeWebsiteSelection pentru cazul cu
        # parametrul explicit. Aici verificam doar ca o categorie legata STRICT de un
        # alt website nu apare, indiferent care e website-ul curent rezolvat.
        self.api_login()
        own_ids = {self.parent.id, self.child.id, self.foreign.id}
        categories = {c['id']: c for c in self.api_get('/categories').json() if c['id'] in own_ids}
        self.assertIn(self.parent.id, categories)
        self.assertIn(self.child.id, categories)
        self.assertNotIn(self.foreign.id, categories)

    def test_categories_parent_id_and_icon_url(self):
        self.api_login()
        by_id = {c['id']: c for c in self.api_get('/categories').json()
                 if c['id'] in (self.parent.id, self.child.id)}
        self.assertIsNone(by_id[self.parent.id]['parent_id'])
        self.assertEqual(by_id[self.child.id]['parent_id'], self.parent.id)
        self.assertIsNone(by_id[self.parent.id]['icon_url'])
        self.assertTrue(by_id[self.child.id]['icon_url'].startswith(
            f'/api/app/v1/categories/{self.child.id}/icon?unique='))

    def test_categories_product_count_is_recursive(self):
        # Categoriile sunt proaspete (create in acest test), deci un numar de 0 la
        # inceput e garantat - nu depindem de ce mai exista in baza locala.
        # product_count trebuie sa fie identic cu ce filtreaza /products pe aceeasi
        # categorie (care foloseste 'child_of', recursiv) - altfel userul vede
        # "Bracketi - 42" pe /categories si un numar diferit de produse cand
        # intra efectiv pe categorie.
        self.api_login()
        Template = self.env['product.template']
        Template.create({
            'name': 'Produs pe categoria parinte', 'is_published': True,
            'public_categ_ids': [(6, 0, [self.parent.id])]})
        Template.create({
            'name': 'Produs pe categoria copil', 'is_published': True,
            'public_categ_ids': [(6, 0, [self.child.id])]})
        by_id = {c['id']: c for c in self.api_get('/categories').json()
                 if c['id'] in (self.parent.id, self.child.id)}
        # Parintele numara si propriul produs direct, si pe cel al copilului: 2.
        # Copilul numara doar al lui: 1.
        self.assertEqual(by_id[self.parent.id]['product_count'], 2)
        self.assertEqual(by_id[self.child.id]['product_count'], 1)

    def test_categories_product_count_does_not_double_count_shared_product(self):
        # Un produs prins DIRECT atat in parinte cat si in copil trebuie numarat o
        # singura data la parinte (child_of numara fiecare produs o data; o simpla
        # insumare a numerelor directe per nod l-ar numara de doua ori).
        self.api_login()
        Template = self.env['product.template']
        Template.create({
            'name': 'Produs pe ambele categorii', 'is_published': True,
            'public_categ_ids': [(6, 0, [self.parent.id, self.child.id])]})
        by_id = {c['id']: c for c in self.api_get('/categories').json()
                 if c['id'] in (self.parent.id, self.child.id)}
        self.assertEqual(by_id[self.parent.id]['product_count'], 1)
        self.assertEqual(by_id[self.child.id]['product_count'], 1)


@tagged('post_install', '-at_install')
class TestControllersProducts(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test produse', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        cls.category = cls.env['product.public.category'].create({'name': 'Categorie produse test'})
        cls.child_category = cls.env['product.public.category'].create({
            'name': 'Subcategorie produse test', 'parent_id': cls.category.id})
        cls.other_website = cls.env['website'].create({'name': 'Alt site produse test'})

        cls.product_visible = cls.env['product.template'].create({
            'name': 'Produs Vizibil ABC', 'default_code': 'SKU-ABC-TEST', 'is_published': True,
            'list_price': 100.0, 'public_categ_ids': [(6, 0, [cls.child_category.id])],
            'image_1920': base64.b64encode(PNG_1PX)})
        cls.product_unpublished = cls.env['product.template'].create({
            'name': 'Produs Nepublicat XYZ', 'is_published': False, 'list_price': 50.0})
        cls.product_other_website = cls.env['product.template'].create({
            'name': 'Produs Alt Site XYZ', 'is_published': True,
            'website_id': cls.other_website.id, 'list_price': 50.0})
        cls.product_no_image = cls.env['product.template'].create({
            'name': 'Produs Fara Poza Test', 'is_published': True, 'list_price': 10.0})

    def test_products_requires_login(self):
        self.assertEqual(self.api_get('/products').status_code, 401)

    def test_products_shape_matches_contract(self):
        self.api_login()
        body = self.api_get(f'/products?q={self.product_visible.default_code}').json()
        contract = load_contract('products.json')
        self.assertEqual(set(body.keys()), set(contract.keys()))
        self.assertEqual(set(body['products'][0].keys()), set(contract['products'][0].keys()))
        self.assertEqual(
            set(body['products'][0]['price'].keys()), set(contract['products'][0]['price'].keys()))

    def test_products_only_published_and_on_configured_website(self):
        self.api_login()
        own_ids = {self.product_visible.id, self.product_unpublished.id, self.product_other_website.id}
        body = self.api_get('/products?q=XYZ').json()
        # Doar produsul publicat pe alt website ar putea aparea aici gresit; cel
        # nepublicat pe niciun website nu ar trebui sa apara niciodata.
        ids = {p['id'] for p in body['products'] if p['id'] in own_ids}
        self.assertEqual(ids, set())

        # limit=100 explicit: la limit-ul implicit (20), acest test ar pica pe o baza
        # cu mai mult de 20 de produse care contin "Produs" in nume, dintr-un motiv
        # care n-are legatura cu ce testeaza (paginare, nu filtrare) - fragil, semnalat
        # de review.
        body_all = self.api_get('/products?q=Produs&limit=100').json()
        ids_all = {p['id'] for p in body_all['products'] if p['id'] in own_ids}
        self.assertEqual(ids_all, {self.product_visible.id})

    def test_products_category_filter_includes_descendants(self):
        self.api_login()
        # Categoria e proaspata (creata in acest test), deci lista de produse gasite
        # pe ea in aceasta baza e garantat doar a noastra.
        body = self.api_get(f'/products?category_id={self.category.id}').json()
        ids = {p['id'] for p in body['products']}
        self.assertEqual(ids, {self.product_visible.id})

    def test_products_search_by_default_code(self):
        self.api_login()
        body = self.api_get('/products?q=SKU-ABC-TEST').json()
        ids = {p['id'] for p in body['products']}
        self.assertEqual(ids, {self.product_visible.id})

    def test_products_pagination_and_total(self):
        self.api_login()
        Template = self.env['product.template']
        created = Template.create([
            {'name': f'Produs Pagina Test {i}', 'is_published': True, 'list_price': 10.0}
            for i in range(5)
        ])
        body_page1 = self.api_get('/products?q=Produs Pagina Test&limit=2&offset=0').json()
        self.assertEqual(body_page1['total'], 5)
        self.assertEqual(len(body_page1['products']), 2)
        self.assertEqual(body_page1['offset'], 0)
        self.assertEqual(body_page1['limit'], 2)

        body_page3 = self.api_get('/products?q=Produs Pagina Test&limit=2&offset=4').json()
        self.assertEqual(body_page3['total'], 5)
        self.assertEqual(len(body_page3['products']), 1)

        seen_ids = set()
        for offset in (0, 2, 4):
            page = self.api_get(f'/products?q=Produs Pagina Test&limit=2&offset={offset}').json()
            seen_ids |= {p['id'] for p in page['products']}
        self.assertEqual(seen_ids, set(created.ids))

    def test_products_default_limit_is_20_and_capped_at_100(self):
        self.api_login()
        body_default = self.api_get('/products?q=Produs Pagina Test Nu Exista').json()
        self.assertEqual(body_default['limit'], 20)

        body_capped = self.api_get('/products?limit=500').json()
        self.assertEqual(body_capped['limit'], 100)

    def test_products_pagination_with_identical_names_yields_each_once(self):
        # I8: ordinea implicita a modelului ('is_favorite desc, name') nu include
        # 'id', deci fara order explicit doua produse cu ACELASI nume isi pot schimba
        # ordinea intre doua pagini succesive - testul de mai sus (nume distincte) nu
        # ar prinde niciodata asta. Cu nume identice, orice ambiguitate de ordine ar
        # duplica un produs pe doua pagini si l-ar sari complet pe altul.
        self.api_login()
        Template = self.env['product.template']
        created = Template.create([
            {'name': 'Produs Nume Identic Test', 'is_published': True, 'list_price': 10.0}
            for _ in range(5)
        ])
        seen_ids = []
        for offset in (0, 1, 2, 3, 4):
            page = self.api_get(
                f'/products?q=Produs Nume Identic Test&limit=1&offset={offset}').json()
            seen_ids.extend(p['id'] for p in page['products'])
        # Fiecare produs exact o data - nici duplicat, nici sarit.
        self.assertEqual(sorted(seen_ids), sorted(created.ids))

    def test_products_search_wildcard_characters_are_escaped(self):
        # M15: '%' si '_' nescapate ar deveni wildcard-uri LIKE/ILIKE - q='%' ar
        # trebui sa caute literal caracterul '%' (deci sa nu gaseasca nimic aici),
        # nu sa listeze tot catalogul.
        self.api_login()
        body = self.api_get('/products?q=%25').json()  # %25 = '%' encodat in URL
        self.assertEqual(body['products'], [])
        self.assertEqual(body['total'], 0)

    def test_products_offset_garbage_is_422(self):
        self.api_login()
        response = self.api_get('/products?offset=abc')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_products_limit_garbage_is_422(self):
        self.api_login()
        response = self.api_get('/products?limit=abc')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_products_pricelist_unavailable_is_503_not_500(self):
        # M16: property_product_pricelist e un camp calculat; daca vreodata rezolva
        # gol pentru un cont, currency.round(...) din calculul de pret ar arunca
        # ensure_one() (ValueError) si ar iesi ca 500 generic prin except Exception
        # din app_route - simulam exact acel gol cu un mock pe metoda Odoo care
        # rezolva fallback-ul, ca sa verificam ca raspunsul e un 503 clar, nu 500.
        self.api_login()
        Pricelist = type(self.env['product.pricelist'])
        with patch.object(Pricelist, '_get_partner_pricelist_multi', return_value={}):
            response = self.api_get('/products')
        self.assertEqual(response.status_code, 503)
        self.assertEqual(response.json()['error']['code'], 'pricelist_unavailable')

    def test_product_image_requires_login(self):
        self.assertEqual(self.api_get(f'/products/{self.product_visible.id}/image').status_code, 401)

    def test_product_image_served_when_present(self):
        self.api_login()
        response = self.api_get(f'/products/{self.product_visible.id}/image')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.headers['Content-Type'].startswith('image/'))

    def test_product_image_missing_is_404(self):
        # Produsul e publicat (accesibil), doar fara imagine - distinct de cazul de mai
        # jos, unde regulile de acces resping complet un produs nepublicat.
        self.api_login()
        self.assertEqual(self.api_get(f'/products/{self.product_no_image.id}/image').status_code, 404)
        self.assertEqual(self.api_get('/products/999999/image').status_code, 404)

    def test_product_image_of_unpublished_product_is_forbidden(self):
        # Un produs nepublicat nu e vizibil deloc pentru portal - regulile de acces
        # standard ale Odoo resping citirea lui, deci ruta raspunde 403, nu 404
        # (comportament corect: nu dam de gol ca id-ul exista, dar nici nu il aratam).
        self.api_login()
        self.assertEqual(self.api_get(f'/products/{self.product_unpublished.id}/image').status_code, 403)


@tagged('post_install', '-at_install')
class TestControllersProductPricing(AppHttpCase):
    """Testeaza inima acestei felii: pretul clientului (pe pricelist-ul lui, cu taxe
    incluse), reducerea aratata (list_amount/discount_pct), pretul Ortho Club (dupa bifa
    clientului `is_compare_pricelist`, cu parametrul de sistem doar ca rezerva pe o baza
    fara modulele lor - niciodata un id fix in cod) si eticheta."""

    CLUB_PARAM = 'uportho_app.club_pricelist_id'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.tax = cls.env['account.tax'].create({
            'name': 'TVA test 20%', 'amount': 20.0, 'amount_type': 'percent',
            'type_tax_use': 'sale', 'price_include_override': 'tax_excluded'})

        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test pret', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        # 200 fara TVA, -50% pe pricelist-ul clientului -> 100 fara TVA -> 120 cu TVA;
        # lista taiata: 200 fara TVA -> 240 cu TVA. Discount asteptat: 50%.
        cls.discounted = cls.env['product.template'].create({
            'name': 'Produs cu reducere test pret', 'is_published': True,
            'list_price': 200.0, 'taxes_id': [(6, 0, [cls.tax.id])]})
        cls.env['product.pricelist.item'].create({
            'pricelist_id': cls.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': cls.discounted.id, 'compute_price': 'percentage',
            'percent_price': 50})

        # Fara regula de pricelist pentru acest produs -> pretul e list_price simplu,
        # fara reducere de aratat: 100 fara TVA -> 120 cu TVA.
        cls.plain = cls.env['product.template'].create({
            'name': 'Produs fara reducere test pret', 'is_published': True,
            'list_price': 100.0, 'taxes_id': [(6, 0, [cls.tax.id])]})

        cls.badged = cls.env['product.template'].create({
            'name': 'Produs cu eticheta test pret', 'is_published': True,
            'list_price': 10.0, 'app_badge_text': 'Nou', 'app_badge_color': 'green'})

    def setUp(self):
        super().setUp()
        # ir.config_parameter e citit prin ormcache; rollback-ul tranzactiei de test nu
        # curata cache-ul, deci il golim explicit intre teste (acelasi fix ca in
        # TestHomeWebsiteSelection din test_controllers_home.py).
        self.addCleanup(self.registry.clear_cache)

    def _product(self, name_fragment):
        self.api_login()
        body = self.api_get(f'/products?q={name_fragment}').json()
        return next(p for p in body['products'] if p['name'].startswith(name_fragment))

    def _expected_formatted(self, number_text, currency=None):
        # Constructie in oglinda cu _format_amount (M10): nu presupunem simbolul dupa
        # numar, il luam din currency.position - valuta companiei de test nu e RON
        # (e USD, cu simbolul inainte), asa ca testul chiar exerseaza ambele pozitii.
        currency = currency or self.currency
        if currency.position == 'before':
            return f'{currency.symbol}{number_text}'
        return f'{number_text} {currency.symbol}'

    def test_product_price_with_discount(self):
        price = self._product('Produs cu reducere test pret')['price']
        self.assertEqual(price['currency'], self.currency.name)
        self.assertAlmostEqual(price['amount'], 120.0, places=2)
        self.assertAlmostEqual(price['list_amount'], 240.0, places=2)
        self.assertEqual(price['discount_pct'], 50)
        self.assertTrue(price['with_vat'])
        self.assertEqual(price['formatted'], self._expected_formatted('120,00'))
        # Pretul taiat vine formatat de server, nu ca numar brut: aplicatia il
        # afisa altfel cu "22430,00 lei", fara separatorul de mii, langa un pret
        # curent formatat corect.
        self.assertEqual(price['list_formatted'], self._expected_formatted('240,00'))

    def test_product_price_without_discount(self):
        price = self._product('Produs fara reducere test pret')['price']
        self.assertAlmostEqual(price['amount'], 120.0, places=2)
        self.assertIsNone(price['list_amount'])
        self.assertIsNone(price['list_formatted'])
        self.assertIsNone(price['discount_pct'])

    def test_list_formatted_has_thousands_separator(self):
        # Regresie directa pentru ce s-a vazut pe staging: peste 1000, pretul taiat
        # trebuie sa aiba separator de mii, la fel ca pretul curent.
        # Fara taxa, ca list_amount sa fie exact 22430 si testul sa vorbeasca
        # despre separatorul de mii, nu despre calculul de TVA.
        product = self.env['product.template'].create({
            'name': 'Produs scump test pret mii', 'is_published': True,
            'list_price': 22430.0, 'taxes_id': [(6, 0, [])]})
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'compute_price': 'percentage',
            'percent_price': 30.0})
        price = self._product('Produs scump test pret mii')['price']
        self.assertEqual(price['list_formatted'], self._expected_formatted('22.430,00'))

    def test_price_formatting_uses_currency_decimal_places_and_position(self):
        # M10: catalog.py presupunea 2 zecimale si simbolul mereu dupa numar. BHD
        # (Bahraini Dinar) are 3 zecimale si, in date, simbolul dupa - diferit de
        # valuta companiei de test (2 zecimale, simbol INAINTE, vezi
        # _expected_formatted) - proba ca ambele campuri chiar vin din
        # currency.decimal_places / currency.position, nu dintr-o presupunere fixa.
        bhd = self.env['res.currency'].with_context(active_test=False).search(
            [('name', '=', 'BHD')], limit=1)
        self.assertTrue(bhd, 'Baza demo Odoo ar trebui sa aiba mereu un rand BHD (inactiv sau nu).')
        bhd_pricelist = self.env['product.pricelist'].create({
            'name': 'Lista BHD test pret', 'currency_id': bhd.id})
        self.portal_user.partner_id.property_product_pricelist = bhd_pricelist.id
        price = self._product('Produs fara reducere test pret')['price']
        self.assertEqual(price['currency'], 'BHD')
        self.assertEqual(bhd.position, 'after')  # presupunere de fixture, nu a codului
        self.assertTrue(price['formatted'].endswith(f' {bhd.symbol}'))
        number = price['formatted'][:-len(f' {bhd.symbol}')]
        decimal_digits = number.split(',')[-1]
        self.assertEqual(len(decimal_digits), 3)

    def test_club_price_null_when_parameter_not_set(self):
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])

    def test_club_price_present_when_parameter_set(self):
        # I20: pricelist-ul de club trebuie sa aiba o regula REALA (10% reducere),
        # altfel testul nu poate distinge intre "s-a calculat pretul de club corect"
        # si "s-a intors din greseala pretul clientului" (bug precis: schimba
        # club_pricelist cu pricelist in serialize_product si testul vechi tot trecea,
        # pentru ca ambele preturi ar fi iesit identice - 120.0 - fara nicio regula).
        club_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club test pret', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': club_pricelist.id, 'applied_on': '3_global',
            'compute_price': 'percentage', 'percent_price': 10})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(club_pricelist.id))
        product = self._product('Produs fara reducere test pret')
        self.assertIsNotNone(product['club_price'])
        # Pret client (fara regula): 100 fara TVA -> 120 cu TVA. Pret club (-10% pe
        # pricelist): 90 fara TVA -> 108 cu TVA. Diferit de pretul clientului - daca
        # nu ar fi, ar insemna ca s-a folosit din greseala pricelist-ul clientului.
        self.assertAlmostEqual(product['club_price']['amount'], 108.0, places=2)
        self.assertNotAlmostEqual(product['club_price']['amount'], product['price']['amount'], places=2)
        self.assertEqual(product['club_price']['currency'], self.currency.name)

    def test_club_price_null_and_warns_when_parameter_points_to_missing_record(self):
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '999999')
        with self.assertLogs('odoo.addons.uportho_app.controllers.catalog', level='WARNING'):
            product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])

    def test_club_price_null_and_warns_when_pricelist_is_archived(self):
        # Cazul real de rollover anual: adminul arhiveaza "Ortho Club 2026" cand apare
        # noul an. Odoo NU filtreaza liniile de pricelist arhivate la calculul
        # pretului (product/models/product_pricelist.py: "Do not filter out archived
        # pricelist items"), deci fara acest filtru explicit club_price ar iesi un
        # pret invechit, nu null.
        club_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club arhivata test pret', 'currency_id': self.currency.id,
            'active': False})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(club_pricelist.id))
        with self.assertLogs('odoo.addons.uportho_app.controllers.catalog', level='WARNING'):
            product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])

    def test_club_price_null_when_currency_differs_from_customer(self):
        # I7: docs/STAGING.md confirma o lista "Euro Discount" printre cele 14 active
        # pe baza reala - daca parametrul ar indica din greseala o lista de club
        # intr-o alta valuta decat a clientului, club_price trebuie sa fie null, nu
        # un numar intr-o valuta necomparabila cu 'price'.
        eur = self.env['res.currency'].with_context(active_test=False).search(
            [('name', '=', 'EUR')], limit=1)
        self.assertTrue(eur, 'Baza demo Odoo ar trebui sa aiba mereu un rand EUR (inactiv sau nu).')
        club_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club EUR test pret', 'currency_id': eur.id})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(club_pricelist.id))
        with self.assertLogs('odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])
        self.assertTrue(any('valuta diferita' in message for message in captured.output))

    def test_club_price_null_when_equal_to_customer_price(self):
        # M14: spec 6.4 - club_price se arata "cand difera". O lista de club fara
        # nicio regula pentru acest produs da acelasi pret ca al clientului (care de
        # asemenea nu are regula pentru el) - nu trebuie aratat separat.
        club_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club identic test pret', 'currency_id': self.currency.id})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(club_pricelist.id))
        product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])

    # --- de unde se ia lista de club: bifa clientului, parametrul doar ca rezerva ---

    def test_local_database_has_no_client_club_flag(self):
        # Premisa tuturor testelor de mai sus: campul clientului chiar lipseste pe baza
        # locala, deci ele exerseaza pe bune ramura de rezerva (parametrul de sistem).
        # Daca modulele clientului ar ajunge vreodata aici, testele acelea ar deveni
        # degenerate fara sa se vada - asa se vede.
        self.assertNotIn('is_compare_pricelist', self.env['product.pricelist']._fields)

    def _client_flags(self, pricelist=None):
        """Simuleaza prezenta bifei clientului (`is_compare_pricelist`), camp care nu
        exista pe baza locala. Se inlocuieste DOAR cautarea dupa bifa; restul -
        filtrarea listelor arhivate, warning-urile, comparatia de valuta, calculul
        pretului - ruleaza codul adevarat. Recordset-ul se re-obtine in mediul cererii
        (nu se trece cel din test), ca sa fie exact ce ar da cautarea reala."""
        pricelist_id = pricelist.id if pricelist else None

        def flagged():
            Pricelist = request.env['product.pricelist'].sudo()
            return Pricelist.browse(pricelist_id) if pricelist_id else Pricelist.browse()

        return patch.object(catalog_controller, '_flagged_club_pricelist', flagged)

    def test_club_pricelist_comes_from_the_client_flag_not_from_the_parameter(self):
        # Motivul intregii schimbari: pana acum lista de club venea din parametrul de
        # sistem, iar tabelul de club de pe pagina de produs din bifa clientului. La
        # trecerea la lista anului urmator cele doua puteau ramane pe liste diferite,
        # fara nicio eroare. Aici sunt puse DELIBERAT in dezacord: bifa (-10% -> 108)
        # si parametrul (-25% -> 90). Trebuie sa castige bifa.
        flagged_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club bifata test pret', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': flagged_pricelist.id, 'applied_on': '3_global',
            'compute_price': 'percentage', 'percent_price': 10})
        stale_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club veche din parametru test pret', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': stale_pricelist.id, 'applied_on': '3_global',
            'compute_price': 'percentage', 'percent_price': 25})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(stale_pricelist.id))

        with self._client_flags(flagged_pricelist):
            product = self._product('Produs fara reducere test pret')
        self.assertIsNotNone(product['club_price'])
        self.assertAlmostEqual(product['club_price']['amount'], 108.0, places=2)

    def test_club_price_null_and_warns_when_no_pricelist_carries_the_flag(self):
        # Baza are mecanismul clientului, dar nicio lista nu e bifata: NU se cade
        # inapoi pe parametrul de sistem (asta ar reintroduce a doua sursa de adevar,
        # exact ce s-a scos), ci club_price e null si warning-ul spune ce bifa lipseste.
        # Parametrul e setat pe o lista valida tocmai ca sa se vada ca nu e consultat.
        param_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club ignorata test pret', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': param_pricelist.id, 'applied_on': '3_global',
            'compute_price': 'percentage', 'percent_price': 25})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(param_pricelist.id))

        with self._client_flags(None):
            with self.assertLogs(
                    'odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
                product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])
        self.assertTrue(any('is_compare_pricelist' in message for message in captured.output))

    def test_club_price_null_and_warns_when_flagged_pricelist_is_archived(self):
        # Acelasi cap de rollover anual ca la parametru, dar pe ramura bifei: Odoo NU
        # filtreaza liniile de pricelist arhivate la calculul pretului, deci o lista
        # arhivata ramasa bifata ar da tacut preturi vechi, nu o eroare.
        archived_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club bifata arhivata test pret', 'currency_id': self.currency.id,
            'active': False})
        self.env['product.pricelist.item'].create({
            'pricelist_id': archived_pricelist.id, 'applied_on': '3_global',
            'compute_price': 'percentage', 'percent_price': 10})

        with self._client_flags(archived_pricelist):
            with self.assertLogs(
                    'odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
                product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])
        self.assertTrue(any('is_compare_pricelist' in message for message in captured.output))

    def test_fallback_warning_names_the_system_parameter(self):
        # Warning-ul trebuie sa spuna PE CE mecanism s-a cazut, ca o configurare gresita
        # sa se diagnosticheze din log, fara sa umble nimeni prin cod.
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        with self.assertLogs(
                'odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            product = self._product('Produs fara reducere test pret')
        self.assertIsNone(product['club_price'])
        self.assertTrue(any(self.CLUB_PARAM in message for message in captured.output))

    def test_tax_display_warning_when_website_not_tax_included(self):
        # I9: spec-ul si site-ul presupun TVA inclus ('Taxe incluse'); daca website-ul
        # e vreodata reconfigurat pe 'tax_excluded', modulul tot arata with_vat=True
        # (nu recalculeaza), dar trebuie sa avertizeze, ca discrepanta sa fie vizibila
        # in loguri, nu descoperita de un client care compara cu magazinul.
        website = self.env['website'].create({
            'name': 'Website taxe excluse test', 'show_line_subtotals_tax_selection': 'tax_excluded'})
        self.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(website.id))
        with self.assertLogs('odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            self._product('Produs fara reducere test pret')
        self.assertTrue(any('show_line_subtotals_tax_selection' in message for message in captured.output))

    def test_no_tax_display_warning_when_website_is_tax_included(self):
        # Negativul testului de mai sus: cand website-ul chiar e pe 'tax_included',
        # nu trebuie sa apara acest warning specific (alte warning-uri, ca cel pentru
        # club_pricelist nesetat, pot aparea in continuare - de-aia verificam continutul
        # mesajelor, nu doar ca "s-a logat ceva").
        website = self.env['website'].create({
            'name': 'Website taxe incluse test', 'show_line_subtotals_tax_selection': 'tax_included'})
        self.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(website.id))
        with self.assertLogs('odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            self._product('Produs fara reducere test pret')
        self.assertFalse(any('show_line_subtotals_tax_selection' in message for message in captured.output))

    def test_rating_comes_from_the_same_reviews_as_the_product_page(self):
        """Pe site cardul poarta o pastila cu nota, desenata doar cand produsul are
        recenzii (`rating_get_stats`). Nota din lista trebuie sa fie aceeasi cu cea din
        pagina produsului, altfel acelasi produs ar arata doua cifre."""
        self.api_login()
        listed = self._product('Produs cu eticheta test pret')
        self.assertIsNone(listed['rating'], 'fara recenzii nu exista pastila')

        template = self.env['product.template'].browse(listed['id'])
        for value in (5, 4):
            partner = self.env['res.partner'].create({'name': f'Autor nota {value} test'})
            self.env['rating.rating'].sudo().create({
                'res_model_id': self.env['ir.model']._get_id('product.template'),
                'res_id': template.id,
                'rating': value,
                'consumed': True,
                'partner_id': partner.id,
            })

        rating = self._product('Produs cu eticheta test pret')['rating']
        self.assertEqual(rating, {'average': 4.5, 'count': 2})
        detail = self.api_get(f"/products/{template.id}").json()['rating']
        self.assertEqual(detail, rating)

    def test_an_internal_review_does_not_change_the_card(self):
        """Recenziile interne nu se arata nicaieri, deci nici nota de pe card."""
        self.api_login()
        template = self.env['product.template'].browse(
            self._product('Produs fara reducere test pret')['id'])
        partner = self.env['res.partner'].create({'name': 'Autor intern nota test'})
        self.env['rating.rating'].sudo().create({
            'res_model_id': self.env['ir.model']._get_id('product.template'),
            'res_id': template.id,
            'rating': 1,
            'consumed': True,
            'is_internal': True,
            'partner_id': partner.id,
        })

        self.assertIsNone(self._product('Produs fara reducere test pret')['rating'])

    def test_badge_present_and_absent(self):
        self.assertEqual(
            self._product('Produs cu eticheta test pret')['badge'],
            {'text': 'Nou', 'color': 'green', 'background_color': None, 'text_color': None})
        self.assertIsNone(self._product('Produs fara reducere test pret')['badge'])


class _WebsiteWithoutShopSort:
    """Dublura pentru o baza pe care `website.shop_default_sort` nu exista deloc
    (website_sale lipsa sau redenumit intr-o versiune viitoare de Odoo). Nu se poate
    obtine dintr-un website real fara sa umblam la `_fields`-ul modelului in timp ce
    serverul il foloseste, deci ordinea se cere direct functiei."""

    _fields = {}

    def __init__(self, env):
        self.env = env
        self.id = 0
        self.name = 'Site fara shop_default_sort'

    def sudo(self):
        return self


@tagged('post_install', '-at_install')
class TestControllersProductsOrdering(AppHttpCase):
    """Ordinea listei de produse.

    Magazinul isi ordoneaza rafturile dupa `website.shop_default_sort` (implicit
    'website_sequence asc', ordinea manuala din spatele sortarii "Recomandate"), nu
    alfabetic. Aplicatia citea ordinea implicita a modelului
    ('is_favorite desc, name'), deci arata alta lista decat site-ul."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test ordine', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        cls.website = cls.env['website'].create({
            'name': 'Site ordine test', 'shop_default_sort': 'website_sequence asc',
            'show_line_subtotals_tax_selection': 'tax_included'})
        cls.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(cls.website.id))

        cls.category = cls.env['product.public.category'].create({'name': 'Categorie ordine test'})
        # Numele cresc alfabetic exact invers fata de secventa de magazin: orice
        # raspuns ordonat alfabetic iese in oglinda fata de cel corect.
        cls.alfa = cls.env['product.template'].create({
            'name': 'Ordine Test Alfa', 'is_published': True, 'list_price': 10.0,
            'website_sequence': 300, 'public_categ_ids': [(6, 0, [cls.category.id])]})
        cls.beta = cls.env['product.template'].create({
            'name': 'Ordine Test Beta', 'is_published': True, 'list_price': 10.0,
            'website_sequence': 200, 'public_categ_ids': [(6, 0, [cls.category.id])]})
        cls.gama = cls.env['product.template'].create({
            'name': 'Ordine Test Gama', 'is_published': True, 'list_price': 10.0,
            'website_sequence': 100, 'public_categ_ids': [(6, 0, [cls.category.id])]})
        cls.own_ids = {cls.alfa.id, cls.beta.id, cls.gama.id}

    def _own_ids_in_order(self, path):
        body = self.api_get(path).json()
        return [p['id'] for p in body['products'] if p['id'] in self.own_ids]

    def test_search_listing_follows_website_sequence_not_the_alphabet(self):
        self.api_login()
        self.assertEqual(
            self._own_ids_in_order('/products?q=Ordine Test&limit=100'),
            [self.gama.id, self.beta.id, self.alfa.id])

    def test_category_listing_follows_website_sequence(self):
        # Aceeasi ordine trebuie sa se aplice si listei filtrate pe categorie, nu doar
        # cautarii - altfel utilizatorul vede doua ordini diferite in acelasi ecran.
        self.api_login()
        self.assertEqual(
            self._own_ids_in_order(f'/products?category_id={self.category.id}&limit=100'),
            [self.gama.id, self.beta.id, self.alfa.id])

    def test_order_follows_the_website_setting_without_a_code_change(self):
        # Rostul intregii schimbari: cand magazinul isi schimba sortarea implicita din
        # Odoo, aplicatia o urmeaza fara release. 'name asc' e o valoare reala din
        # selectia website_sale ("Name (A-Z)").
        self.api_login()
        self.website.shop_default_sort = 'name asc'
        self.assertEqual(
            self._own_ids_in_order('/products?q=Ordine Test&limit=100'),
            [self.alfa.id, self.beta.id, self.gama.id])

    def test_paging_over_equal_sequences_neither_repeats_nor_loses_a_product(self):
        # Doua produse cu ACEEASI website_sequence: fara un criteriu stabil la final,
        # baza le poate intoarce in ordine diferita la doua interogari succesive, iar
        # scroll-ul infinit al aplicatiei ar arata unul de doua ori si l-ar sari
        # complet pe celalalt - tacut, fara nicio eroare.
        self.api_login()
        twins = self.env['product.template'].create([
            {'name': 'Ordine Geamana Unu', 'is_published': True, 'list_price': 10.0,
             'website_sequence': 500},
            {'name': 'Ordine Geamana Doi', 'is_published': True, 'list_price': 10.0,
             'website_sequence': 500},
        ])
        seen = []
        for offset in (0, 1):
            body = self.api_get(
                f'/products?q=Ordine Geamana&limit=1&offset={offset}').json()
            seen.extend(p['id'] for p in body['products'])
        # Fiecare o singura data, si in ordinea deterministica data de criteriul
        # 'id desc' - aceeasi departajare pe care o face magazinul, deci cele doua
        # produse apar la fel ca pe site, nu invers.
        self.assertEqual(seen, sorted(twins.ids, reverse=True))

    def test_nonsense_sort_setting_falls_back_and_warns(self):
        # `shop_default_sort` e text pe care un administrator de site il poate ajunge sa
        # editeze (selectie extinsa de un modul, scriere directa in baza). Interpolat
        # orbeste in `order`, ar iesi 500 la fiecare listare de catalog - sau mai rau.
        # Scrierea prin ORM ar fi respinsa de validarea de Selection, deci punem
        # valoarea gresita direct in baza, exact cum ar ajunge acolo.
        self.api_login()
        self.env.cr.execute(
            'UPDATE website SET shop_default_sort = %s WHERE id = %s',
            ('name asc; DROP TABLE res_users', self.website.id))
        self.env['website'].invalidate_model(['shop_default_sort'])
        with self.assertLogs(
                'odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            ids = self._own_ids_in_order('/products?q=Ordine Test&limit=100')
        # Cade pe ordinea sigura ('website_sequence, id'), nu pe alfabetic si nu pe 500.
        self.assertEqual(ids, [self.gama.id, self.beta.id, self.alfa.id])
        self.assertTrue(any('shop_default_sort' in message for message in captured.output))

    def test_empty_sort_setting_falls_back_and_warns(self):
        # Coloana e NOT NULL (campul e `required=True`), deci "gol" inseamna sir vid,
        # nu NULL - asa poate arata dupa o migrare sau un import.
        self.api_login()
        self.env.cr.execute(
            "UPDATE website SET shop_default_sort = '' WHERE id = %s", (self.website.id,))
        self.env['website'].invalidate_model(['shop_default_sort'])
        with self.assertLogs(
                'odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            ids = self._own_ids_in_order('/products?q=Ordine Test&limit=100')
        self.assertEqual(ids, [self.gama.id, self.beta.id, self.alfa.id])
        self.assertTrue(any('shop_default_sort' in message for message in captured.output))

    def test_missing_sort_field_falls_back_and_warns(self):
        with self.assertLogs(
                'odoo.addons.uportho_app.controllers.catalog', level='WARNING') as captured:
            order = catalog_controller._products_order(_WebsiteWithoutShopSort(self.env))
        self.assertEqual(order, catalog_controller.PRODUCTS_ORDER_FALLBACK)
        self.assertTrue(any('shop_default_sort' in message for message in captured.output))

    def test_sanitized_order_accepts_only_real_fields_and_directions(self):
        Template = self.env['product.template']
        for raw in (
                'name asc; DROP TABLE res_users',   # injectie
                'nu_exista_pe_template asc',        # camp inexistent
                'name sideways',                    # directie inventata
                'name asc desc',                    # doua directii
                '(SELECT 1)',
                'name,',                            # termen gol
                '',
        ):
            self.assertIsNone(
                catalog_controller._sanitized_order(raw, Template), f'ar fi trebuit respins: {raw!r}')

    def test_sanitized_order_appends_a_stable_tiebreaker_once(self):
        Template = self.env['product.template']
        self.assertEqual(
            catalog_controller._sanitized_order('website_sequence asc', Template),
            'website_sequence asc, id desc')
        self.assertEqual(
            catalog_controller._sanitized_order('create_date desc', Template),
            'create_date desc, id desc')
        # Daca sortarea configurata se termina deja pe campul 'id', nu se mai adauga
        # inca unul - indiferent de directia scrisa acolo, ordinea e deja stabila.
        self.assertEqual(
            catalog_controller._sanitized_order('website_sequence asc, id desc', Template),
            'website_sequence asc, id desc')
        self.assertEqual(
            catalog_controller._sanitized_order('website_sequence asc, id asc', Template),
            'website_sequence asc, id asc')
