import functools
import json
import logging

from odoo import http
from odoo.exceptions import AccessDenied, AccessError, MissingError, UserError, ValidationError
from odoo.http import request

_logger = logging.getLogger(__name__)

API_PREFIX = '/api/app/v1'
APP_HEADER = 'X-UpOrtho-App'


class ApiError(Exception):
    """Eroare de API cu cod HTTP si cod masina; se transforma in raspunsul standard de eroare."""

    def __init__(self, status, code, message, details=None):
        super().__init__(message)
        self.status = status
        self.code = code
        self.message = message
        self.details = details or {}


def json_ok(data, status=200):
    return request.make_json_response(data, status=status)


def json_error(code, message, status, details=None):
    return request.make_json_response(
        {'error': {'code': code, 'message': message, 'details': details or {}}}, status=status)


def read_json_body():
    raw = request.httprequest.get_data(as_text=True)
    if not raw:
        return {}
    try:
        data = json.loads(raw)
    except ValueError:
        raise ApiError(422, 'invalid_json', 'Corpul cererii nu este JSON valid.')
    if not isinstance(data, dict):
        raise ApiError(422, 'invalid_json', 'Corpul cererii trebuie sa fie un obiect JSON.')
    return data


def _is_authenticated():
    return bool(request.session.uid) and not request.env.user._is_public()


def app_route(path, methods, auth='user', **kwargs):
    """Ruta de API: prefix /api/app/v1, type='http', fara CSRF, raspuns JSON.
    - `auth='user'` -> 401 in forma standard daca nu exista sesiune (nu redirect la /web/login).
    - metodele non-GET cer header-ul X-UpOrtho-App (403 altfel).
    - exceptiile Odoo si ApiError devin raspunsuri de eroare cu cod HTTP real."""
    route_auth = 'public' if auth == 'user' else auth

    def decorator(func):
        @http.route(API_PREFIX + path, type='http', auth=route_auth, methods=methods, csrf=False, **kwargs)
        @functools.wraps(func)
        def wrapper(*args, **kw):
            try:
                if auth == 'user' and not _is_authenticated():
                    raise ApiError(401, 'unauthorized', 'Trebuie sa te autentifici.')
                if request.httprequest.method != 'GET' and request.httprequest.headers.get(APP_HEADER) != '1':
                    raise ApiError(403, 'forbidden', 'Cerere neacceptata.')
                return func(*args, **kw)
            except ApiError as error:
                return json_error(error.code, error.message, error.status, error.details)
            except AccessDenied:
                return json_error('unauthorized', 'Date de autentificare gresite.', 401)
            except AccessError:
                return json_error('forbidden', 'Nu ai acces la aceasta resursa.', 403)
            except MissingError:
                return json_error('not_found', 'Resursa nu exista.', 404)
            except (ValidationError, UserError) as error:
                return json_error('validation_error', str(error.args[0]) if error.args else str(error), 422)
            except Exception:
                _logger.exception('Eroare neasteptata in %s', path)
                return json_error('internal_error', 'A aparut o eroare. Incearca din nou.', 500)
        return wrapper
    return decorator
