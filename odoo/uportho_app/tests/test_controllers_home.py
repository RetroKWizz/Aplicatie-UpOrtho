import base64
import hashlib

from odoo.tests.common import TransactionCase, tagged

from ..controllers.home import category_icon_field, instagram_username
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


@tagged('post_install', '-at_install')
class TestHomeWebsiteSelection(AppHttpCase):
    """Ce website serveste /home cand exista mai multe.

    Pe instanta reala magazinul e un anume website (11) si host-ul prin care intra
    aplicatia nu e neaparat domeniul lui; fara parametrul de sistem, continutul ar
    disparea tacut."""

    # Numele parametrului e scris aici literal, ca testul sa il si fixeze:
    # cine face deploy trebuie sa seteze exact acest parametru.
    WEBSITE_PARAM = 'uportho_app.website_id'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.website_a = cls.env['website'].search([], limit=1)
        cls.website_b = cls.env['website'].create({'name': 'Al doilea website'})
        cls.banner_a = cls.env['uportho.app.banner'].create({
            'name': 'Doar pe A', 'placement': 'hero', 'link_type': 'none',
            'website_id': cls.website_a.id})
        cls.banner_b = cls.env['uportho.app.banner'].create({
            'name': 'Doar pe B', 'placement': 'hero', 'link_type': 'none',
            'website_id': cls.website_b.id})

    def setUp(self):
        super().setUp()
        # ir.config_parameter e citit prin ormcache; rollback-ul tranzactiei de test nu
        # curata cache-ul, deci il golim explicit ca sa nu se scurga intre teste.
        self.addCleanup(self.registry.clear_cache)

    def _banner_ids(self):
        return {b['id'] for b in self.api_get('/home').json()['banners']}

    def test_without_parameter_falls_back_to_get_current_website(self):
        self.api_login()
        ids = self._banner_ids()
        self.assertIn(self.banner_a.id, ids)
        self.assertNotIn(self.banner_b.id, ids)

    def test_config_parameter_wins_over_the_host_header(self):
        self.env['ir.config_parameter'].sudo().set_param(self.WEBSITE_PARAM, str(self.website_b.id))
        self.api_login()
        ids = self._banner_ids()
        self.assertIn(self.banner_b.id, ids)
        self.assertNotIn(self.banner_a.id, ids)

    def test_parameter_pointing_to_a_missing_website_falls_back_with_a_warning(self):
        self.env['ir.config_parameter'].sudo().set_param(self.WEBSITE_PARAM, '999999')
        self.api_login()
        with self.assertLogs('odoo.addons.uportho_app.controllers.home', level='WARNING'):
            ids = self._banner_ids()
        self.assertIn(self.banner_a.id, ids)


