from datetime import date, timedelta

from odoo.exceptions import ValidationError
from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestAppBanner(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Banner = cls.env['uportho.app.banner']
        cls.website = cls.env['website'].search([], limit=1)
        cls.other_website = cls.env['website'].create({'name': 'Alt site'})
        cls.today = date.today()

    def _make(self, **vals):
        base = {'name': 'Banner', 'placement': 'hero', 'link_type': 'none', 'sequence': 10}
        base.update(vals)
        return self.Banner.create(base)

    def test_active_without_dates_is_returned(self):
        banner = self._make()
        self.assertIn(banner, self.Banner._search_active_now(self.website))

    def test_archived_is_excluded(self):
        banner = self._make(active=False)
        self.assertNotIn(banner, self.Banner._search_active_now(self.website))

    def test_future_start_is_excluded(self):
        banner = self._make(date_start=self.today + timedelta(days=1))
        self.assertNotIn(banner, self.Banner._search_active_now(self.website))

    def test_past_end_is_excluded(self):
        banner = self._make(date_end=self.today - timedelta(days=1))
        self.assertNotIn(banner, self.Banner._search_active_now(self.website))

    def test_window_including_today_is_returned(self):
        banner = self._make(date_start=self.today, date_end=self.today)
        self.assertIn(banner, self.Banner._search_active_now(self.website))

    def test_other_website_is_excluded_but_no_website_is_returned(self):
        generic = self._make(website_id=False)
        mine = self._make(website_id=self.website.id)
        other = self._make(website_id=self.other_website.id)
        result = self.Banner._search_active_now(self.website)
        self.assertIn(generic, result)
        self.assertIn(mine, result)
        self.assertNotIn(other, result)

    def test_ordered_by_sequence(self):
        self._make(sequence=20, name='B')
        self._make(sequence=5, name='A')
        names = self.Banner._search_active_now(self.website).mapped('name')
        self.assertLess(names.index('A'), names.index('B'))

    def test_category_link_requires_category(self):
        with self.assertRaises(ValidationError):
            self._make(link_type='category', category_id=False)

    def test_url_link_requires_url(self):
        with self.assertRaises(ValidationError):
            self._make(link_type='url', external_url=False)
