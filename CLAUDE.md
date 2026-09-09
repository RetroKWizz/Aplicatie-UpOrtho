# Aplicatie UpOrtho — context proiect

Aplicatie mobila cross-platform (Flutter, iOS + Android) pentru **uportho.ro**,
cu backend un modul Odoo 18 propriu care expune un API JSON (`/api/app/v1`).
Design vizual diferit fata de site, dar culori de brand reale (vezi mai jos).
Push notifications planificate (Faza 4), inca neimplementate.

Verificare si lansare: **intai iOS**. Android ramane configurat (compileaza,
testele trec) dar nu e exercitat curent pe device/emulator.

## Structura folderelor din acest proiect

- `odoo/uportho_app/` — modulul Odoo 18 (controllere, modele, views, teste, `contract/`)
- `odoo/docker-compose.yml`, `odoo/odoo.conf`, `odoo/run-tests.sh` — mediu local Odoo+Postgres si rulare teste
- `app/` — aplicatia Flutter (`lib/api`, `lib/design_system`, `lib/features/{auth,home,shell}`, `test/`, `tool/sync_contract.sh`)
- `Rezultate/UPorthoApp/` — vechiul prototip SwiftUI, **arhivat, nu mai e produsul curent** (pastrat ca referinta; a lasat mostenire comportamentul de pricelist si harta rutelor de checkout, preluate in spec-ul de design)
- `docs/superpowers/specs/2026-09-07-uportho-flutter-odoo-design.md` — spec-ul de design (sursa comuna pentru toate fazele)
- `docs/superpowers/plans/2026-09-07-faza-0-1-fundatie.md` — planul Fazei 0-1
- `docs/DE-FACUT.md` — decizii amanate: ce se scoate inainte de lansare (cleartext, ping de debug, semnare cu chei de debug, nume placeholder) si datoria tehnica cunoscuta. **Se citeste inainte de Faza 2 si inainte de Faza 5.**
- `.claude/agents/` — subagenti Claude Code pentru acest proiect
- `PROIECT.md` — planul general, scope, roadmap (limba romana, pentru om)
- `CLAUDE.md` — acest fisier, context tehnic pentru Claude Code

## REGULA CRITICA DE SIGURANTA — Odoo

**NU se modifica NIMIC in Odoo real (uportho.ro / developer.uportho.ro / orice host odoo.sh) fara acceptul explicit al userului.**
Este permis doar accesul de citire (browsing, API read-only). Niciodata:
- scrieri/updateuri prin XML-RPC/JSON-RPC catre Odoo real fara confirmare explicita
- submit real de comenzi/checkout
- orice alta modificare de date in Odoo real
- niciun apel de retea catre uportho.ro, developer.uportho.ro sau vreun host odoo.sh in timpul dezvoltarii

Toata dezvoltarea ruleaza contra instantei **locale Docker** (`http://localhost:8069`, baza `uportho_test`).
Deploy pe odoo.sh e o decizie separata, doar a userului (Task 1.9 din plan a fost
sarit deliberat).

## Stack tehnic

**Aplicatie:** Flutter, package `uportho_app`, org `ro.uportho`, iOS + Android.
Riverpod (state), go_router (navigare), dio (HTTP), freezed (modele). iOS foloseste
Swift Package Manager, nu CocoaPods — nu exista `ios/Podfile` in acest Flutter.

**Backend:** modul Odoo 18 `odoo/uportho_app/`, depinde de `website_sale`, `sale`,
`product`, `portal`. Rute `type='http'` cu coduri HTTP reale, o singura forma de eroare
`{"error": {"code", "message", "details"}}`; orice request non-GET necesita header
`X-UpOrtho-App: 1`. Sesiune Odoo standard (cookie), parola nu se persista niciodata
in app.

Endpointuri curente: `POST /auth/login`, `POST /auth/logout`, `GET /me`, `GET /home`
(banner + categorii rapide intr-un singur call), `GET /banners/<id>/image`,
`GET /categories/<id>/icon` (rute de imagine autentificate), `POST /devices`,
`DELETE /devices/<token>` (token FCM, pregatire push Faza 4).

