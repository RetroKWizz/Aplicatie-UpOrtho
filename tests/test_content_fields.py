from datetime import date, timedelta

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
        self.assertEqual(product._app_badge_active(), {'text': 'Nou', 'color': 'green'})

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
