from odoo import http
from odoo.http import request

from .base import ApiError, app_route, json_ok, read_json_body

PLATFORMS = {'ios', 'android'}


class AppDevices(http.Controller):
    @app_route('/devices', methods=['POST'])
    def register(self, **kw):
        body = read_json_body()
        token = (body.get('fcm_token') or '').strip()
        platform = body.get('platform')
        if not token:
            raise ApiError(422, 'validation_error', 'Lipseste fcm_token.')
        if platform not in PLATFORMS:
            raise ApiError(422, 'validation_error', 'platform trebuie sa fie ios sau android.')
        # `_register_device`, nu `_register` (numele din brief) - coliziune cu
        # atributul intern odoo.models.BaseModel._register, vezi comentariul
        # din models/app_device.py.
        device = request.env['uportho.app.device']._register_device(request.env.user, token, platform)
        return json_ok({'device': {'id': device.id, 'platform': device.platform}}, status=201)

    @app_route('/devices/<string:fcm_token>', methods=['DELETE'])
    def unregister(self, fcm_token, **kw):
        request.env['uportho.app.device'].sudo().search([
            ('fcm_token', '=', fcm_token), ('user_id', '=', request.env.user.id)]).unlink()
        return request.make_response('', status=204)