**Parametru de sistem, de setat la fiecare deploy**: `uportho_app.website_id`
(Setari → Tehnic → Parametri de sistem) = id-ul website-ului magazinului
(pe instanta reala: **11**). Fara el, controllerul cade pe `get_current_website()`,
care rezolva din header-ul HTTP `Host` contra domeniilor configurate si, daca nu
potriveste, ia primul website din baza — pe o instanta cu mai multe website-uri
`/home` ar returna gol si aplicatia ar afisa "Nu exista continut inca.", ca si cum
ar fi o problema de continut, nu un bug. Fallback-ul logheaza un warning
(`odoo.addons.uportho_app.controllers.home`), tocmai ca sa fie vizibil in loguri.

**Ordinea produselor e o setare de magazin, nu o constanta din cod.** `/products`
sorteaza dupa `website.shop_default_sort` al website-ului rezolvat mai sus (Website →
Configurare → Magazin, sau bara de sortare a magazinului), acelasi camp dupa care isi
ordoneaza rafturile site-ul. Pe instanta reala e `website_sequence asc` — ordinea
manuala din spatele sortarii "Recomandate" (603 valori distincte pe 619 produse
publicate, deci chiar ordonata de om). O schimbare de sortare facuta in Odoo se vede
in aplicatie fara release in store. Valoarea e validata inainte de folosire (fiecare
camp numit trebuie sa existe si sa fie stocat pe `product.template`, fiecare directie
sa fie `asc`/`desc`) si i se adauga `id` la final ca criteriu stabil — fara el, doua
produse cu acelasi `website_sequence` pot veni in ordine diferita la doua pagini
succesive, iar scroll-ul infinit al aplicatiei ar dubla unul si l-ar sari pe celalalt.
Setare lipsa, goala sau invalida => ordinea de rezerva `website_sequence, id` plus
warning in `odoo.addons.uportho_app.controllers.catalog`.

**Lista Ortho Club nu mai e configurare de deploy.** Pe o instanta reala sursa unica de
adevar e **bifa clientului `is_compare_pricelist`** de pe `product.pricelist` (campul
adaugat de `terrabit_prime_extension`) — aceeasi bifa dupa care magazinul isi alege
lista de comparatie pe pagina de produs, deci pretul de club si tabelul de club nu au
cum sa arate liste diferite. Parametrul de sistem `uportho_app.club_pricelist_id`
supravietuieste **doar ca rezerva pe bazele fara modulele clientului** (baza locala
`uportho_test`, testele), unde campul nici nu exista; prezenta lui se verifica
defensiv (`'is_compare_pricelist' in Pricelist._fields`). Daca campul exista dar nicio
lista nu e bifata, `club_price` e null cu warning — nu se cade inapoi pe parametru,
altfel s-ar reintroduce a doua sursa de adevar. La rollover-ul anual se bifeaza lista
noua si se debifeaza cea veche; nu mai trebuie atins niciun parametru.

**Regula de operare:** exact **o singura** lista de preturi poate purta fiecare din
`is_public_pricelist` si `is_compare_pricelist`. Codul (al lor si al nostru) ia *prima*
potrivire, iar "prima" e ordinea din baza — cu doua liste bifate, care castiga e
imprevizibil si se poate schimba singur.

Modele de continut care inlocuiesc Odoo Studio: `uportho.app.banner`, plus campuri
`app_home_visible` / `app_home_sequence` / `app_home_icon` pe `product.public.category`
si `app_badge_text` / `app_badge_color` / `app_badge_date_end` pe `product.template`.
Editare din Website → Aplicatie mobila (fara developer).

**Motivul modulului**: aplicatia vorbeste doar cu `/api/app/v1`. O migrare Odoo 19
(asteptata in 3-9 luni) se repara in Python intr-un singur loc, fara release de App Store.

**Regula de business**: aplicatia nu face niciodata aritmetica pe bani — preturile vin
preformatate de la server. (Neexercitat inca; conteaza de la Faza 2.)

