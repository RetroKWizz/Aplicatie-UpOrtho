import logging

from odoo import fields, http
from odoo.http import request

from odoo.addons.portal.controllers.portal import CustomerPortal

from .base import ApiError, app_route, json_ok, read_json_body

_logger = logging.getLogger(__name__)

# Campurile pe care aplicatia le arata si le poate trimite inapoi. Mereu o lista
# scrisa explicit, niciodata "tot ce e scriibil pe partener": pe o ruta JSON, un
# client ar putea altfel sa-si seteze singur agentul de vanzari sau etichetele.
PROFILE_FIELDS = (
    'name', 'email', 'phone', 'mobile', 'function', 'street', 'street2',
    'city', 'zip', 'state_id', 'country_id', 'vat', 'company_name',
)
# Numele campului de cod postal difera intre formularul portalului (`zipcode`) si
# `res.partner` (`zip`). Traducerea se face intr-un singur loc, aici.
ZIP_FORM_FIELD = 'zipcode'

# Campuri pe care formularul web al portalului NU le are, deci nu au voie sa ajunga la
# `details_form_validate`: el respinge orice cheie necunoscuta cu "Unknown field".
# Sunt totusi date de contact ale aceleiasi persoane, iar aplicatia le arata si le
# salveaza - doar ca pe langa validarea lui, nu prin ea.
EXTRA_FIELDS = ('mobile', 'function')


def _profile_partner():
    """Partenerul ale carui date se arata si se editeaza: chiar al utilizatorului
    conectat, nu partenerul comercial.

    Portalul face la fel (`request.env.user.partner_id`): intr-o clinica cu mai multi
    utilizatori pe acelasi client, fiecare isi editeaza propriile date de contact, nu
    pe ale firmei."""
    return request.env.user.partner_id


def serialize_profile(partner):
    """Datele contului, in forma in care le arata ecranul.

    `can_edit_vat` spune daca CUI-ul si tara mai pot fi schimbate: Odoo le blocheaza
    dupa ce s-au emis documente contabile pe cont. Aplicatia trebuie sa stie asta ca
    sa dezactiveze campurile, nu sa lase clientul sa scrie si sa primeasca eroare."""
    partner = partner.sudo()
    return {
        'id': partner.id,
        'name': partner.name,
        'email': partner.email or None,
        'phone': partner.phone or None,
        'mobile': partner.mobile or None,
        'function': partner.function or None,
        'street': partner.street or None,
        'street2': partner.street2 or None,
        'city': partner.city or None,
        'zip': partner.zip or None,
        'state_id': partner.state_id.id or None,
        'state': partner.state_id.name or None,
        'country_id': partner.country_id.id or None,
        'country': partner.country_id.name or None,
        'vat': partner.vat or None,
        'company_name': partner.commercial_company_name or None,
        'can_edit_vat': partner.can_edit_vat(),
    }


