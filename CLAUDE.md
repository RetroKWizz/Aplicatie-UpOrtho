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
`DELETE /devices/<token>` (token FCM, pregatire push Faza 4), `GET /categories`,
`GET /products`, `GET /products/<id>`, `POST /products/<id>/prices`, rutele de imagine
si de document ale produsului, plus (Faza 3-4) `GET /cart`, `POST /cart/lines`,
`GET /checkout`, `POST /checkout/address`, `POST /checkout/delivery`,
`POST /checkout/confirm`, `GET /delivery-methods/<id>/logo`, `GET /orders`,
`GET /orders/<id>`, `GET /invoices`, `GET /invoices/<id>/pdf`, `GET /addresses`,
`GET /addresses/options`, `POST /addresses`, `GET /account/profile`,
`POST /account/profile`, `GET /loyalty`.

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

## Cosul, checkout-ul si plata — cum sunt legate de Odoo

**Cosul aplicatiei E cosul magazinului.** Sesiunea aplicatiei e chiar sesiunea Odoo
(acelasi cookie), iar modulul cheama `website.sale_get_order()` si
`sale.order._cart_update()` — metodele prin care trece si `/shop/cart/update_json`.
Ce adaugi in aplicatie apare in browser si invers. Nu exista un al doilea cos.

**Nimic nu se recalculeaza in modul.** Curierii vin din
`sale.order._get_delivery_methods()`, tariful din `carrier.rate_shipment()`, alegerea
lui din `_set_delivery_method()`, metodele de plata din
`payment.provider._get_compatible_providers()` + `payment.method._get_compatible_payment_methods()`.
Asa trec automat si regulile clientului din `deltatech_website_delivery_and_payment`
(providerii permisi de curier prin `acquirer_allowed_ids`, plafonul `value_limit`,
restrictiile pe etichete de partener) si filtrul de greutate al curierilor.

**Plata are doua drumuri**, dupa provider:
- **offline** (`custom` = transfer bancar, `on_delivery` = ramburs): comanda se
  incheie in aplicatie. Se creeaza tranzactia si se cheama
  `_handle_notification_data(cod, {'reference': ...})` — exact ce fac rutele lor de
  proces — apoi `tx._post_process()`. **Post-procesarea nu vine de la sine**: pe site o
  declanseaza pagina `/payment/status`; fara ea comanda ramane ciorna si nimeni n-o
  vede in Odoo.
- **card salvat** (`kind: token`): plata se face fara sa iesim din aplicatie. Tokenul
  e o referinta pastrata de provider, iar cererea o face serverul
  (`payment.transaction._send_payment_request`) — acelasi apel ca
  `payment.controllers.portal._create_transaction` cu `flow='token'`. Nicio informatie
  de card nu trece prin aplicatie. Pe uportho asta nu e un caz marginal: peste o mie de
  carduri salvate si zeci de plati pe luna facute asa. Rezultatul nu se presupune: se
  citeste starea tranzactiei, iar daca plata nu a trecut (3-D Secure cere clientul in
  fata ecranului, fonduri, card expirat) raspunsul devine `webview` si aplicatia
  trimite clientul in pagina magazinului.
- **card nou** (Stripe): aplicatia deschide pagina de plata a magazinului
  (`/shop/payment`) intr-un **WebView**, cu acelasi cookie de sesiune. In Odoo 18
  formularul Stripe e **inline** (JavaScript in pagina), nu o redirectionare: nu exista
  URL de plata care sa poata fi deschis altfel, iar datele cardului nu trec prin
  aplicatie. WebView-ul se inchide cand URL-ul ajunge la `/shop/confirmation`.

  **Optiunea de plata se identifica prin (provider, metoda, token), nu prin primele
  doua.** Acelasi provider ofera si cardul nou, si fiecare card salvat, toate cu acelasi
  `payment_method_id`. Fara token in cheie, doua randuri din ecran primeau aceeasi
  valoare si apasarea pe cardul salvat alegea de fapt cardul nou.

Ce provideri sunt "offline" se poate schimba fara release, prin parametrul de sistem
`uportho_app.offline_payment_codes` (implicit `custom,on_delivery`).

