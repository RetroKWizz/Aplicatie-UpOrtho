import base64
from unittest.mock import patch

from odoo.addons.uportho_app.controllers import product as product_controller
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
        # Memoria "am scris deja traceback-ul pentru produsul asta" traieste la nivel
        # de proces, nu de tranzactie: fara golire, al doilea test care face
        # `_get_combination_info` sa cada ar vedea doar avertizarea scurta si ar depinde
        # de ordinea testelor.
        product_controller._COMBINATION_INFO_LOGGED.clear()
        self.addCleanup(product_controller._COMBINATION_INFO_LOGGED.clear)

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
        # Fara randuri de varianta nu exista nici total de pornire.
        self.assertIsNone(body['variant_total'])
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

    # --- tabelele de pret calculate direct din listele magazinului -------------

    def _site_pricelists(self, *pricelists):
        """Listele de pret pe care modulul clientului le arata pe pagina de produs.

        Ele se aleg dupa `is_public_pricelist` / `is_compare_pricelist`, doua campuri
        pe care modulele clientului le adauga pe `product.pricelist` si care nu exista
        pe baza locala - deci nu se poate crea o lista "publica" aici. Se inlocuieste
        doar selectia (`_uportho_site_pricelists`); tot restul - pragurile, preturile,
        titlurile, nota, ordinea, regula tabelului inutil - ruleaza codul adevarat, pe
        liste de pret si reguli adevarate."""
        Template = type(self.env['product.template'])
        selected = self.env['product.pricelist'].browse(
            [pricelist.id for pricelist in pricelists])
        return patch.object(Template, '_uportho_site_pricelists', lambda _self: selected)

    def test_price_tables_are_computed_directly_from_the_site_pricelists(self):
        # Cazul de pe serverul clientului: `_get_combination_info` arunca de fiecare
        # data (tema randeaza inauntrul lui un template QWeb de website), deci
        # `other_bulk_prices` nu se poate citi niciodata. Tabelele trebuie sa iasa
        # totusi cu titlurile listelor magazinului, nu cu titlul nostru implicit.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        site_pricelist = self.env['product.pricelist'].create({
            'name': 'Pret public site test', 'currency_id': self.currency.id})
        for min_qty, pret in ((1, 200.0), (5, 150.0)):
            self.env['product.pricelist.item'].create({
                'pricelist_id': site_pricelist.id, 'applied_on': '1_product',
                'product_tmpl_id': self.product_bare.id, 'min_quantity': min_qty,
                'compute_price': 'fixed', 'fixed_price': pret})

        with self._combination_info_raising(), self._site_pricelists(site_pricelist), \
                self.assertLogs('odoo.addons.uportho_app.controllers.product', level='ERROR'):
            body = self._detail(self.product_bare).json()

        self.assertEqual([table['title'] for table in body['price_tables']],
                         ['Pret public site test'])
        entries = body['price_tables'][0]['entries']
        self.assertEqual([entry['label'] for entry in entries], ['1+', '5+'])
        self.assertAlmostEqual(entries[0]['price']['amount'], 200.0, places=2)
        self.assertAlmostEqual(entries[1]['price']['amount'], 150.0, places=2)

    def test_site_pricelists_replace_the_module_own_tiers(self):
        # Cand magazinul are listele lui, tabelul nostru implicit ("Pret pe cantitate")
        # nu mai apare deloc - altfel pagina din app ar spune altceva decat site-ul.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        site_pricelist = self.env['product.pricelist'].create({
            'name': 'Pret public site test 2', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': site_pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'min_quantity': 3,
            'compute_price': 'fixed', 'fixed_price': 120.0})

        with self._site_pricelists(site_pricelist):
            body = self._detail(self.product_bare).json()

        self.assertEqual([table['title'] for table in body['price_tables']],
                         ['Pret public site test 2'])

    def test_theme_tables_win_over_the_direct_computation(self):
        # Daca `other_bulk_prices` chiar ajunge sa fie citibil (un server pe care
        # `_get_combination_info` nu cade), el ramane sursa: e exact ce a calculat
        # magazinul pentru pagina lui.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        site_pricelist = self.env['product.pricelist'].create({
            'name': 'Lista calculata direct', 'currency_id': self.currency.id})
        self.env['product.pricelist.item'].create({
            'pricelist_id': site_pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'min_quantity': 1,
            'compute_price': 'fixed', 'fixed_price': 120.0})

        with self._site_pricelists(site_pricelist), \
                self._combination_info_with_theme_tables([
                    {'name': 'Tabel din tema', 'prices': [{'qty': 1, 'price': 140.0}]}]):
            body = self._detail(self.product_bare).json()

        self.assertEqual([table['title'] for table in body['price_tables']], ['Tabel din tema'])

    def test_site_table_equal_to_the_displayed_price_is_dropped(self):
        # Aceeasi regula ca la celelalte tabele: un singur rand care repeta pretul de
        # deasupra lui nu se deseneaza.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        site_pricelist = self.env['product.pricelist'].create({
            'name': 'Lista identica cu pretul', 'currency_id': self.currency.id})
        price = self._detail(self.product_bare).json()['price']['amount']
        self.env['product.pricelist.item'].create({
            'pricelist_id': site_pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'min_quantity': 1,
            'compute_price': 'fixed', 'fixed_price': price})

        with self._site_pricelists(site_pricelist):
            body = self._detail(self.product_bare).json()

        self.assertEqual(body['price_tables'], [])

    def test_without_the_client_fields_the_module_own_tiers_are_used(self):
        # Baza locala (si orice instanta fara modulele clientului): nicio lista de
        # magazin de ales, deci se cade pe tabelele calculate de modul. Aici nu se
        # inlocuieste nimic - e ramura reala.
        self.api_login()
        self.env['ir.config_parameter'].sudo().set_param(self.CLUB_PARAM, '')
        self.assertFalse(self.product_bare._uportho_site_pricelists())
        self.env['product.pricelist.item'].create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': self.product_bare.id, 'compute_price': 'percentage',
            'percent_price': 20.0, 'min_quantity': 5})
        body = self._detail(self.product_bare).json()
        self.assertEqual([table['title'] for table in body['price_tables']], ['Pret pe cantitate'])

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

    def test_failing_combination_info_logs_the_traceback_only_once_per_product(self):
        # Pe serverul clientului apelul cade la FIECARE cerere de produs, mereu cu
        # acelasi traceback. Scris de fiecare data, ar face logurile de productie
        # nefolosibile: prima aparitie ramane intreaga, urmatoarele sunt o linie scurta.
        self.api_login()
        logger = 'odoo.addons.uportho_app.controllers.product'
        with self._combination_info_raising(), self.assertLogs(logger, level='WARNING') as captured:
            self.assertEqual(self._detail().status_code, 200)
            self.assertEqual(self._detail().status_code, 200)
            self.assertEqual(self._detail().status_code, 200)

        records = [record for record in captured.records
                   if str(self.product.id) in record.getMessage()]
        self.assertEqual(len(records), 3)
        self.assertEqual(records[0].levelname, 'ERROR')
        self.assertIsNotNone(records[0].exc_info)
        for record in records[1:]:
            self.assertEqual(record.levelname, 'WARNING')
            # Fara traceback, dar tot cu id-ul produsului: se vede ca mai pica.
            self.assertIsNone(record.exc_info)
            self.assertIn(str(self.product.id), record.getMessage())

    def test_each_product_gets_its_own_first_traceback(self):
        # Memoria e per produs, nu una singura pe tot procesul: un al doilea produs
        # care cade isi scrie si el traceback-ul, altfel prima cadere a unui produs
        # nou ar ramane fara nicio explicatie in loguri.
        self.api_login()
        logger = 'odoo.addons.uportho_app.controllers.product'
        with self._combination_info_raising(), self.assertLogs(logger, level='WARNING') as captured:
            self._detail()
            self._detail(self.product_bare)

        with_traceback = [record for record in captured.records if record.exc_info]
        self.assertEqual(len(with_traceback), 2)

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

    # --- subtotalurile si totalul de pornire (cantitati zero) ------------------

    def test_rows_carry_the_subtotal_of_a_zero_quantity(self):
        # Tabelul porneste cu toate cantitatile pe zero. Fara sumele astea in
        # raspuns, coloana Subtotal si Totalul raman goale ("—") pana la prima
        # apasare pe plus - aplicatia nu are voie sa scrie ea "0,00 lei".
        self.api_login()
        for row in self._rows():
            self.assertEqual(row['subtotal']['amount'], 0.0)
            self.assertIn('0,00', row['subtotal']['formatted'])
            self.assertIsNone(row['subtotal']['list_amount'])

    def test_detail_carries_the_total_of_zero_quantities(self):
        self.api_login()
        body = self.api_get(f'/products/{self.product.id}').json()
        self.assertEqual(body['variant_total']['amount'], 0.0)
        self.assertIn('0,00', body['variant_total']['formatted'])

    def test_no_total_for_a_product_without_rows(self):
        # Fara tabel nu exista total: sectiunea lipseste cu totul de pe ecran.
        self.api_login()
        body = self.api_get(f'/products/{self.product_single.id}').json()
        self.assertIsNone(body['variant_total'])

    def test_starting_amounts_match_what_the_prices_route_returns_for_zero(self):
        # Dovada ca nu sunt doua adevaruri despre acelasi zero: sumele de pornire din
        # detaliu sunt exact ce raspunde ruta de preturi cu toate cantitatile pe zero.
        self.api_login()
        body = self.api_get(f'/products/{self.product.id}').json()
        priced = self.api_post(f'/products/{self.product.id}/prices', {
            'lines': [{'variant_id': row['variant_id'], 'qty': 0} for row in body['variant_rows']],
        }).json()
        self.assertEqual([row['subtotal'] for row in body['variant_rows']],
                         [line['subtotal'] for line in priced['lines']])
        self.assertEqual(body['variant_total'], priced['total'])

    def test_rows_shape_matches_contract(self):
        self.api_login()
        contract = load_contract('product_detail.json')
        row = self._rows()[0]
        self.assertEqual(set(row.keys()), set(contract['variant_rows'][0].keys()))
        self.assertEqual(set(row['subtotal'].keys()),
                         set(contract['variant_rows'][0]['subtotal'].keys()))
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

    def test_total_sums_lines_priced_at_the_combined_quantity(self):
        # 5 + 2 = 7 bucati in tabel, deci pragul de 5 se aplica pe AMBELE randuri
        # (asa incaseaza si site-ul), nu doar pe randul care are singur 5.
        self.api_login()
        body = self._prices([
            {'variant_id': self.simple.id, 'qty': 5},
            {'variant_id': self.full.id, 'qty': 2},
        ]).json()
        self.assertEqual([line['price']['amount'] for line in body['lines']], [80.0, 96.0])
        self.assertEqual([line['subtotal']['amount'] for line in body['lines']], [400.0, 192.0])
        self.assertEqual(body['total']['amount'], 592.0)
        self.assertIn('592,00', body['total']['formatted'])

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


