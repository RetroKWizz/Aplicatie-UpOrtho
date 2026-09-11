from datetime import date, timedelta
from unittest.mock import patch

from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestHomeCategoryFields(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Category = cls.env['product.public.category']
        cls.website = cls.env['website'].search([], limit=1)

    def test_only_visible_categories_ordered_by_app_sequence(self):
        hidden = self.Category.create({'name': 'Ascunsa', 'app_home_visible': False})
        second = self.Category.create({'name': 'B', 'app_home_visible': True, 'app_home_sequence': 20})
        first = self.Category.create({'name': 'A', 'app_home_visible': True, 'app_home_sequence': 5})
        result = self.Category._search_app_home(self.website)
        self.assertNotIn(hidden, result)
        names = result.mapped('name')
        self.assertLess(names.index('A'), names.index('B'))


@tagged('post_install', '-at_install')
class TestProductBadge(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Template = cls.env['product.template']

    def test_no_badge_returns_none(self):
        product = self.Template.create({'name': 'P'})
        self.assertIsNone(product._app_badge_active())

    def test_badge_without_end_date_is_active(self):
        product = self.Template.create({'name': 'P', 'app_badge_text': 'Nou', 'app_badge_color': 'green'})
        self.assertEqual(product._app_badge_active(), {
            'text': 'Nou', 'color': 'green', 'background_color': None, 'text_color': None})

    def test_expired_badge_returns_none(self):
        product = self.Template.create({
            'name': 'P', 'app_badge_text': 'Nou', 'app_badge_color': 'green',
            'app_badge_date_end': date.today() - timedelta(days=1)})
        self.assertIsNone(product._app_badge_active())

    def test_badge_ending_today_is_active(self):
        product = self.Template.create({
            'name': 'P', 'app_badge_text': 'Nou', 'app_badge_color': 'green',
            'app_badge_date_end': date.today()})
        self.assertIsNotNone(product._app_badge_active())

    def test_badge_text_without_color_defaults_to_purple(self):
        product = self.Template.create({'name': 'P', 'app_badge_text': 'Popular'})
        self.assertEqual(product._app_badge_active()['color'], 'purple')

    def test_the_shop_label_wins_over_our_own_badge(self):
        """Pe instanta reala eticheta vine de la tema magazinului (`dr_label_id`), cu
        textul si culorile ei. Campul nu exista pe baza locala, asa ca testul il
        simuleaza - altfel comportamentul care conteaza in productie n-ar fi acoperit
        de niciun test."""
        product = self.Template.create({
            'name': 'P', 'app_badge_text': 'Eticheta noastra', 'app_badge_color': 'green'})
        Template = type(product)

        class FakeLabel:
            name = 'pana la -40%'
            background_color = '#f47c0b'
            text_color = '#FFFFFF'

            def sudo(self):
                return self

            def __bool__(self):
                return True

        with patch.dict(Template._fields, {'dr_label_id': object()}), \
                patch.object(Template, 'dr_label_id', FakeLabel(), create=True):
            self.assertEqual(product._app_badge_active(), {
                'text': 'pana la -40%',
                'color': None,
                'background_color': '#f47c0b',
                'text_color': '#FFFFFF',
            })
