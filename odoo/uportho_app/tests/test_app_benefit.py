import base64

from odoo.tests.common import TransactionCase, tagged

from .test_controllers_catalog import PNG_1PX


@tagged('post_install', '-at_install')
class TestAppBenefit(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Benefit = cls.env['uportho.app.benefit']

    def _make(self, **vals):
        base = {'name': 'Beneficiu', 'icon': 'info', 'sequence': 10}
        base.update(vals)
        return self.Benefit.create(base)

    def _own(self, result, *records):
        # Testul nu depinde de randuri preexistente in baza: filtram raspunsul pe
        # id-urile create de acest test, apoi verificam continutul si ordinea in acel
        # subset - la fel ca in test_app_banner.py.
        own_ids = set()
        for record in records:
            own_ids |= set(record.ids)
        return result.filtered(lambda r: r.id in own_ids)

    def test_inactive_benefit_is_excluded(self):
        active_benefit = self._make(name='Activ')
        inactive_benefit = self._make(name='Inactiv', active=False)
        result = self._own(self.Benefit._search_active(), active_benefit, inactive_benefit)
        self.assertIn(active_benefit, result)
        self.assertNotIn(inactive_benefit, result)

    def test_ordered_by_sequence(self):
        second = self._make(name='B', sequence=20)
        first = self._make(name='A', sequence=5)
        result = self._own(self.Benefit._search_active(), first, second)
        names = result.mapped('name')
        self.assertLess(names.index('A'), names.index('B'))

    def test_image_is_optional(self):
        # Beneficiile existente n-au imagine si nu se schimba cu nimic: fara ea,
        # aplicatia deseneaza mai departe iconita din lista fixa.
        self.assertFalse(self._make(name='Fara imagine').image)

    def test_image_can_be_uploaded(self):
        # Blocurile echivalente de pe site arata logouri adevarate (curier, siglele de
        # card). Userul le poate schimba din Odoo, fara release de aplicatie.
        benefit = self._make(name='Cu imagine', image=base64.b64encode(PNG_1PX))
        self.assertTrue(benefit.image)
