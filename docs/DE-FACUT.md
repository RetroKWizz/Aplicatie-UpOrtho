# De facut — decizii amanate, urmarite in repo

Acest fisier tine evidenta lucrurilor amanate constient in Faza 0-1. Pana acum ele
traiau doar in registrul de executie `.superpowers/sdd/.../progress.md`, care e
gitignorat — adica dispareau la finalul sesiunii. Aici sunt versionate.

Fiecare intrare spune: **ce este**, **unde traieste**, **de ce a fost amanat**.

---

## De scos inainte de lansare

Primele sase sunt setari de dezvoltare. Niciuna nu e un bug acum; fiecare devine o
problema reala in ziua in care aplicatia ajunge in magazin. A saptea nu e o setare de
dezvoltare, ci doua pachete noi cu urmari de vazut inainte de publicare.

### 1. `android:usesCleartextTraffic="true"` (nescopat)

- **Unde**: `app/android/app/src/main/AndroidManifest.xml`, atributul de pe `<application>`.
- **Ce este**: permite HTTP in clar catre **orice** host, in **toate** variantele de build
  (inclusiv release). Spre deosebire de echivalentul de pe iOS, care e limitat la reteaua
  locala, acesta nu are niciun scop.
- **De ce a fost amanat**: userul a cerut iOS-first; Android nu se lanseaza acum si nu e
  exercitat pe device. E nevoie de el ca aplicatia sa vorbeasca cu Odoo-ul local pe
  `http://10.0.2.2:8069`.
- **Cum se scoate**: se sterge atributul si, daca mai e nevoie de localhost in debug, se
  pune un `network_security_config` limitat la `10.0.2.2` si aplicat doar variantei debug.

### 2. `NSAllowsLocalNetworking` pe iOS

- **Unde**: `app/ios/Runner/Info.plist`, sub `NSAppTransportSecurity`.
- **Ce este**: exceptie App Transport Security care permite HTTP in clar catre reteaua
  locala. E deja mult mai stramt decat varianta Android (doar retea locala, nu orice host).
- **De ce a fost amanat**: fara el, simulatorul iOS nu poate vorbi cu `http://localhost:8069`.
- **Cum se scoate**: se sterge cheia `NSAppTransportSecurity` din Info.plist cand backendul
  de productie e pe https.

### 3. Garda de release pe `API_BASE_URL` (de reevaluat, nu neaparat de scos)

- **Unde**: `app/lib/config.dart` (`AppConfig.assertReleaseApiBaseUrl`), apelata din
  `app/lib/main.dart`.
- **Ce este**: `AppConfig.apiBaseUrl` are default-ul de dezvoltare `http://localhost:8069`.
  Garda arunca `StateError` la pornire daca un build de **release** nu are un URL `https`.
- **De ce arata asa**: un default de productie ar fi facut ca orice rulare locala sa loveasca
  Odoo-ul real, ceea ce regula de siguranta a proiectului interzice; si oricum backendul nu e
  inca deployat, deci nu exista inca un URL de productie de pus pe post de default.
- **De facut la lansare**: cand exista host-ul de productie, se decide daca default-ul devine
  acel host (si garda ramane ca plasa de siguranta) sau daca se pastreaza asa si URL-ul vine
  intotdeauna din `--dart-define` in pipeline-ul de build. Oricum ar fi, trebuie verificat
  explicit ca build-ul din magazin nu porneste spre localhost.

### 4. Ruta de debug `POST /api/app/v1/ping` care da ecou corpului

- **Unde**: `odoo/uportho_app/controllers/ping.py`.
- **Ce este**: `POST /ping` intoarce inapoi campul `echo` din corpul cererii. A fost scrisa ca
  sa se poata testa infrastructura de rute (header-ul `X-UpOrtho-App`, forma erorilor, corpul
  JSON invalid) inainte sa existe endpointuri reale.
- **De ce a fost amanat**: e `auth='user'`, deci nu e accesibila anonim, iar aplicatia nu o
  foloseste. Testele din `tests/test_controllers_base.py` se sprijina pe ea.
- **Cum se scoate**: se sterge `ping_post` (si eventual tot controllerul) si se muta testele de
  infrastructura pe un endpoint real, dupa ce Faza 2 aduce unul cu POST.

### 5. Semnare de release cu cheile de debug

- **Unde**: `app/android/app/build.gradle.kts`, `buildTypes { release { signingConfig =
  signingConfigs.getByName("debug") } }`.