@tagged('post_install', '-at_install')
class TestCategoryIconFallback(AppHttpCase):
    """Iconita categoriei cade pe poza din magazin cand nu are una scrisa pentru
    aplicatie. Pe instanta reala toate cele 6 categorii de pe Acasa aveau poza de pe
    site si niciuna n-avea iconita de aplicatie: fara rezerva asta, Acasa arata
    acelasi patrat generic la toate."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        Category = cls.env['product.public.category']
        cls.doar_poza_magazin = Category.create({
            'name': 'Doar poza de magazin', 'app_home_visible': True,
            'app_home_sequence': 1, 'image_1920': base64.b64encode(PNG_1PX)})
        cls.amandoua = Category.create({
            'name': 'Si iconita si poza', 'app_home_visible': True, 'app_home_sequence': 2,
            'app_home_icon': base64.b64encode(PNG_1PX),
            'image_1920': base64.b64encode(PNG_1PX_RED)})
        cls.fara_nimic = Category.create({
            'name': 'Fara nicio poza', 'app_home_visible': True, 'app_home_sequence': 3})

    def test_iconita_proprie_bate_poza_de_magazin(self):
        self.assertEqual(category_icon_field(self.amandoua), 'app_home_icon')

    def test_fara_iconita_se_ia_poza_de_magazin(self):
        self.assertEqual(category_icon_field(self.doar_poza_magazin), 'image_1920')

    def test_fara_nicio_poza_nu_exista_iconita(self):
        self.assertIsNone(category_icon_field(self.fara_nimic))

    def test_home_trimite_url_pentru_categoria_cu_poza_de_magazin(self):
        self.api_login()
        categories = {c['id']: c for c in self.api_get('/home').json()['quick_categories']}

        self.assertIsNotNone(categories[self.doar_poza_magazin.id]['icon_url'])
        self.assertIsNone(categories[self.fara_nimic.id]['icon_url'])

    def test_ruta_serveste_poza_de_magazin_si_refuza_categoria_fara_poza(self):
        """Ruta face aceeasi alegere ca `/home`, altfel ar da 404 pentru un URL pe
        care tot noi l-am trimis."""
        self.api_login()

        self.assertEqual(
            self.api_get(f'/categories/{self.doar_poza_magazin.id}/icon').status_code, 200)
        self.assertEqual(self.api_get(f'/categories/{self.fara_nimic.id}/icon').status_code, 404)


@tagged('post_install', '-at_install')
class TestBannerImageOnly(AppHttpCase):
    """Un banner a carui imagine poarta deja textul.

    Pe staging, imaginea bannerului Ortho Club avea scris pe ea chiar "Ortho Club" si
    subtitlul, iar aplicatia isi desena titlul si subtitlul peste: doua texte
    suprapuse, bannerul arata rupt."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        Banner = cls.env['uportho.app.banner']
        cls.cu_text_in_poza = Banner.create({
            'name': 'Banner cu text in poza', 'subtitle': 'Nu se arata',
            'placement': 'hero', 'image': base64.b64encode(PNG_1PX), 'image_only': True})
        cls.obisnuit = Banner.create({
            'name': 'Banner obisnuit', 'subtitle': 'Se arata',
            'placement': 'hero', 'image': base64.b64encode(PNG_1PX)})
        cls.fara_poza = Banner.create({
            'name': 'Bifat dar fara poza', 'placement': 'hero', 'image_only': True})

    def _banners(self):
        self.api_login()
        return {b['id']: b for b in self.api_get('/home').json()['banners']}

    def test_bifa_ajunge_in_raspuns(self):
        banners = self._banners()

        self.assertTrue(banners[self.cu_text_in_poza.id]['image_only'])
        self.assertFalse(banners[self.obisnuit.id]['image_only'])

    def test_titlul_se_trimite_oricum(self):
        """Ramane eticheta citita de cititoarele de ecran, chiar daca nu se deseneaza."""
        banners = self._banners()

        self.assertEqual(banners[self.cu_text_in_poza.id]['title'], 'Banner cu text in poza')

    def test_bifa_fara_poza_nu_inseamna_nimic(self):
        """Altfel bannerul ar ramane un dreptunghi gol: nici poza, nici text."""
        banners = self._banners()

        self.assertFalse(banners[self.fara_poza.id]['image_only'])


