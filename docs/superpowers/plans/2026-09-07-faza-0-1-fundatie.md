# Faza 0 + Faza 1 (Fundatie) — plan de implementare

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Un modul Odoo `uportho_app` care expune `/api/app/v1` (login, home, continut, devices) si o aplicatie Flutter care se logheaza si afiseaza ecranul Acasa cu bannere si categorii rapide citite din Odoo.

**Architecture:** Modulul Python ruleaza in Odoo (local in Docker pentru dezvoltare/teste, apoi odoo.sh) si expune controllere `type='http'` cu raspuns JSON si coduri HTTP reale, protejate cu `auth='user'` + header `X-UpOrtho-App`. Aplicatia Flutter are un singur client HTTP (`lib/api/`) care cunoaste contractul `v1`, modele generate din fixture-uri JSON comune cu modulul, si feature-uri (`auth`, `home`) construite pe Riverpod. Nimic din aplicatie nu stie de Odoo.

**Tech Stack:** Odoo 18 (Docker `odoo:18` + `postgres:15`), Python 3.10+ in container, `odoo.tests` (`TransactionCase`, `HttpCase`); Flutter stable, Dart 3, `flutter_riverpod`, `go_router`, `dio`, `freezed`, `json_serializable`, `flutter_secure_storage`, `cached_network_image`.

**Spec:** `docs/superpowers/specs/2026-09-07-uportho-flutter-odoo-design.md`

## Global Constraints

- Regula CLAUDE.md: **nimic nu se modifica in Odoo-ul de productie/staging/dev de pe odoo.sh fara acceptul explicit al lui Mihai, de fiecare data.** Odoo-ul local din Docker e al nostru si se poate modifica liber.
- Toate rutele modulului sunt sub `/api/app/v1`, `type='http'`, raspuns JSON prin `request.make_json_response`, cod HTTP real.
- Toate rutele in afara de `/auth/login` sunt `auth='user'`.
- Toate POST/DELETE au `csrf=False` si cer header `X-UpOrtho-App: 1`; lipsa lui = HTTP 403.
- Forma erorii: `{"error": {"code": "<snake_case>", "message": "<text pentru utilizator>", "details": {}}}`.
- Aplicatia nu face aritmetica pe bani (nu apare in Faza 1, dar regula e globala).
- Pozele se livreaza ca URL-uri (rute `/api/app/v1/.../image`), niciodata base64.
- Fixture-urile de contract traiesc in `odoo/uportho_app/contract/*.json` si se copiaza identic in `app/test/contract/`.
- Numele modulului Odoo: `uportho_app`. Prefixul modelelor: `uportho.app.*`. Prefixul campurilor adaugate pe modele existente: `app_`.
- Codul, comentariile si commit-urile se scriu in limba proiectului (romana fara diacritice), identificatorii in engleza.
- Commit dupa fiecare task, cu prefix Conventional Commits (`feat:`, `test:`, `chore:`, `docs:`).

## Structura de fisiere

```
odoo/
  docker-compose.yml                 Odoo 18 + Postgres local
  odoo.conf                          config local (addons_path, db)
  run-tests.sh                       ruleaza testele modulului in container
  uportho_app/
    __manifest__.py
    __init__.py
    models/__init__.py
    models/app_banner.py             uportho.app.banner + filtrarea "activ acum"
    models/app_device.py             uportho.app.device (token FCM per user)
    models/product_public_category.py  campuri app_home_*
    models/product_template.py       campuri app_badge_*
    controllers/__init__.py
    controllers/base.py              json_ok / json_error / decorator app_route
    controllers/auth.py              /auth/login, /auth/logout, /me
    controllers/home.py              /home, /banners/<id>/image, /categories/<id>/icon
    controllers/devices.py           /devices
    security/ir.model.access.csv
    views/app_banner_views.xml
    views/product_public_category_views.xml
    views/product_template_views.xml
    views/menus.xml
    contract/login.json
    contract/me.json
    contract/home.json
    contract/error.json
    tests/__init__.py
    tests/common.py                  utilizator portal de test + helper de request
    tests/test_app_banner.py
    tests/test_controllers_base.py
    tests/test_controllers_auth.py
    tests/test_controllers_home.py
    tests/test_controllers_devices.py
app/
  pubspec.yaml
  lib/main.dart
  lib/app.dart                       MaterialApp.router + tema
  lib/config.dart                    API_BASE_URL din --dart-define
  lib/router.dart                    go_router + redirect pe auth
  lib/api/api_transport.dart         interfata ApiTransport + ApiResponse
  lib/api/dio_transport.dart         implementare Dio + header + cookie
  lib/api/api_client.dart            get/post/delete tipate, mapare erori
  lib/api/api_exception.dart
  lib/api/session_store.dart         session_id in flutter_secure_storage
  lib/api/models/price.dart          (definit acum, folosit din Faza 2)
  lib/api/models/user_profile.dart
  lib/api/models/banner.dart
  lib/api/models/home_category.dart
  lib/api/models/home_response.dart
  lib/design_system/colors.dart
  lib/design_system/typography.dart
  lib/design_system/theme.dart
  lib/design_system/widgets/banner_card.dart
  lib/design_system/widgets/category_chip.dart
  lib/design_system/widgets/section_header.dart
  lib/features/auth/auth_repository.dart
  lib/features/auth/auth_controller.dart
  lib/features/auth/login_screen.dart
  lib/features/home/home_repository.dart
  lib/features/home/home_controller.dart
  lib/features/home/home_screen.dart
  lib/features/shell/shell_screen.dart   tab bar cu 4 taburi (Acasa functional, restul placeholder)
  test/contract/*.json                 copie identica din odoo/uportho_app/contract/
  test/api/fake_transport.dart
  test/api/api_client_test.dart
  test/api/models_test.dart
  test/design_system/banner_card_test.dart
  test/design_system/category_chip_test.dart
  test/features/auth/auth_controller_test.dart
  test/features/home/home_controller_test.dart
```

---

## FAZA 0 — Pregatire

### Task 0.1: Toolchain Flutter + Android pe macOS

Comenzi pe care le ruleaza Mihai (sau Claude cu permisiune), nu au teste automate. Criteriul de acceptare e `flutter doctor` fara erori pe iOS si Android.

**Files:** niciunul in repo.

- [ ] **Step 1: Instaleaza Flutter, CocoaPods, Android Studio**

```bash
brew install --cask flutter
brew install cocoapods
brew install --cask android-studio
```

- [ ] **Step 2: Deschide Android Studio o data** si accepta instalarea Android SDK din wizard (SDK Platform 35, Build-Tools, Platform-Tools, Emulator). Apoi din SDK Manager > SDK Tools bifeaza "Android SDK Command-line Tools".

- [ ] **Step 3: Accepta licentele si creeaza un emulator**

```bash
flutter doctor --android-licenses
# Din Android Studio: Device Manager > Create Device > Pixel 8, imagine API 35 (arm64)
```

- [ ] **Step 4: Verifica**

```bash
flutter doctor -v
xcrun simctl list devices available | head
```

Expected: `flutter doctor` arata `[✓]` la Flutter, Android toolchain, Xcode, CocoaPods. Daca apare `[!] Xcode ... CocoaPods not installed`, ruleaza `sudo gem install cocoapods` ca alternativa la brew.

### Task 0.2: Odoo 18 local in Docker

**Files:**
- Create: `odoo/docker-compose.yml`
- Create: `odoo/odoo.conf`
- Create: `odoo/run-tests.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Porneste Docker Desktop** (daemon-ul nu ruleaza pe masina; `docker info` trebuie sa raspunda).

- [ ] **Step 2: Scrie `odoo/docker-compose.yml`**

```yaml
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: odoo
      POSTGRES_PASSWORD: odoo
      POSTGRES_DB: postgres
    volumes:
      - odoo-db:/var/lib/postgresql/data
  odoo:
    image: odoo:18
    depends_on: [db]
    ports: ["8069:8069"]
    environment:
      HOST: db
      USER: odoo
      PASSWORD: odoo
    volumes:
      - ./:/mnt/extra-addons:ro
      - ./odoo.conf:/etc/odoo/odoo.conf:ro
      - odoo-data:/var/lib/odoo
volumes:
  odoo-db:
  odoo-data:
```

- [ ] **Step 3: Scrie `odoo/odoo.conf`**

```ini
[options]
addons_path = /mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons
db_host = db
db_user = odoo
db_password = odoo
```

- [ ] **Step 4: Scrie `odoo/run-tests.sh`**

```bash
#!/usr/bin/env bash
# Ruleaza testele modulului uportho_app pe o baza de test dedicata, in containerul Odoo.
# Prima rulare instaleaza modulul (-i); urmatoarele il actualizeaza (-u).
set -euo pipefail
cd "$(dirname "$0")"
DB=uportho_test
MODE=${1:-u}   # "i" la prima rulare
docker compose run --rm odoo odoo -c /etc/odoo/odoo.conf -d "$DB" "-$MODE" uportho_app \
  --test-enable --test-tags /uportho_app --stop-after-init --log-level=test
```

- [ ] **Step 5: Adauga in `.gitignore`**

```
.DS_Store
build/
app/.dart_tool/
app/ios/Pods/
app/android/.gradle/
```

- [ ] **Step 6: Porneste si verifica ca Odoo boot-eaza**

```bash
chmod +x odoo/run-tests.sh
cd odoo && docker compose up -d && sleep 20 && curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8069/web/login
```

Expected: `200`.

- [ ] **Step 7: Verifica semnatura de autentificare din imaginea `odoo:18`** (se foloseste in Task 1.6; difera intre 17 si 18, si poate iar in 19)

```bash
cd odoo && docker compose run --rm odoo python3 -c "import inspect, odoo.http; print(inspect.signature(odoo.http.Session.authenticate))"
```

Expected (Odoo 18): `(self, dbname, credential)`. Noteaza rezultatul in commit-ul task-ului. Daca semnatura e `(self, dbname, login, password)`, adapteaza `controllers/auth.py` din Task 1.6 la forma cu 3 argumente.

- [ ] **Step 8: Commit**

```bash
git add odoo/docker-compose.yml odoo/odoo.conf odoo/run-tests.sh .gitignore
git commit -m "chore: Odoo 18 local in Docker pentru dezvoltarea modulului uportho_app"
```

### Task 0.3: Export modul Studio in repo (plasa de siguranta)

Actiune manuala a lui Mihai in backend-ul Odoo de productie. Este doar **citire/export**, nu modifica nimic.

**Files:**
- Create: `Rezultate/odoo-studio-export/<fisier>.zip`

- [ ] **Step 1:** In Odoo productie: deschide Studio (iconita cheie), meniul Studio > **Export** (sau Settings > Technical > Studio Customizations > Export). Descarca `.zip`.
- [ ] **Step 2:** Copiaza zip-ul in `Rezultate/odoo-studio-export/` si commit:

```bash
mkdir -p Rezultate/odoo-studio-export && cp ~/Downloads/<nume>.zip Rezultate/odoo-studio-export/
git add Rezultate/odoo-studio-export && git commit -m "chore: export customizari Studio (x_app_banner) ca backup inainte de modulul propriu"
```

---

## FAZA 1 — Modulul `uportho_app`

### Task 1.1: Schelet modul instalabil

**Files:**
- Create: `odoo/uportho_app/__manifest__.py`
- Create: `odoo/uportho_app/__init__.py`
- Create: `odoo/uportho_app/models/__init__.py`
- Create: `odoo/uportho_app/controllers/__init__.py`
- Create: `odoo/uportho_app/tests/__init__.py`
- Create: `odoo/uportho_app/tests/test_module.py`

**Interfaces:**
- Produces: modul `uportho_app` instalabil, dependent de `website_sale`, `sale`, `product`, `portal`.

- [ ] **Step 1: Scrie testul care verifica instalarea**

`odoo/uportho_app/tests/__init__.py`:
```python
from . import test_module
```

`odoo/uportho_app/tests/test_module.py`:
```python
from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestModuleInstalled(TransactionCase):
    def test_module_is_installed(self):
        module = self.env['ir.module.module'].search([('name', '=', 'uportho_app')])
        self.assertEqual(module.state, 'installed')
