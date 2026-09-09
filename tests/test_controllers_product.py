import base64
from unittest.mock import patch

from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract
from .test_controllers_catalog import PNG_1PX

# Un URL de video acceptat de `get_video_embed_code` (constrangerea Odoo de pe
# `product.image.video_url` respinge orice URL din care nu poate scoate un embed).
VIDEO_URL = 'https://www.youtube.com/watch?v=ykU7NEmEd8g'


@tagged('post_install', '-at_install')
class TestControllersProductDetail(AppHttpCase):
    """`GET /products/<id>` - pagina de produs. Fiecare test filtreaza pe
    inregistrarile pe care si le creeaza singur; baza locala are date ramase din
    verificari manuale si nu are voie sa influenteze rezultatul."""

    CLUB_PARAM = 'uportho_app.club_pricelist_id'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test detaliu', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        # Taxe explicite, nu cele implicite ale companiei de test: altfel cifrele
        # asteptate in teste ar depinde de configurarea bazei, nu de ce testeaza ele.
        cls.tax = cls.env['account.tax'].create({
            'name': 'TVA test detaliu 20%', 'amount': 20.0, 'amount_type': 'percent',
            'type_tax_use': 'sale', 'price_include_override': 'tax_excluded'})

        cls.category = cls.env['product.public.category'].create({'name': 'Categorie detaliu test'})
        cls.other_website = cls.env['website'].create({'name': 'Alt site detaliu test'})

        # Doua atribute, ca sa existe si combinatii imposibile (exclusion) pentru
        # `available: false` pe o valoare.
        cls.attr_size = cls.env['product.attribute'].create({
            'name': 'Marime detaliu test',
            'value_ids': [(0, 0, {'name': 'Mare detaliu'}), (0, 0, {'name': 'Mic detaliu'})],
        })
        cls.attr_color = cls.env['product.attribute'].create({
            'name': 'Culoare detaliu test',
            'value_ids': [(0, 0, {'name': 'Argintiu detaliu'}), (0, 0, {'name': 'Auriu detaliu'})],
        })

        cls.product = cls.env['product.template'].create({
            'name': 'Produs Detaliu Complet Test',
            'default_code': 'DET-FULL',
            'is_published': True,
            'list_price': 100.0,
            'taxes_id': [(6, 0, [cls.tax.id])],
            'image_1920': base64.b64encode(PNG_1PX),
            'app_badge_text': 'Nou', 'app_badge_color': 'blue',
            'public_categ_ids': [(6, 0, [cls.category.id])],
            'website_description': (
                '<h2>Titlu de test</h2><p>Un <strong>paragraf</strong> de test.</p>'
                '<ul><li>Prima linie</li></ul>'),
            'attribute_line_ids': [
                (0, 0, {'attribute_id': cls.attr_size.id,
                        'value_ids': [(6, 0, cls.attr_size.value_ids.ids)]}),
                (0, 0, {'attribute_id': cls.attr_color.id,
                        'value_ids': [(6, 0, cls.attr_color.value_ids.ids)]}),
            ],
        })
        cls.ptav = {
            ptav.product_attribute_value_id.name: ptav
            for line in cls.product.attribute_line_ids
            for ptav in line.product_template_value_ids
        }
        # "Mare detaliu" costa cu 50 mai mult - proba ca schimbarea variantei chiar
        # schimba pretul intors.
        cls.ptav['Mare detaliu'].price_extra = 50.0
        # Combinatia (Mic detaliu, Auriu detaliu) e imposibila.
        cls.ptav['Mic detaliu'].write({'exclude_for': [(0, 0, {
            'product_tmpl_id': cls.product.id,
            'value_ids': [(6, 0, [cls.ptav['Auriu detaliu'].id])],
        })]})

        cls.gallery_image = cls.env['product.image'].create({
            'name': 'Poza suplimentara detaliu test',
            'product_tmpl_id': cls.product.id,
            'image_1920': base64.b64encode(PNG_1PX),
        })
        cls.gallery_video = cls.env['product.image'].create({
            'name': 'Video detaliu test',
            'product_tmpl_id': cls.product.id,
            'video_url': VIDEO_URL,
        })

        # Produs "gol": fara poza, fara descriere, fara atribute, fara praguri -
        # 354 din 619 produse reale arata asa.
        # Fara taxe: pretul intors e exact list_price, deci testele de club si de
        # praguri vorbesc despre pricelist, nu despre TVA (acela e exersat pe
        # `cls.product`, care are o taxa explicita).
        cls.product_bare = cls.env['product.template'].create({
            'name': 'Produs Detaliu Gol Test', 'is_published': True, 'list_price': 10.0,
            'taxes_id': [(6, 0, [])]})
        cls.product_unpublished = cls.env['product.template'].create({
            'name': 'Produs Detaliu Nepublicat Test', 'is_published': False, 'list_price': 10.0})
        cls.product_other_website = cls.env['product.template'].create({
            'name': 'Produs Detaliu Alt Site Test', 'is_published': True,
            'website_id': cls.other_website.id, 'list_price': 10.0})

    def setUp(self):
        super().setUp()
        # ir.config_parameter e citit prin ormcache; rollback-ul tranzactiei de test
        # nu curata cache-ul (acelasi fix ca in TestControllersProductPricing).
        self.addCleanup(self.registry.clear_cache)

    def _detail(self, product=None, **params):
        product = product or self.product
        query = '&'.join(f'{key}={value}' for key, value in params.items())
        path = f'/products/{product.id}' + (f'?{query}' if query else '')
        return self.api_get(path)

    def _variant(self, *value_names):
        """Varianta produsului care are exact valorile date."""
        wanted = {self.ptav[name].id for name in value_names}
        return next(
            variant for variant in self.product.product_variant_ids
            if set(variant.product_template_attribute_value_ids.ids) == wanted)

    # --- acces si erori -------------------------------------------------------

    def test_detail_requires_login(self):
        self.assertEqual(self._detail().status_code, 401)

    def test_unpublished_product_is_404(self):
        self.api_login()
        self.assertEqual(self._detail(self.product_unpublished).status_code, 404)

    def test_product_of_other_website_is_404(self):
        # Website-ul configurat e altul decat `other_website` (parametrul e setat
        # explicit aici, ca sa nu depinda de ce rezolva get_current_website()).
        website = self.env['website'].create({'name': 'Site configurat detaliu test'})
        self.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(website.id))
        self.api_login()
        self.assertEqual(self._detail(self.product_other_website).status_code, 404)

    def test_missing_product_is_404(self):
        self.api_login()
        response = self.api_get('/products/999999')
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json()['error']['code'], 'not_found')

    def test_variant_id_of_another_product_is_422_not_500(self):
        self.api_login()
        other_variant = self.product_bare.product_variant_id
        response = self._detail(variant_id=other_variant.id)
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_variant_id_garbage_is_422(self):
        self.api_login()
        response = self._detail(variant_id='abc')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_values_of_another_product_is_422_not_500(self):
        # Un id de valoare care exista, dar apartine altui produs: cerere gresita,
        # nu eroare interna.
        other = self.env['product.template'].create({
            'name': 'Produs Values Strain Test', 'is_published': True, 'list_price': 10.0,
            'attribute_line_ids': [(0, 0, {
                'attribute_id': self.attr_size.id,
                'value_ids': [(6, 0, self.attr_size.value_ids.ids)]})],
        })
        foreign = other.attribute_line_ids.product_template_value_ids[0]
        self.api_login()
        response = self._detail(values=foreign.id)
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_values_with_unknown_id_is_422_not_500(self):
        self.api_login()
        response = self._detail(values=999999)
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_values_garbage_is_422(self):
        self.api_login()
        response = self._detail(values='abc')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    # --- forma raspunsului ----------------------------------------------------

    def test_shape_matches_contract(self):
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        self.env['uportho.app.benefit'].create({
            'name': 'Beneficiu forma test', 'text': 'subtitlu', 'icon': 'club'})
        self.env['product.template'].create({
            'name': 'Produs Similar Forma Test', 'is_published': True, 'list_price': 5.0,
            'public_categ_ids': [(6, 0, [self.category.id])]})
        # Un prag de cantitate, ca sa existe un tabel de pret in raspuns: un tabel de
        # un singur rand, egal cu pretul de deasupra lui, nu se trimite deloc.
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        contract = load_contract('product_detail.json')
        body = self._detail().json()

        self.assertEqual(set(body.keys()), set(contract.keys()))
        self.assertEqual(set(body['price'].keys()), set(contract['price'].keys()))
        self.assertEqual(set(body['images'][0].keys()), set(contract['images'][0].keys()))
        self.assertEqual(set(body['price_tables'][0].keys()),
                         set(contract['price_tables'][0].keys()))
        self.assertEqual(set(body['price_tables'][0]['entries'][0].keys()),
                         set(contract['price_tables'][0]['entries'][0].keys()))
        self.assertEqual(set(body['price_tables'][0]['entries'][0]['price'].keys()),
                         set(contract['price_tables'][0]['entries'][0]['price'].keys()))
        self.assertEqual(set(body['variants'].keys()), set(contract['variants'].keys()))
        self.assertEqual(set(body['variants']['attributes'][0].keys()),
                         set(contract['variants']['attributes'][0].keys()))
        self.assertEqual(set(body['variants']['attributes'][0]['values'][0].keys()),
                         set(contract['variants']['attributes'][0]['values'][0].keys()))
        self.assertEqual(set(body['specs'][0].keys()), set(contract['specs'][0].keys()))
        self.assertEqual(set(body['description'][0].keys()), set(contract['description'][0].keys()))
        self.assertEqual(set(body['description'][0]['spans'][0].keys()),
                         set(contract['description'][0]['spans'][0].keys()))
        self.assertEqual(set(body['rating'].keys()), set(contract['rating'].keys()))
        self.assertEqual(set(body['similar'][0].keys()), set(contract['similar'][0].keys()))
        self.assertEqual(set(body['benefits'][0].keys()), set(contract['benefits'][0].keys()))

    def test_bare_product_has_empty_lists_and_nulls_never_missing_keys(self):
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        body = self._detail(self.product_bare).json()
        # Liste: goale, niciodata null.
        for key in ('price_tables', 'specs', 'description', 'reviews', 'similar',
                    'benefits', 'images', 'variant_rows'):
            self.assertIsInstance(body[key], list, key)
        self.assertEqual(body['images'], [])
        # Produs cu o singura varianta: tabelul de comanda pe variante nu are ce arata.
        self.assertEqual(body['variant_rows'], [])
        self.assertEqual(body['specs'], [])
        self.assertEqual(body['description'], [])
        self.assertEqual(body['reviews'], [])
        # Null cand nu se aplica.
        self.assertIsNone(body['variants'])
        self.assertIsNone(body['badge'])
        self.assertIsNone(body['club_price'])
        self.assertIsNone(body['availability'])
        # Fara reduceri de cantitate, singurul rand ar fi "1+" cu pretul deja afisat
        # deasupra: un asemenea tabel nu se trimite deloc.
        self.assertEqual(body['price_tables'], [])
        self.assertEqual(body['rating'], {'average': 0.0, 'count': 0})

    def test_identity_fields(self):
        self.api_login()
        body = self._detail().json()
        self.assertEqual(body['id'], self.product.id)
        self.assertEqual(body['name'], self.product.name)
        self.assertEqual(body['badge'], {'text': 'Nou', 'color': 'blue'})
        self.assertIn(body['variant_id'], self.product.product_variant_ids.ids)

    def test_description_and_specs_come_from_model_helpers(self):
        self.api_login()
        body = self._detail().json()
        self.assertEqual(body['description'], self.product._uportho_description_blocks())
        self.assertEqual([spec['name'] for spec in body['specs']],
                         [self.attr_size.name, self.attr_color.name])

    # --- variante -------------------------------------------------------------

    def test_variants_null_when_product_has_no_multi_value_attribute(self):
        self.api_login()
        self.assertIsNone(self._detail(self.product_bare).json()['variants'])

    def test_variants_list_values_with_selected_flag(self):
        self.api_login()
        variant = self._variant('Mare detaliu', 'Argintiu detaliu')
        body = self._detail(variant_id=variant.id).json()
        self.assertEqual(body['variant_id'], variant.id)
        by_attribute = {attr['name']: attr for attr in body['variants']['attributes']}
        self.assertEqual(set(by_attribute), {self.attr_size.name, self.attr_color.name})
        selected = {value['name'] for attr in body['variants']['attributes']
                    for value in attr['values'] if value['selected']}
        self.assertEqual(selected, {'Mare detaliu', 'Argintiu detaliu'})

    def test_impossible_combination_value_is_marked_unavailable(self):
        # Exclusion in fixture: (Mic detaliu, Auriu detaliu) e imposibil. Pe varianta
        # (Mic detaliu, Argintiu detaliu), valoarea "Auriu detaliu" trebuie sa apara
        # dezactivata - starea vine de la Odoo (_is_combination_possible), nu dedusa.
        self.api_login()
        variant = self._variant('Mic detaliu', 'Argintiu detaliu')
        body = self._detail(variant_id=variant.id).json()
        values = {value['name']: value
                  for attr in body['variants']['attributes'] for value in attr['values']}
        self.assertFalse(values['Auriu detaliu']['available'])
        self.assertTrue(values['Argintiu detaliu']['available'])

    def test_variant_changes_price_and_default_code(self):
        self.api_login()
        cheap = self._variant('Mic detaliu', 'Argintiu detaliu')
        expensive = self._variant('Mare detaliu', 'Argintiu detaliu')
        cheap.default_code = 'DET-MIC'
        expensive.default_code = 'DET-MARE'

        cheap_body = self._detail(variant_id=cheap.id).json()
        expensive_body = self._detail(variant_id=expensive.id).json()
        self.assertEqual(cheap_body['default_code'], 'DET-MIC')
        self.assertEqual(expensive_body['default_code'], 'DET-MARE')
        # price_extra de 50 pe "Mare detaliu", plus TVA-ul de 20% al fixture-ului:
        # pretul vine de la Odoo pentru varianta ceruta, nu de pe template.
        self.assertAlmostEqual(
            expensive_body['price']['amount'] - cheap_body['price']['amount'], 60.0, places=2)

    # --- combinatia ceruta prin `values` --------------------------------------

    def test_values_select_the_combination_and_change_the_price(self):
        # Aplicatia are in mana doar id-uri de valoare de atribut; `values` e singura
        # cale prin care poate cere o alta varianta. Fara el, fiecare apasare pe o
        # marime ar da 422 pe date reale.
        self.api_login()
        cheap = [self.ptav['Mic detaliu'].id, self.ptav['Argintiu detaliu'].id]
        expensive = [self.ptav['Mare detaliu'].id, self.ptav['Argintiu detaliu'].id]

        cheap_body = self._detail(values=','.join(str(i) for i in cheap)).json()
        expensive_body = self._detail(values=','.join(str(i) for i in expensive)).json()

        self.assertEqual(cheap_body['variant_id'], self._variant('Mic detaliu', 'Argintiu detaliu').id)
        self.assertEqual(
            expensive_body['variant_id'], self._variant('Mare detaliu', 'Argintiu detaliu').id)
        # price_extra 50 pe "Mare detaliu" + TVA 20% din fixture.
        self.assertAlmostEqual(
            expensive_body['price']['amount'] - cheap_body['price']['amount'], 60.0, places=2)

    def test_values_report_the_selected_combination(self):
        # Dupa o re-cerere aplicatia trebuie sa poata desena din nou starea de
        # selectie fara sa deduca nimic: raspunsul spune ce combinatie e activa.
        self.api_login()
        wanted = [self.ptav['Mic detaliu'].id, self.ptav['Argintiu detaliu'].id]
        body = self._detail(values=','.join(str(i) for i in wanted)).json()
        self.assertEqual(sorted(body['variants']['selected']), sorted(wanted))
        selected = {value['name'] for attr in body['variants']['attributes']
                    for value in attr['values'] if value['selected']}
        self.assertEqual(selected, {'Mic detaliu', 'Argintiu detaliu'})

    def test_every_value_carries_the_combination_to_send_for_it(self):
        # Nicio intrare din selector nu are voie sa ceara aplicatiei sa inventeze
        # id-uri: fiecare valoare vine cu combinatia completa de trimis la apasare.
        self.api_login()
        body = self._detail(values=str(self.ptav['Mic detaliu'].id)).json()
        lines = len(body['variants']['attributes'])
        for attribute in body['variants']['attributes']:
            for value in attribute['values']:
                self.assertIn(value['id'], value['combination'], value['name'])
                self.assertEqual(len(value['combination']), lines, value['name'])

        # Si combinatia trimisa inapoi chiar selecteaza acea valoare. (Doar pentru o
        # valoare disponibila: una indisponibila e dezactivata in ecran si oricum
        # cade pe cea mai apropiata combinatie posibila.)
        other = next(value for attr in body['variants']['attributes']
                     for value in attr['values']
                     if value['available'] and not value['selected'])
        again = self._detail(values=','.join(str(i) for i in other['combination'])).json()
        chosen = {value['id'] for attr in again['variants']['attributes']
                  for value in attr['values'] if value['selected']}
        self.assertIn(other['id'], chosen)
        self.assertEqual(sorted(again['variants']['selected']), sorted(other['combination']))

    def test_partial_values_resolve_to_a_complete_combination(self):
        # O singura valoare (utilizatorul a ales doar marimea): Odoo completeaza
        # combinatia, nu e o eroare.
        self.api_login()
        body = self._detail(values=str(self.ptav['Mare detaliu'].id)).json()
        self.assertIn(body['variant_id'], self.product.product_variant_ids.ids)
        self.assertIn(self.ptav['Mare detaliu'].id, body['variants']['selected'])
        self.assertEqual(len(body['variants']['selected']), 2)

    def test_empty_values_resolve_to_the_default_combination(self):
        self.api_login()
        body = self._detail(values='').json()
        default_body = self._detail().json()
        self.assertIn(body['variant_id'], self.product.product_variant_ids.ids)
        self.assertEqual(body['variant_id'], default_body['variant_id'])

    def test_values_win_over_variant_id(self):
        self.api_login()
        expensive = self._variant('Mare detaliu', 'Argintiu detaliu')
        wanted = [self.ptav['Mic detaliu'].id, self.ptav['Argintiu detaliu'].id]
        body = self._detail(
            variant_id=expensive.id, values=','.join(str(i) for i in wanted)).json()
        self.assertEqual(body['variant_id'], self._variant('Mic detaliu', 'Argintiu detaliu').id)

    def test_impossible_values_fall_back_to_the_closest_possible_combination(self):
        # (Mic detaliu, Auriu detaliu) e exclus in fixture. Nu e 500 si nu e 422:
        # Odoo intoarce cea mai apropiata combinatie posibila, ca pe site.
        self.api_login()
        impossible = [self.ptav['Mic detaliu'].id, self.ptav['Auriu detaliu'].id]
        response = self._detail(values=','.join(str(i) for i in impossible))
        self.assertEqual(response.status_code, 200)
        self.assertIn(response.json()['variant_id'], self.product.product_variant_ids.ids)

    def test_tiers_follow_the_selected_variant(self):
        # Tabelul de praguri trebuie sa arate pretul variantei alese; altfel randul
        # "1+" ar contrazice pretul mare de deasupra lui pe aceeasi pagina.
        self.api_login()
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        expensive = self._variant('Mare detaliu', 'Argintiu detaliu')
        body = self._detail(variant_id=expensive.id).json()
        entries = body['price_tables'][0]['entries']
        self.assertEqual(entries[0]['price']['amount'], body['price']['amount'])

    # --- tabele de pret (praguri de cantitate, club, tema) --------------------

    def test_price_tables_from_pricelist_rules(self):
        self.api_login()
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        body = self._detail(self.product_bare).json()
        # Fara modulul de tema (nu e pe baza locala), titlul vine tot de la server -
        # aplicatia nu mai stie niciun titlu de tabel.
        self.assertEqual([table['title'] for table in body['price_tables']],
                         ['Pret pe cantitate'])
        entries = body['price_tables'][0]['entries']
        self.assertEqual([tier['min_qty'] for tier in entries], [1, 5])
        self.assertEqual([tier['label'] for tier in entries], ['1+', '5+'])
        self.assertGreater(entries[0]['price']['amount'], entries[1]['price']['amount'])
        self.assertEqual(body['price_tables'][0]['note'], [])

    def test_club_price_and_club_table_when_parameter_set(self):
        club_pricelist = self.env['product.pricelist'].create({
            'name': 'Ortho Club detaliu test', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': club_pricelist.id, 'applied_on': '3_global',
            'compute_price': 'percentage', 'percent_price': 10})
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, str(club_pricelist.id))
        self.api_login()
        body = self._detail(self.product_bare).json()
        self.assertIsNotNone(body['club_price'])
        self.assertAlmostEqual(body['club_price']['amount'], 9.0, places=2)
        # Tabelul clientului ar avea un singur rand, egal cu pretul de deasupra: nu
        # se trimite. Ramane doar cel de club, cu titlul lui, tot de la server.
        self.assertEqual([table['title'] for table in body['price_tables']],
                         ['Pret Ortho Club'])
        club_entries = body['price_tables'][0]['entries']
        # Regula globala a listei de club are min_quantity 0; eticheta aratata ramane
        # '1+' (regula 5 din Task 2), asa ca aici se verifica eticheta, nu pragul brut.
        self.assertEqual([tier['label'] for tier in club_entries], ['1+'])
        self.assertAlmostEqual(club_entries[0]['price']['amount'], 9.0, places=2)

    def test_price_tables_empty_when_club_parameter_not_set(self):
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        self.api_login()
        body = self._detail(self.product_bare).json()
        self.assertIsNone(body['club_price'])
        self.assertEqual(body['price_tables'], [])

    # --- tabelele de pret ale temei (modulul clientului) ----------------------

    def _combination_info_with_theme_tables(self, tables):
        """Un `_get_combination_info` care adauga `other_bulk_prices`, ca modulul
        clientului (`terrabit_prime_extension`).

        Modulul acela suprascrie `_get_combination_info` si pune acolo tabelele deja
        calculate pentru pagina de produs de pe site: cate o intrare per lista de pret
        aratata (`is_public_pricelist`, `is_compare_pricelist`), cu `name` (titlul de
        pe site, pe productie un nume de campanie), `bulk_info` (HTML) si `prices`.
        Nu e instalat pe baza locala, deci raspunsul lui se simuleaza aici - forma e
        copiata din codul lor."""
        Template = type(self.env['product.template'])
        original = Template._get_combination_info

        def with_tables(inner_self, *args, **kwargs):
            info = original(inner_self, *args, **kwargs)
            info['other_bulk_prices'] = tables
            return info

        return patch.object(Template, '_get_combination_info', with_tables)

    def test_price_tables_come_from_the_theme_when_present(self):
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        theme_tables = [
            {'name': 'Pret public',
             'bulk_info': '<p>Pretul <strong>fara</strong> abonament.</p>',
             'prices': [
                 {'id': '1_1', 'qty': 1, 'price': 120.0,
                  'formatted_price': '<span class="oe_currency_value">120,00</span>&nbsp;lei',
                  'uom_name': 'Units'},
                 {'id': '1_5', 'qty': 5, 'price': 100.0,
                  'formatted_price': '<span class="oe_currency_value">100,00</span>&nbsp;lei',
                  'uom_name': 'Units'},
             ]},
            {'name': 'Campanie Toamna 2026', 'bulk_info': '',
             'prices': [{'id': '2_1', 'qty': 1, 'price': 90.0, 'uom_name': 'Units'}]},
        ]
        with self._combination_info_with_theme_tables(theme_tables):
            body = self._detail(self.product_bare).json()

        # Titlurile sunt cele de pe site, in ordinea de pe site - inclusiv numele de
        # campanie, pe care aplicatia nu are cum sa-l ghiceasca.
        self.assertEqual([table['title'] for table in body['price_tables']],
                         ['Pret public', 'Campanie Toamna 2026'])
        self.assertEqual([entry['label'] for entry in body['price_tables'][0]['entries']],
                         ['1+', '5+'])
        self.assertAlmostEqual(body['price_tables'][0]['entries'][1]['price']['amount'],
                               100.0, places=2)
        # `bulk_info` ajunge blocuri, niciodata HTML: aplicatia nu are motor HTML.
        note = body['price_tables'][0]['note']
        self.assertEqual([block['type'] for block in note], ['paragraph'])
        self.assertEqual(''.join(span['text'] for span in note[0]['spans']),
                         'Pretul fara abonament.')
        self.assertEqual(body['price_tables'][1]['note'], [])
        # Nici sumele nu sunt HTML: `formatted_price` al temei e Markup, noi il
        # inlocuim cu formatorul modulului.
        for table in body['price_tables']:
            for entry in table['entries']:
                self.assertNotIn('<', entry['price']['formatted'])

    def test_theme_tables_replace_the_module_own_tiers(self):
        # Cand magazinul are deja tabelele calculate, ele sunt singurele aratate -
        # altfel pagina din app ar spune altceva decat pagina de pe site.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        with self._combination_info_with_theme_tables([
                {'name': 'Pret public', 'prices': [{'qty': 1, 'price': 120.0}]}]):
            body = self._detail(self.product_bare).json()

        self.assertEqual([table['title'] for table in body['price_tables']], ['Pret public'])
        self.assertEqual([entry['min_qty'] for entry in body['price_tables'][0]['entries']], [1])

    def test_theme_table_equal_to_the_displayed_price_is_dropped(self):
        # Aceeasi regula ca la tabelele proprii: un singur rand care repeta pretul de
        # deasupra lui nu spune nimic nou.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        price = self._detail(self.product_bare).json()['price']['amount']
        with self._combination_info_with_theme_tables([
                {'name': 'Pret public', 'prices': [{'qty': 1, 'price': price}]}]):
            body = self._detail(self.product_bare).json()
        self.assertEqual(body['price_tables'], [])

    def test_theme_tables_survive_a_combination_info_that_fails(self):
        # Daca override-ul temei cade, raspunsul ramane intreg: se cade pe tabelele
        # calculate de modul (aici, un prag de cantitate real).
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        with self._combination_info_raising(), \
                self.assertLogs('odoo.addons.uportho_app.controllers.product', level='ERROR'):
            body = self._detail(self.product_bare).json()

        self.assertEqual([table['title'] for table in body['price_tables']], ['Pret pe cantitate'])
        self.assertEqual([entry['min_qty'] for entry in body['price_tables'][0]['entries']], [1, 5])

    # --- produse similare -----------------------------------------------------

    def test_similar_uses_alternative_products_and_the_products_serializer(self):
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        alternative = self.env['product.template'].create({
            'name': 'Produs Alternativ Detaliu Test', 'is_published': True, 'list_price': 30.0})
        self.product_bare.alternative_product_ids = [(6, 0, [alternative.id])]

        body = self._detail(self.product_bare).json()
        self.assertEqual([item['id'] for item in body['similar']], [alternative.id])
        # Exact acelasi serializator ca /products: aplicatia refoloseste ProductCard
        # fara nicio conversie, deci dictionarele trebuie sa fie identice.
        listed = next(p for p in self.api_get('/products?q=Produs Alternativ Detaliu Test').json()['products']
                      if p['id'] == alternative.id)
        self.assertEqual(body['similar'][0], listed)

    def test_similar_falls_back_to_category_and_excludes_self_and_unpublished(self):
        self.api_login()
        same_category = self.env['product.template'].create({
            'name': 'Produs Aceeasi Categorie Detaliu Test', 'is_published': True,
            'list_price': 20.0, 'public_categ_ids': [(6, 0, [self.category.id])]})
        hidden = self.env['product.template'].create({
            'name': 'Produs Categorie Nepublicat Detaliu Test', 'is_published': False,
            'list_price': 20.0, 'public_categ_ids': [(6, 0, [self.category.id])]})

        ids = [item['id'] for item in self._detail().json()['similar']]
        self.assertIn(same_category.id, ids)
        self.assertNotIn(hidden.id, ids)
        self.assertNotIn(self.product.id, ids)

    def test_similar_is_capped_at_ten(self):
        self.api_login()
        self.env['product.template'].create([
            {'name': f'Produs Plafon Similar Test {i}', 'is_published': True, 'list_price': 1.0,
             'public_categ_ids': [(6, 0, [self.category.id])]}
            for i in range(12)
        ])
        self.assertEqual(len(self._detail().json()['similar']), 10)

    # --- recenzii -------------------------------------------------------------

    def _create_rating(self, value, feedback, author_name):
        partner = self.env['res.partner'].create({'name': author_name})
        return self.env['rating.rating'].sudo().create({
            'res_model_id': self.env['ir.model']._get_id('product.template'),
            'res_id': self.product.id,
            'rating': value,
            'feedback': feedback,
            'consumed': True,
            'partner_id': partner.id,
        })

    def test_reviews_and_rating_average(self):
        self.api_login()
        self._create_rating(5, 'Foarte bun.', 'Ana Recenzie Test')
        self._create_rating(3, 'Acceptabil.', 'Bogdan Recenzie Test')
        body = self._detail().json()
        self.assertEqual(body['rating']['count'], 2)
        self.assertAlmostEqual(body['rating']['average'], 4.0, places=2)
        self.assertEqual({review['author'] for review in body['reviews']},
                         {'Ana Recenzie Test', 'Bogdan Recenzie Test'})
        review = next(r for r in body['reviews'] if r['author'] == 'Ana Recenzie Test')
        self.assertEqual(set(review.keys()), set(load_contract('product_detail.json')['reviews'][0].keys()))
        self.assertEqual(review['rating'], 5)
        self.assertEqual(review['text'], 'Foarte bun.')

    def test_reviews_are_capped_at_twenty_newest_first(self):
        self.api_login()
        for index in range(22):
            self._create_rating(5, f'Recenzie {index}', f'Autor Recenzie Test {index}')
        body = self._detail().json()
        self.assertEqual(len(body['reviews']), 20)
        self.assertEqual(body['rating']['count'], 22)

    # --- beneficii ------------------------------------------------------------

    def test_benefits_are_active_and_ordered(self):
        self.api_login()
        Benefit = self.env['uportho.app.benefit']
        second = Benefit.create({'name': 'Beneficiu doi test', 'icon': 'delivery', 'sequence': 20})
        first = Benefit.create({'name': 'Beneficiu unu test', 'icon': 'club', 'sequence': 10,
                                'text': 'subtitlu unu'})
        inactive = Benefit.create({'name': 'Beneficiu inactiv test', 'icon': 'info',
                                   'sequence': 15, 'active': False})
        body = self._detail().json()
        titles = [benefit['title'] for benefit in body['benefits']]
        own = [title for title in titles if title in (first.name, second.name, inactive.name)]
        self.assertEqual(own, [first.name, second.name])
        self.assertNotIn(inactive.name, titles)
        by_title = {benefit['title']: benefit for benefit in body['benefits']}
        self.assertEqual(by_title[first.name]['icon'], 'club')
        self.assertEqual(by_title[first.name]['text'], 'subtitlu unu')
        self.assertIsNone(by_title[second.name]['text'])

    # --- disponibilitate ------------------------------------------------------

    def test_availability_is_null_without_website_sale_stock_fields(self):
        # `out_of_stock_message` / `show_availability` vin din `website_sale_stock`,
        # care NU e instalat pe baza locala (si nu e in dependintele modulului).
        # Fara campuri nu exista mesaj de disponibilitate de aratat -> null, nu 500.
        self.api_login()
        self.assertNotIn('out_of_stock_message', self.env['product.template']._fields)
        self.assertIsNone(self._detail().json()['availability'])

    # --- context de website si override-uri de tema ---------------------------

    def _combination_info_raising(self, message="'NoneType' object is not callable"):
        """Un `_get_combination_info` care cade, ca override-ul de tema de pe staging.

        Tema magazinului (`droggol_theme_common`) randeaza un template QWeb de website
        in interiorul lui `_get_combination_info`; pe rutele noastre, care nu sunt
        rute de website, randarea aceea a cazut cu `TypeError: 'NoneType' object is
        not callable` si a facut din pagina de produs un 500. Temele nu sunt instalate
        pe baza locala, deci esecul se simuleaza."""
        def raising(_self, *args, **kwargs):
            raise TypeError(message)
        return patch.object(type(self.env['product.template']), '_get_combination_info', raising)

    def test_website_context_is_bound_before_asking_odoo_for_the_combination(self):
        # `_get_combination_info` (si orice override de tema din el) intreaba
        # `self.env['website'].get_current_website()`. Rutele noastre sunt `type='http'`
        # simple: fara `website_id` in context, Odoo rezolva website-ul din header-ul
        # `Host` si poate nimeri altul decat magazinul. Legarea contextului e chiar
        # mecanismul pe care `get_current_website()` il citeste.
        website = self.env['website'].create({'name': 'Site context combinatie test'})
        self.env['ir.config_parameter'].sudo().set_param('uportho_app.website_id', str(website.id))
        self.api_login()

        Template = type(self.env['product.template'])
        original = Template._get_combination_info
        seen = []

        def spy(inner_self, *args, **kwargs):
            seen.append(inner_self.env.context.get('website_id'))
            return original(inner_self, *args, **kwargs)

        with patch.object(Template, '_get_combination_info', spy):
            response = self._detail()

        self.assertEqual(response.status_code, 200)
        self.assertEqual(seen, [website.id])

    def test_failing_combination_info_still_renders_the_product(self):
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        normal = self._detail().json()
        with self._combination_info_raising(), \
                self.assertLogs('odoo.addons.uportho_app.controllers.product',
                                level='ERROR') as captured:
            response = self._detail()

        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertIn(body['variant_id'], self.product.product_variant_ids.ids)
        self.assertEqual(body['name'], self.product.name)
        self.assertGreater(body['price']['amount'], 0)
        self.assertTrue(body['price']['formatted'])
        self.assertIsNotNone(body['variants'])
        # Datele pe care le calculeaza modulul singur sunt aceleasi ca fara esec;
        # doar eventualele adaugiri ale temei ar lipsi.
        for key in ('id', 'name', 'variant_id', 'default_code', 'price', 'variants'):
            self.assertEqual(body[key], normal[key], key)
        # Esecul nu se inghite: apare in loguri, cu id-ul produsului.
        logged = '\n'.join(captured.output)
        self.assertIn(str(self.product.id), logged)
        self.assertIn('TypeError', logged)

    def test_failing_combination_info_keeps_the_requested_variant(self):
        # Cu `variant_id`, varianta ceruta ramane cea intoarsa (si pretul ei), chiar
        # daca `_get_combination_info` cade.
        self.api_login()
        expensive = self._variant('Mare detaliu', 'Argintiu detaliu')
        expensive.default_code = 'DET-MARE'
        with self._combination_info_raising(), \
                self.assertLogs('odoo.addons.uportho_app.controllers.product', level='ERROR'):
            body = self._detail(variant_id=expensive.id).json()

        self.assertEqual(body['variant_id'], expensive.id)
        self.assertEqual(body['default_code'], 'DET-MARE')
        self.assertEqual(sorted(body['variants']['selected']),
                         sorted(expensive.product_template_attribute_value_ids.ids))

    def test_failing_combination_info_keeps_the_requested_values(self):
        # Cu `values`, combinatia ceruta se rezolva local (`_get_closest_possible_
        # combination` + `_get_variant_for_combination`), fara `_get_combination_info`.
        self.api_login()
        wanted = [self.ptav['Mic detaliu'].id, self.ptav['Argintiu detaliu'].id]
        with self._combination_info_raising(), \
                self.assertLogs('odoo.addons.uportho_app.controllers.product', level='ERROR'):
            body = self._detail(values=','.join(str(i) for i in wanted)).json()

        self.assertEqual(body['variant_id'], self._variant('Mic detaliu', 'Argintiu detaliu').id)
        self.assertEqual(sorted(body['variants']['selected']), sorted(wanted))

    def test_failing_combination_info_on_a_product_without_variants(self):
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        with self._combination_info_raising(), \
                self.assertLogs('odoo.addons.uportho_app.controllers.product', level='ERROR'):
            response = self._detail(self.product_bare)

        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertEqual(body['variant_id'], self.product_bare.product_variant_id.id)
        self.assertIsNone(body['variants'])
        self.assertAlmostEqual(body['price']['amount'], 10.0, places=2)

    def test_html_message_is_cleaned_to_plain_text(self):
        # Calea "exista mesaj" nu poate fi exersata local (vezi testul de mai sus),
        # dar curatarea de HTML - singura parte scrisa de noi - da.
        from odoo.addons.uportho_app.models.product_template import _uportho_html_to_text
        self.assertEqual(
            _uportho_html_to_text('<p>Precomanda. <b>Livrare</b> din 1 August</p>'),
            'Precomanda. Livrare din 1 August')
        self.assertIsNone(_uportho_html_to_text('<p><br></p>'))
        self.assertIsNone(_uportho_html_to_text(False))


