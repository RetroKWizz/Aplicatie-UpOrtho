# Magazinul fara cont — plan de implementare

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicatia porneste in magazin, nu la autentificare: un vizitator vede produsele si categoriile fara preturi, iar contul se poate crea din aplicatie prin chiar metodele de signup ale Odoo.

**Architecture:** Rutele de continut primesc `auth='public'` (infrastructura exista deja in `app_route`). Fara sesiune, serverul nu calculeaza niciun pret si trimite `price: null` plus un bloc `pricing` care spune DE CE lipseste; aplicatia deseneaza banda si textele dupa acel bloc, nu dupa starea ei locala de autentificare. Inregistrarea e o ruta noua care mosteneste `AuthSignupHome` si cheama `_signup_with_values` — zero reguli proprii.

**Tech Stack:** Odoo 18 (`uportho_app`), Flutter 3.47 (Riverpod 3, go_router, freezed), contract JSON comun in `odoo/uportho_app/contract/`.

**Spec:** `docs/superpowers/specs/2026-10-15-magazin-fara-cont.md`

## Global Constraints

- **Nu se reimplementeaza nimic din Odoo.** Orice regula de business (signup, validare, preturi) se obtine chemand metodele lor; codul nostru doar adauga rute sub `/api/app/v1`. Confirmat explicit de user pe 15 octombrie 2026.
- **Aplicatia nu face aritmetica pe bani.** Preturile vin preformatate; lipsa lor se arata, nu se calculeaza.
- **Aplicatia arata exact ce arata site-ul unui vizitator** — nici mai mult, nici mai putin.
- Lista de preturi e intotdeauna cea de pe contul autentificat; un client nou fara Ortho Club merge pe lista publica. Nu se ocoleste.
- Contractul JSON e sursa de adevar: orice camp nou intra in `odoo/uportho_app/contract/*.json` si se sincronizeaza cu `app/tool/sync_contract.sh`.
- Fiecare provider Riverpod cu date ale contului incepe cu `await ref.watch(authControllerProvider.future)` (regula din CLAUDE.md) si, nou, se opreste devreme cand starea nu e `SignedIn`.
- Paleta e `InheritedWidget` (`context.colors`), nu globala; `const` lipseste din expresiile cu culori de tema.
- Comenzile de verificare: `odoo/run-tests.sh`, `cd app && flutter test`, `cd app && flutter analyze`.

## Review Focus

Cazuri pe care specul le implica, dar pe care niciun task nu le-ar exercita din reflex. Fiecare are testul lui, pus in task-ul care detine codul:

1. **Un build vechi al aplicatiei cere `/products` fara sesiune** si primeste `price: null` — `Product.fromJson` trebuie sa accepte null fara sa arunce, altfel ecranul ramane gol in loc sa arate catalogul (Task 4).
2. **Clientul autentificat nu trebuie sa piarda nimic**: aceleasi preturi, acelasi `club_price`, aceleasi tabele ca azi, dupa ce rutele devin publice (Task 1).
3. **Un email cu cont existent trimis la `/auth/signup`** nu trebuie sa atinga contul existent si nici sa scurga daca parola data e cea buna (Task 3).
4. **Sesiunea expira in timpul rasfoirii**: `/cart` da 401, iar aplicatia trebuie sa treaca in starea de vizitator, nu sa arate un ecran de eroare (Task 6).
5. **Ruta de imagine a unui produs nepublicat** ramane 404 pentru un vizitator, nu devine o fereastra prin care se citesc imagini din baza (Task 2).

---

## File Structure

**Server (`odoo/uportho_app/`)**

- `controllers/base.py` — nimic de schimbat: `app_route(auth='public')` exista deja.
- `controllers/catalog.py` — `auth='public'` pe `/categories`, `/products`, `/products/<id>/image`; `_serialize_templates` si `serialize_product` invata sa lucreze fara client; functie noua `pricing_block()`.
- `controllers/product.py` — `auth='public'` pe `/products/<id>` si pe rutele lui de imagine/document/galerie/logo; detaliul fara client.
- `controllers/home.py` — `auth='public'` pe `/home` si pe rutele de imagine.
- `controllers/auth.py` — ruta noua `POST /auth/signup`, cu mostenirea `AuthSignupHome`.
- `contract/products.json`, `contract/product_detail.json`, `contract/home.json`, `contract/signup.json` (nou).
- `tests/test_controllers_public.py` (nou) — ce e public si ce nu.
- `tests/test_controllers_signup.py` (nou) — inregistrarea.

**Aplicatie (`app/`)**

