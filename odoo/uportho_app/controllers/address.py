import logging

from odoo.http import request

from odoo.addons.website_sale.controllers.main import WebsiteSale

from .base import ApiError, app_route, json_ok, read_json_body
from .checkout import serialize_address
from .home import _current_website

_logger = logging.getLogger(__name__)

# Tipurile de adresa pe care le poate adauga aplicatia, traduse in vocabularul
# magazinului: 'billing' si 'delivery' sunt exact valorile pe care le asteapta
# `_validate_address_values` si restul metodelor din `website_sale`.
ADDRESS_KINDS = {'invoice': 'billing', 'delivery': 'delivery'}

# Campurile pe care aplicatia are voie sa le trimita. Lista e restrictiva in mod
# deliberat: `_parse_form_data` de pe site accepta orice camp "scriibil din formular"
# al lui `res.partner`, ceea ce pe o ruta JSON ar insemna ca un client isi poate seta
# singur campuri de care nu are treaba (agent de vanzari, etichete, categorie).
ALLOWED_FIELDS = {
    'name', 'street', 'street2', 'city', 'city_id', 'zip', 'state_id', 'country_id',
    'phone', 'email', 'vat', 'company_name',
}
INT_FIELDS = {'city_id', 'state_id', 'country_id'}


def _partner_of_account():
    return request.env.user.partner_id.commercial_partner_id


def _parse_values(raw):
    """Valorile de adresa din corpul cererii, curatate.

    Doar campurile din `ALLOWED_FIELDS` trec mai departe; restul se ignora in tacere,
    ca un client care trimite un camp in plus sa nu primeasca eroare, dar nici sa nu
    poata scrie in el. Campurile de tip many2one trebuie sa fie numerice."""
    if not isinstance(raw, dict):
        raise ApiError(422, 'validation_error', 'values trebuie sa fie un obiect JSON.')
    values = {}
    for key, value in raw.items():
        if key not in ALLOWED_FIELDS:
            continue
        if key in INT_FIELDS:
            if value in (None, ''):
                continue
            if isinstance(value, bool) or not isinstance(value, int):
                raise ApiError(422, 'validation_error', f'{key} trebuie sa fie numeric.')
            values[key] = value
        elif isinstance(value, str):
            values[key] = value.strip()
        elif value is None:
            continue
        else:
            raise ApiError(422, 'validation_error', f'{key} trebuie sa fie text.')
    return values


def _serialize_country(country):
    return {
        'id': country.id,
        'name': country.name,
        'code': country.code,
        'state_required': country.state_required,
        'zip_required': country.zip_required,
    }