**Adresele noi si datele contului trec prin validarea lor, nu prin a noastra.**
`controllers/address.py` mosteneste `WebsiteSale` si `controllers/profile.py`
mosteneste `CustomerPortal` — mostenirea e chiar mecanismul prin care se leaga si
modulele clientului, deci `self._validate_address_values` si
`self.details_form_validate` trec prin toate override-urile lor:
`terrabit_website_invoice_address` sare peste verificarea de format a CUI-ului (au
coduri pe care Odoo le-ar refuza) dar il face obligatoriu cand se completeaza numele
firmei, iar `deltatech_website_city` adauga `city_id` la campurile obligatorii, pentru
ca orasul e o inregistrare legata. **Cele doua clase nu suprascriu nicio metoda si
nicio ruta a lor** — adauga doar rute sub `/api/app/v1`.

Campurile obligatorii nu se scriu in codul nostru: se cer magazinului
(`_get_mandatory_billing_address_fields` / `_get_mandatory_delivery_address_fields`) si
portalului (`_get_mandatory_fields`), deci o schimbare facuta de ei ajunge in aplicatie
fara release. Ce trimite aplicatia e insa o lista scrisa explicit (`ALLOWED_FIELDS`,
`PROFILE_FIELDS`): `_parse_form_data` de pe site accepta orice camp "scriibil din
formular", ceea ce pe o ruta JSON ar lasa un client sa-si seteze singur agentul de
vanzari sau etichetele.

Doua capcane, amandoua prinse de teste:
- `details_form_validate` **respinge orice cheie necunoscuta** ("Unknown field"), deci
  `mobile` si `function` (care nu sunt in formularul web) se salveaza pe langa ea, nu
  prin ea.
- "netrimis" si "trimis gol" sunt lucruri diferite. Un camp netrimis se completeaza cu
  valoarea de acum; unul trimis gol e o cerere de stergere si merge asa la validare.
  Confundate, o stergere ceruta de client primea 200 si nu se intampla nimic.

**Lista de adrese are o singura sursa**, `address._account_addresses()`: partenerul
comercial, copiii lui **si** partenerii cu `access_for_user_id` — campul prin care
clientul da acces la o firma din afara arborelui. Site-ul le adauga in
`_prepare_checkout_page_values`; fara ele aplicatia ar arata mai putine adrese decat
magazinul.

**Accesul B2B al temei inseamna "utilizator autentificat".**
`website._dr_has_b2b_access()` din `droggol_theme_common` intoarce
`not user.has_group('base.group_public')` cand B2B e pornit. Utilizatorii aplicatiei
sunt mereu autentificati (`auth='user'`), deci au acces — la fel ca pe site. Atentie:
acelasi modul goleste cosul in `_cart_update` daca accesul lipseste.

## Status curent — Fazele 0-4 livrate (mai putin push-ul)

- Modul Odoo `uportho_app`: 371 teste trecute.
- Aplicatia Flutter: 339 teste trecute, `flutter analyze` curat. Login cu restaurare
  silentioasa a sesiunii, Acasa, catalog cu cautare si paginare, pagina de produs
  completa (galerie, tabele de pret, tabel de variante, brand, file, documente,
  recenzii, produse similare), cos, checkout, plata (offline, card salvat, card nou in
  WebView), cont cu datele contului editabile, comenzi, facturi (PDF), adrese cu
  adaugare de adrese noi si carduri Ortho Club. Toate cele patru taburi sunt reale.
- Contract JSON comun: `odoo/uportho_app/contract/*.json` e sursa de adevar, copiat in
  `app/test/contract/` prin `app/tool/sync_contract.sh` — o schimbare pe server care
  rupe aplicatia pica un test inainte de a ajunge in productie. Divergenta intre cele
  doua copii e prinsa de `app/test/contract_sync_test.dart` (compara byte cu byte);
  daca pica, ruleaza `app/tool/sync_contract.sh`.
- Nu e facut inca: notificari push (partea de FCM din Faza 4 — modelul `uportho.app.device`
  si rutele exista, trimiterea nu), lansare in store (Faza 5), migrare Odoo 19 (Faza 6).
- Verificat pe staging, pe catalogul real (11 septembrie 2026): login, catalog, produs,
  cos, checkout si **doua comenzi duse pana la capat** (CMD42024, CMD42026), plus
  contul lui Mihai cu 31 de comenzi, 2 facturi si 4 adrese. Doua defecte gasite acolo,
  nu in teste: pretul pe bucata ignora reducerea liniei, si al doilea cont vedea datele
  primului. Ambele reparate, cu teste care le reproduc.