- `lib/api/models/pricing.dart` (nou) — blocul `pricing`.
- `lib/api/models/product.dart`, `product_detail.dart` — `price` devine nullable.
- `lib/api/models/signup_result.dart` (nou).
- `lib/api/api_client.dart` — metoda `signup`.
- `lib/features/auth/auth_controller.dart` — `SignedOut` ca stare normala.
- `lib/features/auth/signup_screen.dart` (nou).
- `lib/router.dart` — fara redirect global la login; paza pe rutele de cont.
- `lib/design_system/widgets/sign_in_banner.dart` (nou) — banda varianta B.
- `lib/design_system/widgets/product_card.dart` — pretul lipsa.
- `lib/features/account/account_screen.dart` — fata de vizitator.
- `lib/features/shell/shell_screen.dart` — butonul "Contul meu" in antet.

---

### Task 1: Catalogul raspunde fara sesiune, fara preturi

**Files:**
- Modify: `odoo/uportho_app/controllers/catalog.py` (`_serialize_templates` ~652, `serialize_product` ~439, rutele ~676 si ~684)
- Modify: `odoo/uportho_app/contract/products.json`
- Test: `odoo/uportho_app/tests/test_controllers_public.py` (creat aici)

**Interfaces:**
- Consumes: `app_route(path, methods, auth=...)` din `controllers/base.py`; `_products_domain`, `_prices_by_template` din acelasi fisier.
- Produces: `pricing_block(is_signed_in) -> dict` in `controllers/catalog.py`, importata de `controllers/product.py` si `controllers/home.py` in Task 2.

- [ ] **Step 1: Write the failing test**

Fisier nou `odoo/uportho_app/tests/test_controllers_public.py`:

```python
from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestCatalogPublic(AppHttpCase):
    """Catalogul se vede fara cont, dar fara preturi — ca pe site."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.produs = cls.env['product.template'].create({
            'name': 'Produs public test', 'is_published': True, 'list_price': 10.0})

    def test_produsele_se_vad_fara_sesiune(self):
        response = self.api_get('/products')

        self.assertEqual(response.status_code, 200)
        names = [p['name'] for p in response.json()['products']]
        self.assertIn('Produs public test', names)

    def test_fara_sesiune_pretul_lipseste_si_blocul_spune_de_ce(self):
        body = self.api_get('/products').json()

        self.assertIsNone(body['products'][0]['price'])
        self.assertIsNone(body['products'][0]['club_price'])
        self.assertEqual(body['pricing'], {'visible': False, 'reason': 'sign_in_required'})

    def test_cu_sesiune_preturile_sunt_cele_de_azi(self):
        """Clientul autentificat nu pierde nimic cand ruta devine publica."""
        self.api_login()
        body = self.api_get('/products').json()

        self.assertEqual(body['pricing'], {'visible': True, 'reason': None})
        produs = next(p for p in body['products'] if p['name'] == 'Produs public test')
        self.assertIsNotNone(produs['price'])
        self.assertIn('formatted', produs['price'])

    def test_categoriile_se_vad_fara_sesiune(self):
        self.assertEqual(self.api_get('/categories').status_code, 200)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `odoo/run-tests.sh 2>&1 | grep -aE "FAIL:|ERROR:|failed, "`
Expected: FAIL — `/products` da 401 fara sesiune.

- [ ] **Step 3: Write minimal implementation**

In `controllers/catalog.py`, langa `serialize_product`:

```python
def pricing_block(is_signed_in):
    """De ce lipsesc preturile, spus de server.

    Aplicatia nu ghiceste din `price: null`: ar insemna doua adevaruri (starea ei de
    autentificare si raspunsul serverului), iar ele se pot despica — o sesiune expirata
    arata inca "autentificat" in aplicatie cat timp nu cere nimic. Blocul asta e singura
    sursa pentru banda de invitatie si pentru textele de pe carduri. Daca magazinul
    opreste intr-o zi regula B2B, se schimba aici si preturile apar fara release."""
    return {
        'visible': bool(is_signed_in),
        'reason': None if is_signed_in else 'sign_in_required',
    }
```

In `_serialize_templates`, inainte de a cere lista de preturi:

```python
def _serialize_templates(templates, website):
    if not templates:
        return []
    # Fara cont nu se calculeaza niciun pret: `_customer_pricelist` ar arunca 503 pe
    # partenerul public, iar o lista publica aleasa de noi ar arata ceva ce site-ul nu
    # arata unui vizitator.
    if not _is_signed_in():
        ids_with_image = _ids_with_image(templates)
        rating_by_template = _ratings_by_template(templates)
        return [
            serialize_product(t, None, None, t.id in ids_with_image,
                              rating_by_template.get(t.id))
            for t in templates
        ]
    partner = request.env.user.partner_id
    pricelist = _customer_pricelist(partner)
    ...
```

In `controllers/base.py` se exporta ajutorul deja existent:

```python
def is_signed_in():
    """Public: `_is_authenticated` sub un nume pe care-l pot folosi si controllerele."""
    return _is_authenticated()
```

iar `catalog.py` il importa ca `_is_signed_in`.

Rutele devin publice:

```python
    @app_route('/categories', methods=['GET'], auth='public')
    @app_route('/products', methods=['GET'], auth='public')
