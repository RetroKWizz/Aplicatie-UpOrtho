import json

from odoo.tests.common import HttpCase

APP_HEADER = {'X-UpOrtho-App': '1'}
PORTAL_LOGIN = 'app.test@uportho.ro'
PORTAL_PASSWORD = 'AppTest123!'


class AppHttpCase(HttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        portal_group = cls.env.ref('base.group_portal')
        cls.portal_user = cls.env['res.users'].create({
            'name': 'App Test',
            'login': PORTAL_LOGIN,
            'password': PORTAL_PASSWORD,
            'groups_id': [(6, 0, [portal_group.id])],  # Odoo 19: campul se numeste group_ids
        })

    def api_get(self, path, with_header=True):
        headers = dict(APP_HEADER) if with_header else {}
        return self.url_open('/api/app/v1' + path, headers=headers)

    def api_post(self, path, body=None, with_header=True):
        headers = {'Content-Type': 'application/json'}
        if with_header:
            headers.update(APP_HEADER)
        return self.url_open('/api/app/v1' + path, data=json.dumps(body or {}), headers=headers)

    def api_delete(self, path, with_header=True):
        headers = dict(APP_HEADER) if with_header else {}
        return self.opener.delete(self.base_url() + '/api/app/v1' + path, headers=headers, timeout=12)

    def api_login(self):
        """Deschide o sesiune pentru utilizatorul portal de test prin mecanismul standard
        HttpCase, nu prin endpoint-ul /auth/login (care e testat separat in Task 1.6)."""
        self.authenticate(PORTAL_LOGIN, PORTAL_PASSWORD)
