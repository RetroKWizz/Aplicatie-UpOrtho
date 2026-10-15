import logging

from odoo import http
from odoo.exceptions import AccessDenied, UserError
from odoo.http import request

from odoo.addons.auth_signup.controllers.main import AuthSignupHome
from odoo.addons.auth_signup.models.res_partner import SignupError

from .base import ApiError, app_route, json_ok, read_json_body
from .home import _current_website

_logger = logging.getLogger(__name__)

# Campurile pe care le are si formularul magazinului, scrise explicit. `do_signup` ar
# citi orice cheie din contextul primit; pe o ruta JSON asta ar lasa un client sa-si
# trimita singur grupuri sau alte campuri de utilizator. Aceeasi grija ca la adrese.
SIGNUP_FIELDS = ('login', 'name', 'password', 'confirm_password')


def serialize_user(user):
    return {
        'id': user.id,
        'name': user.name,
        'email': user.email or user.login,
        'partner_id': user.partner_id.id,
    }


class AppAuth(AuthSignupHome):
    """Rutele de autentificare ale aplicatiei.

    Mosteneste controllerul de inregistrare al Odoo (`AuthSignupHome`) ca sa cheme
    `do_signup`-ul lui, cu toate override-urile modulelor clientului - acelasi tipar ca
    `controllers/address.py` (WebsiteSale) si `controllers/profile.py` (CustomerPortal).
    Nu suprascrie nicio ruta a lor: adauga doar rute sub /api/app/v1."""

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

    @app_route('/auth/signup', methods=['POST'], auth='public')
    def signup(self, **kw):
        """Creeaza un cont si lasa omul inauntru, fara al doilea pas.

        Nicio regula nu e scrisa aici: parola, unicitatea emailului, mesajele de eroare
        si orice adauga clientul vin din `do_signup`. Ce decide ruta e doar CE are voie
        sa ajunga pana acolo si cum arata raspunsul."""
        body = read_json_body()
        values = {key: body.get(key) for key in SIGNUP_FIELDS}
        values = {k: v.strip() if isinstance(v, str) else v for k, v in values.items()}
        if not values.get('login') or not values.get('name') or not values.get('password'):
            raise ApiError(422, 'validation_error', 'Completeaza nume, email si parola.')

        # Website-ul magazinului se leaga de context INAINTE de orice intrebare:
        # `_get_signup_invitation_scope` e suprascrisa de modulul `website` si citeste
        # `auth_signup_uninvited` de pe website-ul curent, rezolvat altfel din header-ul
        # Host. Pe o instanta cu mai multe website-uri am intreba alt magazin daca are
        # inregistrarea deschisa.
        _current_website()
        Users = request.env['res.users'].sudo()
        if Users._get_signup_invitation_scope() != 'b2c':
            raise ApiError(403, 'signup_disabled',
                           'Inregistrarea nu e deschisa. Cere un cont de la UpOrtho.')

        # Pagina lor verifica un token reCAPTCHA inainte de creare. O ruta JSON care
        # cheama direct `do_signup` ar sari peste acea verificare, adica ar deveni un
        # endpoint de creat conturi fara nicio protectie anti-bot. Cand magazinul o are
        # pornita, trimitem clientul in pagina lui, unde protectia functioneaza.
        if request.env['ir.config_parameter'].sudo().get_param('recaptcha_private_key'):
            raise ApiError(409, 'signup_needs_webview',
                           'Inregistrarea se face in pagina magazinului.')

        try:
            self.do_signup(values)
        except UserError as error:
            raise ApiError(422, 'validation_error',
                           error.args[0] if error.args else 'Datele nu sunt bune.')
        except (SignupError, AssertionError) as error:
            # Acelasi criteriu ca al lor: daca exista deja un cont cu emailul asta,
            # mesajul e despre email, nu despre o eroare interna.
            if Users.search_count([('login', '=', values['login'])], limit=1):
                raise ApiError(409, 'email_taken', 'Exista deja un cont cu acest email.')
            _logger.warning('Inregistrare esuata pentru %s: %s', values['login'], error)
            raise ApiError(422, 'validation_error', 'Contul nu a putut fi creat.')

        request.session.authenticate(
            request.db,
            {'type': 'password', 'login': values['login'], 'password': values['password']})
        request.update_env(user=request.session.uid)
        return json_ok({'user': serialize_user(request.env.user)})
