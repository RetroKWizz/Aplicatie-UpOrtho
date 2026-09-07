from odoo import http
from odoo.exceptions import AccessDenied
from odoo.http import request

from .base import ApiError, app_route, json_ok, read_json_body


def serialize_user(user):
    return {
        'id': user.id,
        'name': user.name,
        'email': user.email or user.login,
        'partner_id': user.partner_id.id,
    }


class AppAuth(http.Controller):
    @app_route('/auth/login', methods=['POST'], auth='public')
    def login(self, **kw):
        body = read_json_body()
        login = (body.get('login') or '').strip()
        password = body.get('password') or ''
        if not login or not password:
            raise ApiError(422, 'validation_error', 'Introdu email si parola.')
        try:
            # Odoo 18: Session.authenticate(dbname, credential). Verificat in Task 0.2 pasul 7.
            request.session.authenticate(request.db, {'type': 'password', 'login': login, 'password': password})
        except AccessDenied:
            raise ApiError(401, 'invalid_credentials', 'Email sau parola gresite.')
        request.update_env(user=request.session.uid)
        return json_ok({'user': serialize_user(request.env.user)})

    @app_route('/auth/logout', methods=['POST'])
    def logout(self, **kw):
        request.session.logout(keep_db=True)
        return request.make_response('', status=204)

    @app_route('/me', methods=['GET'])
    def me(self, **kw):
        return json_ok({'user': serialize_user(request.env.user)})
