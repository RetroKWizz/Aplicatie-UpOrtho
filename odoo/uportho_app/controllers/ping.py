from odoo import http

from .base import app_route, json_ok, read_json_body


class AppPing(http.Controller):
    @app_route('/ping', methods=['GET'])
    def ping(self, **kw):
        return json_ok({'ok': True})

    @app_route('/ping', methods=['POST'])
    def ping_post(self, **kw):
        body = read_json_body()
        return json_ok({'ok': True, **({'echo': body['echo']} if 'echo' in body else {})})