```

- [ ] **Step 2: Scrie manifestul si init-urile**

`odoo/uportho_app/__manifest__.py`:
```python
{
    'name': 'UpOrtho App API',
    'version': '18.0.1.0.0',
    'summary': 'API JSON /api/app/v1 pentru aplicatia mobila UpOrtho (iOS + Android)',
    'category': 'Website/eCommerce',
    'license': 'LGPL-3',
    'depends': ['website_sale', 'sale', 'product', 'portal'],
    'data': [
        'security/ir.model.access.csv',
        'views/app_banner_views.xml',
        'views/product_public_category_views.xml',
        'views/product_template_views.xml',
        'views/menus.xml',
    ],
    'installable': True,
    'application': False,
}
```

Pentru ca modulul sa se instaleze de la primul task, creeaza fisierele de date goale-dar-valide:

`odoo/uportho_app/security/ir.model.access.csv`:
```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
```

`odoo/uportho_app/views/app_banner_views.xml`, `views/product_public_category_views.xml`, `views/product_template_views.xml`, `views/menus.xml` — toate cu continutul:
```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo/>
```

`odoo/uportho_app/__init__.py`:
```python
from . import models
from . import controllers
```

`odoo/uportho_app/models/__init__.py` si `odoo/uportho_app/controllers/__init__.py`: fisiere goale (vor primi importuri in task-urile urmatoare).

- [ ] **Step 3: Ruleaza testele (prima instalare)**

```bash
odoo/run-tests.sh i
```

Expected: in log, `uportho_app: 1 test, 0 failed` (formatul exact: cauta `0 failed, 0 error(s)` si lipsa oricarui `ERROR`).

- [ ] **Step 4: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): schelet modul uportho_app instalabil"
```

### Task 1.2: Model `uportho.app.banner` + filtrarea "activ acum"

**Files:**
- Create: `odoo/uportho_app/models/app_banner.py`
- Modify: `odoo/uportho_app/models/__init__.py`
- Modify: `odoo/uportho_app/security/ir.model.access.csv`
- Create: `odoo/uportho_app/tests/test_app_banner.py`
- Modify: `odoo/uportho_app/tests/__init__.py`

**Interfaces:**
- Produces: model `uportho.app.banner` cu campurile din spec si metoda de model `_search_active_now(website)` -> recordset ordonat dupa `sequence, id`.

- [ ] **Step 1: Scrie testele**

`odoo/uportho_app/tests/test_app_banner.py`:
```python
from datetime import date, timedelta

from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestAppBanner(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Banner = cls.env['uportho.app.banner']
        cls.website = cls.env['website'].search([], limit=1)
        cls.other_website = cls.env['website'].create({'name': 'Alt site'})
        cls.today = date.today()

    def _make(self, **vals):
        base = {'name': 'Banner', 'placement': 'hero', 'link_type': 'none', 'sequence': 10}
        base.update(vals)
        return self.Banner.create(base)

    def test_active_without_dates_is_returned(self):
        banner = self._make()
        self.assertIn(banner, self.Banner._search_active_now(self.website))

    def test_archived_is_excluded(self):
        banner = self._make(active=False)
        self.assertNotIn(banner, self.Banner._search_active_now(self.website))

    def test_future_start_is_excluded(self):
        banner = self._make(date_start=self.today + timedelta(days=1))
        self.assertNotIn(banner, self.Banner._search_active_now(self.website))

    def test_past_end_is_excluded(self):
        banner = self._make(date_end=self.today - timedelta(days=1))
        self.assertNotIn(banner, self.Banner._search_active_now(self.website))

    def test_window_including_today_is_returned(self):
        banner = self._make(date_start=self.today, date_end=self.today)
        self.assertIn(banner, self.Banner._search_active_now(self.website))

    def test_other_website_is_excluded_but_no_website_is_returned(self):
        generic = self._make(website_id=False)
        mine = self._make(website_id=self.website.id)
        other = self._make(website_id=self.other_website.id)
        result = self.Banner._search_active_now(self.website)
        self.assertIn(generic, result)
        self.assertIn(mine, result)
        self.assertNotIn(other, result)

    def test_ordered_by_sequence(self):
        second = self._make(sequence=20, name='B')
        first = self._make(sequence=5, name='A')
        result = self.Banner._search_active_now(self.website)
        self.assertEqual(result[:2].mapped('name'), ['A', 'B'])

    def test_category_link_requires_category(self):
        with self.assertRaises(Exception):
            self._make(link_type='category', category_id=False)

    def test_url_link_requires_url(self):
        with self.assertRaises(Exception):
            self._make(link_type='url', external_url=False)
```

`odoo/uportho_app/tests/__init__.py`:
```python
from . import test_module
from . import test_app_banner
```

- [ ] **Step 2: Ruleaza testele, verifica ca pica**

```bash
odoo/run-tests.sh
```

Expected: erori `KeyError: 'uportho.app.banner'` sau similar.

- [ ] **Step 3: Scrie modelul**

`odoo/uportho_app/models/app_banner.py`:
```python
from odoo import api, fields, models
from odoo.exceptions import ValidationError


class AppBanner(models.Model):
    _name = 'uportho.app.banner'
    _description = 'Banner aplicatie mobila UpOrtho'
    _order = 'sequence, id'

    name = fields.Char(string='Titlu', required=True)
    subtitle = fields.Char(string='Subtitlu')
    cta_text = fields.Char(string='Text buton', default='Vezi produse')
    image = fields.Image(string='Imagine', max_width=1600, max_height=1600)
    placement = fields.Selection(
        [('hero', 'Hero'), ('promo', 'Promo')], string='Plasare', required=True, default='hero')
    link_type = fields.Selection(
        [('category', 'Categorie'), ('url', 'URL extern'), ('none', 'Fara link')],
        string='Tip link', required=True, default='none')
    category_id = fields.Many2one('product.public.category', string='Categorie')
    external_url = fields.Char(string='URL extern')
    sequence = fields.Integer(string='Ordine', default=10)
    active = fields.Boolean(default=True)
    date_start = fields.Date(string='Activ de la')
    date_end = fields.Date(string='Activ pana la')
    website_id = fields.Many2one('website', string='Website')

    @api.constrains('link_type', 'category_id', 'external_url')
    def _check_link_target(self):
        for banner in self:
            if banner.link_type == 'category' and not banner.category_id:
                raise ValidationError('Alege o categorie pentru un banner cu link de tip Categorie.')
            if banner.link_type == 'url' and not banner.external_url:
                raise ValidationError('Completeaza URL-ul pentru un banner cu link de tip URL extern.')

    @api.model
    def _search_active_now(self, website):
        """Bannerele vizibile ACUM pentru website-ul dat: activ (arhivarea e filtrata automat),
        in fereastra de date (limite inclusive, lipsa = fara limita), si fie fara website,
        fie pe website-ul cerut."""
        today = fields.Date.context_today(self)
        domain = [
            '|', ('date_start', '=', False), ('date_start', '<=', today),
            '|', ('date_end', '=', False), ('date_end', '>=', today),
            '|', ('website_id', '=', False), ('website_id', '=', website.id),
        ]
        return self.search(domain)
```

`odoo/uportho_app/models/__init__.py`:
```python
from . import app_banner
```

`odoo/uportho_app/security/ir.model.access.csv`:
```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_app_banner_portal,uportho.app.banner portal read,model_uportho_app_banner,base.group_portal,1,0,0,0
access_app_banner_user,uportho.app.banner user read,model_uportho_app_banner,base.group_user,1,0,0,0
access_app_banner_designer,uportho.app.banner designer,model_uportho_app_banner,website.group_website_designer,1,1,1,1
```

- [ ] **Step 4: Ruleaza testele, verifica ca trec**

```bash
odoo/run-tests.sh
```

Expected: `0 failed, 0 error(s)`.

- [ ] **Step 5: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): model uportho.app.banner cu filtrare activ/date/website"
```

### Task 1.3: Campuri `app_home_*` pe categorie si `app_badge_*` pe produs

**Files:**
- Create: `odoo/uportho_app/models/product_public_category.py`
- Create: `odoo/uportho_app/models/product_template.py`
- Modify: `odoo/uportho_app/models/__init__.py`
- Create: `odoo/uportho_app/tests/test_content_fields.py`
- Modify: `odoo/uportho_app/tests/__init__.py`

**Interfaces:**
- Produces: `product.public.category.app_home_visible/app_home_sequence/app_home_icon`, metoda `_search_app_home(website)`; `product.template.app_badge_text/app_badge_color/app_badge_date_end`, metoda `_app_badge_active()` -> dict sau None.

- [ ] **Step 1: Scrie testele**

`odoo/uportho_app/tests/test_content_fields.py`:
```python
from datetime import date, timedelta

from odoo.tests.common import TransactionCase, tagged