```

iar raspunsul lui `/products` capata cheia:

```python
        return json_ok({
            'products': _serialize_templates(templates, website),
            'pricing': pricing_block(_is_signed_in()),
            ...
        })
```

- [ ] **Step 4: Run test to verify it passes**

Run: `odoo/run-tests.sh 2>&1 | grep -a "failed, "`
Expected: `0 failed, 0 error(s)`

- [ ] **Step 5: Actualizeaza contractul**

In `contract/products.json`, adauga la nivelul de sus `"pricing": {"visible": true, "reason": null}` si lasa un produs cu `"price": null, "club_price": null` ca al doilea element, ca aplicatia sa aiba de decodat ambele forme. Apoi `app/tool/sync_contract.sh`.

- [ ] **Step 6: Commit**

```bash
git add odoo/uportho_app/controllers/catalog.py odoo/uportho_app/controllers/base.py \
        odoo/uportho_app/tests/test_controllers_public.py odoo/uportho_app/contract/products.json \
        app/test/contract/products.json
git commit -m "Catalogul se vede fara cont, fara preturi"
```

---

### Task 2: Acasa, pagina de produs si imaginile, fara sesiune

**Files:**
- Modify: `odoo/uportho_app/controllers/home.py` (rutele `/home`, `/banners/<id>/image`, `/categories/<id>/icon`, `/brands/<id>/logo`)
- Modify: `odoo/uportho_app/controllers/product.py` (`/products/<id>` ~544, `/products/<id>/image`, `/gallery/<id>`, `/documents/<id>`, `/brand/logo`, `/benefits/<id>/image`)
- Modify: `odoo/uportho_app/contract/home.json`, `contract/product_detail.json`
- Test: `odoo/uportho_app/tests/test_controllers_public.py`

**Interfaces:**
- Consumes: `pricing_block(is_signed_in)` din Task 1.
- Produces: nimic nou; rutele isi pastreaza forma.

- [ ] **Step 1: Write the failing test**

Adauga in `tests/test_controllers_public.py`:

```python
@tagged('post_install', '-at_install')
class TestContinutPublic(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.publicat = cls.env['product.template'].create({
            'name': 'Produs vizibil', 'is_published': True, 'list_price': 10.0})
        cls.nepublicat = cls.env['product.template'].create({
            'name': 'Produs ascuns', 'is_published': False, 'list_price': 10.0})

    def test_acasa_se_vede_fara_sesiune(self):
        response = self.api_get('/home')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['pricing'],
                         {'visible': False, 'reason': 'sign_in_required'})

    def test_pagina_de_produs_se_vede_fara_pret(self):
        body = self.api_get('/products/%s' % self.publicat.id).json()

        self.assertEqual(body['product']['name'], 'Produs vizibil')
        self.assertIsNone(body['product']['price'])
        self.assertEqual(body['pricing']['reason'], 'sign_in_required')

    def test_un_produs_nepublicat_ramane_404_pentru_vizitator(self):
        """Ruta publica nu are voie sa devina o fereastra spre tot ce e in baza."""
        self.assertEqual(self.api_get('/products/%s' % self.nepublicat.id).status_code, 404)

    def test_imaginea_unui_produs_nepublicat_ramane_404(self):
        self.assertEqual(
            self.api_get('/products/%s/image' % self.nepublicat.id).status_code, 404)

    def test_rutele_de_cont_raman_pe_cont(self):
        for path in ('/cart', '/checkout', '/orders', '/invoices', '/addresses',
                     '/favorites', '/loyalty', '/account/profile', '/payment-methods'):
            with self.subTest(path=path):
                self.assertEqual(self.api_get(path).status_code, 401)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `odoo/run-tests.sh 2>&1 | grep -aE "FAIL:|ERROR:"`
Expected: FAIL — `/home` si `/products/<id>` dau 401.

- [ ] **Step 3: Write minimal implementation**

`auth='public'` pe rutele enumerate in **Files**. In `controllers/product.py`, detaliul sare peste preturi la fel ca `_serialize_templates`:

```python
        if not is_signed_in():
            price = club_price = None
            price_tables = []
            variants = _serialize_variants(template, None, None)
        else:
            pricelist = _customer_pricelist(partner)
            ...
```

Raspunsul lui `/home` si al lui `/products/<id>` capata `'pricing': pricing_block(is_signed_in())`.

`controllers/home.py` importa `pricing_block` **in interiorul functiei**, nu la nivel de fisier — `home` si `catalog` se importa reciproc si modulul nu mai porneste altfel (capcana stiuta, scrisa in CLAUDE.md).

- [ ] **Step 4: Run test to verify it passes**

Run: `odoo/run-tests.sh 2>&1 | grep -a "failed, "`
Expected: `0 failed, 0 error(s)`

- [ ] **Step 5: Sincronizeaza contractele si commit**

