from datetime import date, timedelta

from odoo.exceptions import ValidationError
from odoo.tests.common import TransactionCase, tagged
from odoo.tools.safe_eval import safe_eval


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

    def _allowed_categories(self, banner):
        """Evalueaza domeniul declarat pe campul category_id exact cum il evalueaza
        clientul web: cu valorile inregistrarii curente. Cautam apoi cu el, ca sa
        verificam ce se ofera efectiv editorului, nu doar textul domeniului."""
        domain = safe_eval(self.Banner._fields['category_id'].domain,
                           {'website_id': banner.website_id.id})
        return self.env['product.public.category'].search(domain)

    def test_category_domain_restricts_to_the_banner_website(self):
        Category = self.env['product.public.category']
        generic = Category.create({'name': 'Categorie fara website'})
        mine = Category.create({'name': 'Categorie site A', 'website_id': self.website.id})
        other = Category.create({'name': 'Categorie site B', 'website_id': self.other_website.id})
        banner = self._make(website_id=self.website.id)

        allowed = self._allowed_categories(banner)
        self.assertIn(generic, allowed)
        self.assertIn(mine, allowed)
        self.assertNotIn(other, allowed)

    def test_category_domain_for_a_banner_without_website_allows_only_generic_categories(self):
        """Un banner fara website apare pe toate website-urile, deci o categorie legata
        de un anume website nu i-ar fi rezolvabila peste tot."""
        Category = self.env['product.public.category']
        generic = Category.create({'name': 'Categorie fara website'})
        scoped = Category.create({'name': 'Categorie site A', 'website_id': self.website.id})
        banner = self._make(website_id=False)

        allowed = self._allowed_categories(banner)
        self.assertIn(generic, allowed)
        self.assertNotIn(scoped, allowed)
