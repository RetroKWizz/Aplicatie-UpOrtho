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