@tagged('post_install', '-at_install')
class TestHomeSections(AppHttpCase):
    """Randurile de produse de pe Acasa.

    Produsele lor trec prin acelasi domeniu ca `/products`: un rand nu poate arata
    produse pe care catalogul nu le-ar da."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        Template = cls.env['product.template']
        cls.categorie = cls.env['product.public.category'].create({'name': 'Categorie sectiune test'})
        cls.publicat = Template.create({
            'name': 'Produs sectiune publicat', 'list_price': 10.0, 'is_published': True,
            'public_categ_ids': [(6, 0, [cls.categorie.id])]})
        cls.nepublicat = Template.create({
            'name': 'Produs sectiune nepublicat', 'list_price': 20.0, 'is_published': False,
            'public_categ_ids': [(6, 0, [cls.categorie.id])]})
        cls.sectiune = cls.env['uportho.app.section'].create({
            'name': 'Noutati test', 'source': 'category', 'category_id': cls.categorie.id})

    def _sections(self):
        self.api_login()
        return {s['title']: s for s in self.api_get('/home').json()['sections']}

    def test_randul_arata_produsele_categoriei(self):
        sections = self._sections()

        self.assertIn('Noutati test', sections)
        names = [p['name'] for p in sections['Noutati test']['products']]
        self.assertIn('Produs sectiune publicat', names)

    def test_un_produs_depublicat_dispare_din_rand(self):
        """Fara sa stearga nimeni nimic din sectiune."""
        sections = self._sections()

        names = [p['name'] for p in sections['Noutati test']['products']]
        self.assertNotIn('Produs sectiune nepublicat', names)

    def test_produsele_au_aceeasi_forma_ca_in_catalog(self):
        sections = self._sections()
        product = sections['Noutati test']['products'][0]
        contract = load_contract('products.json')['products'][0]

        self.assertEqual(set(product), set(contract))

    def test_un_rand_ramas_gol_nu_se_trimite(self):
        """Un titlu peste un rand gol e mai rau decat lipsa lui."""
        goala = self.env['product.public.category'].create({'name': 'Categorie fara produse test'})
        self.env['uportho.app.section'].create({
            'name': 'Rand gol test', 'source': 'category', 'category_id': goala.id})

        self.assertNotIn('Rand gol test', self._sections())

    def test_produsele_alese_de_mana_trec_tot_prin_domeniul_catalogului(self):
        self.env['uportho.app.section'].create({
            'name': 'De mana test', 'source': 'manual',
            'product_ids': [(6, 0, [self.publicat.id, self.nepublicat.id])]})

        names = [p['name'] for p in self._sections()['De mana test']['products']]
        self.assertEqual(names, ['Produs sectiune publicat'])

    def test_limita_taie_randul(self):
        Template = self.env['product.template']
        for index in range(3):
            Template.create({
                'name': 'Produs limita test %s' % index, 'list_price': 5.0, 'is_published': True,
                'public_categ_ids': [(6, 0, [self.categorie.id])]})
        self.sectiune.limit = 2

        self.assertEqual(len(self._sections()['Noutati test']['products']), 2)

    def test_sectiunea_fara_categorie_e_refuzata(self):
        with self.assertRaises(Exception):
            self.env['uportho.app.section'].create({'name': 'Fara categorie', 'source': 'category'})


@tagged('post_install', '-at_install')
class TestHomeBrandsAndCounts(AppHttpCase):
    """Randul de branduri si numarul de produse de sub categorii.

    Brandul e un camp al magazinului (`dr_brand_value_id` din tema): pe baza de test nu
    exista, deci randul lipseste cu totul - asta se si verifica aici, ca o baza fara
    tema sa nu pice. Numaratoarea de categorii e insa a noastra si se verifica pe date."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        Category = cls.env['product.public.category']
        cls.parinte = Category.create({
            'name': 'Parinte numarare test', 'app_home_visible': True, 'app_home_sequence': 1})
        cls.copil = Category.create({
            'name': 'Copil numarare test', 'parent_id': cls.parinte.id})
        Template = cls.env['product.template']
        Template.create({
            'name': 'Produs numarare 1', 'is_published': True, 'list_price': 10.0,
            'public_categ_ids': [(6, 0, [cls.parinte.id])]})
        # Acelasi produs in parinte SI in copil: trebuie numarat o singura data.
        Template.create({
            'name': 'Produs numarare 2', 'is_published': True, 'list_price': 10.0,
            'public_categ_ids': [(6, 0, [cls.parinte.id, cls.copil.id])]})
        Template.create({
            'name': 'Produs numarare nepublicat', 'is_published': False, 'list_price': 10.0,
            'public_categ_ids': [(6, 0, [cls.copil.id])]})

    def _home(self):
        self.api_login()
        return self.api_get('/home').json()

    def test_numarul_de_produse_e_recursiv_si_numara_o_data(self):
        body = self._home()
        categories = {c['id']: c for c in body['quick_categories']}

        self.assertEqual(categories[self.parinte.id]['product_count'], 2)

    def test_produsele_nepublicate_nu_se_numara(self):
        """Altfel numarul de sub iconita ar promite mai mult decat deschide."""
        body = self._home()
        categories = {c['id']: c for c in body['quick_categories']}

        self.assertNotIn('Produs numarare nepublicat',
                         [c['name'] for c in body['quick_categories']])
        self.assertEqual(categories[self.parinte.id]['product_count'], 2)

    def test_fara_campurile_temei_randul_de_branduri_lipseste(self):
        body = self._home()

        self.assertIn('brands', body)
        if 'dr_is_brand' not in self.env['product.attribute']._fields:
            self.assertEqual(body['brands'], [])

    def test_logoul_unui_brand_inexistent_da_404(self):
        self.api_login()
        self.assertEqual(self.api_get('/brands/999999/logo').status_code, 404)


