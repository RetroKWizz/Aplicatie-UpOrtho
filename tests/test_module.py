from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestModuleInstalled(TransactionCase):
    def test_module_is_installed(self):
        module = self.env['ir.module.module'].search([('name', '=', 'uportho_app')])
        self.assertEqual(module.state, 'installed')