class AppAddress(WebsiteSale):
    """Adresele contului: ce cere formularul si adaugarea unei adrese noi.

    **Mosteneste `WebsiteSale` dinadins.** Validarea adresei e locul in care traiesc
    regulile clientului, iar ele sunt scrise ca override-uri de controller:
    `terrabit_website_invoice_address` sare peste verificarea de format a CUI-ului
    (clientii au coduri pe care Odoo le-ar refuza) dar face CUI-ul **obligatoriu** cand
    se completeaza numele firmei, iar `deltatech_website_city` adauga `city_id` la
    campurile obligatorii, pentru ca orasul e o inregistrare legata, nu text liber.

    Mostenirea e chiar mecanismul prin care modulele lor se leaga de `website_sale`:
    Odoo construieste o singura clasa din toate, deci `self._validate_address_values`
    trece prin toate override-urile. Reimplementata aici, validarea noastra s-ar
    desincroniza de a lor la prima schimbare.

    Clasa asta **nu suprascrie nicio metoda si nicio ruta a magazinului** - adauga doar
    rute noi sub `/api/app/v1`. Comportamentul site-ului ramane neschimbat."""

    @app_route('/addresses/options', methods=['GET'])
    def address_options(self, **kw):
        """Ce are nevoie formularul de adresa: campurile obligatorii si listele legate.

        Campurile obligatorii se cer chiar magazinului
        (`_get_mandatory_billing_address_fields` / `_get_mandatory_delivery_address_fields`),
        deci includ automat si ce adauga modulele clientului. Depind de tara: o tara cu
        `state_required` cere judetul, una cu `zip_required` cere codul postal.

        Judetele si orasele vin doar cand sunt cerute (`country_id`, `state_id`), ca sa
        nu trimitem mii de inregistrari pe un ecran de telefon."""
        country_id = kw.get('country_id')
        state_id = kw.get('state_id')

        Country = request.env['res.country'].sudo()
        countries = Country.search([])
        country = Country.browse(int(country_id)) if str(country_id or '').isdigit() else Country
        if country_id and not country.exists():
            raise ApiError(422, 'validation_error', 'country_id nu exista.')

        states = []
        if country:
            states = [{'id': s.id, 'name': s.name, 'code': s.code} for s in country.state_ids]

        cities = []
        City = request.env['res.city'].sudo() if 'res.city' in request.env else None
        if City is not None and str(state_id or '').isdigit():
            found = City.search([('state_id', '=', int(state_id))], order='name')
            cities = [{'id': c.id, 'name': c.name, 'zip': c.zipcode or None} for c in found]

        return json_ok({
            'countries': [_serialize_country(c) for c in countries],
            'default_country_id': _current_website().company_id.country_id.id or None,
            'states': states,
            'cities': cities,
            'required': {
                'delivery': sorted(self._get_mandatory_delivery_address_fields(country)),
                'invoice': sorted(self._get_mandatory_billing_address_fields(country)),
            },
            # Orasul e o inregistrare legata pe bazele clientului
            # (`deltatech_website_city`); pe o baza fara acel modul ramane text liber,
            # iar aplicatia trebuie sa stie care din doua sa afiseze.
            'city_is_list': City is not None,
        })

    @app_route('/addresses', methods=['POST'])
    def create_address(self, **kw):
        """Adauga o adresa noua contului: `{"kind": "delivery"|"invoice", "values": {...}}`.

        Validarea e a magazinului, nu a noastra (vezi comentariul clasei). Erorile ei se
        intorc in forma standard, cu lista campurilor gresite in `details`, ca ecranul sa
        le poata marca pe fiecare in parte.

        Completarea valorilor (companie, tip, parinte) reface ce face
        `WebsiteSale._complete_address_values`. Nu se cheama metoda lor pentru ca ea
        citeste `request.website` si `request.lang`, atribute pe care rutele acestui
        modul nu le au si nu au voie sa le primeasca - `request.website` schimba lista
        de preturi a clientului (vezi gotcha 7 din CLAUDE.md). Partea reprodusa e
        mecanica si scurta; partea cu reguli de business ramane chemata."""
        body = read_json_body()
        kind = body.get('kind')
        if kind not in ADDRESS_KINDS:
            raise ApiError(422, 'validation_error', "kind trebuie sa fie 'delivery' sau 'invoice'.")
        address_type = ADDRESS_KINDS[kind]
        values = _parse_values(body.get('values'))

        Partner = request.env['res.partner'].sudo()
        invalid, missing, messages = self._validate_address_values(
            values,
            Partner.browse(),          # partener nou, nu unul existent
            address_type,
            False,                     # aceeasi adresa si la livrare si la facturare
            '',                        # campuri cerute in plus de formularul web
            False,                     # nu e adresa principala a contului
        )
        if messages:
            raise ApiError(
                422, 'invalid_address',
                ' '.join(messages),
                {'fields': sorted(set(invalid) | set(missing))})

        commercial = _partner_of_account()
        website = _current_website()
        values.pop('company_name', None)
        values.update({
            'type': 'invoice' if address_type == 'billing' else 'delivery',
            'company_id': website.company_id.id,
            'parent_id': commercial.id if commercial.active else False,
        })
        partner = Partner.with_context(tracking_disable=True).create(values)

        return json_ok({
            'address': serialize_address(partner),
            'addresses': [serialize_address(p) for p in _account_addresses()],
        })


def _account_addresses():
    """Adresele pe care contul le poate folosi.

    Partenerul comercial, copiii lui, **si** partenerii carora li s-a dat acces explicit
    prin `access_for_user_id` - campul adaugat de `terrabit_website_invoice_address`.
    Site-ul le adauga pe acestea din urma in `_prepare_checkout_page_values`, tocmai ca
    un cont sa poata factura pe o firma care nu e in arborele lui. Fara ele, aplicatia
    ar arata mai putine adrese decat magazinul, pentru aceiasi clienti."""
    Partner = request.env['res.partner'].sudo()
    commercial = _partner_of_account()
    addresses = commercial | commercial.child_ids.filtered(
        lambda p: p.type in ('delivery', 'invoice', 'other'))
    if 'access_for_user_id' in Partner._fields:
        granted = Partner.with_context(show_address=1).search([
            ('access_for_user_id', '=', request.env.user.id),
        ])
        addresses |= granted.filtered(lambda p: p.type in ('delivery', 'invoice', 'other'))
    return addresses
