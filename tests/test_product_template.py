from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestProductDescriptionBlocks(TransactionCase):
    """`_uportho_description_blocks()`: HTML -> blocuri/spans-uri JSON, niciodata HTML.
    Vezi planul Fazei 2, Task 2, si spec-ul sectiunea 12 (sectiunile in mai multe
    limbi din website_description)."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Template = cls.env['product.template']

    def test_empty_html_returns_empty_list(self):
        product = self.Template.create({'name': 'P', 'website_description': False})
        self.assertEqual(product._uportho_description_blocks(), [])

    def test_heading_tags_become_heading_blocks(self):
        product = self.Template.create({
            'name': 'P', 'website_description': '<h2>Titlu sectiune</h2>'})
        blocks = product._uportho_description_blocks()
        self.assertEqual(len(blocks), 1)
        self.assertEqual(blocks[0]['type'], 'heading')
        self.assertEqual(blocks[0]['spans'], [{'text': 'Titlu sectiune', 'bold': False, 'italic': False}])

    def test_paragraph_tag_becomes_paragraph_block(self):
        product = self.Template.create({
            'name': 'P', 'website_description': '<p>Un text simplu.</p>'})
        blocks = product._uportho_description_blocks()
        self.assertEqual(blocks, [{
            'type': 'paragraph',
            'spans': [{'text': 'Un text simplu.', 'bold': False, 'italic': False}],
        }])

    def test_list_tag_becomes_bullets_block(self):
        product = self.Template.create({
            'name': 'P',
            'website_description': '<ul><li>Primul punct.</li><li>Al doilea punct.</li></ul>'})
        blocks = product._uportho_description_blocks()
        self.assertEqual(len(blocks), 1)
        self.assertEqual(blocks[0]['type'], 'bullets')
        self.assertEqual(blocks[0]['items'], [
            {'spans': [{'text': 'Primul punct.', 'bold': False, 'italic': False}]},
            {'spans': [{'text': 'Al doilea punct.', 'bold': False, 'italic': False}]},
        ])

    def test_ordered_list_also_becomes_bullets_block(self):
        product = self.Template.create({
            'name': 'P', 'website_description': '<ol><li>Un pas.</li></ol>'})
        blocks = product._uportho_description_blocks()
        self.assertEqual(blocks[0]['type'], 'bullets')

    def test_strong_and_em_become_bold_and_italic_spans(self):
        product = self.Template.create({
            'name': 'P',
            'website_description': '<p>Text <strong>ingrosat</strong> si <em>inclinat</em>.</p>'})
        spans = product._uportho_description_blocks()[0]['spans']
        self.assertIn({'text': 'ingrosat', 'bold': True, 'italic': False}, spans)
        self.assertIn({'text': 'inclinat', 'bold': False, 'italic': True}, spans)

    def test_b_and_i_tags_are_treated_like_strong_and_em(self):
        product = self.Template.create({
            'name': 'P', 'website_description': '<p><b>gras</b> <i>oblic</i></p>'})
        spans = product._uportho_description_blocks()[0]['spans']
        self.assertIn({'text': 'gras', 'bold': True, 'italic': False}, spans)
        self.assertIn({'text': 'oblic', 'bold': False, 'italic': True}, spans)

    def test_unknown_inline_tag_is_flattened_to_plain_text(self):
        # "Orice altceva se aplatizeaza la text": un <span> (sau <a>) nu produce
        # formatare, doar textul lui intra in span-ul curent.
        product = self.Template.create({
            'name': 'P',
            'website_description': '<p>Vezi <a href="https://uportho.ro">acest link</a>.</p>'})
        spans = product._uportho_description_blocks()[0]['spans']
        for span in spans:
            self.assertFalse(span['bold'])
            self.assertFalse(span['italic'])
        full_text = ''.join(s['text'] for s in spans)
        self.assertIn('acest link', full_text)

    def test_result_is_json_shape_never_html(self):
        # Nu se trimite HTML catre aplicatie - aplicatia nu are motor HTML.
        product = self.Template.create({
            'name': 'P', 'website_description': '<p>Text <strong>simplu</strong>.</p>'})
        blocks = product._uportho_description_blocks()
        serialized = str(blocks)
        self.assertNotIn('<p>', serialized)
        self.assertNotIn('<strong>', serialized)

    def test_only_romanian_tagged_section_is_kept(self):
        # Vezi spec sectiunea 12: website_description poate contine sectiuni cu
        # `data-visibility-value-lang` per limba; se pastreaza doar ro_RO si
        # continutul netaguit, se elimina alte limbi.
        html = (
            '<section data-visibility-value-lang=\'[{"code":"ro_RO","matches":true}]\'>'
            '<p>Continut romana.</p></section>'
            '<section data-visibility-value-lang=\'[{"code":"en_US","matches":true}]\'>'
            '<p>English content.</p></section>'
        )
        product = self.Template.create({'name': 'P', 'website_description': html})
        blocks = product._uportho_description_blocks()
        texts = [span['text'] for block in blocks for span in block.get('spans', [])]
        self.assertIn('Continut romana.', texts)
        self.assertNotIn('English content.', texts)

    def test_untagged_content_outside_language_sections_is_kept(self):
        html = (
            '<p>Continut comun.</p>'
            '<section data-visibility-value-lang=\'[{"code":"en_US","matches":true}]\'>'
            '<p>English only.</p></section>'
        )
        product = self.Template.create({'name': 'P', 'website_description': html})
        blocks = product._uportho_description_blocks()
        texts = [span['text'] for block in blocks for span in block.get('spans', [])]
        self.assertIn('Continut comun.', texts)
        self.assertNotIn('English only.', texts)


@tagged('post_install', '-at_install')
class TestProductSpecs(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Template = cls.env['product.template']
        cls.Attribute = cls.env['product.attribute']
        cls.AttributeValue = cls.env['product.attribute.value']

    def test_specs_returns_name_value_pairs_in_attribute_line_order(self):
        brand_attr = self.Attribute.create({'name': 'Brand Test Specs', 'create_variant': 'no_variant'})
        brand_value = self.AttributeValue.create({'name': 'DB Orthodontics', 'attribute_id': brand_attr.id})
        size_attr = self.Attribute.create({'name': 'Marime Test Specs', 'create_variant': 'always'})
        size_small = self.AttributeValue.create({'name': 'Mic', 'attribute_id': size_attr.id})
        size_big = self.AttributeValue.create({'name': 'Mare', 'attribute_id': size_attr.id})

        product = self.Template.create({
            'name': 'Produs cu specificatii test',
            'attribute_line_ids': [
                (0, 0, {'attribute_id': brand_attr.id, 'value_ids': [(6, 0, [brand_value.id])]}),
                (0, 0, {'attribute_id': size_attr.id, 'value_ids': [(6, 0, [size_small.id, size_big.id])]}),
            ],
        })
        specs = product._uportho_specs()
        self.assertEqual(specs[0], {'name': 'Brand Test Specs', 'value': 'DB Orthodontics'})
        self.assertEqual(specs[1]['name'], 'Marime Test Specs')
        self.assertIn('Mic', specs[1]['value'])
        self.assertIn('Mare', specs[1]['value'])

    def test_no_attribute_lines_returns_empty_list(self):
        product = self.Template.create({'name': 'Produs fara atribute test specs'})
        self.assertEqual(product._uportho_specs(), [])


@tagged('post_install', '-at_install')
class TestProductPriceTiers(TransactionCase):
    """`_uportho_price_tiers()`: pragurile de cantitate, cerute la Odoo unul cate
    unul (niciodata calculate in Python) - vezi planul Fazei 2, Task 2, regulile 1-5."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Template = cls.env['product.template']
        cls.Pricelist = cls.env['product.pricelist']
        cls.Item = cls.env['product.pricelist.item']
        cls.currency = cls.env.company.currency_id
        cls.partner = cls.env['res.partner'].create({'name': 'Client test praguri'})
        cls.pricelist = cls.Pricelist.create({
            'name': 'Lista test praguri', 'currency_id': cls.currency.id})

    def test_no_matching_rules_returns_single_tier_at_quantity_one(self):
        # Regula 4: un singur prag ramas, la cantitatea 1 -> lista NU e goala.
        product = self.Template.create({'name': 'Produs fara reguli test praguri', 'list_price': 100.0})
        tiers = product._uportho_price_tiers(self.pricelist, self.partner)
        self.assertEqual(len(tiers), 1)
        self.assertEqual(tiers[0]['min_qty'], 1)
        self.assertEqual(tiers[0]['label'], '1+')

    def test_distinct_thresholds_produce_distinct_tiers_with_odoo_prices(self):
        # Regulile 1-2: pragurile candidate vin din min_quantity ale regulilor
        # aplicabile, iar pretul fiecarui prag vine de la Odoo (nu se recalculeaza
        # in Python) - aici verificam ca pretul de la Odoo la fiecare cantitate
        # apare corect in tier-ul corespunzator.
        # taxes_id golit explicit: fara el, produsul mosteneste taxa implicita a
        # companiei de test si suma cu TVA nu ar mai fi exact 200.0 - acelasi motiv
        # ca in test_controllers_catalog.py (produsele "fara reducere").
        product = self.Template.create({
            'name': 'Produs cu praguri test praguri', 'list_price': 200.0, 'taxes_id': [(6, 0, [])]})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 1,
            'compute_price': 'fixed', 'fixed_price': 200.0})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 3,
            'compute_price': 'fixed', 'fixed_price': 150.0})

        tiers = product._uportho_price_tiers(self.pricelist, self.partner)
        self.assertEqual([t['min_qty'] for t in tiers], [1, 3])
        self.assertEqual([t['label'] for t in tiers], ['1+', '3+'])
        self.assertAlmostEqual(tiers[0]['price']['amount'], 200.0, places=2)
        self.assertAlmostEqual(tiers[1]['price']['amount'], 150.0, places=2)

    def test_consecutive_identical_prices_collapse_to_the_lowest_threshold(self):
        # Regula 3: trei praguri, doua consecutive cu acelasi pret -> raman doar
        # doua tiere, pastrandu-l pe cel cu cantitatea mai mica dintre cele identice.
        product = self.Template.create({
            'name': 'Produs praguri identice test praguri', 'list_price': 300.0, 'taxes_id': [(6, 0, [])]})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 1,
            'compute_price': 'fixed', 'fixed_price': 300.0})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 3,
            'compute_price': 'fixed', 'fixed_price': 250.0})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 5,
            'compute_price': 'fixed', 'fixed_price': 250.0})

        tiers = product._uportho_price_tiers(self.pricelist, self.partner)
        self.assertEqual([t['min_qty'] for t in tiers], [1, 3])
        self.assertAlmostEqual(tiers[1]['price']['amount'], 250.0, places=2)

    def test_label_for_min_quantity_zero_or_one_is_one_plus(self):
        # Regula 5, cazul cantitatii 0: o regula cu min_quantity 0 se eticheteaza
        # tot "1+", nu "0+".
        product = self.Template.create({'name': 'Produs prag zero test praguri', 'list_price': 100.0})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 0,
            'compute_price': 'fixed', 'fixed_price': 100.0})

        tiers = product._uportho_price_tiers(self.pricelist, self.partner)
        self.assertEqual(len(tiers), 1)
        self.assertEqual(tiers[0]['label'], '1+')

    def test_zero_threshold_does_not_add_a_second_one_plus_row(self):
        # Regresie vazuta pe staging: tabelul arata doua randuri "1+", primul cu
        # pretul intreg (22.430,00) langa cel al clientului (15.701,00).
        #
        # Cauza: pragurile candidate includeau 0 (o regula cu min_quantity 0), iar
        # pretul cerut chiar la cantitatea 0 NU trece prin regula cu min_quantity 1
        # (0 < 1), deci intoarce pretul nereduse. Ambele praguri se eticheteaza "1+".
        # Fixtura are nevoie de doua reguli ca sa reproduca: una la 0 si una la 1.
        product = self.Template.create({
            'name': 'Produs prag zero si unu test praguri', 'list_price': 100.0})
        for min_qty, pret in ((0, 100.0), (1, 70.0), (2, 50.0)):
            self.Item.create({
                'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
                'product_tmpl_id': product.id, 'min_quantity': min_qty,
                'compute_price': 'fixed', 'fixed_price': pret})

        tiers = product._uportho_price_tiers(self.pricelist, self.partner)

        self.assertEqual([t['label'] for t in tiers], ['1+', '2+'])
        self.assertEqual([t['min_qty'] for t in tiers], [1, 2])
        # Randul "1+" arata pretul de la cantitatea 1, nu pe cel de la 0.
        la_unu, _ = product._uportho_price_amounts_for(self.pricelist, self.partner, quantity=1.0)
        la_zero, _ = product._uportho_price_amounts_for(self.pricelist, self.partner, quantity=0.0)
        self.assertAlmostEqual(tiers[0]['price']['amount'], la_unu, places=2)
        self.assertNotAlmostEqual(
            la_zero, la_unu, places=2,
            msg='fixtura degenerata: pretul la 0 si la 1 coincid, testul nu ar prinde regresia')

    def test_label_for_higher_threshold_is_n_plus(self):
        product = self.Template.create({'name': 'Produs eticheta prag test praguri', 'list_price': 100.0})
        self.Item.create({
            'pricelist_id': self.pricelist.id, 'applied_on': '1_product',
            'product_tmpl_id': product.id, 'min_quantity': 10,
            'compute_price': 'fixed', 'fixed_price': 80.0})
        tiers = product._uportho_price_tiers(self.pricelist, self.partner)
        labels = [t['label'] for t in tiers]
        self.assertIn('10+', labels)

    def test_no_pricelist_returns_empty_list(self):
        product = self.Template.create({'name': 'Produs fara pricelist test praguri', 'list_price': 100.0})
        empty_pricelist = self.Pricelist.browse()
        self.assertEqual(product._uportho_price_tiers(empty_pricelist, self.partner), [])