@tagged('post_install', '-at_install')
class TestHomeCategoryFields(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Category = cls.env['product.public.category']
        cls.website = cls.env['website'].search([], limit=1)

    def test_only_visible_categories_ordered_by_app_sequence(self):
        hidden = self.Category.create({'name': 'Ascunsa', 'app_home_visible': False})
        second = self.Category.create({'name': 'B', 'app_home_visible': True, 'app_home_sequence': 20})
        first = self.Category.create({'name': 'A', 'app_home_visible': True, 'app_home_sequence': 5})
        result = self.Category._search_app_home(self.website)
        self.assertNotIn(hidden, result)
        names = result.mapped('name')
        self.assertLess(names.index('A'), names.index('B'))


@tagged('post_install', '-at_install')
class TestProductBadge(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.Template = cls.env['product.template']

    def test_no_badge_returns_none(self):
        product = self.Template.create({'name': 'P'})
        self.assertIsNone(product._app_badge_active())

    def test_badge_without_end_date_is_active(self):
        product = self.Template.create({'name': 'P', 'app_badge_text': 'Nou', 'app_badge_color': 'green'})
        self.assertEqual(product._app_badge_active(), {'text': 'Nou', 'color': 'green'})

    def test_expired_badge_returns_none(self):
        product = self.Template.create({
            'name': 'P', 'app_badge_text': 'Nou', 'app_badge_color': 'green',
            'app_badge_date_end': date.today() - timedelta(days=1)})
        self.assertIsNone(product._app_badge_active())

    def test_badge_ending_today_is_active(self):
        product = self.Template.create({
            'name': 'P', 'app_badge_text': 'Nou', 'app_badge_color': 'green',
            'app_badge_date_end': date.today()})
        self.assertIsNotNone(product._app_badge_active())

    def test_badge_text_without_color_defaults_to_purple(self):
        product = self.Template.create({'name': 'P', 'app_badge_text': 'Popular'})
        self.assertEqual(product._app_badge_active()['color'], 'purple')
```

`odoo/uportho_app/tests/__init__.py`:
```python
from . import test_module
from . import test_app_banner
from . import test_content_fields
```

- [ ] **Step 2: Ruleaza testele, verifica ca pica**

```bash
odoo/run-tests.sh
```

Expected: erori de camp inexistent (`app_home_visible`) / metoda inexistenta.

- [ ] **Step 3: Scrie modelele**

`odoo/uportho_app/models/product_public_category.py`:
```python
from odoo import api, fields, models


class ProductPublicCategory(models.Model):
    _inherit = 'product.public.category'

    app_home_visible = fields.Boolean(string='Vizibila pe Acasa (app)', default=False)
    app_home_sequence = fields.Integer(string='Ordine pe Acasa (app)', default=10)
    app_home_icon = fields.Image(string='Iconita (app)', max_width=512, max_height=512)

    @api.model
    def _search_app_home(self, website):
        """Categoriile rapide de pe Acasa: bifate `app_home_visible`, pe website-ul dat
        sau fara website, ordonate dupa `app_home_sequence`."""
        domain = [
            ('app_home_visible', '=', True),
            '|', ('website_id', '=', False), ('website_id', '=', website.id),
        ]
        return self.search(domain, order='app_home_sequence, id')
```

`odoo/uportho_app/models/product_template.py`:
```python
from odoo import fields, models

BADGE_COLORS = [
    ('orange', 'Portocaliu'), ('green', 'Verde'), ('blue', 'Albastru'),
    ('purple', 'Mov'), ('red', 'Rosu'),
]


class ProductTemplate(models.Model):
    _inherit = 'product.template'

    app_badge_text = fields.Char(string='Eticheta (app)')
    app_badge_color = fields.Selection(BADGE_COLORS, string='Culoare eticheta (app)', default='purple')
    app_badge_date_end = fields.Date(string='Eticheta activa pana la (app)')

    def _app_badge_active(self):
        """Eticheta de afisat in app pentru acest produs, sau None daca nu exista sau a expirat."""
        self.ensure_one()
        if not self.app_badge_text:
            return None
        today = fields.Date.context_today(self)
        if self.app_badge_date_end and self.app_badge_date_end < today:
            return None
        return {'text': self.app_badge_text, 'color': self.app_badge_color or 'purple'}
```

`odoo/uportho_app/models/__init__.py`:
```python
from . import app_banner
from . import product_public_category
from . import product_template
```

- [ ] **Step 4: Ruleaza testele, verifica ca trec**

```bash
odoo/run-tests.sh
```

Expected: `0 failed, 0 error(s)`.

- [ ] **Step 5: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): campuri app_home_* pe categorie si app_badge_* pe produs"
```

### Task 1.4: Vizualizari si meniu pentru editarea continutului

Fara teste unitare (XML de UI); acceptarea e ca modulul se actualizeaza fara eroare si ecranele apar in backend.

**Files:**
- Modify: `odoo/uportho_app/views/app_banner_views.xml`
- Modify: `odoo/uportho_app/views/product_public_category_views.xml`
- Modify: `odoo/uportho_app/views/product_template_views.xml`
- Modify: `odoo/uportho_app/views/menus.xml`

- [ ] **Step 1: Scrie vizualizarile de banner**

`odoo/uportho_app/views/app_banner_views.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <record id="view_app_banner_list" model="ir.ui.view">
        <field name="name">uportho.app.banner.list</field>
        <field name="model">uportho.app.banner</field>
        <field name="arch" type="xml">
            <list default_order="sequence">
                <field name="sequence" widget="handle"/>
                <field name="name"/>
                <field name="placement"/>
                <field name="link_type"/>
                <field name="date_start"/>
                <field name="date_end"/>
                <field name="website_id"/>
                <field name="active" widget="boolean_toggle"/>
            </list>
        </field>
    </record>

    <record id="view_app_banner_form" model="ir.ui.view">
        <field name="name">uportho.app.banner.form</field>
        <field name="model">uportho.app.banner</field>
        <field name="arch" type="xml">
            <form>
                <sheet>
                    <field name="image" widget="image" class="oe_avatar" options="{'size': [0, 160]}"/>
                    <div class="oe_title">
                        <h1><field name="name" placeholder="Titlu banner"/></h1>
                    </div>
                    <group>
                        <group string="Continut">
                            <field name="subtitle"/>
                            <field name="cta_text"/>
                            <field name="placement"/>
                        </group>
                        <group string="Link">
                            <field name="link_type"/>
                            <field name="category_id" invisible="link_type != 'category'" required="link_type == 'category'"/>
                            <field name="external_url" invisible="link_type != 'url'" required="link_type == 'url'"/>
                        </group>
                        <group string="Programare">
                            <field name="sequence"/>
                            <field name="active"/>
                            <field name="date_start"/>
                            <field name="date_end"/>
                            <field name="website_id"/>
                        </group>
                    </group>
                </sheet>
            </form>
        </field>
    </record>

    <record id="action_app_banner" model="ir.actions.act_window">
        <field name="name">Bannere aplicatie</field>
        <field name="res_model">uportho.app.banner</field>
        <field name="view_mode">list,form</field>
        <field name="context">{'active_test': False}</field>
    </record>
</odoo>
```

- [ ] **Step 2: Adauga campurile pe formularele existente**

`odoo/uportho_app/views/product_public_category_views.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <record id="product_public_category_form_app" model="ir.ui.view">
        <field name="name">product.public.category.form.app</field>
        <field name="model">product.public.category</field>
        <field name="inherit_id" ref="website_sale.product_public_category_form_view"/>
        <field name="arch" type="xml">
            <xpath expr="//sheet" position="inside">
                <group string="Aplicatie mobila">
                    <field name="app_home_visible"/>
                    <field name="app_home_sequence"/>
                    <field name="app_home_icon" widget="image" options="{'size': [0, 96]}"/>
                </group>
            </xpath>
        </field>
    </record>
</odoo>
```

`odoo/uportho_app/views/product_template_views.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <record id="product_template_form_app" model="ir.ui.view">
        <field name="name">product.template.form.app</field>
        <field name="model">product.template</field>
        <field name="inherit_id" ref="website_sale.product_template_form_view"/>
        <field name="arch" type="xml">
            <xpath expr="//notebook" position="inside">
                <page string="Aplicatie mobila" name="uportho_app">
                    <group>
                        <field name="app_badge_text"/>
                        <field name="app_badge_color"/>
                        <field name="app_badge_date_end"/>
                    </group>
                </page>
            </xpath>
        </field>
    </record>
</odoo>
```

Daca `website_sale.product_public_category_form_view` sau `website_sale.product_template_form_view` nu exista sub acest id in 18, gaseste id-ul corect cu:
```bash
cd odoo && docker compose run --rm odoo grep -rn 'model">product.public.category<' /usr/lib/python3/dist-packages/odoo/addons/website_sale/views/ | head
```

- [ ] **Step 3: Meniul**

`odoo/uportho_app/views/menus.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <menuitem id="menu_app_root" name="Aplicatie mobila" parent="website.menu_website_configuration" sequence="60"/>
    <menuitem id="menu_app_banner" name="Bannere" parent="menu_app_root" action="action_app_banner" sequence="10"/>
</odoo>
```

- [ ] **Step 4: Actualizeaza modulul si verifica in browser**

```bash
odoo/run-tests.sh
cd odoo && docker compose up -d
```

Deschide `http://localhost:8069`, login `admin`/`admin` pe baza `uportho_test`, Website > Configuration > Aplicatie mobila > Bannere: creeaza un banner cu imagine. Deschide o categorie eCommerce si un produs: grupul/pagina "Aplicatie mobila" apar.

Expected: fara eroare la update, ecranele exista.

- [ ] **Step 5: Commit**

```bash
git add odoo/uportho_app/views
git commit -m "feat(odoo): ecrane de editare bannere + campuri app pe categorie si produs"
```

### Task 1.5: Baza controllerelor — raspunsuri JSON, erori, header obligatoriu

**Files:**
- Create: `odoo/uportho_app/controllers/base.py`
- Create: `odoo/uportho_app/controllers/ping.py` (ruta de test, ramane in modul ca health-check)
- Modify: `odoo/uportho_app/controllers/__init__.py`
- Create: `odoo/uportho_app/tests/common.py`
- Create: `odoo/uportho_app/tests/test_controllers_base.py`
- Modify: `odoo/uportho_app/tests/__init__.py`
- Create: `odoo/uportho_app/contract/error.json`

**Interfaces:**
- Produces: `json_ok(data, status=200)`, `json_error(code, message, status, details=None)`, decorator `app_route(...)` (wrapper peste `http.route` care seteaza `type='http'`, `csrf=False`, verifica header-ul pe metodele non-GET, mapeaza exceptiile Odoo la coduri HTTP), helper `read_json_body()`.
- Produces (teste): `AppHttpCase` cu `self.portal_user` (login `app.test@uportho.ro`, parola `AppTest123!`), metode `api_get(path)`, `api_post(path, body, with_header=True)`, `api_delete(path, with_header=True)`, `api_login()`.

- [ ] **Step 1: Scrie fixture-ul de eroare**

`odoo/uportho_app/contract/error.json`:
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Trebuie sa te autentifici.",
    "details": {}
  }
}
```

- [ ] **Step 2: Scrie helper-ul de test si testele**

`odoo/uportho_app/tests/common.py`:
```python
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
```

`odoo/uportho_app/tests/test_controllers_base.py`:
```python
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
```

`odoo/uportho_app/tests/__init__.py`:
```python
from . import test_module
from . import test_app_banner
from . import test_content_fields
from . import test_controllers_base
```

- [ ] **Step 3: Ruleaza testele, verifica ca pica**

```bash
odoo/run-tests.sh
```

Expected: `/api/app/v1/ping` -> 404, testele pica.

- [ ] **Step 4: Scrie baza controllerelor**

`odoo/uportho_app/controllers/base.py`:
```python
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
```

`odoo/uportho_app/controllers/ping.py`:
```python
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
```

`odoo/uportho_app/controllers/__init__.py`:
```python
from . import ping
```

Nota despre `auth`: ruta se inregistreaza cu `auth='public'` si verificam noi sesiunea, pentru ca `auth='user'` din Odoo raspunde la lipsa sesiunii cu redirect HTML la `/web/login`, nu cu 401 JSON. Regulile de acces ORM se aplica identic: `request.env` e construit pe `session.uid` cand exista sesiune.

- [ ] **Step 5: Ruleaza testele, verifica ca trec**

```bash
odoo/run-tests.sh
```

Expected: `0 failed, 0 error(s)`.

- [ ] **Step 6: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): baza controllerelor API: raspuns JSON, erori standard, header obligatoriu"
```

### Task 1.6: `/auth/login`, `/auth/logout`, `/me`

**Files:**
- Create: `odoo/uportho_app/controllers/auth.py`
- Modify: `odoo/uportho_app/controllers/__init__.py`
- Create: `odoo/uportho_app/contract/login.json`
- Create: `odoo/uportho_app/contract/me.json`
- Create: `odoo/uportho_app/tests/test_controllers_auth.py`
- Modify: `odoo/uportho_app/tests/__init__.py`

**Interfaces:**
- Produces: `POST /auth/login {login, password}` -> 200 cu `{"user": {...}}` si cookie `session_id`; 401 `invalid_credentials`. `POST /auth/logout` -> 204. `GET /me` -> `{"user": {"id", "name", "email", "partner_id"}}`.
- Produces: functia `serialize_user(user)` in `controllers/auth.py`, refolosita de `/home` daca e nevoie.

- [ ] **Step 1: Fixture-uri**

`odoo/uportho_app/contract/login.json`:
```json
{
  "user": {
    "id": 42,
    "name": "App Test",
    "email": "app.test@uportho.ro",
    "partner_id": 77
  }
}
```

`odoo/uportho_app/contract/me.json` — continut identic cu `login.json`.

- [ ] **Step 2: Teste**

`odoo/uportho_app/tests/test_controllers_auth.py`:
```python
from odoo.tests.common import tagged

from .common import AppHttpCase, PORTAL_LOGIN, PORTAL_PASSWORD
from .test_controllers_base import load_contract


@tagged('post_install', '-at_install')
class TestControllersAuth(AppHttpCase):
    def test_login_ok_returns_user_and_session_cookie(self):
        response = self.api_post('/auth/login', {'login': PORTAL_LOGIN, 'password': PORTAL_PASSWORD})
        self.assertEqual(response.status_code, 200, response.text)
        body = response.json()
        self.assertEqual(set(body['user'].keys()), set(load_contract('login.json')['user'].keys()))
        self.assertEqual(body['user']['email'], PORTAL_LOGIN)
        self.assertIn('session_id', response.cookies)

    def test_login_wrong_password_is_401(self):
        response = self.api_post('/auth/login', {'login': PORTAL_LOGIN, 'password': 'gresit'})
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()['error']['code'], 'invalid_credentials')

    def test_login_missing_fields_is_422(self):
        response = self.api_post('/auth/login', {'login': PORTAL_LOGIN})
        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()['error']['code'], 'validation_error')

    def test_me_after_login(self):
        self.api_login()
        response = self.api_get('/me')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['user']['email'], PORTAL_LOGIN)

    def test_logout_then_me_is_401(self):
        self.api_login()
        response = self.api_post('/auth/logout')
        self.assertEqual(response.status_code, 204)
        self.assertEqual(self.api_get('/me').status_code, 401)
```