@tagged('post_install', '-at_install')
class TestControllersProductGallery(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test galerie', 'currency_id': cls.env.company.currency_id.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        cls.product = cls.env['product.template'].create({
            'name': 'Produs Galerie Test', 'is_published': True, 'list_price': 10.0,
            'image_1920': base64.b64encode(PNG_1PX)})
        cls.image = cls.env['product.image'].create({
            'name': 'Poza galerie test', 'product_tmpl_id': cls.product.id,
            'image_1920': base64.b64encode(PNG_1PX)})
        cls.video = cls.env['product.image'].create({
            'name': 'Video galerie test', 'product_tmpl_id': cls.product.id,
            'video_url': VIDEO_URL})

        cls.other_product = cls.env['product.template'].create({
            'name': 'Alt Produs Galerie Test', 'is_published': True, 'list_price': 10.0})
        cls.unpublished = cls.env['product.template'].create({
            'name': 'Produs Galerie Nepublicat Test', 'is_published': False, 'list_price': 10.0,
            'image_1920': base64.b64encode(PNG_1PX)})
        cls.no_image = cls.env['product.template'].create({
            'name': 'Produs Galerie Fara Poza Test', 'is_published': True, 'list_price': 10.0})

    def test_images_list_main_first_then_extra_and_video(self):
        self.api_login()
        images = self.api_get(f'/products/{self.product.id}').json()['images']
        self.assertEqual([image['id'] for image in images], [0, self.image.id, self.video.id])
        self.assertEqual(images[0]['kind'], 'image')
        self.assertIsNone(images[0]['video_url'])
        self.assertTrue(images[0]['url'].startswith(
            f'/api/app/v1/products/{self.product.id}/gallery/0?unique='))
        self.assertEqual(images[2]['kind'], 'video')
        self.assertEqual(images[2]['video_url'], VIDEO_URL)

    def test_gallery_requires_login(self):
        self.assertEqual(self.api_get(f'/products/{self.product.id}/gallery/0').status_code, 401)

    def test_gallery_serves_main_image(self):
        self.api_login()
        response = self.api_get(f'/products/{self.product.id}/gallery/0')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.headers['Content-Type'].startswith('image/'))

    def test_gallery_serves_extra_image(self):
        self.api_login()
        response = self.api_get(f'/products/{self.product.id}/gallery/{self.image.id}')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.headers['Content-Type'].startswith('image/'))

    def test_gallery_image_of_another_product_is_404(self):
        self.api_login()
        response = self.api_get(f'/products/{self.other_product.id}/gallery/{self.image.id}')
        self.assertEqual(response.status_code, 404)

    def test_gallery_of_unpublished_product_is_404(self):
        self.api_login()
        self.assertEqual(self.api_get(f'/products/{self.unpublished.id}/gallery/0').status_code, 404)

    def test_gallery_without_image_is_404(self):
        self.api_login()
        self.assertEqual(self.api_get(f'/products/{self.no_image.id}/gallery/0').status_code, 404)
        self.assertEqual(
            self.api_get(f'/products/{self.product.id}/gallery/{self.video.id}').status_code, 404)