```bash
app/tool/sync_contract.sh
git add odoo/uportho_app app/test/contract
git commit -m "Acasa, produsul si imaginile se vad fara cont"
```

---

### Task 3: `POST /auth/signup`, prin metodele Odoo

**Files:**
- Modify: `odoo/uportho_app/controllers/auth.py`
- Create: `odoo/uportho_app/contract/signup.json`
- Test: `odoo/uportho_app/tests/test_controllers_signup.py`

**Interfaces:**
- Consumes: `serialize_user(user)` din `controllers/auth.py`.
- Produces: `POST /api/app/v1/auth/signup` cu corp `{"login", "name", "password", "confirm_password"}` → 200 `{"user": {...}}`, 409 `{"error": {"code": "email_taken"}}`, 409 `signup_needs_webview`, 403 `signup_disabled`, 422 `validation_error`.

- [ ] **Step 1: Write the failing test**

Fisier nou `odoo/uportho_app/tests/test_controllers_signup.py`:

```python
from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestSignup(AppHttpCase):
    """Inregistrarea trece prin `AuthSignupHome`, deci primim regulile si mesajele lor.

    Signup-ul face `commit()` explicit in Odoo, deci contul chiar ramane in baza: fiecare
    test isi sterge contul creat."""

    def setUp(self):
        super().setUp()
        self.env['ir.config_parameter'].sudo().set_param('auth_signup.invitation_scope', 'b2c')
        self.addCleanup(self.registry.clear_cache)
        self.addCleanup(self._sterge_conturile_de_test)

    def _sterge_conturile_de_test(self):
        users = self.env['res.users'].sudo().search([('login', 'like', 'signup.test')])
        users.unlink()

    def test_creeaza_contul_si_deschide_sesiunea(self):
        response = self.api_post('/auth/signup', {
            'login': 'signup.test1@uportho.ro', 'name': 'Cabinet Test',
            'password': 'ParolaBuna123!', 'confirm_password': 'ParolaBuna123!'})

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['user']['email'], 'signup.test1@uportho.ro')
        # Sesiunea e deschisa: o ruta de cont raspunde acum.
        self.assertEqual(self.api_get('/account/profile').status_code, 200)

    def test_un_email_cu_cont_existent_nu_atinge_contul_existent(self):
        existing = self.env['res.users'].sudo().create({
            'name': 'Deja Inregistrat', 'login': 'signup.test2@uportho.ro',
            'password': 'ParolaVeche123!',
            'groups_id': [(6, 0, [self.env.ref('base.group_portal').id])]})

        response = self.api_post('/auth/signup', {
            'login': 'signup.test2@uportho.ro', 'name': 'Altcineva',
            'password': 'ParolaNoua123!', 'confirm_password': 'ParolaNoua123!'})

        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['error']['code'], 'email_taken')
        existing.invalidate_recordset()
        self.assertEqual(existing.name, 'Deja Inregistrat')

    def test_parolele_diferite_sunt_oprite_inainte_de_orice_scriere(self):
        response = self.api_post('/auth/signup', {
            'login': 'signup.test3@uportho.ro', 'name': 'Cabinet',
            'password': 'Parola123!', 'confirm_password': 'AltaParola123!'})

        self.assertEqual(response.status_code, 422)
        self.assertFalse(self.env['res.users'].sudo().search(
            [('login', '=', 'signup.test3@uportho.ro')]))

    def test_cu_inregistrarea_oprita_ruta_refuza(self):
        self.env['ir.config_parameter'].sudo().set_param('auth_signup.invitation_scope', 'b2b')

        response = self.api_post('/auth/signup', {
            'login': 'signup.test4@uportho.ro', 'name': 'Cabinet',
            'password': 'Parola123!', 'confirm_password': 'Parola123!'})

        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json()['error']['code'], 'signup_disabled')

    def test_cu_recaptcha_configurat_ruta_trimite_in_webview(self):
        """Nu ocolim protectia anti-bot a magazinului ca sa ne fie noua mai comod."""
        self.env['ir.config_parameter'].sudo().set_param('recaptcha_private_key', 'cheie-test')

        response = self.api_post('/auth/signup', {
            'login': 'signup.test5@uportho.ro', 'name': 'Cabinet',
            'password': 'Parola123!', 'confirm_password': 'Parola123!'})

        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.json()['error']['code'], 'signup_needs_webview')
        self.assertFalse(self.env['res.users'].sudo().search(
            [('login', '=', 'signup.test5@uportho.ro')]))

    def test_campurile_in_plus_sunt_ignorate(self):
        """Un client nu-si poate seta singur grupuri sau agent de vanzari."""
        response = self.api_post('/auth/signup', {
            'login': 'signup.test6@uportho.ro', 'name': 'Cabinet',
            'password': 'Parola123!', 'confirm_password': 'Parola123!',
            'groups_id': [[6, 0, []]], 'user_id': 2})

        self.assertEqual(response.status_code, 200)
        user = self.env['res.users'].sudo().search([('login', '=', 'signup.test6@uportho.ro')])
        self.assertTrue(user.has_group('base.group_portal'))
```