@tagged('post_install', '-at_install')
class TestProductPriceTablesFromTheme(TransactionCase):
    """`_uportho_price_tables_from_theme()`: tabelele de pret CITITE din ce a calculat
    deja magazinul, nu recalculate de noi.

    Modulul clientului (`terrabit_prime_extension`) suprascrie `_get_combination_info`
    si pune in dictionarul intors `other_bulk_prices`: cate o intrare per lista de pret
    aratata pe pagina de produs (`is_public_pricelist`, `is_compare_pricelist`), cu
    `name` (titlul aratat pe site), `bulk_info` (HTML) si `prices`
    (`qty` / `price` / `formatted_price`). Titlul celei de-a doua liste e un nume de
    campanie pe care aplicatia nu are cum sa-l ghiceasca - de aceea vine de la server.

    Modulele acelea nu exista pe baza locala; forma de aici e copiata din codul lor,
    verbatim ca structura (inclusiv `Markup` pe campurile de HTML)."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Template = cls.env['product.template']
        cls.currency = cls.env.company.currency_id
        cls.product = cls.Template.create({'name': 'Produs test tabele tema', 'list_price': 100.0})

    def _payload(self, tables):
        """Un `combination_info` ca cel intors de tema, din care ne intereseaza doar
        `other_bulk_prices` (+ `currency`, valuta afisata)."""
        return {'currency': self.currency, 'other_bulk_prices': tables}

    def test_each_entry_becomes_a_table_with_its_own_title(self):
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Pret public', 'bulk_info': '', 'prices': [
                {'id': '1_1', 'qty': 1, 'price': 120.0, 'uom_name': 'Units'},
                {'id': '1_5', 'qty': 5, 'price': 100.0, 'uom_name': 'Units'},
            ]},
            {'name': 'Campanie Toamna 2026', 'bulk_info': '', 'prices': [
                {'id': '2_1', 'qty': 1, 'price': 90.0, 'uom_name': 'Units'},
            ]},
        ]), self.currency)

        self.assertEqual([t['title'] for t in tables], ['Pret public', 'Campanie Toamna 2026'])
        self.assertEqual([e['label'] for e in tables[0]['entries']], ['1+', '5+'])
        self.assertEqual([e['min_qty'] for e in tables[0]['entries']], [1, 5])
        self.assertAlmostEqual(tables[0]['entries'][1]['price']['amount'], 100.0, places=2)
        self.assertEqual([e['label'] for e in tables[1]['entries']], ['1+'])

    def test_prices_are_formatted_by_the_module_never_as_html(self):
        # `formatted_price` din tema e HTML (Markup). Aplicatia nu are motor HTML:
        # suma se formateaza cu formatorul modulului, ca toate celelalte sume din API.
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Pret public', 'bulk_info': '', 'prices': [
                {'qty': 1, 'price': 1234.5,
                 'formatted_price': '<span class="oe_currency_value">1.234,50</span>&nbsp;lei'},
            ]},
        ]), self.currency)

        price = tables[0]['entries'][0]['price']
        self.assertNotIn('<', price['formatted'])
        self.assertIn('1.234,50', price['formatted'])
        self.assertEqual(price['currency'], self.currency.name)
        self.assertTrue(price['with_vat'])
        self.assertIsNone(price['list_amount'])

    def test_bulk_info_html_becomes_description_blocks_never_html(self):
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Pret public',
             'bulk_info': '<p>Pret <strong>fara</strong> abonament.</p>',
             'prices': [{'qty': 1, 'price': 120.0}]},
        ]), self.currency)

        note = tables[0]['note']
        self.assertEqual([block['type'] for block in note], ['paragraph'])
        self.assertEqual(''.join(span['text'] for span in note[0]['spans']),
                         'Pret fara abonament.')
        self.assertTrue(any(span['bold'] for span in note[0]['spans']))

    def test_missing_bulk_info_gives_an_empty_note(self):
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Pret public', 'prices': [{'qty': 1, 'price': 120.0}]},
        ]), self.currency)
        self.assertEqual(tables[0]['note'], [])

    def test_quantity_zero_is_labelled_as_one(self):
        # `min_quantity = 0` e implicitul Odoo pentru "fara minim", nu un prag real -
        # aceeasi normalizare ca in `_uportho_price_tiers`.
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Pret public', 'prices': [{'qty': 0, 'price': 120.0}]},
        ]), self.currency)
        self.assertEqual(tables[0]['entries'][0], {
            'min_qty': 1, 'label': '1+', 'price': tables[0]['entries'][0]['price']})

    def test_currency_comes_from_the_combination_info_displayed_currency(self):
        # `active_test=False`: pe baza de test o singura valuta e activa, iar o cautare
        # normala ar intoarce un recordset gol (si testul ar trece degeaba).
        other = self.env['res.currency'].with_context(active_test=False).search(
            [('name', '!=', self.currency.name)], limit=1)
        self.assertTrue(other, 'fixtura degenerata: nu exista o a doua valuta')
        tables = self.product._uportho_price_tables_from_theme(
            {'currency': other, 'other_bulk_prices': [
                {'name': 'Pret public', 'prices': [{'qty': 1, 'price': 120.0}]}]},
            self.currency)
        self.assertEqual(tables[0]['entries'][0]['price']['currency'], other.name)

    def test_no_theme_data_returns_no_tables(self):
        for info in ({}, {'other_bulk_prices': []}, {'other_bulk_prices': None}):
            self.assertEqual(
                self.product._uportho_price_tables_from_theme(info, self.currency), [], info)

    def test_entry_without_prices_is_skipped(self):
        # Un tabel fara niciun rand n-are ce desena; nu ajunge in raspuns.
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Lista goala', 'prices': []},
            {'name': 'Pret public', 'prices': [{'qty': 1, 'price': 120.0}]},
        ]), self.currency)
        self.assertEqual([t['title'] for t in tables], ['Pret public'])

    def test_entry_without_name_has_a_null_title_instead_of_breaking(self):
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'bulk_info': '', 'prices': [{'qty': 1, 'price': 120.0}]},
        ]), self.currency)
        self.assertIsNone(tables[0]['title'])

    def test_garbage_rows_are_ignored_not_fatal(self):
        # Cod strain: un rand fara pret sau cu un pret ne-numeric nu are voie sa
        # transforme pagina de produs in 500.
        tables = self.product._uportho_price_tables_from_theme(self._payload([
            {'name': 'Pret public', 'prices': [
                {'qty': 1, 'price': None}, 'nu e un dictionar',
                {'qty': 'x', 'price': 120.0}, {'qty': 3, 'price': 110.0},
            ]},
        ]), self.currency)
        self.assertEqual([e['label'] for e in tables[0]['entries']], ['3+'])