`odoo/uportho_app/tests/__init__.py`: adauga `from . import test_controllers_auth`.

- [ ] **Step 3: Ruleaza testele, verifica ca pica** (`/auth/login` -> 404).

- [ ] **Step 4: Scrie controllerul**

`odoo/uportho_app/controllers/auth.py`:
```python
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
```

`odoo/uportho_app/controllers/__init__.py`:
```python
from . import ping
from . import auth
```

Daca `request.update_env` nu exista in 18, foloseste `request.env = request.env(user=request.session.uid)` — verifica cu `grep -n "def update_env" /usr/lib/python3/dist-packages/odoo/http.py` in container.

- [ ] **Step 5: Ruleaza testele, verifica ca trec** (inclusiv cele din Task 1.5 care apeleaza `api_login`).

```bash
odoo/run-tests.sh
```

Expected: `0 failed, 0 error(s)`.

- [ ] **Step 6: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): /auth/login, /auth/logout, /me"
```

### Task 1.7: `/home` + rute de imagine

**Files:**
- Create: `odoo/uportho_app/controllers/home.py`
- Modify: `odoo/uportho_app/controllers/__init__.py`
- Create: `odoo/uportho_app/contract/home.json`
- Create: `odoo/uportho_app/tests/test_controllers_home.py`
- Modify: `odoo/uportho_app/tests/__init__.py`

**Interfaces:**
- Produces: `GET /home` -> `{"banners": [...], "quick_categories": [...]}`. Bannere: `{id, title, subtitle, cta_text, placement, image_url, link: {type, category_id, url}}`. Categorii: `{id, name, icon_url}`. `GET /banners/<id>/image`, `GET /categories/<id>/icon` -> imagine binara (sau 404).
- Nota: campul `recommended` din spec se adauga in Faza 2, cand exista serializatorul de pret. Adaugarea unui camp nou e compatibila cu `v1`.

- [ ] **Step 1: Fixture**

`odoo/uportho_app/contract/home.json`:
```json
{
  "banners": [
    {
      "id": 1,
      "title": "Alatura-te Ortho Club",
      "subtitle": "Preturi speciale pentru membri",
      "cta_text": "Vezi beneficii",
      "placement": "hero",
      "image_url": "/api/app/v1/banners/1/image",
      "link": { "type": "category", "category_id": 12, "url": null }
    },
    {
      "id": 2,
      "title": "Bracketi metalici",
      "subtitle": null,
      "cta_text": "Vezi produse",
      "placement": "promo",
      "image_url": null,
      "link": { "type": "none", "category_id": null, "url": null }
    }
  ],
  "quick_categories": [
    { "id": 12, "name": "Bracketi", "icon_url": "/api/app/v1/categories/12/icon" },
    { "id": 13, "name": "Arcuri", "icon_url": null }
  ]
}
```

- [ ] **Step 2: Teste**

`odoo/uportho_app/tests/test_controllers_home.py`:
```python
import base64

from odoo.tests.common import tagged

from .common import AppHttpCase
from .test_controllers_base import load_contract

# PNG 1x1 valid, pentru campuri Image
PNG_1PX = base64.b64decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=')


@tagged('post_install', '-at_install')
class TestControllersHome(AppHttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.category = cls.env['product.public.category'].create({
            'name': 'Bracketi', 'app_home_visible': True, 'app_home_sequence': 1,
            'app_home_icon': base64.b64encode(PNG_1PX)})
        cls.category_no_icon = cls.env['product.public.category'].create({
            'name': 'Arcuri', 'app_home_visible': True, 'app_home_sequence': 2})
        cls.env['product.public.category'].create({'name': 'Ascunsa', 'app_home_visible': False})
        cls.hero = cls.env['uportho.app.banner'].create({
            'name': 'Hero', 'subtitle': 'Sub', 'placement': 'hero', 'sequence': 1,
            'link_type': 'category', 'category_id': cls.category.id,
            'image': base64.b64encode(PNG_1PX)})
        cls.promo = cls.env['uportho.app.banner'].create({
            'name': 'Promo', 'placement': 'promo', 'sequence': 2, 'link_type': 'url',
            'external_url': 'https://uportho.ro/promo'})
        cls.env['uportho.app.banner'].create({'name': 'Arhivat', 'placement': 'hero', 'active': False})

    def test_home_requires_login(self):
        self.assertEqual(self.api_get('/home').status_code, 401)

    def test_home_shape_matches_contract(self):
        self.api_login()
        body = self.api_get('/home').json()
        contract = load_contract('home.json')
        self.assertEqual(set(body.keys()), set(contract.keys()))
        self.assertEqual(set(body['banners'][0].keys()), set(contract['banners'][0].keys()))
        self.assertEqual(set(body['banners'][0]['link'].keys()), set(contract['banners'][0]['link'].keys()))
        self.assertEqual(set(body['quick_categories'][0].keys()), set(contract['quick_categories'][0].keys()))

    def test_home_banners_active_only_in_order_with_links(self):
        self.api_login()
        banners = self.api_get('/home').json()['banners']
        self.assertEqual([b['title'] for b in banners], ['Hero', 'Promo'])
        hero, promo = banners
        self.assertEqual(hero['link'], {'type': 'category', 'category_id': self.category.id, 'url': None})
        self.assertEqual(hero['image_url'], f'/api/app/v1/banners/{self.hero.id}/image')
        self.assertEqual(promo['link'], {'type': 'url', 'category_id': None, 'url': 'https://uportho.ro/promo'})
        self.assertIsNone(promo['image_url'])

    def test_home_quick_categories_visible_only_in_order(self):
        self.api_login()
        categories = self.api_get('/home').json()['quick_categories']
        self.assertEqual([c['name'] for c in categories], ['Bracketi', 'Arcuri'])
        self.assertEqual(categories[0]['icon_url'], f'/api/app/v1/categories/{self.category.id}/icon')
        self.assertIsNone(categories[1]['icon_url'])

    def test_banner_image_is_served_for_logged_user(self):
        self.api_login()
        response = self.api_get(f'/banners/{self.hero.id}/image')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.headers['Content-Type'].startswith('image/'))

    def test_banner_image_requires_login(self):
        self.assertEqual(self.api_get(f'/banners/{self.hero.id}/image').status_code, 401)

    def test_missing_banner_image_is_404(self):
        self.api_login()
        self.assertEqual(self.api_get(f'/banners/{self.promo.id}/image').status_code, 404)
        self.assertEqual(self.api_get('/banners/999999/image').status_code, 404)

    def test_category_icon_is_served(self):
        self.api_login()
        self.assertEqual(self.api_get(f'/categories/{self.category.id}/icon').status_code, 200)
        self.assertEqual(self.api_get(f'/categories/{self.category_no_icon.id}/icon').status_code, 404)
```

`odoo/uportho_app/tests/__init__.py`: adauga `from . import test_controllers_home`.

- [ ] **Step 3: Ruleaza testele, verifica ca pica** (`/home` -> 404).

- [ ] **Step 4: Scrie controllerul**

`odoo/uportho_app/controllers/home.py`:
```python
from odoo import http
from odoo.http import request

from .base import API_PREFIX, ApiError, app_route, json_ok


def _current_website():
    return request.env['website'].get_current_website()


def serialize_banner(banner):
    return {
        'id': banner.id,
        'title': banner.name,
        'subtitle': banner.subtitle or None,
        'cta_text': banner.cta_text or None,
        'placement': banner.placement,
        'image_url': f'{API_PREFIX}/banners/{banner.id}/image' if banner.image else None,
        'link': {
            'type': banner.link_type,
            'category_id': banner.category_id.id if banner.link_type == 'category' else None,
            'url': banner.external_url if banner.link_type == 'url' else None,
        },
    }


def serialize_quick_category(category):
    return {
        'id': category.id,
        'name': category.name,
        'icon_url': f'{API_PREFIX}/categories/{category.id}/icon' if category.app_home_icon else None,
    }


def _image_response(record, field_name):
    if not record.exists() or not record[field_name]:
        raise ApiError(404, 'not_found', 'Imaginea nu exista.')
    stream = request.env['ir.binary']._get_image_stream_from(record, field_name=field_name)
    return stream.get_response()


class AppHome(http.Controller):
    @app_route('/home', methods=['GET'])
    def home(self, **kw):
        website = _current_website()
        banners = request.env['uportho.app.banner']._search_active_now(website)
        categories = request.env['product.public.category']._search_app_home(website)
        return json_ok({
            'banners': [serialize_banner(b) for b in banners],
            'quick_categories': [serialize_quick_category(c) for c in categories],
        })

    @app_route('/banners/<int:banner_id>/image', methods=['GET'])
    def banner_image(self, banner_id, **kw):
        return _image_response(request.env['uportho.app.banner'].browse(banner_id), 'image')

    @app_route('/categories/<int:category_id>/icon', methods=['GET'])
    def category_icon(self, category_id, **kw):
        return _image_response(request.env['product.public.category'].browse(category_id), 'app_home_icon')
```

`odoo/uportho_app/controllers/__init__.py`:
```python
from . import ping
from . import auth
from . import home
```

Daca `ir.binary._get_image_stream_from` are alta semnatura in 18, verifica cu `grep -n "def _get_image_stream_from" /usr/lib/python3/dist-packages/odoo/addons/base/models/ir_binary.py` in container si adapteaza argumentele (in 17/18 e `(record, field_name='raw', filename=None, filename_field='name', mimetype=None, default_mimetype='image/png', placeholder=None, width=0, height=0, crop=False, quality=0)`).

- [ ] **Step 5: Ruleaza testele, verifica ca trec**

```bash
odoo/run-tests.sh
```

Expected: `0 failed, 0 error(s)`.

- [ ] **Step 6: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): GET /home cu bannere si categorii rapide + rute de imagine"
```

### Task 1.8: Model `uportho.app.device` + `/devices`

**Files:**
- Create: `odoo/uportho_app/models/app_device.py`
- Modify: `odoo/uportho_app/models/__init__.py`
- Modify: `odoo/uportho_app/security/ir.model.access.csv`
- Create: `odoo/uportho_app/controllers/devices.py`
- Modify: `odoo/uportho_app/controllers/__init__.py`
- Create: `odoo/uportho_app/tests/test_controllers_devices.py`
- Modify: `odoo/uportho_app/tests/__init__.py`

**Interfaces:**
- Produces: `POST /devices {fcm_token, platform}` -> 201 `{"device": {"id", "platform"}}` (idempotent: acelasi token = aceeasi inregistrare, mutata la userul curent); `DELETE /devices/<fcm_token>` -> 204. Model `uportho.app.device` cu `user_id`, `fcm_token` (unic), `platform` (`ios`/`android`), `last_seen`. Faza 4 il foloseste pentru push.

- [ ] **Step 1: Teste**