- [ ] **Step 2: Run test to verify it fails**

Run: `odoo/run-tests.sh 2>&1 | grep -aE "FAIL:|ERROR:"`
Expected: FAIL — ruta nu exista, 404.

- [ ] **Step 3: Write minimal implementation**

In `controllers/auth.py`:

```python
from odoo.addons.auth_signup.controllers.main import AuthSignupHome
from odoo.addons.auth_signup.models.res_partner import SignupError

# Campurile pe care le accepta formularul magazinului, scrise explicit. `do_signup` ar
# citi orice cheie din qcontext; pe o ruta JSON asta ar lasa un client sa-si trimita
# singur grupuri sau alte campuri de utilizator.
SIGNUP_FIELDS = ('login', 'name', 'password', 'confirm_password')


class AppAuth(AuthSignupHome):
    """Mostenim controllerul lor de inregistrare, ca sa chemam `_signup_with_values` cu
    toate override-urile modulelor clientului. Nu suprascriem nicio ruta a lor: adaugam
    doar rute sub /api/app/v1 — acelasi tipar ca la adrese si la datele contului."""

    @app_route('/auth/signup', methods=['POST'], auth='public')
    def signup(self, **kw):
        body = read_json_body()
        values = {key: (body.get(key) or '').strip() if isinstance(body.get(key), str)
                  else body.get(key) for key in SIGNUP_FIELDS}
        if not values.get('login') or not values.get('name') or not values.get('password'):
            raise ApiError(422, 'validation_error', 'Completeaza nume, email si parola.')

        Config = request.env['ir.config_parameter'].sudo()
        if request.env['res.users'].sudo()._get_signup_invitation_scope() != 'b2c':
            raise ApiError(403, 'signup_disabled',
                           'Inregistrarea nu e deschisa. Cere cont de la UpOrtho.')
        # Pagina lor verifica reCAPTCHA inainte de creare. O ruta JSON care cheama direct
        # `do_signup` ar sari peste acea verificare, adica ar fi un endpoint de creat
        # conturi fara protectie anti-bot. Cand magazinul o are pornita, trimitem clientul
        # in pagina lui, unde protectia functioneaza.
        if Config.get_param('recaptcha_private_key'):
            raise ApiError(409, 'signup_needs_webview',
                           'Inregistrarea se face in pagina magazinului.')

        try:
            self.do_signup(values)
        except UserError as error:
            raise ApiError(422, 'validation_error',
                           error.args[0] if error.args else 'Datele nu sunt bune.')
        except (SignupError, AssertionError) as error:
            if request.env['res.users'].sudo().search_count(
                    [('login', '=', values['login'])], limit=1):
                raise ApiError(409, 'email_taken',
                               'Exista deja un cont cu acest email.')
            _logger.warning('Inregistrare esuata: %s', error)
            raise ApiError(422, 'validation_error', 'Contul nu a putut fi creat.')

        request.session.authenticate(
            request.db,
            {'type': 'password', 'login': values['login'], 'password': values['password']})
        request.update_env(user=request.session.uid)
        return json_ok({'user': serialize_user(request.env.user)})
```

`do_signup` citeste din `qcontext`-ul lor; aici primeste direct dictionarul nostru, deci se cheama `self._prepare_signup_values`-ul lor pe el. Daca semnatura difera in Odoo 18, se cheama in schimb `self._signup_with_values(None, {'login':…, 'name':…, 'password':…})` dupa ce verificam singuri potrivirea parolelor cu mesajul lor.

- [ ] **Step 4: Run test to verify it passes**

Run: `odoo/run-tests.sh 2>&1 | grep -a "failed, "`
Expected: `0 failed, 0 error(s)`

- [ ] **Step 5: Scrie contractul**

`contract/signup.json`:

```json
{
  "user": {
    "id": 42,
    "name": "Cabinet Test",
    "email": "cabinet@exemplu.ro",
    "partner_id": 77
  }
}
```

Apoi `app/tool/sync_contract.sh`.

- [ ] **Step 6: Commit**

```bash
git add odoo/uportho_app app/test/contract
git commit -m "Inregistrare prin metodele de signup ale magazinului"
```

---

### Task 4: Modelele aplicatiei accepta lipsa pretului

**Files:**
- Create: `app/lib/api/models/pricing.dart`
- Modify: `app/lib/api/models/product.dart`, `product_detail.dart`, `products_response.dart`, `home_response.dart`
- Test: `app/test/api/models_test.dart`

**Interfaces:**
- Consumes: contractele din Task 1-3.
- Produces: `Pricing({required bool visible, String? reason})`; `Product.price` si `Product.clubPrice` devin `Price?`; `ProductsResponse.pricing`, `HomeResponse.pricing`, `ProductDetailResponse.pricing` de tip `Pricing`.

