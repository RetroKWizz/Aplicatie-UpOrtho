from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestControllersDevices(AppHttpCase):
    def test_register_requires_login(self):
        self.assertEqual(self.api_post('/devices', {'fcm_token': 't1', 'platform': 'ios'}).status_code, 401)

    def test_register_creates_device_for_current_user(self):
        self.api_login()
        response = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'ios'})
        self.assertEqual(response.status_code, 201, response.text)
        device = self.env['uportho.app.device'].search([('fcm_token', '=', 't1')])
        self.assertEqual(device.user_id, self.portal_user)
        self.assertEqual(device.platform, 'ios')

    def test_register_same_token_twice_is_idempotent(self):
        self.api_login()
        first = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'android'}).json()['device']['id']
        second = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'android'}).json()['device']['id']
        self.assertEqual(first, second)
        self.assertEqual(self.env['uportho.app.device'].search_count([('fcm_token', '=', 't1')]), 1)

    def test_register_invalid_platform_is_422(self):
        self.api_login()
        response = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'windows'})
        self.assertEqual(response.status_code, 422)

    def test_delete_removes_device(self):
        self.api_login()
        self.api_post('/devices', {'fcm_token': 't1', 'platform': 'ios'})
        response = self.api_delete('/devices/t1')
        self.assertEqual(response.status_code, 204)
        self.assertEqual(self.env['uportho.app.device'].search_count([('fcm_token', '=', 't1')]), 0)

    def test_delete_unknown_token_is_204(self):
        self.api_login()
        self.assertEqual(self.api_delete('/devices/nope').status_code, 204)