`odoo/uportho_app/tests/test_controllers_devices.py`:
```python
from odoo.tests.common import tagged

from .common import AppHttpCase


@tagged('post_install', '-at_install')
class TestControllersDevices(AppHttpCase):
    def test_register_requires_login(self):
        self.assertEqual(self.api_post('/devices', {'fcm_token': 't1', 'platform': 'ios'}).status_code, 401)

    def test_register_creates_device_for_current_user(self):
        self.api_login()
        response = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'ios'})
        self.assertEqual(response.status_code, 201, response.text)
        device = self.env['uportho.app.device'].search([('fcm_token', '=', 't1')])
        self.assertEqual(device.user_id, self.portal_user)
        self.assertEqual(device.platform, 'ios')

    def test_register_same_token_twice_is_idempotent(self):
        self.api_login()
        first = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'android'}).json()['device']['id']
        second = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'android'}).json()['device']['id']
        self.assertEqual(first, second)
        self.assertEqual(self.env['uportho.app.device'].search_count([('fcm_token', '=', 't1')]), 1)

    def test_register_invalid_platform_is_422(self):
        self.api_login()
        response = self.api_post('/devices', {'fcm_token': 't1', 'platform': 'windows'})
        self.assertEqual(response.status_code, 422)

    def test_delete_removes_device(self):
        self.api_login()
        self.api_post('/devices', {'fcm_token': 't1', 'platform': 'ios'})
        response = self.api_delete('/devices/t1')
        self.assertEqual(response.status_code, 204)
        self.assertEqual(self.env['uportho.app.device'].search_count([('fcm_token', '=', 't1')]), 0)

    def test_delete_unknown_token_is_204(self):
        self.api_login()
        self.assertEqual(self.api_delete('/devices/nope').status_code, 204)
```

`odoo/uportho_app/tests/__init__.py`: adauga `from . import test_controllers_devices`.

- [ ] **Step 2: Ruleaza testele, verifica ca pica.**

- [ ] **Step 3: Model + controller**

`odoo/uportho_app/models/app_device.py`:
```python
from odoo import fields, models


class AppDevice(models.Model):
    _name = 'uportho.app.device'
    _description = 'Dispozitiv (token FCM) al unui utilizator al aplicatiei'

    user_id = fields.Many2one('res.users', required=True, ondelete='cascade', index=True)
    fcm_token = fields.Char(required=True, index=True)
    platform = fields.Selection([('ios', 'iOS'), ('android', 'Android')], required=True)
    last_seen = fields.Datetime(default=fields.Datetime.now)

    _sql_constraints = [
        ('fcm_token_unique', 'unique(fcm_token)', 'Token-ul FCM trebuie sa fie unic.'),
    ]

    def _register(self, user, fcm_token, platform):
        """Creeaza sau actualizeaza inregistrarea pentru token; un token apartine
        intotdeauna ultimului utilizator logat pe acel dispozitiv."""
        device = self.sudo().search([('fcm_token', '=', fcm_token)], limit=1)
        values = {'user_id': user.id, 'platform': platform, 'last_seen': fields.Datetime.now()}
        if device:
            device.write(values)
            return device
        return self.sudo().create(dict(values, fcm_token=fcm_token))
```

Adauga in `models/__init__.py`: `from . import app_device`.

`security/ir.model.access.csv` — adauga:
```csv
access_app_device_admin,uportho.app.device admin,model_uportho_app_device,base.group_system,1,1,1,1
```
(Utilizatorii portal nu au acces direct la model; controllerul foloseste `sudo()` si leaga mereu dispozitivul de `request.env.user`.)

`odoo/uportho_app/controllers/devices.py`:
```python
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
        device = request.env['uportho.app.device']._register(request.env.user, token, platform)
        return json_ok({'device': {'id': device.id, 'platform': device.platform}}, status=201)

    @app_route('/devices/<string:fcm_token>', methods=['DELETE'])
    def unregister(self, fcm_token, **kw):
        request.env['uportho.app.device'].sudo().search([
            ('fcm_token', '=', fcm_token), ('user_id', '=', request.env.user.id)]).unlink()
        return request.make_response('', status=204)
```

`controllers/__init__.py`: adauga `from . import devices`.

- [ ] **Step 4: Ruleaza testele, verifica ca trec.**

- [ ] **Step 5: Commit**

```bash
git add odoo/uportho_app
git commit -m "feat(odoo): inregistrare dispozitive FCM (POST/DELETE /devices)"
```

### Task 1.9: Deploy pe odoo.sh (branch dev) si date initiale — ACTIUNE CU CONFIRMARE

Acest task modifica Odoo-ul de pe odoo.sh. **Fiecare pas marcat (CONFIRMARE) se executa doar dupa ce Mihai spune explicit "da" pentru acel pas, in chat.**

**Files:** niciunul in acest repo (modulul se copiaza in repo-ul odoo.sh).

- [ ] **Step 1:** Cloneaza local repo-ul odoo.sh al proiectului (URL-ul din odoo.sh > Settings > Repository) si creeaza branch `feature/uportho-app` din branch-ul de dev.
- [ ] **Step 2:** Copiaza `odoo/uportho_app/` in radacina repo-ului odoo.sh (sau in folderul de addons folosit acolo). Nu copia `docker-compose.yml`, `odoo.conf`, `run-tests.sh`.
- [ ] **Step 3 (CONFIRMARE):** `git push` pe branch-ul `feature/uportho-app`. odoo.sh construieste un build de dev si ruleaza testele modulului. Verifica log-ul build-ului: `0 failed`.
- [ ] **Step 4 (CONFIRMARE):** Pe build-ul de dev, instaleaza modulul `uportho_app` din Apps si creeaza 1-2 bannere + bifeaza 3-4 categorii ca `app_home_visible`.
- [ ] **Step 5:** Verifica de pe Mac contra build-ului de dev (URL-ul lui din odoo.sh), cu un cont de client de test:

```bash
BASE=https://<build-dev>.dev.odoo.com
curl -s -c /tmp/c.txt -X POST "$BASE/api/app/v1/auth/login" -H 'Content-Type: application/json' -H 'X-UpOrtho-App: 1' -d '{"login":"<email>","password":"<parola>"}'
curl -s -b /tmp/c.txt "$BASE/api/app/v1/home" | head -c 800
```

Expected: JSON cu `banners` si `quick_categories` populate.

- [ ] **Step 6:** Retragerea Studio (`x_app_banner`) se face **dupa Faza 1 completa, pe productie, cu confirmare separata**. Pana atunci nu se atinge.

---

## FAZA 1 — Aplicatia Flutter

### Task 1.10: Proiect Flutter + dependinte + configurare

**Files:**
- Create: `app/` (generat de `flutter create`)
- Create: `app/lib/config.dart`
- Modify: `app/pubspec.yaml`
- Create: `app/analysis_options.yaml` (suprascrie pe cel generat)

**Interfaces:**
- Produces: `AppConfig.apiBaseUrl` (String), citit din `--dart-define=API_BASE_URL=...`, default `http://localhost:8069`.

- [ ] **Step 1: Creeaza proiectul**

```bash
cd /Users/mihaim/Desktop/ClaudeC/AplicatieUp
flutter create --org ro.uportho --project-name uportho_app --platforms ios,android app
cd app
flutter pub add flutter_riverpod go_router dio freezed_annotation json_annotation flutter_secure_storage cached_network_image
flutter pub add --dev build_runner freezed json_serializable
```

- [ ] **Step 2: Config**

`app/lib/config.dart`:
```dart
/// Configurare de build. `API_BASE_URL` vine din `--dart-define`; pe emulatorul
/// Android `localhost` al Mac-ului este `10.0.2.2`, pe simulatorul iOS este `localhost`.
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8069',
  );
}
```

- [ ] **Step 3: Analiza stricta**

`app/analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  errors:
    missing_required_param: error
    missing_return: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
```

- [ ] **Step 4: Ruleaza pe ambele platforme** (verifica toolchain-ul, nu functionalitate)

```bash
cd app && flutter analyze && flutter test
open -a Simulator && flutter run -d iphone --dart-define=API_BASE_URL=http://localhost:8069
# intr-un alt terminal, dupa ce emulatorul e pornit din Android Studio:
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8069
```

Expected: app-ul demo Flutter porneste pe ambele.

- [ ] **Step 5: Commit**

```bash
cd /Users/mihaim/Desktop/ClaudeC/AplicatieUp
git add app .gitignore
git commit -m "chore(app): proiect Flutter uportho_app cu dependintele de baza"
```

### Task 1.11: Transport HTTP, client API, erori, sesiune

**Files:**
- Create: `app/lib/api/api_transport.dart`
- Create: `app/lib/api/dio_transport.dart`
- Create: `app/lib/api/api_exception.dart`
- Create: `app/lib/api/session_store.dart`
- Create: `app/lib/api/api_client.dart`
- Create: `app/test/api/fake_transport.dart`
- Create: `app/test/api/api_client_test.dart`

**Interfaces:**
- Produces:
  - `abstract class ApiTransport { Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}); }`
  - `class ApiResponse { final int status; final Map<String, dynamic>? json; final String? sessionCookie; }`
  - `abstract class SessionStore { Future<String?> read(); Future<void> write(String); Future<void> clear(); }` + `SecureSessionStore`, `InMemorySessionStore`
  - `class ApiException implements Exception { final int status; final String code; final String message; final Map<String, dynamic> details; }`
  - `class ApiClient { ApiClient(ApiTransport, SessionStore); Future<Map<String, dynamic>> get(path); Future<Map<String, dynamic>> post(path, {body}); Future<void> delete(path); Future<Map<String, dynamic>> login(login, password); Future<void> logout(); Future<bool> hasSession(); String absoluteUrl(String path); }`
  - `DioTransport(baseUrl, SessionStore)` adauga `X-UpOrtho-App: 1` si `Cookie: session_id=...`.

- [ ] **Step 1: Teste**

`app/test/api/fake_transport.dart`:
```dart
import 'package:uportho_app/api/api_transport.dart';

class RecordedCall {
  RecordedCall(this.method, this.path, this.body);
  final String method;
  final String path;
  final Map<String, dynamic>? body;
}

/// Transport de test: raspunsuri pre-inregistrate pe (metoda, cale), plus jurnalul apelurilor.
class FakeTransport implements ApiTransport {
  final Map<String, ApiResponse> responses = {};
  final List<RecordedCall> calls = [];

  void when(String method, String path, ApiResponse response) {
    responses['$method $path'] = response;
  }

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) async {
    calls.add(RecordedCall(method, path, body));
    final response = responses['$method $path'];
    if (response == null) {
      throw StateError('Fara raspuns inregistrat pentru $method $path');
    }
    return response;
  }
}
```

`app/test/api/api_client_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';

import 'fake_transport.dart';

void main() {
  late FakeTransport transport;
  late InMemorySessionStore store;
  late ApiClient client;

  setUp(() {
    transport = FakeTransport();
    store = InMemorySessionStore();
    client = ApiClient(transport, store, baseUrl: 'https://example.test');
  });

  test('get returns json body on 200', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: {'banners': []}));
    final body = await client.get('/home');
    expect(body['banners'], isEmpty);
  });

  test('error response becomes ApiException with code and message', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 401, json: {
      'error': {'code': 'unauthorized', 'message': 'Trebuie sa te autentifici.', 'details': {}}
    }));
    expect(
      () => client.get('/home'),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 401)
          .having((e) => e.code, 'code', 'unauthorized')
          .having((e) => e.message, 'message', 'Trebuie sa te autentifici.')),
    );
  });

  test('401 clears stored session', () async {
    await store.write('abc');
    transport.when('GET', '/api/app/v1/me', ApiResponse(status: 401, json: {
      'error': {'code': 'unauthorized', 'message': 'x', 'details': {}}
    }));
    await expectLater(client.get('/me'), throwsA(isA<ApiException>()));
    expect(await store.read(), isNull);
  });

  test('non-json 500 becomes internal_error', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 500, json: null));
    expect(
      () => client.get('/home'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'internal_error')),
    );
  });

  test('login stores session cookie and returns body', () async {
    transport.when('POST', '/api/app/v1/auth/login', ApiResponse(
      status: 200,
      json: {'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}},
      sessionCookie: 'sess123',
    ));
    final body = await client.login('a@b.ro', 'pw');
    expect(body['user']['id'], 1);
    expect(await store.read(), 'sess123');
    expect(transport.calls.single.body, {'login': 'a@b.ro', 'password': 'pw'});
  });

  test('logout calls endpoint and clears session even if it fails', () async {
    await store.write('abc');
    transport.when('POST', '/api/app/v1/auth/logout', ApiResponse(status: 500, json: null));
    await client.logout();
    expect(await store.read(), isNull);
  });

  test('hasSession reflects store', () async {
    expect(await client.hasSession(), isFalse);
    await store.write('abc');
    expect(await client.hasSession(), isTrue);
  });

  test('absoluteUrl joins base and relative path', () {
    expect(client.absoluteUrl('/api/app/v1/banners/1/image'), 'https://example.test/api/app/v1/banners/1/image');
  });
}
```