class AppProfile(CustomerPortal):
    """Datele contului: citire si modificare, pe acelasi drum ca portalul.

    **Mosteneste `CustomerPortal`** din acelasi motiv pentru care controllerul de
    adrese mosteneste `WebsiteSale`: validarea e locul in care traiesc regulile, iar
    ele sunt scrise ca override-uri de controller. `details_form_validate` verifica
    emailul, refuza schimbarea CUI-ului dupa emiterea documentelor si trece prin orice
    override pus de modulele clientului. Rescrisa aici, s-ar desincroniza de a lor.

    Clasa nu suprascrie nicio metoda si nicio ruta a portalului."""

    @app_route('/account/profile', methods=['GET'])
    def profile(self, **kw):
        """Datele contului, plus ce campuri sunt obligatorii.

        Lista campurilor obligatorii se cere portalului (`_get_mandatory_fields`), nu
        se scrie in codul nostru: asa intra automat si ce adauga modulele clientului."""
        mandatory = list(self._get_mandatory_fields())
        optional = list(self._get_optional_fields())
        return json_ok({
            'profile': serialize_profile(_profile_partner()),
            # Numele de camp se dau in vocabularul aplicatiei (`zip`), nu in cel al
            # formularului web (`zipcode`).
            'required': sorted({'zip' if f == ZIP_FORM_FIELD else f for f in mandatory}),
            'editable': sorted(
                {'zip' if f == ZIP_FORM_FIELD else f for f in mandatory + optional}
                & set(PROFILE_FIELDS)),
        })

    @app_route('/account/profile', methods=['POST'])
    def update_profile(self, **kw):
        """Modifica datele contului.

        Validarea e a portalului. Erorile lui vin ca dictionar `{camp: motiv}`; le
        intoarcem ca lista de campuri in `details`, ca ecranul sa le poata marca pe
        fiecare, plus mesajele lui pentru cele care au unul (email gresit, CUI blocat).

        Ca si portalul, cand CUI-ul nu mai poate fi editat pastram tara asa cum e:
        altfel clientul ar primi o eroare pentru un camp pe care oricum nu-l poate
        schimba."""
        body = read_json_body()
        values = body.get('values')
        if not isinstance(values, dict):
            raise ApiError(422, 'validation_error', 'values trebuie sa fie un obiect JSON.')

        partner = _profile_partner()
        # Forma pe care o asteapta `details_form_validate`: toate valorile ca text, cu
        # `zipcode` in loc de `zip`, exact ce trimite formularul web.
        #
        # "Netrimis" si "trimis gol" sunt lucruri diferite si se tin separat. Un camp
        # netrimis se completeaza cu valoarea de acum, ca validarea sa nu ceara
        # completarea a tot contul pentru o schimbare de telefon. Un camp trimis gol e
        # o cerere de stergere si merge asa cum e la validare - daca e obligatoriu, ea
        # il refuza. Confundate, o stergere ceruta de client primea 200 si nu se
        # intampla nimic: cel mai prost raspuns posibil.
        portal_fields = tuple(f for f in PROFILE_FIELDS if f not in EXTRA_FIELDS)
        sent = {f for f in portal_fields if f in values and values[f] is not None}
        form = {f: str(values[f]).strip() for f in sent}
        extra = {
            f: str(values[f]).strip()
            for f in EXTRA_FIELDS if f in values and values[f] is not None
        }
        if 'zip' in form:
            form[ZIP_FORM_FIELD] = form.pop('zip')
            sent.discard('zip')
            sent.add(ZIP_FORM_FIELD)

        current = serialize_profile(partner)
        for field in self._get_mandatory_fields():
            if field in sent:
                continue
            source = 'zip' if field == ZIP_FORM_FIELD else field
            existing = current.get(source)
            form[field] = str(existing) if existing is not None else ''
        if not partner.can_edit_vat():
            form['country_id'] = str(partner.country_id.id)

        error, messages = self.details_form_validate(form)
        if error:
            raise ApiError(
                422, 'invalid_profile',
                ' '.join(messages) if messages else 'Verifica datele introduse.',
                {'fields': sorted({'zip' if f == ZIP_FORM_FIELD else f for f in error})})

        write_values = {}
        for field in list(self._get_mandatory_fields()) + list(self._get_optional_fields()):
            if field not in form:
                continue
            target = 'zip' if field == ZIP_FORM_FIELD else field
            if target not in PROFILE_FIELDS:
                continue
            value = form[field]
            if target in ('country_id', 'state_id'):
                write_values[target] = int(value) if str(value).isdigit() else False
            else:
                write_values[target] = value
        write_values.update(extra)
        # Numele neschimbat nu se rescrie: pe `res.partner` el atinge si titularul
        # conturilor bancare, iar portalul il scoate din scriere tocmai de aceea.
        if write_values.get('name', '').strip() == (partner.name or '').strip():
            write_values.pop('name', None)

        partner.sudo().write(write_values)
        return json_ok({'profile': serialize_profile(partner)})


class AppLoyalty(http.Controller):
    """Cardurile de fidelitate ale contului: Ortho Club, carduri cadou, vouchere.

    Pe uportho asta nu e un detaliu: sunt 5178 de carduri in baza si programul Ortho
    Club e chiar oferta din jurul careia e construit magazinul. Portalul le arata, deci
    aplicatia trebuie sa le arate."""

    @app_route('/loyalty', methods=['GET'])
    def loyalty(self, **kw):
        """Cardurile contului, cu punctele lor.

        Punctele se afiseaza cum le afiseaza si programul (`_format_points`): un
        program pe bani scrie "150,00 lei", unul pe puncte scrie "150 puncte". Textul
        vine de la Odoo, nu se compune aici - aplicatia nu formateaza bani.

        Cardurile fara puncte si fara reducere de folosit nu se arata: ar umple ecranul
        cu randuri care nu spun nimic."""
        if 'loyalty.card' not in request.env:
            return json_ok([])
        commercial = request.env.user.partner_id.commercial_partner_id
        partners = commercial | commercial.child_ids
        cards = request.env['loyalty.card'].sudo().search([
            ('partner_id', 'in', partners.ids),
            ('program_id.active', '=', True),
        ])
        return json_ok([
            {
                'id': card.id,
                'program': card.program_id.name,
                'program_type': card.program_id.program_type,
                'code': card.code or None,
                'points': card.points,
                'points_display': card.points_display,
                'expiration_date': fields.Date.to_string(card.expiration_date)
                                   if card.expiration_date else None,
            }
            for card in cards if card.points
        ])