**Culori de brand** (citite din stylesheet-ul public uportho.ro — nu le "corecta" din
ghiceala): primary `#78449B`, secondary `#BA9FCC`, background `#F9FAFE`,
text `#232F3E`. Accent `#F28C28` e o culoare functionala deliberata (oferte), nu vine
de pe site.

## Status curent — Faza 0-1 livrata

- Modul Odoo `uportho_app`: 46 teste trecute.
- Aplicatia Flutter: 80 teste trecute, `flutter analyze` curat. Login, restaurare
  silentioasa a sesiunii la relansare, ecran Acasa (banner + categorii rapide din Odoo),
  tab bar cu 4 taburi (doar Acasa e real in Faza 1).
- Contract JSON comun: `odoo/uportho_app/contract/*.json` e sursa de adevar, copiat in
  `app/test/contract/` prin `app/tool/sync_contract.sh` — o schimbare pe server care
  rupe aplicatia pica un test inainte de a ajunge in productie. Divergenta intre cele
  doua copii e prinsa de `app/test/contract_sync_test.dart` (compara byte cu byte);
  daca pica, ruleaza `app/tool/sync_contract.sh`.
- Nu e facut inca: catalog/preturi (Faza 2), cos/checkout/plata (Faza 3), cont/comenzi/
  facturi/push (Faza 4), lansare in store (Faza 5), migrare Odoo 19 (Faza 6).
- Ramase, de decis doar de user: export Odoo Studio ca plasa de siguranta (plan Task 0.3),
  deploy pe odoo.sh (plan Task 1.9, sarit deliberat).
- Ce a fost amanat constient (setari de dezvoltare de scos la lansare + datorie tehnica):
  `docs/DE-FACUT.md`.

## Gotchas de mediu (cost real de timp la redescoperire)

1. **Android `compileSdk = 37` depinde de un symlink din afara repo-ului.**
   `flutter_secure_storage` 11.0.0 cere compileSdk 37, dar SDK-ul instalat local are
   doar `android-37.0` (denumire noua major.minor). S-a creat manual un symlink
   `android-37 → android-37.0` in `$ANDROID_HOME`
   (`/opt/homebrew/share/android-commandlinetools/platforms/`). Fara el, un clone nou
   pica Gradle sync cu "Failed to find target with hash string 'android-37'".
2. **`ANDROID_HOME` si `JAVA_HOME` nu sunt exportate in profilul de shell.** Valorile:
   `ANDROID_HOME=/opt/homebrew/share/android-commandlinetools`,
   `JAVA_HOME=/opt/homebrew/opt/openjdk@17`. `flutter config` le stie deja, deci
   `flutter` merge fara ele exportate; apeluri directe `sdkmanager`/`adb`/Gradle au
   nevoie sa fie exportate manual in sesiunea de shell.
3. **Riverpod 3 reincearca automat erorile aparute in `build()`-ul unui provider**,
   cu backoff exponential pana la ~38 secunde. Fiecare provider de aici al carui
   `build()` poate arunca eroare primeste `retry: (retryCount, error) => null`.
   Daca uiti asta, un ecran de eroare apare abia dupa 38 de secunde.
4. **Containerul Odoo poate servi cod de controller invechit.** Daca rutele
   `/api/app/v1/...` dau 404 neasteptat, restarteaza containerul
   (`docker compose restart` in `odoo/`).
5. **`odoo.tests.stats` logheaza un numar de teste cumulativ, mai mare decat cel real.**
   Linia autoritara e `N failed, M error(s) of K tests`.
6. **Testele nu au voie sa depinda de datele preexistente din baza.** Baza locala
   `uportho_test` are inregistrari ramase din verificari manuale (bannere, categorii
   bifate ca vizibile pe Acasa). Un test care compara o lista intoarsa de `/home` cu
   exact ce si-a creat el pica pe o astfel de baza — s-a si intamplat. Forma corecta:
   testul filtreaza pe id-urile proprii SI isi creeaza singur inregistrarea care
   interfereaza. Asa dovada de robustete sta in test si supravietuieste unui clone nou
   sau unui container reconstruit. (Doctrina anterioara — "lasa bannerul strain in baza,
   e dovada ca testele sunt robuste" — era gresita: dovada era locala unei masini si
   facea baza nereproductibila.)