- **Ce este**: build-ul de release Android e semnat cu cheia de debug, ca `flutter run
  --release` sa functioneze fara keystore.
- **De ce a fost amanat**: nu exista inca un cont Google Play Console si niciun keystore.
- **Cum se scoate**: keystore propriu + `signingConfigs.release` alimentat din
  `key.properties` (fisier tinut in afara repo-ului).

### 6. Nume si texte de placeholder generate de `flutter create`

- **Unde si ce este**:
  - `app/android/app/src/main/AndroidManifest.xml`: `android:label="uportho_app"` — numele
    tehnic al pachetului, nu numele produsului.
  - `app/ios/Runner/Info.plist`: `CFBundleDisplayName` = `Uportho App` — nici asta nu e
    scrierea corecta, care e **UpOrtho**.
  - `app/pubspec.yaml`: `description: "A new Flutter project."`.
  - `app/README.md`: textul standard de proiect nou Flutter ("A new Flutter project", linkuri
    catre codelab-urile Flutter), care nu spune nimic despre acest proiect.
- **De ce a fost amanat**: numele afisat sub iconita si textele de store sunt lucruri pe care
  le decide userul, si intra oricum in Faza 5 (iconite, screenshots, descriere store).
- **Cum se scoate**: `android:label="UpOrtho"`, `CFBundleDisplayName` = `UpOrtho`, descriere
  reala in `pubspec.yaml`, README care descrie aplicatia si comenzile ei.

### 7. Doua pachete noi pentru documentele de produs: `open_filex` si `path_provider`

- **Unde**: `app/pubspec.yaml` (`open_filex: ^4.7.0`, `path_provider: ^2.1.6`), folosite
  doar in `app/lib/features/product/document_files.dart`.
- **De ce au fost adaugate** (decizie explicita a userului, care intoarce regula
  "fara pachete noi" din planul Fazei 2): documentele de produs se servesc pe o ruta
  **autentificata** a modulului. Aruncat in browserul telefonului, URL-ul raspunde 401 —
  browserul nu duce cookie-ul de sesiune al aplicatiei. Deci fisierul trebuie adus de
  aplicatie (prin `ApiClient`, cu sesiunea pe cerere), scris pe disc si abia apoi dat
  vizualizatorului de sistem. `url_launcher`, deja in proiect, **nu** poate deschide o cale
  locala pe iOS/Android (schema `file:` e documentata doar pentru desktop), iar dosarul
  scriibil al aplicatiei se afla doar prin `path_provider`.
- **Ce trebuie vazut la review-ul de dinainte de lansare**:
  - `open_filex` isi aduce propriul `FileProvider` in manifestul Android **si trei
    permisiuni**: `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO` (plus
    `READ_EXTERNAL_STORAGE` pana la SDK 32). Ele se contopesc in manifestul aplicatiei, deci
    apar in fisa de permisiuni din Google Play desi aplicatia nu citeste galeria.
    **DECIS de Mihai (10 sept 2026): raman asa, nu se scot.** Nu mai e un punct deschis
    pentru review-ul de dinainte de lansare; daca vreodata Google le contesta la
    publicare, solutia e `tools:node="remove"` in manifestul aplicatiei, urmata de un
    test ca deschiderea documentelor inca merge.
  - Pe iOS nu cere nicio cheie in `Info.plist` si nicio permisiune.
  - Documentele se scriu in dosarul **temporar** al aplicatiei
    (`uportho_documente/<calea rutei>/<nume fisier>`), pe care sistemul are voie sa-l
    curete. Nu exista curatare proprie: daca la Faza 5 se constata ca fisierele se aduna,
    se sterge dosarul la pornire.

---

## Constatari ale recenziei de cod pe ramura "magazin fara cont" (15 octombrie 2026)

Recenzie facuta de un recenzor cu context proaspat, pe toata ramura. Cele doua probleme
grave au fost reparate pe loc (pagina de produs care crapa pentru vizitatori, ecranul de
autentificare fara iesire). **Ce urmeaza NU e reparat** — amanat constient, cu acordul
userului, ca sa nu intarzie testarea pe TestFlight.

### 1. Rutele publice de imagine nu verifica vizibilitatea (SECURITATE, de facut primul)

- **Unde**: `odoo/uportho_app/controllers/home.py` — `/banners/<id>/image` si
  `/categories/<id>/icon`; `odoo/uportho_app/controllers/product.py` —
  `/benefits/<id>/image`.