@tagged('post_install', '-at_install')
class TestHomeSocial(AppHttpCase):
    """Randul de retele sociale de pe Acasa.

    Site-ul are, sub produse, blocul "Hai alaturi de noi si in Social Media", cu
    iconitele retelelor. Adresele lor nu stau in sablon: stau in setarile
    website-ului, iar aplicatia le citeste de acolo - cine muta pagina de Facebook
    in Odoo o muta si in aplicatie, fara release."""

    WEBSITE_PARAM = 'uportho_app.website_id'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        # Website propriu, cu retelele golite. Odoo pune din fabrica adrese catre
        # paginile LUI (facebook.com/Odoo s.a.m.d.) pe orice website nou - si site-ul
        # le arata la fel, in subsol, pana le schimba cineva. Testul si le goleste ca
        # sa poata compara liste intregi; pe magazinul real toate patru sunt
        # completate cu paginile UpOrtho.
        cls.website = cls.env['website'].create({'name': 'Website retele test'})
        cls.website.write({
            name: False for name in cls.website._fields
            if name.startswith('social_') and name != 'social_default_image'
        })

    def setUp(self):
        super().setUp()
        self.env['ir.config_parameter'].sudo().set_param(
            self.WEBSITE_PARAM, str(self.website.id))
        self.addCleanup(self.registry.clear_cache)

    def _social(self):
        self.api_login()
        return self.api_get('/home').json()['social']

    def test_trimite_doar_retelele_completate(self):
        """O iconita care nu duce nicaieri e mai rea decat lipsa ei."""
        self.website.write({
            'social_facebook': 'https://www.facebook.com/UpOrthoStore',
            'social_instagram': 'https://www.instagram.com/uporthoromania',
            'social_youtube': '',
        })

        self.assertEqual(self._social(), [
            {'network': 'facebook', 'url': 'https://www.facebook.com/UpOrthoStore'},
            {'network': 'instagram', 'url': 'https://www.instagram.com/uporthoromania'},
        ])

    def test_ordinea_e_cea_de_pe_site(self):
        """Blocul de pe pagina de start arata Facebook, LinkedIn, YouTube, Instagram -
        in aceasta ordine, nu in ordinea campurilor din baza."""
        self.website.write({
            'social_instagram': 'https://instagram.test/u',
            'social_youtube': 'https://youtube.test/u',
            'social_facebook': 'https://facebook.test/u',
            'social_linkedin': 'https://linkedin.test/u',
        })

        self.assertEqual([link['network'] for link in self._social()],
                         ['facebook', 'linkedin', 'youtube', 'instagram'])

    def test_o_retea_pe_care_aplicatia_nu_o_cunoaste_se_trimite_la_coada(self):
        """`github` exista pe model dar nu e in lista noastra de ordine. Daca un editor
        ii pune adresa, aplicatia o arata oricum: altfel ar parea ca a pierdut-o."""
        self.website.write({
            'social_facebook': 'https://facebook.test/u',
            'social_github': 'https://github.test/u',
        })

        self.assertEqual([link['network'] for link in self._social()],
                         ['facebook', 'github'])

    def test_spatiile_din_jur_nu_ajung_in_aplicatie(self):
        """Un URL copiat cu spatiu la final nu se deschide pe telefon."""
        self.website.write({'social_facebook': '  https://facebook.test/u  '})

        self.assertEqual(self._social(), [
            {'network': 'facebook', 'url': 'https://facebook.test/u'}])

    def test_fara_nicio_retea_blocul_e_gol_nu_lipseste(self):
        """Cheia exista mereu: aplicatia nu trebuie sa ghiceasca daca lipsa ei
        inseamna 'nicio retea' sau 'server vechi'."""
        body_social = self._social()

        self.assertEqual(body_social, [])

    def test_contractul_descrie_randul_de_retele(self):
        contract = load_contract('home.json')

        self.assertTrue(contract['social'])
        for link in contract['social']:
            self.assertEqual(set(link), {'network', 'url'})