- [ ] **Step 2: Ruleaza testele, verifica ca pica** (`flutter test test/api` — erori de import).

- [ ] **Step 3: Implementare**

`app/lib/api/api_transport.dart`:
```dart
/// Raspuns brut de la server: cod HTTP, corp JSON (daca a putut fi decodat) si
/// valoarea cookie-ului `session_id` daca serverul a trimis unul nou.
class ApiResponse {
  const ApiResponse({required this.status, this.json, this.sessionCookie});
  final int status;
  final Map<String, dynamic>? json;
  final String? sessionCookie;
}

/// Singurul punct prin care aplicatia trimite HTTP. Implementarea reala foloseste Dio;
/// testele folosesc un fake.
abstract class ApiTransport {
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body});
}
```

`app/lib/api/api_exception.dart`:
```dart
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.details = const {},
  });

  final int status;
  final String code;
  final String message;
  final Map<String, dynamic> details;

  bool get isUnauthorized => status == 401;

  @override
  String toString() => 'ApiException($status $code: $message)';
}
```

`app/lib/api/session_store.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String sessionId);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();
  static const _key = 'odoo_session_id';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String sessionId) => _storage.write(key: _key, value: sessionId);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class InMemorySessionStore implements SessionStore {
  String? _value;
  @override
  Future<String?> read() async => _value;
  @override
  Future<void> write(String sessionId) async => _value = sessionId;
  @override
  Future<void> clear() async => _value = null;
}
```

`app/lib/api/api_client.dart`:
```dart
import 'api_exception.dart';
import 'api_transport.dart';
import 'session_store.dart';

/// Clientul contractului /api/app/v1. Nu stie de Odoo; stie doar forma raspunsurilor.
class ApiClient {
  ApiClient(this._transport, this._sessions, {required this.baseUrl});

  static const prefix = '/api/app/v1';
  final ApiTransport _transport;
  final SessionStore _sessions;
  final String baseUrl;

  Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<void> delete(String path) async {
    await _request('DELETE', path);
  }

  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await _transport.send('POST', '$prefix/auth/login',
        body: {'login': login, 'password': password});
    final body = _bodyOrThrow(response);
    if (response.sessionCookie != null) {
      await _sessions.write(response.sessionCookie!);
    }
    return body;
  }

  Future<void> logout() async {
    try {
      await _transport.send('POST', '$prefix/auth/logout');
    } catch (_) {
      // Sesiunea locala se sterge oricum; serverul o expira singur.
    } finally {
      await _sessions.clear();
    }
  }

  Future<bool> hasSession() async => (await _sessions.read()) != null;

  String absoluteUrl(String path) => path.startsWith('http') ? path : '$baseUrl$path';

  Future<Map<String, dynamic>> _request(String method, String path, {Map<String, dynamic>? body}) async {
    final response = await _transport.send(method, '$prefix$path', body: body);
    if (response.status == 401) {
      await _sessions.clear();
    }
    return _bodyOrThrow(response);
  }

  Map<String, dynamic> _bodyOrThrow(ApiResponse response) {
    if (response.status >= 200 && response.status < 300) {
      return response.json ?? const {};
    }
    final error = response.json?['error'];
    if (error is Map<String, dynamic>) {
      throw ApiException(
        status: response.status,
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String? ?? 'Eroare necunoscuta.',
        details: (error['details'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
    throw ApiException(
      status: response.status,
      code: response.status == 401 ? 'unauthorized' : 'internal_error',
      message: 'A aparut o eroare. Incearca din nou.',
    );
  }
}
```

`app/lib/api/dio_transport.dart`:
```dart
import 'package:dio/dio.dart';

import 'api_transport.dart';
import 'session_store.dart';

/// Transport real: Dio + header X-UpOrtho-App + cookie de sesiune din SessionStore.
class DioTransport implements ApiTransport {
  DioTransport(String baseUrl, this._sessions)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {'X-UpOrtho-App': '1', 'Accept': 'application/json'},
          validateStatus: (_) => true, // codurile de eroare le interpreteaza ApiClient
          responseType: ResponseType.json,
        ));

  final Dio _dio;
  final SessionStore _sessions;

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) async {
    final sessionId = await _sessions.read();
    final response = await _dio.request<dynamic>(
      path,
      data: body,
      options: Options(
        method: method,
        headers: {if (sessionId != null) 'Cookie': 'session_id=$sessionId'},
        contentType: body == null ? null : Headers.jsonContentType,
      ),
    );
    return ApiResponse(
      status: response.statusCode ?? 0,
      json: response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null,
      sessionCookie: _extractSessionId(response.headers['set-cookie']),
    );
  }

  static String? _extractSessionId(List<String>? setCookies) {
    if (setCookies == null) return null;
    for (final cookie in setCookies) {
      final match = RegExp(r'(?:^|;\s*)session_id=([^;]+)').firstMatch(cookie);
      if (match != null) return match.group(1);
    }
    return null;
  }
}
```

- [ ] **Step 4: Ruleaza testele, verifica ca trec**

```bash
cd app && flutter test test/api && flutter analyze
```

Expected: toate verzi, `No issues found!`.

- [ ] **Step 5: Commit**

```bash
git add app/lib/api app/test/api
git commit -m "feat(app): client API v1 cu transport Dio, sesiune securizata si erori standard"
```

### Task 1.12: Modele din contract (freezed) + teste de decodare

**Files:**
- Create: `app/test/contract/login.json`, `me.json`, `home.json`, `error.json` (copii identice din `odoo/uportho_app/contract/`)
- Create: `app/lib/api/models/user_profile.dart`
- Create: `app/lib/api/models/banner.dart`
- Create: `app/lib/api/models/home_category.dart`
- Create: `app/lib/api/models/home_response.dart`
- Create: `app/lib/api/models/price.dart`
- Create: `app/test/api/models_test.dart`
- Create: `app/tool/sync_contract.sh`

**Interfaces:**
- Produces: `UserProfile(id, name, email, partnerId)`, `BannerLink(type, categoryId, url)`, `AppBanner(id, title, subtitle, ctaText, placement, imageUrl, link)` (numele `Banner` e luat de widget-ul Material), `HomeCategory(id, name, iconUrl)`, `HomeResponse(banners, quickCategories)`, `Price(amount, currency, formatted, withVat, listAmount, discountPct)` — toate cu `fromJson`.

- [ ] **Step 1: Script de sincronizare a fixture-urilor si copiere**

`app/tool/sync_contract.sh`:
```bash
#!/usr/bin/env bash
# Copiaza fixture-urile de contract din modulul Odoo in testele Flutter. Sursa de adevar e modulul.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf test/contract && mkdir -p test/contract
cp ../odoo/uportho_app/contract/*.json test/contract/
echo "contract sincronizat: $(ls test/contract | tr '\n' ' ')"
```

```bash
chmod +x app/tool/sync_contract.sh && app/tool/sync_contract.sh
```

- [ ] **Step 2: Teste**

`app/test/api/models_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/home_response.dart';
import 'package:uportho_app/api/models/price.dart';
import 'package:uportho_app/api/models/user_profile.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/contract/$name').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('UserProfile decodes login.json', () {
    final user = UserProfile.fromJson(fixture('login.json')['user'] as Map<String, dynamic>);
    expect(user.id, 42);
    expect(user.email, 'app.test@uportho.ro');
    expect(user.partnerId, 77);
  });

  test('HomeResponse decodes home.json with nullable fields', () {
    final home = HomeResponse.fromJson(fixture('home.json'));
    expect(home.banners, hasLength(2));
    final hero = home.banners.first;
    expect(hero.placement, BannerPlacement.hero);
    expect(hero.link.type, BannerLinkType.category);
    expect(hero.link.categoryId, 12);
    expect(hero.imageUrl, '/api/app/v1/banners/1/image');
    final promo = home.banners.last;
    expect(promo.subtitle, isNull);
    expect(promo.imageUrl, isNull);
    expect(promo.link.type, BannerLinkType.none);
    expect(home.quickCategories.last.iconUrl, isNull);
  });

  test('unknown placement or link type falls back safely', () {
    final json = fixture('home.json');
    (json['banners'] as List)[0]['placement'] = 'sidebar';
    (json['banners'] as List)[0]['link']['type'] = 'deeplink';
    final home = HomeResponse.fromJson(json);
    expect(home.banners.first.placement, BannerPlacement.promo);
    expect(home.banners.first.link.type, BannerLinkType.none);
  });

  test('Price decodes and exposes formatted only', () {
    final price = Price.fromJson({
      'amount': 149.9, 'currency': 'RON', 'formatted': '149,90 lei',
      'with_vat': true, 'list_amount': 189.9, 'discount_pct': 21,
    });
    expect(price.formatted, '149,90 lei');
    expect(price.discountPct, 21);
    expect(price.listAmount, 189.9);
  });
}
```

- [ ] **Step 3: Ruleaza, verifica ca pica.**

- [ ] **Step 4: Modele**

`app/lib/api/models/user_profile.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String name,
    required String email,
    @JsonKey(name: 'partner_id') required int partnerId,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
```

`app/lib/api/models/banner.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

/// Valorile necunoscute cad pe `promo` (afisare in grila, niciodata ca hero).
@JsonEnum(valueField: 'value')
enum BannerPlacement {
  hero('hero'),
  promo('promo');

  const BannerPlacement(this.value);
  final String value;
}

/// Valorile necunoscute cad pe `none` (banner fara actiune, nu link gresit).
@JsonEnum(valueField: 'value')
enum BannerLinkType {
  category('category'),
  url('url'),
  none('none');

  const BannerLinkType(this.value);
  final String value;
}

@freezed
class BannerLink with _$BannerLink {
  const factory BannerLink({
    @JsonKey(unknownEnumValue: BannerLinkType.none) required BannerLinkType type,
    @JsonKey(name: 'category_id') int? categoryId,
    String? url,
  }) = _BannerLink;

  factory BannerLink.fromJson(Map<String, dynamic> json) => _$BannerLinkFromJson(json);
}

@freezed
class AppBanner with _$AppBanner {
  const factory AppBanner({
    required int id,
    required String title,
    String? subtitle,
    @JsonKey(name: 'cta_text') String? ctaText,
    @JsonKey(unknownEnumValue: BannerPlacement.promo) required BannerPlacement placement,
    @JsonKey(name: 'image_url') String? imageUrl,
    required BannerLink link,
  }) = _AppBanner;

  factory AppBanner.fromJson(Map<String, dynamic> json) => _$AppBannerFromJson(json);
}
```

`app/lib/api/models/home_category.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_category.freezed.dart';
part 'home_category.g.dart';

@freezed
class HomeCategory with _$HomeCategory {
  const factory HomeCategory({
    required int id,
    required String name,
    @JsonKey(name: 'icon_url') String? iconUrl,
  }) = _HomeCategory;

  factory HomeCategory.fromJson(Map<String, dynamic> json) => _$HomeCategoryFromJson(json);
}
```

`app/lib/api/models/home_response.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'banner.dart';
import 'home_category.dart';

export 'banner.dart';
export 'home_category.dart';

part 'home_response.freezed.dart';
part 'home_response.g.dart';

@freezed
class HomeResponse with _$HomeResponse {
  const factory HomeResponse({
    @Default([]) List<AppBanner> banners,
    @JsonKey(name: 'quick_categories') @Default([]) List<HomeCategory> quickCategories,
  }) = _HomeResponse;

  factory HomeResponse.fromJson(Map<String, dynamic> json) => _$HomeResponseFromJson(json);
}
```