- **Ce este**: rutele au devenit `auth='public'` odata cu catalogul, iar modelele au
  primit drept de citire pentru `base.group_public`. Niciuna nu verifica insa `active`,
  `date_start`/`date_end` sau `website_id`. Cineva care incearca id-uri la rand poate
  scoate **poza unui banner arhivat sau programat pentru o campanie viitoare** — adica
  poate vedea campania inainte de lansare. Nu sunt date de client, sunt imagini de
  marketing, dar sunt imagini pe care magazinul nu le arata nimanui inca.
- **Confirmat cu un test**, scris si rulat: bannerul arhivat raspunde 200 in loc de 404.
  Testele sunt in `tests/test_controllers_public.py::TestImaginiPublice` — **ele pica
  acum**, deliberat, si marcheaza exact ce e de reparat.
- **Cum se repara**: bannerul prin `_search_active_now(_current_website())`, iconita prin
  `_search_app_home(website)`, beneficiul prin cautarea lui activa; 404 altfel. Acelasi
  tipar ca `/products/<id>/image`, care **a** fost intarit in aceeasi ramura.
- **Contrast**: `/products/<id>/image` si `/brands/<id>/logo` trec corect prin domeniul
  catalogului. Bannerul a fost uitat.

### 2. Inregistrarea prin WebView nu aduce sesiunea inapoi

- **Unde**: `app/lib/features/auth/signup_screen.dart`, ramura `signup_needs_webview`.
- **Ce este**: `PaymentWebViewScreen` are propriul magazin de cookie-uri. Dupa ce omul
  isi face contul in pagina magazinului, sesiunea exista **doar in WebView**: aplicatia
  n-o citeste, n-o scrie in `sessionStore` si nu reimprospateaza `authController`. Omul
  se intoarce tot vizitator, desi are cont, si nimic nu-l anunta.
- **Latent azi**: reCAPTCHA nu e configurat pe instanta, deci drumul asta nu se
  foloseste. Devine real **in clipa in care cineva porneste reCAPTCHA** — adica exact
  cand creste traficul si cineva se gandeste la boti.
- **Cum se repara**: dupa inchiderea WebView-ului, cookie-ul se citeste din
  `WebViewCookieManager` si se scrie in `sessionStore`, apoi `/me`. Daca nu se poate
  citi, macar un mesaj "Contul e creat — intra cu el" si trimiterea la autentificare cu
  emailul completat. De verificat si `returnUrlPrefix: '/my'`, care e o presupunere
  despre unde aterizeaza Odoo dupa signup.

### 3. Un vizitator care apasa inimioara nu primeste nimic

- **Unde**: `app/lib/features/favorites/favorites_controller.dart`, metoda `toggle()`.
- **Ce este**: `build()` se opreste devreme fara sesiune, `toggle()` nu. Inimioara se
  deseneaza pe fiecare card si in antetul paginii de produs, inclusiv pentru vizitatori.
  O apasare trimite `POST /favorites`, primeste 401 si pe ecran nu se schimba nimic —
  plus un 401 in logurile magazinului la fiecare apasare.
- **Cum se repara**: `toggle()` sa duca la autentificare cand starea nu e `SignedIn`,
  sau inimioara sa nu se deseneze pentru un vizitator.

### 4. Doua copii ale conductei de preturi

- **Unde**: `odoo/uportho_app/controllers/catalog.py` — `_products_with_prices` (noua,
  folosita de `/products`) si ramura cu cont din `_serialize_templates` (folosita de
  randurile de pe Acasa si de `/favorites`).
- **Ce este**: acelasi calcul, scris de doua ori. CLAUDE.md cere explicit ca o lista de
  favorite sa nu poata arata alte preturi decat catalogul; cu doua copii, regula se tine
  din mana. **Deja difera**: prima cheama `_warn_if_tax_display_mismatch`, a doua nu.
- **Cum se repara**: o linie — `_serialize_templates` sa intoarca
  `_products_with_prices(templates, website)` dupa verificarea de vizitator.

### 5. Documentele de produs sunt acum publice; de verificat ca si site-ul le da

- **Unde**: `odoo/uportho_app/controllers/product.py`, `/products/<id>/documents/<id>`.
- **Ce este**: ruta a devenit publica (e in tabelul din spec), dar propriul ei comentariu
  spune inca ca atasamentele **nu** sunt publice si ca Odoo le-ar refuza unui vizitator.
  Daca site-ul nu le da unui om nelogat, aplicatia arata acum strict mai mult decat
  site-ul — contra principiului central al specului.