- Neverificat inca pe staging: adaugarea de adrese, editarea datelor contului, plata cu
  card salvat. Sunt acoperite de teste, dar n-au fost exercitate pe date reale.
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

   **Si, separat de retry: orice provider care aduce date ALE CONTULUI trebuie sa
   inceapa cu `await ref.watch(authControllerProvider.future)`.** Riverpod pastreaza
   valoarea in cache cat traieste containerul, iar nimic nu o invalideaza la
   schimbarea de utilizator: al doilea cont vede datele primului. **S-a intamplat pe
   staging, cu doua conturi reale** — ecranul "Contul meu" arata numele corect (venea
   din raspunsul de login) dar comenzile si adresele contului dinainte. Regula e
   acoperita de `app/test/features/account/account_switch_test.dart`, care face chiar
   logout + login cu alt cont. Providerii legati azi: cos, checkout, comenzi, facturi,
   adrese, detaliu de comanda, plus `homeControllerProvider` si `imageHeadersProvider`.

   Catalogul e cazul special: `CatalogController` foloseste `ref.listen`, nu `watch`,
   fiindca un watch ar goli grila la fiecare tranzitie (inclusiv la restaurarea
   sesiunii de la pornire). Si `_initialized` **nu** se reseteaza la deconectare: el
   pazeste doar `ensureLoaded`, pe care ecranul il cheama o singura data din
   `initState` — resetat, login-ul urmator ar lasa grila goala.
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
   interiorul ei sablonul `theme_prime.product_extra_fields`.

   **Cauza (verificata, reprodusa local):** acel sablon cheama
   `is_view_active('website_sale.product_tags')`. `is_view_active` **nu** e o functie
   globala de QWeb: `website/models/ir_qweb.py` o pune in valorile de randare
   (`is_view_active=lazy(lambda: current_website.is_view_active)`) din
   `_prepare_frontend_environment`, iar `http_routing/models/ir_qweb.py` intra pe acea
   metoda **doar daca `request.is_frontend` e adevarat**. Rutele acestui modul sunt
   `type='http'` simple, deci `ir_http._match` le pune `is_frontend = False`: numele
   iese `None` din context si apelul devine `None(...)` →
   `TypeError: 'NoneType' object is not callable`.

   **Explicatia veche — "QWeb nu poate evalua `lambda`" — era gresita.** Pe staging,
   in acelasi sablon, `slug(...)`, `filtered('visible_on_ecommerce')`, `any([...])` si
   toate citirile de campuri merg; lipseste exact un ajutor. Reprodus local (Odoo 18
   din container, fara tema instalata): un sablon QWeb care cheama `is_view_active`,
   randat dintr-un `_get_combination_info` chemat de pe ruta noastra, da fix acel
   `TypeError`.

   **Reparatia evidenta e blocata deocamdata, si nu din intamplare.** Ca sablonul sa
   randeze e nevoie de *doua* lucruri pe request, nu de unul: `is_frontend = True`
   **si** `request.website` (mediul de frontend din `website` face
   `current_website = request.website`; doar cu flagul, randarea da
   `AttributeError: 'Request' object has no attribute 'website'` — verificat local).
   Iar `request.website` schimba **preturile**: `website_sale` suprascrie
   `product.pricelist._get_partner_pricelist_multi_filter_hook` si filtreaza lista
   clientului prin `_is_available_on_website(request.website)`, deci
   `partner.property_product_pricelist` se rezolva altfel cat timp atributul e pus.
   Local, cu ea pusa, lista clientului dispare si ruta raspunde 503
   `pricelist_unavailable` (`controllers/catalog._customer_pricelist`). Scurgerea in
   afara ferestrei se poate opri cu `invalidate_model(['property_product_pricelist'])`,
   dar **inauntrul** ferestrei tema tot calculeaza `other_bulk_prices` pe lista
   filtrata — adica exact datele pentru care se face schimbarea. Daca listele
   clientului de pe serverul lor sunt disponibile pe website (`website_id` potrivit,
   sau `selectable`/`code`), nu se schimba nimic; daca nu, se schimba preturile.
   **Se verifica pe serverul lor inainte de a merge mai departe.** Lucrarea completa
   (implementare + teste, 300/300 verde local) e pastrata in
   `.superpowers/faza2-frontend-flag.patch`.

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
10. **Pe iOS proiectul a pornit pe Swift Package Manager, dar are din nou si CocoaPods.**
   `open_filex` (adaugat pentru documentele de produs) nu are suport SPM, asa ca
   `flutter pub get` a generat `app/ios/Podfile` si a bagat Pods in workspace; buildul
   ruleaza `pod install` singur si trece. Flutter avertizeaza la fiecare build
   ("plugins do not support Swift Package Manager ... will become an error in a future
   version of Flutter") — daca pachetul nu adopta SPM, la o versiune viitoare de Flutter
   trebuie inlocuit. `Podfile` si `Podfile.lock` sunt versionate, `Pods/` nu.

## Desfasurare pe staging (odoo.sh)

Modulul sta pe staging la `~/src/user/custom_modules/uportho_app` si e **installed**.
Actualizarea codului, din terminalul editorului odoo.sh:

```bash
cd ~/src/user/custom_modules
tar czf ~/tmp/backup_uportho_app_$(date +%Y%m%d_%H%M).tar.gz uportho_app   # plasa de siguranta
curl -sSL -o /tmp/uportho_app.tar.gz \
  https://raw.githubusercontent.com/RetroKWizz/Aplicatie-UpOrtho/main/uportho_app.tar.gz
tar xzf /tmp/uportho_app.tar.gz -C . 2>/dev/null   # se dezarhiveaza PESTE, fara rm
odoo-update uportho_app                            # reporneste si actualizeaza modulul
```

`uportho_app.tar.gz` din radacina repo-ului e chiar arhiva de desfasurare; se
regenereaza cu `tar czf uportho_app.tar.gz -C odoo --exclude='__pycache__' uportho_app`.

**Reteta completa de refacere — `docs/STAGING.md`**, sectiunea "Cum se reface, de la
zero, dupa ce build-ul dispare": modul, parametri de sistem, contul de test si adresa
lui, providerul de plata, reparatia din tema, verificarea rutelor si proba de comanda
de la login pana la confirmare. Se citeste inainte de orice re-desfasurare.

**Copia e temporara.** `~/src/user` e checkout-ul repo-ului lor; la primul build al
ramurii de staging (adica la primul push facut de Terrabit) fisierele copiate manual
dispar. Pentru ceva permanent, modulul trebuie sa intre in repo-ul lor.

**Terminalul editorului e ALT container decat serverul Odoo.** Acolo asculta doar
jupyter-lab; `curl http://127.0.0.1:8069/...` da mereu `000`. Testarea rutelor se face
pe URL-ul public al instantei (`https://uportho-staging-36862484.dev.odoo.com/...`),
tot din acel terminal. Baza de date si filesystemul sunt insa comune, deci `psql` si
`odoo-bin shell` merg direct.

**Pe staging, Odoo dezactiveaza singur toti providerii de plata** (`state='disabled'`),
ca sa nu se incaseze bani reali dintr-o copie de productie. Fara ca cineva sa porneasca
explicit unul in mod test, `/checkout` intoarce lista de plati goala — nu e un bug al
modulului.

**Starea configurarii pe website 11, verificata pe copia de staging din 29 iulie 2026:**
singurul curier ACTIV si publicat e "Ridicare din sediu" (id 4). Fan Courier (3) si
Fan Courier ramburs (5) raman publicate dar sunt **arhivate** (`active = false`) din
28 iulie, iar cele doua "Caut Curier – Sameday" (31, 32) sunt legate de website 12.
Aplicatia arata exact ce e publicat SI activ, deci daca in productie lipsesc curierii,
lipsesc si in aplicatie.

**Un cont fara adresa nu primeste niciun curier.** `carrier.rate_shipment()` raspunde
"aceasta metoda de livrare nu este disponibila pentru aceasta adresa" cand partenerul
n-are tara/oras, iar checkout-ul arata atunci lista goala si blocajul
`no_delivery_method`. E raspunsul corect al Odoo, nu un defect al modulului: primul
lucru de verificat cand un client zice ca "nu apare livrarea" e adresa lui.

**Comanda de proba dusa pana la capat pe staging (11 septembrie 2026):** CMD42024 si
CMD42026, cont `app.test@uportho.ro`, transfer bancar, ridicare din sediu. Comanda iese
din ciorna (`state = sent`), tranzactia ramane `pending` si post-procesata, iar cosul se
goleste. Providerul a fost pornit in mod test doar pentru proba si pus inapoi pe
`disabled`.

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