`app/lib/api/models/price.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price.freezed.dart';
part 'price.g.dart';

/// Pret gata calculat de server. Aplicatia afiseaza DOAR `formatted`; `amount` exista
/// pentru comparatii (ex. "e reducere?"), niciodata pentru calcule.
@freezed
class Price with _$Price {
  const factory Price({
    required double amount,
    required String currency,
    required String formatted,
    @JsonKey(name: 'with_vat') @Default(true) bool withVat,
    @JsonKey(name: 'list_amount') double? listAmount,
    @JsonKey(name: 'discount_pct') int? discountPct,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}
```

- [ ] **Step 5: Genereaza codul si ruleaza testele**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter test test/api && flutter analyze
```

Expected: verde. Fisierele `*.freezed.dart` si `*.g.dart` se comit (build-ul nu depinde de generare la CI).

- [ ] **Step 6: Commit**

```bash
git add app/lib/api/models app/test app/tool
git commit -m "feat(app): modele v1 generate din fixture-urile de contract"
```

### Task 1.13: Design system — culori, tipografie, tema, componente de Acasa

**Files:**
- Create: `app/lib/design_system/colors.dart`
- Create: `app/lib/design_system/typography.dart`
- Create: `app/lib/design_system/theme.dart`
- Create: `app/lib/design_system/widgets/banner_card.dart`
- Create: `app/lib/design_system/widgets/category_chip.dart`
- Create: `app/lib/design_system/widgets/section_header.dart`
- Create: `app/test/design_system/banner_card_test.dart`
- Create: `app/test/design_system/category_chip_test.dart`

**Interfaces:**
- Produces: `AppColors` (primary `#6B40A1`, primaryDark `#4E2C7A`, accent `#F28C28`, background `#F5F5F7`, surface `#FFFFFF`, textPrimary `#1C1C1E`, textSecondary `#6E6E73`, success `#2E9E5B`, danger `#D93B3B`), `AppTypography`, `buildAppTheme()`, `BannerCard({banner, imageUrl, onTap, hero})`, `CategoryChip({name, iconUrl, onTap})`, `SectionHeader(title)`.

- [ ] **Step 1: Teste widget**

`app/test/design_system/banner_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/banner.dart';
import 'package:uportho_app/design_system/widgets/banner_card.dart';

void main() {
  const banner = AppBanner(
    id: 1, title: 'Titlu', subtitle: 'Sub', ctaText: 'Vezi', placement: BannerPlacement.hero,
    imageUrl: null, link: BannerLink(type: BannerLinkType.none),
  );

  testWidgets('shows title, subtitle and cta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BannerCard(banner: banner, imageUrl: null))));
    expect(find.text('Titlu'), findsOneWidget);
    expect(find.text('Sub'), findsOneWidget);
    expect(find.text('Vezi'), findsOneWidget);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: BannerCard(banner: banner, imageUrl: null, onTap: () => tapped = true))));
    await tester.tap(find.byType(BannerCard));
    expect(tapped, isTrue);
  });

  testWidgets('hides subtitle and cta when null', (tester) async {
    const bare = AppBanner(id: 2, title: 'T', placement: BannerPlacement.promo, link: BannerLink(type: BannerLinkType.none));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BannerCard(banner: bare, imageUrl: null))));
    expect(find.text('T'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
```

`app/test/design_system/category_chip_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/category_chip.dart';

void main() {
  testWidgets('shows name and placeholder icon without iconUrl', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CategoryChip(name: 'Bracketi', iconUrl: null))));
    expect(find.text('Bracketi'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CategoryChip(name: 'X', iconUrl: null, onTap: () => tapped = true))));
    await tester.tap(find.text('X'));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Ruleaza, verifica ca pica.**

- [ ] **Step 3: Implementare**

`app/lib/design_system/colors.dart`:
```dart
import 'package:flutter/material.dart';

/// Paleta UpOrtho: mov de brand (ca pe site), accent portocaliu pentru oferte/etichete.
abstract final class AppColors {
  static const primary = Color(0xFF6B40A1);
  static const primaryDark = Color(0xFF4E2C7A);
  static const accent = Color(0xFFF28C28);
  static const background = Color(0xFFF5F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6E6E73);
  static const success = Color(0xFF2E9E5B);
  static const danger = Color(0xFFD93B3B);
  static const heroGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

`app/lib/design_system/typography.dart`:
```dart
import 'package:flutter/material.dart';

import 'colors.dart';

abstract final class AppTypography {
  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2);
  static const sectionTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const body = TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.35);
  static const caption = TextStyle(fontSize: 13, color: AppColors.textSecondary);
  static const bannerTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15);
  static const bannerSubtitle = TextStyle(fontSize: 14, color: Colors.white70, height: 1.3);
}
```

`app/lib/design_system/theme.dart`:
```dart
import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, surface: AppColors.surface);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: Color(0x226B40A1),
    ),
  );
}
```

`app/lib/design_system/widgets/banner_card.dart`:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/models/banner.dart';
import '../colors.dart';
import '../typography.dart';

/// Card de banner: imagine (daca exista) peste gradient de brand, titlu/subtitlu/CTA.
/// `hero` = format lat, inaltime mare; altfel format de grila (promo).
class BannerCard extends StatelessWidget {
  const BannerCard({super.key, required this.banner, required this.imageUrl, this.onTap, this.hero = false});

  final AppBanner banner;
  /// URL absolut (clientul API il construieste); null = fara imagine.
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: hero ? 16 / 9 : 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroGradient)),
              if (imageUrl != null)
                CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => const SizedBox()),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x99000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banner.title, style: AppTypography.bannerTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(banner.subtitle!, style: AppTypography.bannerSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    if (banner.ctaText != null) ...[
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                        child: Text(banner.ctaText!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`app/lib/design_system/widgets/category_chip.dart`:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Categorie rapida de pe Acasa: iconita rotunda + nume, pentru lista orizontala.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.name, required this.iconUrl, this.onTap});

  final String name;
  final String? iconUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: iconUrl == null
                  ? const Icon(Icons.grid_view_rounded, color: AppColors.primary)
                  : CachedNetworkImage(imageUrl: iconUrl!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            Text(name, style: AppTypography.caption, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
```

`app/lib/design_system/widgets/section_header.dart`:
```dart
import 'package:flutter/material.dart';

import '../typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title, style: AppTypography.sectionTitle),
    );
  }
}
```

- [ ] **Step 4: Ruleaza testele**

```bash
cd app && flutter test test/design_system && flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add app/lib/design_system app/test/design_system
git commit -m "feat(app): design system (culori, tipografie, tema) + BannerCard, CategoryChip"
```

### Task 1.14: Feature auth — repository, controller Riverpod, ecran login

**Files:**
- Create: `app/lib/features/auth/auth_repository.dart`
- Create: `app/lib/features/auth/auth_controller.dart`
- Create: `app/lib/features/auth/login_screen.dart`
- Create: `app/lib/providers.dart` (provideri globali: `apiClientProvider`)
- Create: `app/test/features/auth/auth_controller_test.dart`

**Interfaces:**
- Produces: `apiClientProvider` (`Provider<ApiClient>`), `AuthRepository(ApiClient)` cu `Future<UserProfile?> restore()`, `Future<UserProfile> login(login, password)`, `Future<void> logout()`; `authControllerProvider` (`AsyncNotifierProvider<AuthController, AuthState>`), `AuthState` = `unknown | signedOut | signedIn(UserProfile)`; `LoginScreen`.

- [ ] **Step 1: Teste**

`app/test/features/auth/auth_controller_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

const userJson = {'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}};

void main() {
  late FakeTransport transport;
  late InMemorySessionStore store;
  late ProviderContainer container;

  setUp(() {
    transport = FakeTransport();
    store = InMemorySessionStore();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  test('without stored session starts signedOut', () async {
    final state = await container.read(authControllerProvider.future);
    expect(state, const AuthState.signedOut());
  });

  test('with stored session restores profile via /me', () async {
    await store.write('sess');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: userJson));
    final state = await container.read(authControllerProvider.future);
    expect(state, isA<SignedIn>().having((s) => s.user.email, 'email', 'a@b.ro'));
  });

  test('with expired session (/me 401) starts signedOut', () async {
    await store.write('sess');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 401, json: {
      'error': {'code': 'unauthorized', 'message': 'x', 'details': {}}
    }));
    final state = await container.read(authControllerProvider.future);
    expect(state, const AuthState.signedOut());
  });

  test('login success moves to signedIn', () async {
    await container.read(authControllerProvider.future);
    transport.when('POST', '/api/app/v1/auth/login', const ApiResponse(status: 200, json: userJson, sessionCookie: 's'));
    await container.read(authControllerProvider.notifier).login('a@b.ro', 'pw');
    expect(container.read(authControllerProvider).value, isA<SignedIn>());
  });

  test('login failure exposes error and stays signedOut', () async {
    await container.read(authControllerProvider.future);
    transport.when('POST', '/api/app/v1/auth/login', const ApiResponse(status: 401, json: {
      'error': {'code': 'invalid_credentials', 'message': 'Email sau parola gresite.', 'details': {}}
    }));
    await container.read(authControllerProvider.notifier).login('a@b.ro', 'bad');
    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(container.read(authControllerProvider.notifier).lastErrorMessage, 'Email sau parola gresite.');
  });

  test('logout moves to signedOut and clears session', () async {
    await store.write('sess');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: userJson));
    await container.read(authControllerProvider.future);
    transport.when('POST', '/api/app/v1/auth/logout', const ApiResponse(status: 204));
    await container.read(authControllerProvider.notifier).logout();
    expect(container.read(authControllerProvider).value, const AuthState.signedOut());
    expect(await store.read(), isNull);
  });
}
```

- [ ] **Step 2: Ruleaza, verifica ca pica.**

- [ ] **Step 3: Implementare**

`app/lib/providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/dio_transport.dart';
import 'api/session_store.dart';
import 'config.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return ApiClient(DioTransport(AppConfig.apiBaseUrl, store), store, baseUrl: AppConfig.apiBaseUrl);
});
```

`app/lib/features/auth/auth_repository.dart`:
```dart
import '../../api/api_client.dart';
import '../../api/api_exception.dart';
import '../../api/models/user_profile.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  /// Profilul userului daca exista o sesiune valida, altfel null (sesiune lipsa sau expirata).
  Future<UserProfile?> restore() async {
    if (!await _api.hasSession()) return null;
    try {
      final body = await _api.get('/me');
      return UserProfile.fromJson(body['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null;
      rethrow;
    }
  }

  Future<UserProfile> login(String login, String password) async {
    final body = await _api.login(login, password);
    return UserProfile.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<void> logout() => _api.logout();
}
```

`app/lib/features/auth/auth_controller.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/user_profile.dart';
import '../../providers.dart';
import 'auth_repository.dart';

sealed class AuthState {
  const AuthState();
  const factory AuthState.signedOut() = SignedOut;
  const factory AuthState.signedIn(UserProfile user) = SignedIn;
}

class SignedOut extends AuthState {
  const SignedOut();
  @override
  bool operator ==(Object other) => other is SignedOut;
  @override
  int get hashCode => 0;
}

class SignedIn extends AuthState {
  const SignedIn(this.user);
  final UserProfile user;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  String? lastErrorMessage;

  @override
  Future<AuthState> build() async {
    final user = await ref.read(authRepositoryProvider).restore();
    return user == null ? const AuthState.signedOut() : AuthState.signedIn(user);
  }

  Future<void> login(String login, String password) async {
    lastErrorMessage = null;
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).login(login.trim(), password);
      state = AsyncData(AuthState.signedIn(user));
    } on ApiException catch (e, st) {
      lastErrorMessage = e.message;
      state = AsyncError(e, st);
    } catch (e, st) {
      lastErrorMessage = 'Nu s-a putut contacta serverul. Verifica conexiunea.';
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.signedOut());
  }
}
```

`app/lib/features/auth/login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = auth.hasError ? ref.read(authControllerProvider.notifier).lastErrorMessage : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('UpOrtho', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(height: 6),
              const Text('Intra in contul tau de client', style: AppTypography.caption),
              const SizedBox(height: 28),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Parola'),
                onSubmitted: (_) => _submit(),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Autentificare'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introdu email si parola.')));
      return;
    }
    ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
  }
}
```

- [ ] **Step 4: Ruleaza testele**

```bash
cd app && flutter test && flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add app/lib/providers.dart app/lib/features/auth app/test/features/auth
git commit -m "feat(app): autentificare (repository, controller Riverpod, ecran login)"
```

### Task 1.15: Feature home — repository, controller, ecran Acasa

**Files:**
- Create: `app/lib/features/home/home_repository.dart`
- Create: `app/lib/features/home/home_controller.dart`
- Create: `app/lib/features/home/home_screen.dart`
- Create: `app/test/features/home/home_controller_test.dart`

**Interfaces:**
- Produces: `HomeRepository(ApiClient)` cu `Future<HomeResponse> fetch()`; `homeControllerProvider` (`AsyncNotifierProvider<HomeController, HomeResponse>`) cu `refresh()`; `HomeScreen`. Tap pe banner cu link `url` deschide URL-ul in browser (Faza 2 aduce navigarea la categorie).

- [ ] **Step 1: Teste**

`app/test/features/home/home_controller_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/banner.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/home/home_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  Map<String, dynamic> homeFixture() =>
      jsonDecode(File('test/contract/home.json').readAsStringSync()) as Map<String, dynamic>;

  setUp(() {
    transport = FakeTransport();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  test('loads home from /home and splits hero vs promo', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));
    final home = await container.read(homeControllerProvider.future);
    expect(home.banners.where((b) => b.placement == BannerPlacement.hero), hasLength(1));
    expect(home.banners.where((b) => b.placement == BannerPlacement.promo), hasLength(1));
    expect(home.quickCategories, hasLength(2));
  });

  test('api error surfaces as AsyncError with ApiException', () async {
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 500, json: null));
    await expectLater(container.read(homeControllerProvider.future), throwsA(isA<ApiException>()));
  });

  test('refresh refetches', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));
    await container.read(homeControllerProvider.future);
    await container.read(homeControllerProvider.notifier).refresh();
    expect(transport.calls.where((c) => c.path == '/api/app/v1/home'), hasLength(2));
  });
}
```

- [ ] **Step 2: Ruleaza, verifica ca pica.**

- [ ] **Step 3: Implementare**

`app/lib/features/home/home_repository.dart`:
```dart
import '../../api/api_client.dart';
import '../../api/models/home_response.dart';