- **Cum se verifica**: o cerere fara sesiune catre documentul unui produs, pe staging.
  Apoi ori se stramteaza ruta, ori se rescrie comentariul.

### 6. Lipsa de acoperire, nu defecte

- Paza de vizitator din `cartQuantityProvider` (tot ce s-a schimbat la Task 6) n-are test
  propriu, si nici cazul "sesiunea expira in timpul rasfoirii" (401 pe `/cart` →
  starea de vizitator). Comportamentul e corect azi, verificat prin citirea codului.
- Banda de invitatie din catalog n-are test; doar cea de pe Acasa are.
- Fixture-urile de contract nu descriu niciodata forma de **vizitator** (fara preturi).
  De-aici a scapat si defectul paginii de produs: nimic nu putea sa-l prinda.

---

## Datorie tehnica cunoscuta

Nimic din sectiunea asta nu e defect acum. Sunt decizii care devin mai scumpe cu cat sunt
amanate mai mult, cu momentul potrivit notat la fiecare.

### 1. Design system-ul depinde de modelele de wire si cara headere HTTP

- **Unde**: `app/lib/design_system/widgets/banner_card.dart` (primeste un `AppBanner` intreg
  si un `Map<String, String>? httpHeaders`), `app/lib/design_system/widgets/category_chip.dart`
  (acelasi `httpHeaders`), `app/lib/features/home/home_screen.dart` (care ajunge la
  `api.baseUrl` ca sa decida ce headere merg pe fiecare imagine).
- **Ce ar trebui**: widgeturile de design system sa primeasca parametri simpli (titlu,
  subtitlu, text de buton, URL de imagine), fara sa stie de modelele API si fara sa transporte
  autentificare. Maparea model -> parametri sa stea in ecran.
- **De ce a fost amanat**: e refactor, nu defect, si a fost scos deliberat din valul unic de
  fix-uri de la finalul Fazei 1, ca sa nu creasca riscul valului.
- **Cand**: **inainte ca Faza 2 sa scrie widgeturi noi** peste acest cuplaj. Cu cat mai tarziu,
  cu atat mai multe locuri de schimbat.

### 2. `ApiClient.get` nu poate exprima parametri de query

- **Unde**: `app/lib/api/api_client.dart` — `get(String path)`, si `ApiTransport.send`, care
  primeste tot doar `path`.
- **Ce lipseste**: un mod de a trimite `?category_id=&q=&offset=&limit=`, altfel decat lipind
  stringuri in `path` (care nu face escaping si nu se poate verifica in teste).
- **De ce a fost amanat**: in Faza 1 niciun endpoint nu are parametri de query.
- **Cand**: la primul endpoint din Faza 2 —`/products?category_id=&q=&offset=&limit=` — deci
  practic imediat ce incepe catalogul.

### 3. `Price` nu are fixture de contract

- **Unde**: modelul `app/lib/api/models/price.dart`; fixture-urile sunt in
  `odoo/uportho_app/contract/` (`home.json`, `login.json`, `me.json`, `error.json`).
- **Ce este**: singurul model care poarta bani e exact cel pe care mecanismul de contract
  comun nu il acopera. Regula de business a proiectului e ca aplicatia nu face niciodata
  aritmetica pe bani — preturile vin preformatate de la server — deci forma lor e tocmai ce
  ar trebui fixat de un contract.
- **De ce a fost amanat**: in Faza 1 niciun endpoint nu intoarce preturi; modelul a fost
  scris in avans.
- **Cand**: odata cu primul endpoint de produse din Faza 2. Se adauga `product.json` (sau
  `price.json`) in `odoo/uportho_app/contract/`, se ruleaza `app/tool/sync_contract.sh`, si
  se verifica din ambele suite.

### 4. Testele de contract din Python compara doar multimi de chei, nu tipuri

- **Unde**: `odoo/uportho_app/tests/test_controllers_home.py`
  (`test_home_shape_matches_contract`) si `tests/test_controllers_base.py` (`load_contract`).
- **Ce este**: verificarea compara `set(body.keys())` cu `set(contract.keys())`. O schimbare
  de tip — de exemplu `id` care devine string in loc de int — trece verde pe server si pica
  abia in Dart, la decodare.