- [ ] **Step 1: Write the failing test**

In `app/test/api/models_test.dart`:

```dart
  test('un produs fara pret se decodeaza, nu arunca', () {
    // Un raspuns de vizitator: serverul nu trimite niciun pret. Daca modelul ar cere
    // `price`, ecranul ar ramane gol in loc sa arate catalogul.
    final json = fixture('products.json');
    final anonim = Map<String, dynamic>.from(json);
    anonim['pricing'] = {'visible': false, 'reason': 'sign_in_required'};
    anonim['products'] = (json['products'] as List)
        .map((p) => {...p as Map<String, dynamic>, 'price': null, 'club_price': null})
        .toList();

    final response = ProductsResponse.fromJson(anonim);

    expect(response.pricing.visible, isFalse);
    expect(response.pricing.reason, 'sign_in_required');
    expect(response.products.first.price, isNull);
  });

  test('cu cont, pretul se decodeaza ca pana acum', () {
    final response = ProductsResponse.fromJson(fixture('products.json'));

    expect(response.pricing.visible, isTrue);
    expect(response.products.first.price?.formatted, isNotEmpty);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/api/models_test.dart`
Expected: FAIL — `pricing` nu exista pe model.

- [ ] **Step 3: Write minimal implementation**

`app/lib/api/models/pricing.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing.freezed.dart';
part 'pricing.g.dart';

/// De ce lipsesc preturile dintr-un raspuns de catalog.
///
/// Vine de la server, si asta e tot rostul lui: aplicatia nu decide din starea ei de
/// autentificare daca are voie sa arate preturi. O sesiune expirata arata inca
/// "autentificat" in aplicatie cat timp nu cere nimic, iar atunci cele doua adevaruri
/// s-ar despica. Cu blocul asta exista unul singur.
@freezed
abstract class Pricing with _$Pricing {
  const factory Pricing({
    @Default(true) bool visible,
    String? reason,
  }) = _Pricing;

  factory Pricing.fromJson(Map<String, dynamic> json) => _$PricingFromJson(json);
}
```

In `product.dart`, `price` si `clubPrice` devin `Price?` (se scoate `required`). In fiecare raspuns de catalog se adauga `@Default(Pricing()) Pricing pricing`.

Apoi `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/api/models_test.dart && flutter analyze`
Expected: PASS, analyze curat. Compilatorul va arata fiecare loc care foloseste `product.price` fara verificare — Task 5 le rezolva.

- [ ] **Step 5: Commit**

```bash
git add app/lib/api app/test/api
git commit -m "Modelele accepta un catalog fara preturi"
```

---

### Task 5: Cardul si pagina de produs fara pret

**Files:**
- Modify: `app/lib/design_system/widgets/product_card.dart`
- Modify: `app/lib/features/product/product_screen.dart`, `app/lib/features/catalog/catalog_screen.dart`, `app/lib/features/home/home_screen.dart`
- Test: `app/test/design_system/product_card_test.dart`

**Interfaces:**
- Consumes: `Product.price` (`Price?`) din Task 4.
- Produces: `ProductCard({..., String? priceUnavailableLabel})` — cand `price` e null, cardul deseneaza eticheta in locul pretului.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('fara pret, cardul spune unde se vede, nu lasa gol', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ProductCard(product: produsFaraPret(), onTap: () {})),
    ));

    expect(find.text('Pretul se vede in cont'), findsOneWidget);
    expect(find.textContaining('lei'), findsNothing);
  });

  testWidgets('cu pret, cardul arata exact ce a trimis serverul', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ProductCard(product: produsCuPret(), onTap: () {})),
    ));

    expect(find.text('148,50 lei'), findsOneWidget);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/design_system/product_card_test.dart`
Expected: FAIL — cardul arunca pe `price` null.

- [ ] **Step 3: Write minimal implementation**

In `product_card.dart`, blocul de pret:

```dart
          if (product.price case final Price price) ...[
            Text(price.formatted, style: ...),
            ...
          ] else
            // Fara pret nu se lasa un gol: golul arata a aplicatie stricata. Textul e
            // acelasi peste tot, iar butonul de actiune lipseste aici dinadins — la
            // varianta B invitatia se face o singura data, in banda de sus.
            Text('Pretul se vede in cont',
                style: AppTypography.caption(context)
                    .copyWith(color: context.colors.textSecondary)),
```

In `product_screen.dart`, butonul "Adauga in cos" devine "Intra in cont" cand `pricing.visible` e fals, si duce la `/login`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test && flutter analyze`
Expected: toate trec, analyze curat.

- [ ] **Step 5: Commit**

```bash
git add app/lib app/test
git commit -m "Cardul si pagina de produs, fara pret"
```

---

### Task 6: Aplicatia porneste in magazin