7. **Pe instanta reala, `product.template._get_combination_info` arunca la fiecare apel,
   pentru orice produs.** Tema magazinului (`droggol_theme_common`) randeaza in
   interiorul ei sablonul `theme_prime.product_extra_fields`, iar acolo sta
   `t-value="product_variant.all_product_tag_ids.filtered(lambda x: x.visible_on_ecommerce)"`
   — QWeb nu poate evalua `lambda`, deci randarea pica cu
   `TypeError: 'NoneType' object is not callable`. **Nu e o problema de context**:
   verificat pe staging cu website-ul real dat explicit in `values`, cu `website_id`
   in context si pe produse cu si fara etichete de ecommerce — pica identic.

   **Ce face ruta de produs azi:** prinde exceptia si cheama direct implementarea
   standard din Odoo, `website_sale.models.product_template.ProductTemplate.
   _get_combination_info(template, ...)`, adica acelasi cod, doar fara veriga de tema.
   Verificat pe staging (produsul 14219): apelul normal arunca, apelul direct intoarce
   `price: 264.0`, `list_price: 330.0`, `product_id: 41868`. **Deci aplicatia primeste
   datele Odoo, nu o reconstructie locala.** Reconstructia din API-ul de baza
   (`_fallback_combination`) a ramas doar ca ultima plasa, daca ar cadea si standardul.

   Dupa prima cadere, produsul intra in `_COMBINATION_INFO_BROKEN` (set la nivel de
   proces, in `controllers/product.py`) si apelul care oricum arunca nu se mai face.
   Memoria moare odata cu procesul: un deploy sau o repornire de worker reincearca
   apelul normal, deci **cand Terrabit repara sablonul, adaugirile temei se intorc
   singure in raspuns, fara schimbare de cod si fara release de aplicatie.** Logarea a
   ramas cum era: traceback intreg prima data pentru fiecare produs, apoi o linie
   scurta.

   Ce ramane **reprodus** in modul, nu apelat: tabelele de pret si regulile din jurul
   lor (selectia listelor publica/comparatie, pragurile `max(1, min_quantity)`,
   cumularea cantitatilor pe tot tabelul de variante) — acelea vin din modulele
   clientului, nu din `website_sale`, deci apelul standard nu le contine.
8. **Pragurile de cantitate se aplica pe cantitatea CUMULATA a tabelului de variante**,
   nu pe fiecare rand. Sursa: `website_variant_cart` (`total_qty += item['add_qty']`,
   apoi `_get_combination_info_variant(add_qty=total_qty)`). 4 bucati pe o varianta plus
   7 pe alta inseamna 11, deci pragul 10+ pentru ambele randuri. Calculul pe rand
   separat afiseaza preturi mai mari decat comanda reala.
9. **Terminalul din editorul odoo.sh moare cand sta neatins** si accepta text fara
   sa-l execute — de doua ori a inghitit tacut un deploy intreg. Dupa orice comanda
   de desfasurare se verifica **rezultatul pe disc** (`grep` intr-un fisier nou), nu
   se presupune din ce s-a tastat.
10. **Acest Flutter foloseste Swift Package Manager pe iOS, nu CocoaPods** — nu exista
   `ios/Podfile`; nu cauta/instala pods.

## Comenzi utile

```bash
cd odoo && docker compose up -d     # porneste Odoo 18 + Postgres local pe :8069, baza uportho_test
odoo/run-tests.sh                   # testele modulului Odoo, in container
app/tool/sync_contract.sh           # sincronizeaza fixture-urile de contract Odoo -> app
cd app && flutter test              # testele aplicatiei Flutter
cd app && flutter analyze
cd app && flutter run -d <simulator-id> --dart-define=API_BASE_URL=http://localhost:8069
```

## Conventii de lucru

- Commit doar cand userul cere explicit.
- Numele de model `Category` din vechiul prototip SwiftUI intra in conflict cu
  `ObjectiveC.Category` — daca se mai atinge acel cod, foloseste `ProductCategory`
  (irelevant pentru codul Flutter/Odoo curent).