- **De ce a fost amanat**: verificarea pe chei prinde deja cazul frecvent (camp adaugat,
  redenumit sau scos), iar suita Dart decodeaza fixture-ul in modele tipizate, deci exista o
  a doua plasa.
- **Cand**: cel tarziu odata cu contractul de preturi (punctul 3), unde tipul chiar conteaza.

### 5. `flutter_secure_storage` foloseste optiunile iOS implicite

- **Unde**: `app/lib/api/session_store.dart` — `SecureSessionStore` construieste
  `const FlutterSecureStorage()` fara `IOSOptions`.
- **Ce este**: pe iOS, elementele din Keychain supravietuiesc dezinstalarii aplicatiei. Deci
  id-ul de sesiune ramas de la o instalare anterioara e recitit dupa o reinstalare. Nu e o
  scurgere catre alta persoana (Keychain-ul e al aceluiasi dispozitiv si aceluiasi cont), dar
  e o surpriza: aplicatia proaspat instalata poate porni direct autentificata.
- **De ce a fost amanat**: comportamentul nu s-a manifestat ca defect in verificarile manuale,
  iar sesiunea expirata e oricum tratata corect (`/me` da 401 -> ecran de login).
- **Cum se rezolva**: `IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device)`
  plus stergerea explicita a cheii la prima pornire dupa instalare, marcata intr-un store
  care **nu** supravietuieste dezinstalarii (ex. `shared_preferences`, care ar trebui
  adaugat ca dependinta — acum nu e).

### 8. Adresele noi se adauga doar de pe site, nu din aplicatie

- **Unde**: `odoo/uportho_app/controllers/checkout.py` (`POST /checkout/address` accepta
  doar `delivery_id` / `invoice_id` dintre adresele existente) si
  `app/lib/features/checkout/checkout_screen.dart`.
- **Ce este**: clientul poate alege intre adresele deja salvate pe contul lui, dar nu poate
  adauga una noua din aplicatie. Textul de sub selector spune asta explicit.
- **De ce a fost amanat**: formularul de adresa al magazinului e modificat de client
  (`terrabit_website_invoice_address` — validare de CUI si adresa de facturare separata;
  `deltatech_website_city` — orasul e camp legat, ales dintr-o lista, nu text liber). O a
  doua validare, scrisa de noi, s-ar putea contrazice cu a lor exact la clientii pe care
  contabilitatea ii verifica.
- **Cand**: cand un client real se plange. Solutia corecta e sa chemam validarea lor
  (`WebsiteSale._validate_address_values`), nu sa scriem alta.

### 9. Plata cu cardul se face in pagina magazinului, nu nativ

- **Unde**: `app/lib/features/checkout/payment_webview_screen.dart`, dependinta
  `webview_flutter`.
- **Ce este**: la plata cu cardul, aplicatia deschide `/shop/payment` intr-un WebView cu
  aceeasi sesiune. Ecranul nu arata designul aplicatiei, ci al site-ului.
- **De ce**: in Odoo 18 formularul Stripe e **inline** (JavaScript in pagina), nu o
  redirectionare catre o adresa a providerului. Nu exista URL de plata care sa poata fi
  deschis altfel, iar datele cardului nu au voie sa treaca prin aplicatie. Reprodus nativ,
  ar insemna sa integram Stripe SDK separat si sa tinem doua integrari de plata in
  paralel — exact ce evita tot modulul.
- **Cand**: doar daca Apple/Google Pay intra in scope (spec 9, v1.1). Atunci se verifica
  intai ce suporta providerul configurat.

### 10. Idempotenta la trimiterea comenzii nu e implementata

- **Unde**: `POST /checkout/confirm`.
- **Ce este**: spec-ul initial cerea o cheie `idempotency_key` unica pe `sale.order`, ca a
  doua apasare pe "Trimite comanda" sa intoarca aceeasi comanda in loc sa creeze alta.
- **Ce exista in loc**: butonul e inactiv cat timp cererea e in aer, iar serverul refuza un
  cos care nu mai e ciorna (409 `cart_not_editable`) si o comanda deja platita (verificarea
  lui `_check_cart_is_ready_to_be_paid` plus `amount_paid`). Odoo insusi trateaza a doua
  tranzactie pe aceeasi comanda.
- **Cand**: daca apar comenzi duplicate reale in Odoo. Atunci se adauga campul si indexul
  unic, nu inainte — un camp nou pe `sale.order` se propaga in baza clientului.
