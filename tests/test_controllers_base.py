import json
import os

from odoo.tests.common import tagged

from .common import AppHttpCase

CONTRACT_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'contract')


def load_contract(name):
    with open(os.path.join(CONTRACT_DIR, name), encoding='utf-8') as handle:
        return json.load(handle)


@tagged('post_install', '-at_install')
class TestControllersBase(AppHttpCase):
    def test_ping_without_login_is_401_in_error_shape(self):
        response = self.api_get('/ping')
        self.assertEqual(response.status_code, 401)
        body = response.json()
        self.assertEqual(set(body['error'].keys()), set(load_contract('error.json')['error'].keys()))
        self.assertEqual(body['error']['code'], 'unauthorized')

    def test_ping_after_login_is_200(self):
        self.api_login()
        response = self.api_get('/ping')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {'ok': True})

    def test_post_without_app_header_is_403(self):
        self.api_login()
        response = self.api_post('/ping', {}, with_header=False)
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json()['error']['code'], 'forbidden')

    def test_post_with_app_header_is_200(self):
        self.api_login()
        response = self.api_post('/ping', {'echo': 'x'})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {'ok': True, 'echo': 'x'})

    def test_invalid_json_body_is_422(self):
        self.api_login()
        headers = {'Content-Type': 'application/json', 'X-UpOrtho-App': '1'}
        response = self.url_open('/api/app/v1/ping', data='{not json', headers=headers)
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'invalid_json')