@tagged('post_install', '-at_install')
class TestControllersProductVariantRows(AppHttpCase):
    """Randurile de variante din `GET /products/<id>` - tabelul de comanda de pe
    site (Atribute | Pret | Cantitate | Subtotal), cate un rand per varianta.

    Fiecare test isi creeaza singur produsele si lista de pret; baza locala are date
    ramase din verificari manuale si nu are voie sa influenteze rezultatul."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test randuri', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        cls.attribute = cls.env['product.attribute'].create({
            'name': 'Set randuri test',
            'value_ids': [(0, 0, {'name': 'Simplu randuri'}), (0, 0, {'name': 'Complet randuri'})],
        })
        # Fara taxe: cifrele din teste vorbesc despre pricelist si cantitate, nu despre TVA.
        cls.product = cls.env['product.template'].create({
            'name': 'Produs Randuri Variante Test', 'default_code': 'RND-BASE',
            'is_published': True, 'list_price': 100.0, 'taxes_id': [(6, 0, [])],
            'attribute_line_ids': [(0, 0, {
                'attribute_id': cls.attribute.id,
                'value_ids': [(6, 0, cls.attribute.value_ids.ids)],
            })],
        })
        cls.ptav = {
            ptav.product_attribute_value_id.name: ptav
            for line in cls.product.attribute_line_ids
            for ptav in line.product_template_value_ids
        }
        cls.ptav['Complet randuri'].price_extra = 20.0
        cls.simple = cls.product._get_variant_for_combination(cls.ptav['Simplu randuri'])
        cls.full = cls.product._get_variant_for_combination(cls.ptav['Complet randuri'])
        cls.simple.default_code = 'RND-S'
        cls.full.default_code = 'RND-C'

        # Pragul de cantitate: de la 5 bucati in sus, -20%. Fara el, un total ar fi
        # mereu pretul unitar inmultit cu cantitatea si testul n-ar dovedi nimic.
        cls.env['product.pricelist.item'].create({
            'pricelist_id': cls.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': cls.product.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})

        cls.product_single = cls.env['product.template'].create({
            'name': 'Produs Randuri Fara Variante Test', 'is_published': True,
            'list_price': 10.0, 'taxes_id': [(6, 0, [])]})

    def setUp(self):
        super().setUp()
        self.addCleanup(self.registry.clear_cache)

    def _rows(self, product=None):
        product = product or self.product
        return self.api_get(f'/products/{product.id}').json()['variant_rows']

    def test_one_row_per_variant_with_attributes_code_and_price(self):
        self.api_login()
        rows = self._rows()
        self.assertEqual([row['variant_id'] for row in rows],
                         self.product.product_variant_ids.ids)
        by_id = {row['variant_id']: row for row in rows}
        self.assertEqual(by_id[self.simple.id]['attributes'],
                         [{'name': 'Set randuri test', 'value': 'Simplu randuri'}])
        self.assertEqual(by_id[self.simple.id]['default_code'], 'RND-S')
        self.assertEqual(by_id[self.full.id]['default_code'], 'RND-C')
        # `price_extra` se vede in pretul randului: altfel tabelul ar arata acelasi
        # pret pe toate randurile, desi magazinul le arata diferite.
        self.assertEqual(by_id[self.simple.id]['price']['amount'], 100.0)
        self.assertEqual(by_id[self.full.id]['price']['amount'], 120.0)
        # Simbolul depinde de valuta companiei bazei de test; ce e de contract e
        # formatarea romaneasca a numarului (virgula zecimala).
        self.assertIn('120,00', by_id[self.full.id]['price']['formatted'])

    def test_row_availability_uses_the_shared_helper(self):
        # `website_sale_stock` nu e instalat pe baza locala, deci ajutorul intoarce
        # None - important e ca randul are cheia, nu ca are un mesaj.
        self.api_login()
        rows = self._rows()
        for row in rows:
            self.assertIn('availability', row)
            self.assertEqual(row['availability'],
                             self.product._uportho_availability(
                                 variant=self.env['product.product'].browse(row['variant_id'])))

    def test_single_variant_product_has_no_rows(self):
        self.api_login()
        self.assertEqual(self._rows(self.product_single), [])

    def test_rows_shape_matches_contract(self):
        self.api_login()
        contract = load_contract('product_detail.json')
        row = self._rows()[0]
        self.assertEqual(set(row.keys()), set(contract['variant_rows'][0].keys()))
        self.assertEqual(set(row['attributes'][0].keys()),
                         set(contract['variant_rows'][0]['attributes'][0].keys()))
        self.assertEqual(set(row['price'].keys()),
                         set(contract['variant_rows'][0]['price'].keys()))


@tagged('post_install', '-at_install')
class TestControllersProductPrices(AppHttpCase):
    """`POST /products/<id>/prices` - preturile si subtotalurile tabelului de
    variante, calculate de Odoo. Aplicatia nu inmulteste niciodata bani, iar o
    cantitate mai mare poate trece un prag de pret: de aceea cere aici."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista client test preturi linii', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        cls.attribute = cls.env['product.attribute'].create({
            'name': 'Set linii test',
            'value_ids': [(0, 0, {'name': 'Simplu linii'}), (0, 0, {'name': 'Complet linii'})],
        })
        cls.product = cls.env['product.template'].create({
            'name': 'Produs Linii Pret Test', 'is_published': True, 'list_price': 100.0,
            'taxes_id': [(6, 0, [])],
            'attribute_line_ids': [(0, 0, {
                'attribute_id': cls.attribute.id,
                'value_ids': [(6, 0, cls.attribute.value_ids.ids)],
            })],
        })
        cls.ptav = {
            ptav.product_attribute_value_id.name: ptav
            for line in cls.product.attribute_line_ids
            for ptav in line.product_template_value_ids
        }
        cls.ptav['Complet linii'].price_extra = 20.0
        cls.simple = cls.product._get_variant_for_combination(cls.ptav['Simplu linii'])
        cls.full = cls.product._get_variant_for_combination(cls.ptav['Complet linii'])

        cls.env['product.pricelist.item'].create({
            'pricelist_id': cls.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': cls.product.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})

        cls.other_product = cls.env['product.template'].create({
            'name': 'Alt Produs Linii Pret Test', 'is_published': True, 'list_price': 10.0})
        cls.unpublished = cls.env['product.template'].create({
            'name': 'Produs Linii Pret Nepublicat Test', 'is_published': False, 'list_price': 10.0})

    def setUp(self):
        super().setUp()
        self.addCleanup(self.registry.clear_cache)

    def _prices(self, lines, product=None, with_header=True):
        product = product or self.product
        return self.api_post(f'/products/{product.id}/prices',
                             {'lines': lines}, with_header=with_header)

    # --- acces si validare ----------------------------------------------------

    def test_requires_login(self):
        self.assertEqual(self._prices([]).status_code, 401)

    def test_requires_app_header(self):
        self.api_login()
        response = self._prices([], with_header=False)
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json()['error']['code'], 'forbidden')

    def test_unpublished_product_is_404(self):
        self.api_login()
        self.assertEqual(self._prices([], product=self.unpublished).status_code, 404)

    def test_error_shape_is_the_module_one(self):
        response = self._prices([])
        self.assertEqual(set(response.json()['error'].keys()),
                         set(load_contract('error.json')['error'].keys()))

    def test_variant_of_another_product_is_422_not_500(self):
        self.api_login()
        stranger = self.other_product.product_variant_id
        response = self._prices([{'variant_id': stranger.id, 'qty': 1}])
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_unknown_variant_is_422_not_500(self):
        self.api_login()
        self.assertEqual(self._prices([{'variant_id': 99999999, 'qty': 1}]).status_code, 422)

    def test_missing_variant_id_is_422(self):
        self.api_login()
        self.assertEqual(self._prices([{'qty': 1}]).status_code, 422)

    def test_negative_quantity_is_422(self):
        self.api_login()
        self.assertEqual(
            self._prices([{'variant_id': self.simple.id, 'qty': -1}]).status_code, 422)

    def test_non_integer_quantity_is_422(self):
        self.api_login()
        for qty in (1.5, '3', None, True):
            self.assertEqual(
                self._prices([{'variant_id': self.simple.id, 'qty': qty}]).status_code, 422, qty)

    def test_lines_must_be_a_list_of_objects(self):
        self.api_login()
        self.assertEqual(self._prices('nu e lista').status_code, 422)
        self.assertEqual(self._prices([7]).status_code, 422)

    # --- preturi --------------------------------------------------------------

    def test_empty_lines_give_a_zero_total(self):
        self.api_login()
        body = self._prices([]).json()
        self.assertEqual(body['lines'], [])
        self.assertEqual(body['total']['amount'], 0.0)
        self.assertIn('0,00', body['total']['formatted'])

    def test_line_price_and_subtotal_come_from_odoo(self):
        self.api_login()
        body = self._prices([{'variant_id': self.simple.id, 'qty': 2}]).json()
        line = body['lines'][0]
        self.assertEqual(line['variant_id'], self.simple.id)
        self.assertEqual(line['qty'], 2)
        self.assertEqual(line['price']['amount'], 100.0)
        self.assertEqual(line['subtotal']['amount'], 200.0)
        self.assertIn('200,00', line['subtotal']['formatted'])
        self.assertEqual(body['total']['amount'], 200.0)

    def test_quantity_threshold_changes_the_unit_price_and_the_total(self):
        # Miezul rutei: la 5 bucati se aplica pragul, deci totalul NU e pretul
        # unitar afisat (100) inmultit cu cantitatea. Daca aplicatia ar inmulti
        # singura, ar arata 500 in loc de 400.
        self.api_login()
        body = self._prices([{'variant_id': self.simple.id, 'qty': 5}]).json()
        line = body['lines'][0]
        self.assertEqual(line['price']['amount'], 80.0)
        self.assertEqual(line['subtotal']['amount'], 400.0)
        self.assertEqual(body['total']['amount'], 400.0)

    def test_price_extra_of_the_variant_is_included(self):
        self.api_login()
        body = self._prices([{'variant_id': self.full.id, 'qty': 1}]).json()
        self.assertEqual(body['lines'][0]['price']['amount'], 120.0)

    def test_total_sums_lines_priced_at_their_own_quantity(self):
        self.api_login()
        body = self._prices([
            {'variant_id': self.simple.id, 'qty': 5},
            {'variant_id': self.full.id, 'qty': 2},
        ]).json()
        self.assertEqual([line['subtotal']['amount'] for line in body['lines']], [400.0, 240.0])
        self.assertEqual(body['total']['amount'], 640.0)
        self.assertIn('640,00', body['total']['formatted'])

    def test_zero_quantity_keeps_the_unit_price_of_one(self):
        # `quantity=0` nu e un prag real: pretuit chiar la 0, Odoo nu aplica regula
        # (aceeasi capcana ca `min_quantity = 0` din `_uportho_price_tiers`). Randul
        # gol trebuie sa arate pretul de la 1 bucata, cu subtotal zero.
        self.api_login()
        body = self._prices([{'variant_id': self.simple.id, 'qty': 0}]).json()
        self.assertEqual(body['lines'][0]['price']['amount'], 100.0)
        self.assertEqual(body['lines'][0]['subtotal']['amount'], 0.0)
        self.assertEqual(body['total']['amount'], 0.0)

    def test_shape_matches_contract(self):
        self.api_login()
        contract = load_contract('product_prices.json')
        body = self._prices([{'variant_id': self.simple.id, 'qty': 5}]).json()
        self.assertEqual(set(body.keys()), set(contract.keys()))
        self.assertEqual(set(body['lines'][0].keys()), set(contract['lines'][0].keys()))
        self.assertEqual(set(body['lines'][0]['price'].keys()),
                         set(contract['lines'][0]['price'].keys()))
        self.assertEqual(set(body['lines'][0]['subtotal'].keys()),
                         set(contract['lines'][0]['subtotal'].keys()))
        self.assertEqual(set(body['total'].keys()), set(contract['total'].keys()))
