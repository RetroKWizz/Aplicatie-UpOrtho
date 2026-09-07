from odoo.tests.common import tagged

from .common import AppHttpCase, PORTAL_LOGIN, PORTAL_PASSWORD
from .test_controllers_base import load_contract


@tagged('post_install', '-at_install')
class TestControllersAuth(AppHttpCase):
    def test_login_ok_returns_user_and_session_cookie(self):
        response = self.api_post('/auth/login', {'login': PORTAL_LOGIN, 'password': PORTAL_PASSWORD})
        self.assertEqual(response.status_code, 200, response.text)
        body = response.json()
        self.assertEqual(set(body['user'].keys()), set(load_contract('login.json')['user'].keys()))
        self.assertEqual(body['user']['email'], PORTAL_LOGIN)
        self.assertIn('session_id', response.cookies)

    def test_login_wrong_password_is_401(self):
        response = self.api_post('/auth/login', {'login': PORTAL_LOGIN, 'password': 'gresit'})
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()['error']['code'], 'invalid_credentials')

    def test_login_missing_fields_is_422(self):
        response = self.api_post('/auth/login', {'login': PORTAL_LOGIN})
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_me_after_login(self):
        self.api_login()
        response = self.api_get('/me')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['user']['email'], PORTAL_LOGIN)

    def test_logout_then_me_is_401(self):
        self.api_login()
        response = self.api_post('/auth/logout')
        self.assertEqual(response.status_code, 204)
        self.assertEqual(self.api_get('/me').status_code, 401)