**Files:**
- Modify: `app/lib/router.dart`
- Modify: `app/lib/features/auth/auth_controller.dart`
- Modify: `app/lib/providers.dart` (providerii de cont)
- Test: `app/test/router_test.dart`, `app/test/features/account/account_switch_test.dart`

**Interfaces:**
- Consumes: `authControllerProvider` (`AsyncValue<AuthState>`), `SignedIn`/`SignedOut`.
- Produces: `bool isSignedIn(Ref ref)` in `providers.dart`, folosita de providerii de cont ca sa se opreasca devreme.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('fara sesiune, aplicatia porneste pe Acasa, nu la autentificare',
      (tester) async {
    await pumpApp(tester, signedIn: false);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('un vizitator dus la cos ajunge la autentificare', (tester) async {
    await pumpApp(tester, signedIn: false);
    router.go('/cart');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  test('providerii de cont nu cer serverul cat timp nu exista sesiune', () async {
    final transport = FakeTransport();
    final container = containerFara(transport);

    await container.read(cartControllerProvider.future);

    expect(transport.requests, isEmpty);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/router_test.dart`
Expected: FAIL — redirectul trimite la `/login`.

- [ ] **Step 3: Write minimal implementation**

In `router.dart`:

```dart
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading && !auth.hasValue) return null; // inca restauram sesiunea
      final signedIn = auth.value is SignedIn;
      final onAuthScreen = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      // Un vizitator are voie peste tot in magazin. Doar ecranele care au nevoie de
      // cont il trimit la autentificare — lista e scrisa aici, nu ghicita din adresa.
      const needsAccount = ['/cart', '/checkout', '/account', '/orders', '/invoices'];
      if (!signedIn && needsAccount.any(state.matchedLocation.startsWith)) return '/login';
      if (signedIn && onAuthScreen) return '/';
      return null;
    },
```

In fiecare provider de cont, dupa `await ref.watch(authControllerProvider.future)`:

```dart
  // Fara sesiune nu se cere serverul: ar fi patru 401-uri la fiecare pornire, in loguri
  // si in retea, pentru un raspuns pe care il stim dinainte.
  if (!isSignedIn(ref)) return const CartState.empty();
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test && flutter analyze`
Expected: toate trec.

- [ ] **Step 5: Commit**

```bash
git add app/lib app/test
git commit -m "Aplicatia porneste in magazin, nu la autentificare"
```

---

### Task 7: Banda de invitatie si butonul "Contul meu"

**Files:**
- Create: `app/lib/design_system/widgets/sign_in_banner.dart`
- Modify: `app/lib/features/home/home_screen.dart`, `app/lib/features/catalog/catalog_screen.dart`, `app/lib/features/shell/shell_screen.dart`
- Test: `app/test/design_system/sign_in_banner_test.dart`

**Interfaces:**
- Consumes: `Pricing` din Task 4.
- Produces: `SignInBanner({required VoidCallback onSignIn})`.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('banda apare doar cand serverul spune ca preturile nu se vad',
      (tester) async {
    await pumpHome(tester, pricing: const Pricing(visible: false, reason: 'sign_in_required'));

    expect(find.byType(SignInBanner), findsOneWidget);
    expect(find.textContaining('Intra in cont'), findsWidgets);
  });

  testWidgets('cu preturi vizibile, banda lipseste cu totul', (tester) async {
    await pumpHome(tester, pricing: const Pricing(visible: true));

    expect(find.byType(SignInBanner), findsNothing);
  });

  testWidgets('apasarea pe Intra cere autentificarea', (tester) async {
    var cerut = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SignInBanner(onSignIn: () => cerut++)),
    ));

    await tester.tap(find.text('Intra'));

    expect(cerut, 1);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/design_system/sign_in_banner_test.dart`
Expected: FAIL — widgetul nu exista.

- [ ] **Step 3: Write minimal implementation**

`sign_in_banner.dart`: o banda cu lacat, textul "Intra in cont ca sa vezi preturile si sa comanzi." si butonul "Intra", pe `context.colors.primaryLight` la 25% (varianta B din panza). Se deseneaza **doar** cand `pricing.visible` e fals.

In `shell_screen.dart` / antetul ecranelor, butonul de iesire e inlocuit cu "Contul meu" (iconita + text, minim 44px inaltime), care duce la tabul Cont.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test && flutter analyze`

- [ ] **Step 5: Commit**

```bash
git add app/lib app/test
git commit -m "Banda de invitatie si butonul Contul meu"
```

---

### Task 8: Ecranul Cont pentru vizitator si inregistrarea

**Files:**
- Create: `app/lib/features/auth/signup_screen.dart`
- Create: `app/lib/api/models/signup_result.dart`
- Modify: `app/lib/api/api_client.dart`, `app/lib/features/account/account_screen.dart`, `app/lib/features/auth/auth_controller.dart`, `app/lib/router.dart`
- Test: `app/test/features/auth/signup_screen_test.dart`

**Interfaces:**
- Consumes: `POST /auth/signup` din Task 3.
- Produces: `ApiClient.signup({required String login, required String name, required String password, required String confirmPassword}) -> Future<UserProfile>`; ruta `/signup`.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('un cont nou te lasa inauntru fara al doilea pas', (tester) async {
    transport.when('POST', '/api/app/v1/auth/signup',
        ApiResponse(status: 200, json: fixture('signup.json')));
    await pumpSignup(tester);

    await completeazaFormularul(tester);
    await tester.tap(find.text('Creeaza contul'));
    await tester.pumpAndSettle();

    expect(container.read(authControllerProvider).value, isA<SignedIn>());
  });

  testWidgets('un email cu cont existent propune autentificarea, cu emailul dus mai departe',
      (tester) async {
    transport.when('POST', '/api/app/v1/auth/signup', ApiResponse(status: 409, json: {
      'error': {'code': 'email_taken', 'message': 'Exista deja un cont cu acest email.'}
    }));
    await pumpSignup(tester);

    await completeazaFormularul(tester, email: 'cabinet@exemplu.ro');
    await tester.tap(find.text('Creeaza contul'));
    await tester.pumpAndSettle();

    expect(find.text('Exista deja un cont cu acest email.'), findsOneWidget);
    expect(find.text('Am deja cont — intra'), findsOneWidget);
  });

  testWidgets('cand magazinul cere reCAPTCHA, inregistrarea se muta in pagina lui',
      (tester) async {
    transport.when('POST', '/api/app/v1/auth/signup', ApiResponse(status: 409, json: {
      'error': {'code': 'signup_needs_webview', 'message': 'Inregistrarea se face in pagina magazinului.'}
    }));
    await pumpSignup(tester);

    await completeazaFormularul(tester);
    await tester.tap(find.text('Creeaza contul'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupWebViewScreen), findsOneWidget);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/features/auth/signup_screen_test.dart`
Expected: FAIL — ecranul nu exista.

- [ ] **Step 3: Write minimal implementation**

Ecranul cu patru campuri (nume, email, parola, confirmare), erorile sub campul lor, iar la `email_taken` butonul "Am deja cont — intra" care duce la `/login` cu emailul precompletat. La `signup_needs_webview`, deschide pagina `/web/signup` a magazinului intr-un WebView cu aceeasi sesiune, ca la plata.

`account_screen.dart` capata fata de vizitator: card cu doua butoane si lista scurta de beneficii (varianta din panza).

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test && flutter analyze`

- [ ] **Step 5: Commit**

```bash
git add app/lib app/test
git commit -m "Ecranul Cont pentru vizitator si crearea contului"
```

---

### Task 9: Verificare pe staging, pe date reale

**Files:**
- Modify: `CLAUDE.md` (sectiunea noua despre vizitator), `docs/STAGING.md`
- Modify: `uportho_app.tar.gz`

- [ ] **Step 1: Urca modulul pe staging**

```bash
COPYFILE_DISABLE=1 tar czf uportho_app.tar.gz -C odoo --exclude='__pycache__' --exclude='*.pyc' uportho_app
git add -A && git commit -m "Arhiva de desfasurare" && git push
```

Pe staging, **dupa SHA-ul commitului**, nu dupa `main` (CDN-ul serveste minute bune arhiva veche):

```bash
curl -sSL -o /tmp/uportho_app.tar.gz \
  https://raw.githubusercontent.com/RetroKWizz/Aplicatie-UpOrtho/<SHA>/uportho_app.tar.gz
sha256sum /tmp/uportho_app.tar.gz   # se compara cu suma locala
tar xzf /tmp/uportho_app.tar.gz -C . && odoo-update uportho_app
```

- [ ] **Step 2: Verifica rutele fara sesiune**

```bash
for p in /home /products /categories; do
  curl -s -o /dev/null -w "$p -> %{http_code}\n" "https://developer.uportho.ro/api/app/v1$p"
done
```

Expected: toate `200`. Si `/cart` → `401`.

- [ ] **Step 3: Parcurge aplicatia pe simulator, fara cont**

```bash
cd app && flutter run -d <simulator-id> \
  --dart-define=API_BASE_URL=https://developer.uportho.ro
```

De verificat, cu captura la fiecare: Acasa porneste fara login; banda apare o singura data; cardurile spun "Pretul se vede in cont"; "Contul meu" duce la ecranul de vizitator; crearea unui cont nou intra direct in aplicatie; dupa autentificare aceeasi grila arata preturi si banda dispare.

- [ ] **Step 4: Scrie in CLAUDE.md ce s-a invatat**

Sectiune noua: ce e public si ce nu, de ce preturile vin de la server si nu din starea locala, si capcana reCAPTCHA.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md docs/STAGING.md uportho_app.tar.gz
git commit -m "Magazinul fara cont, verificat pe staging"
```