@tagged('post_install', '-at_install')
class TestControllersProductPricesCombinedQuantity(AppHttpCase):
    """Pragurile de cantitate se aplica pe cantitatea CUMULATA a tuturor liniilor, nu
    pe fiecare linie in parte - exact ce face `website_variant_cart` pe serverul
    clientului (`total_qty` insumat, apoi `_get_combination_info_variant(add_qty=
    total_qty)` pentru fiecare varianta).

    Defectul pe care il inchid testele astea: cu praguri 1+ 98 / 4+ 77 / 10+ 70, o
    comanda de 4 pe o varianta si 7 pe alta era pretuita 77 pe ambele randuri, desi
    site-ul incaseaza 70 (4 + 7 = 11, peste pragul de 10).

    Toate sumele asteptate se cer de la Odoo (`_uportho_price_amounts_for`), nu se
    scriu de mana: altfel un test ar putea trece cu o aritmetica de pricelist deviata."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.currency = cls.env.company.currency_id
        cls.pricelist = cls.env['product.pricelist'].create({
            'name': 'Lista praguri cumulate test', 'currency_id': cls.currency.id})
        cls.portal_user.partner_id.property_product_pricelist = cls.pricelist.id

        cls.attribute = cls.env['product.attribute'].create({
            'name': 'Set cumulat test',
            'value_ids': [(0, 0, {'name': 'Simplu cumulat'}), (0, 0, {'name': 'Complet cumulat'})],
        })
        # Fara taxe: testul vorbeste despre praguri de cantitate, nu despre TVA.
        cls.product = cls.env['product.template'].create({
            'name': 'Produs Cantitate Cumulata Test', 'is_published': True, 'list_price': 98.0,
            'taxes_id': [(6, 0, [])],
            'attribute_line_ids': [(0, 0, {
                'attribute_id': cls.attribute.id,
                'value_ids': [(6, 0, cls.attribute.value_ids.ids)],
            })],
        })
        ptav = {
            value.product_attribute_value_id.name: value
            for line in cls.product.attribute_line_ids
            for value in line.product_template_value_ids
        }
        cls.simple = cls.product._get_variant_for_combination(ptav['Simplu cumulat'])
        cls.full = cls.product._get_variant_for_combination(ptav['Complet cumulat'])

        # Pragurile din raportul de pe staging: 1+ 98,00 / 4+ 77,00 / 10+ 70,00.
        for min_quantity, price in ((1, 98.0), (4, 77.0), (10, 70.0)):
            cls.env['product.pricelist.item'].create({
                'pricelist_id': cls.pricelist.id, 'applied_on': '1_product',
                'product_tmpl_id': cls.product.id, 'compute_price': 'fixed',
                'fixed_price': price, 'min_quantity': min_quantity})

    def setUp(self):
        super().setUp()
        self.addCleanup(self.registry.clear_cache)

    def _odoo_amount(self, variant, quantity):
        """Pretul unitar pe care il da Odoo pentru varianta asta la cantitatea asta -
        aceeasi cale pe care o foloseste si ruta. Sumele asteptate vin de aici, nu din
        cifre scrise de mana."""
        amount, _list_amount = self.product._uportho_price_amounts_for(
            self.pricelist, self.portal_user.partner_id, quantity=quantity, variant=variant)
        return amount

    def _prices(self, lines):
        return self.api_post(f'/products/{self.product.id}/prices', {'lines': lines}).json()

    def test_thresholds_apply_to_the_combined_quantity_of_all_lines(self):
        self.api_login()
        body = self._prices([
            {'variant_id': self.simple.id, 'qty': 4},
            {'variant_id': self.full.id, 'qty': 7},
        ])
        # 4 + 7 = 11, deci ambele randuri se pretuiesc la pragul de 10.
        expected_simple = self._odoo_amount(self.simple, 11)
        expected_full = self._odoo_amount(self.full, 11)
        # Dovada ca testul chiar prinde defectul: pretul la 11 NU e pretul la 4.
        self.assertNotEqual(expected_simple, self._odoo_amount(self.simple, 4))

        lines = {line['variant_id']: line for line in body['lines']}
        self.assertEqual(lines[self.simple.id]['price']['amount'], expected_simple)
        self.assertEqual(lines[self.full.id]['price']['amount'], expected_full)
        self.assertEqual(lines[self.simple.id]['subtotal']['amount'],
                         self.currency.round(expected_simple * 4))
        self.assertEqual(lines[self.full.id]['subtotal']['amount'],
                         self.currency.round(expected_full * 7))
        self.assertEqual(body['total']['amount'],
                         self.currency.round(expected_simple * 4) +
                         self.currency.round(expected_full * 7))

    def test_a_single_line_of_four_still_gets_the_four_price(self):
        # Regula noua nu inseamna "mereu cel mai ieftin prag": o singura linie de 4
        # ramane la pretul de 4+, nu coboara la cel de 10+.
        self.api_login()
        body = self._prices([
            {'variant_id': self.simple.id, 'qty': 4},
            {'variant_id': self.full.id, 'qty': 0},
        ])
        expected = self._odoo_amount(self.simple, 4)
        self.assertNotEqual(expected, self._odoo_amount(self.simple, 10))
        lines = {line['variant_id']: line for line in body['lines']}
        self.assertEqual(lines[self.simple.id]['price']['amount'], expected)
        self.assertEqual(lines[self.simple.id]['subtotal']['amount'],
                         self.currency.round(expected * 4))
        self.assertEqual(body['total']['amount'], self.currency.round(expected * 4))

    def test_a_zero_quantity_line_is_priced_at_the_combined_quantity_too(self):
        # Randul necomandat arata pretul pe care l-ar avea daca ar fi adaugat la
        # comanda curenta - ca pe site, unde tot tabelul se repretuieste la total.
        self.api_login()
        body = self._prices([
            {'variant_id': self.simple.id, 'qty': 11},
            {'variant_id': self.full.id, 'qty': 0},
        ])
        lines = {line['variant_id']: line for line in body['lines']}
        self.assertEqual(lines[self.full.id]['price']['amount'],
                         self._odoo_amount(self.full, 11))
        self.assertEqual(lines[self.full.id]['subtotal']['amount'], 0.0)

    def test_all_quantities_zero_are_priced_at_one(self):
        # `add_qty=total_qty or 1` din template-ul clientului: cu totalul zero, pretul
        # afisat e cel de la o bucata, nu pretul nereduse pe care l-ar da o pretuire
        # la cantitatea 0.
        self.api_login()
        body = self._prices([
            {'variant_id': self.simple.id, 'qty': 0},
            {'variant_id': self.full.id, 'qty': 0},
        ])
        for line in body['lines']:
            variant = self.env['product.product'].browse(line['variant_id'])
            self.assertEqual(line['price']['amount'], self._odoo_amount(variant, 1))
            self.assertEqual(line['subtotal']['amount'], 0.0)
        self.assertEqual(body['total']['amount'], 0.0)

    def test_starting_rows_of_the_detail_match_a_table_with_no_quantities(self):
        # Tabelul se deschide cu toate cantitatile pe zero: preturile din
        # `variant_rows` trebuie sa fie exact cele pe care le da ruta de preturi
        # pentru aceeasi stare, altfel prima apasare pe plus ar schimba un pret fara
        # motiv vizibil.
        self.api_login()
        rows = self.api_get(f'/products/{self.product.id}').json()['variant_rows']
        priced = self._prices([{'variant_id': row['variant_id'], 'qty': 0} for row in rows])
        self.assertEqual([row['price'] for row in rows],
                         [line['price'] for line in priced['lines']])