class HomeRepository {
  HomeRepository(this._api);
  final ApiClient _api;

  Future<HomeResponse> fetch() async => HomeResponse.fromJson(await _api.get('/home'));
}
```

`app/lib/features/home/home_controller.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/home_response.dart';
import '../../providers.dart';
import 'home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => HomeRepository(ref.watch(apiClientProvider)));

final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeResponse>(HomeController.new);

class HomeController extends AsyncNotifier<HomeResponse> {
  @override
  Future<HomeResponse> build() => ref.read(homeRepositoryProvider).fetch();

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeRepositoryProvider).fetch());
  }
}
```

`app/lib/features/home/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_exception.dart';
import '../../api/models/home_response.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/banner_card.dart';
import '../../design_system/widgets/category_chip.dart';
import '../../design_system/widgets/section_header.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final api = ref.watch(apiClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UpOrtho', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Iesire',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: home.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : 'Nu s-a putut incarca pagina.',
          onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
          child: _HomeContent(data: data, absoluteUrl: api.absoluteUrl),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data, required this.absoluteUrl});
  final HomeResponse data;
  final String Function(String) absoluteUrl;

  @override
  Widget build(BuildContext context) {
    final heroes = data.banners.where((b) => b.placement == BannerPlacement.hero).toList();
    final promos = data.banners.where((b) => b.placement == BannerPlacement.promo).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        for (final banner in heroes)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: BannerCard(
              banner: banner,
              hero: true,
              imageUrl: banner.imageUrl == null ? null : absoluteUrl(banner.imageUrl!),
              onTap: () => _openBanner(context, banner),
            ),
          ),
        if (data.quickCategories.isNotEmpty) ...[
          const SectionHeader('Categorii'),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.quickCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = data.quickCategories[index];
                return CategoryChip(
                  name: category.name,
                  iconUrl: category.iconUrl == null ? null : absoluteUrl(category.iconUrl!),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Catalogul vine in Faza 2: ${category.name}')),
                  ),
                );
              },
            ),
          ),
        ],
        if (promos.isNotEmpty) ...[
          const SectionHeader('Oferte'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 4 / 3,
              children: [
                for (final banner in promos)
                  BannerCard(
                    banner: banner,
                    imageUrl: banner.imageUrl == null ? null : absoluteUrl(banner.imageUrl!),
                    onTap: () => _openBanner(context, banner),
                  ),
              ],
            ),
          ),
        ],
        if (data.banners.isEmpty && data.quickCategories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Nu exista continut inca. Adauga bannere si categorii din Odoo.')),
          ),
      ],
    );
  }

  Future<void> _openBanner(BuildContext context, AppBanner banner) async {
    switch (banner.link.type) {
      case BannerLinkType.url:
        final uri = Uri.tryParse(banner.link.url ?? '');
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      case BannerLinkType.category:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalogul vine in Faza 2.')));
      case BannerLinkType.none:
        break;
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Reincearca')),
        ],
      ),
    );
  }
}
```

Adauga dependinta pentru deschiderea link-urilor externe:
```bash
cd app && flutter pub add url_launcher
```

- [ ] **Step 4: Ruleaza testele**

```bash
cd app && flutter test && flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/home app/test/features/home app/pubspec.yaml app/pubspec.lock
git commit -m "feat(app): ecran Acasa cu bannere hero/promo si categorii rapide din /home"
```

### Task 1.16: Router cu redirect pe auth, shell cu taburi, `main.dart`, verificare cap-coada

**Files:**
- Create: `app/lib/router.dart`
- Create: `app/lib/features/shell/shell_screen.dart`
- Create: `app/lib/app.dart`
- Modify: `app/lib/main.dart`
- Create: `app/test/router_test.dart`

**Interfaces:**
- Produces: `routerProvider` (`Provider<GoRouter>`), rute `/login`, `/` (shell cu `/` Acasa, `/catalog`, `/cart`, `/account` placeholder-e), redirect: nelogat -> `/login`, logat pe `/login` -> `/`.

- [ ] **Step 1: Test de redirect**

`app/test/router_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/providers.dart';
import 'package:uportho_app/router.dart';

import 'api/fake_transport.dart';

void main() {
  test('signed out user is redirected to /login', () async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    router.go('/');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
  });

  test('signed in user on /login is redirected to /', () async {
    final transport = FakeTransport();
    final store = InMemorySessionStore();
    await store.write('s');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: {
      'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}
    }));
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 200, json: {'banners': [], 'quick_categories': []}));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    router.go('/login');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });
}
```

- [ ] **Step 2: Ruleaza, verifica ca pica.**

- [ ] **Step 3: Implementare**

`app/lib/features/shell/shell_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tab bar-ul aplicatiei. Acasa e functional in Faza 1; celelalte sunt placeholder-e
/// pana la fazele lor (Catalog: Faza 2, Cos: Faza 3, Cont: Faza 4).
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Acasa'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Cos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Cont'),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title — in curand')));
  }
}
```

`app/lib/router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/shell/shell_screen.dart';

/// Notifica GoRouter cand se schimba starea de auth, ca sa re-evalueze redirect-ul.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading && !auth.hasValue) return null; // inca restauram sesiunea
      final signedIn = auth.value is SignedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!signedIn && !onLogin) return '/login';
      if (signedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ShellScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/catalog', builder: (_, __) => const PlaceholderScreen('Catalog'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/cart', builder: (_, __) => const PlaceholderScreen('Cos'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/account', builder: (_, __) => const PlaceholderScreen('Cont'))]),
        ],
      ),
    ],
  );
});
```

`app/lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/theme.dart';
import 'router.dart';

class UpOrthoApp extends ConsumerWidget {
  const UpOrthoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'UpOrtho',
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

`app/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: UpOrthoApp()));
}
```

Sterge `app/test/widget_test.dart` generat de `flutter create` (testeaza counter-ul demo).

Pentru HTTP in clar catre Odoo-ul local: in `app/ios/Runner/Info.plist` adauga sub `<dict>`:
```xml
<key>NSAppTransportSecurity</key>
<dict><key>NSAllowsLocalNetworking</key><true/></dict>
```
si in `app/android/app/src/main/AndroidManifest.xml`, pe `<application>`: `android:usesCleartextTraffic="true"`. Ambele sunt doar pentru dezvoltare locala; build-urile de release folosesc HTTPS si nu au nevoie de ele — se scot in Faza 5.

- [ ] **Step 4: Ruleaza testele si analiza**

```bash
cd app && flutter test && flutter analyze
```

- [ ] **Step 5: Verificare cap-coada pe Odoo local**

Odoo local pornit (`cd odoo && docker compose up -d`), cu baza `uportho_test` avand modulul instalat, un banner cu imagine si 2-3 categorii bifate (Task 1.4 pasul 4), si un utilizator portal: in backend, Contacts > un contact > Action > Grant portal access, seteaza parola.

```bash
cd app
flutter run -d iphone --dart-define=API_BASE_URL=http://localhost:8069
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8069
```

Expected, pe ambele platforme: ecran login; parola gresita arata "Email sau parola gresite."; login corect arata Acasa cu bannerul (imagine incarcata) si categoriile; pull-to-refresh merge; iesire duce inapoi la login; repornirea app-ului dupa login pastreaza sesiunea (nu mai cere parola).

- [ ] **Step 6: Commit**

```bash
git add app
git commit -m "feat(app): router cu redirect pe auth, shell cu 4 taburi, flux login->Acasa functional"
```

### Task 1.17: Documentatie proiect actualizata

**Files:**
- Modify: `CLAUDE.md`
- Modify: `PROIECT.md`

- [ ] **Step 1:** Actualizeaza `CLAUDE.md`: sectiunea "Structura folderelor" primeste `odoo/` (modul + Docker local) si `app/` (Flutter); "Stack tehnic" devine Flutter + modul Odoo; "Status curent" descrie Faza 1 livrata si `Rezultate/UPorthoApp/` ca referinta arhivata; adauga comenzile `odoo/run-tests.sh`, `app/tool/sync_contract.sh`, `flutter test`. Regula de siguranta Odoo ramane neschimbata.
- [ ] **Step 2:** Actualizeaza `PROIECT.md`: obiectivul devine iOS + Android (Flutter), fazele din spec cu Faza 0-1 bifate.
- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md PROIECT.md
git commit -m "docs: CLAUDE.md si PROIECT.md pentru arhitectura Flutter + modul Odoo"
```

---

## Ce urmeaza dupa acest plan

Planuri separate, fiecare cu spec-ul comun ca sursa:
- **Faza 2 — Catalog:** `/categories`, `/products`, `/products/<id>` cu serializatorul de pret (folosind pricelist-urile Odoo, Public 45 / Ortho Club 59, tiers normalizate), `recommended` in `/home`, ecranele de catalog/cautare/detaliu, `PriceText`, badge-uri.
- **Faza 3 — Cumparare:** cos, checkout, confirm cu idempotenta, plata offline + WebView card (provider `card` prov 8 / `wire_transfer` prov 5 pe instanta, curieri Fan Courier 3/5, ridicare 4, `country_id` 188, judete 710-751).
- **Faza 4 — Cont:** comenzi, facturi PDF, push FCM din modul (foloseste `uportho.app.device` din Task 1.8).
- **Faza 5 — Lansare.** **Faza 6 — Odoo 19.**

Din Faza 0 a spec-ului, raman pentru planurile urmatoare (nu blocheaza Faza 1): proiectul Firebase (Faza 4, push), conturile Apple Developer si Google Play Console (Faza 5), verificarea providerului de plata (Faza 3).