@tagged('post_install', '-at_install')
class TestInstagramUsername(TransactionCase):
    """Din ce adresa iese contul de Instagram. Functia e pura, deci se testeaza direct."""

    def test_adresa_obisnuita_da_contul(self):
        self.assertEqual(
            instagram_username('https://www.instagram.com/uporthoromania'), 'uporthoromania')

    def test_slash_la_final_si_spatii_nu_conteaza(self):
        self.assertEqual(
            instagram_username('  https://instagram.com/uporthoromania/  '), 'uporthoromania')

    def test_adresa_fara_schema_tot_merge(self):
        """Un editor poate scrie doar `instagram.com/cont` in setari."""
        self.assertEqual(instagram_username('instagram.com/uporthoromania'), 'uporthoromania')

    def test_alt_site_nu_da_niciun_cont(self):
        """Altfel am incarca intr-un iframe o adresa pusa de altcineva."""
        self.assertIsNone(instagram_username('https://exemplu.test/uporthoromania'))
        self.assertIsNone(instagram_username('https://instagram.com.exemplu.test/cont'))

    def test_adresa_catre_o_postare_nu_e_un_cont(self):
        self.assertIsNone(instagram_username('https://www.instagram.com/p/Cabcdef/'))
        self.assertIsNone(instagram_username('https://www.instagram.com/uportho/reel/1/'))

    def test_gol_inseamna_fara_feed(self):
        self.assertIsNone(instagram_username(''))
        self.assertIsNone(instagram_username(None))


@tagged('post_install', '-at_install')
class TestHomeInstagram(AppHttpCase):
    """Blocul de feed Instagram din /home."""

    WEBSITE_PARAM = 'uportho_app.website_id'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.website = cls.env['website'].create({'name': 'Website instagram test'})

    def setUp(self):
        super().setUp()
        self.env['ir.config_parameter'].sudo().set_param(
            self.WEBSITE_PARAM, str(self.website.id))
        self.addCleanup(self.registry.clear_cache)

    def _instagram(self):
        self.api_login()
        return self.api_get('/home').json()['instagram']

    def test_contul_vine_din_aceeasi_adresa_ca_iconita(self):
        """Nu exista o a doua setare: feedul si iconita de Instagram arata acelasi cont."""
        self.website.social_instagram = 'https://www.instagram.com/uporthoromania'

        self.assertEqual(self._instagram(), {
            'username': 'uporthoromania',
            'embed_url': 'https://www.instagram.com/uporthoromania/embed',
            'profile_url': 'https://www.instagram.com/uporthoromania/',
        })

    def test_fara_cont_blocul_e_null_nu_un_chenar_gol(self):
        self.website.social_instagram = False

        self.assertIsNone(self._instagram())

    def test_contractul_descrie_blocul(self):
        contract = load_contract('home.json')

        self.assertEqual(set(contract['instagram']), {'username', 'embed_url', 'profile_url'})
