# Aplicatie UpOrtho iOS + Android — design

Data: 2026-09-07
Status: aprobat in brainstorming, in asteptarea revizuirii finale

## 1. Obiectiv

O singura aplicatie mobila (iOS + Android), publicata in App Store si Google Play,
pentru clientii uportho.ro. Foloseste Odoo ca backend (aceleasi conturi, produse,
preturi, comenzi si facturi ca site-ul), dar cu design vizual propriu, independent de
site. Aplicatia trebuie sa functioneze pe Odoo 18 si sa supravietuiasca migrarii la
Odoo 19 (estimata in 3-9 luni) fara release in magazine.

## 2. Fapte despre mediu (verificate)

- Odoo 18 Enterprise (`server_version: "18.0+e"`), gazduit pe odoo.sh, baza
  `uportho-main-4035869`. Acces git de deploy: da.
- Checkout-ul site-ului depinde de tema terta `theme_prime`; markup-ul ei nu e un
  contract si se schimba fara aviz.
- Pricelist-uri relevante: Public (id 45) si Ortho Club (id 59). `website_id` = 11.
- Toolchain local (macOS): Xcode 26.6 prezent; Flutter, Dart, Android SDK, CocoaPods
  lipsesc. Cont Apple Developer si Google Play Console: inca nu exista.
- Regula de proiect (CLAUDE.md): nimic nu se modifica in Odoo fara acceptul explicit
  al lui Mihai. Se aplica fiecarui deploy pe odoo.sh, de fiecare data.

## 3. Decizii luate

| Decizie | Alegere | Motiv |
|---|---|---|
| Client | Un singur cod cross-platform | Echipa mica; fiecare feature se scrie o data |
| Framework | Flutter | Deseneaza fiecare pixel: design propriu, identic pe ambele platforme |
| Backend API | Modul Odoo custom `uportho_app` pe odoo.sh | Acces direct la ORM, fara server suplimentar; la 19 se repara un singur loc |
| Scop v1 | Acasa + catalog + detaliu, cos + checkout, cont + comenzi + facturi, push | Cerinta userului |
| Plata v1 | Transfer bancar / ramburs (nativ) + card prin providerul site-ului (WebView) | Apple Pay / Google Pay in v1.1, conditionat de provider |
| SwiftUI existent | Arhivat ca referinta in `Rezultate/UPorthoApp/` | Cunostintele despre Odoo se pastreaza (sectiunea 12) |

## 4. Arhitectura

```
+------------------+   /api/app/v1/*   +---------------------+        +------------+
|  App Flutter     | ----------------> |  Modul uportho_app  | <----> |  Odoo 18   |
|  iOS + Android   |   JSON, HTTPS     |  (Python, odoo.sh)  |  ORM   |  (apoi 19) |
+------------------+                   +---------------------+        +------------+
         ^                                       |
         +-------- push (FCM) --------------------+
```

Principiul de independenta: aplicatia cunoaste un singur contract, `/api/app/v1`.
Nu stie ce e Odoo, ce versiune are, ce tema are site-ul. La migrarea pe 19 se schimba
interiorul modulului; contractul si aplicatia raman neschimbate.

## 5. Aplicatia Flutter

### 5.1 Stack

| Rol | Pachet |
|---|---|
| Stare | `riverpod` |
| Navigare | `go_router` |
| HTTP | `dio` |
| Modele | `freezed` + `json_serializable`, generate din contract |
| Sesiune | `flutter_secure_storage` (Keychain / Keystore) |
| Push | `firebase_messaging` |
| Plata card | `webview_flutter` |
| Poze | `cached_network_image` |

### 5.2 Structura

```
lib/
  api/              client HTTP + modele generate din contract; singurul loc care stie de v1
  design_system/    culori, tipografie, componente (card produs, pret, badge, banner)
  features/
    auth/  home/  catalog/  product/  cart/  checkout/  account/  orders/  invoices/
      -> fiecare: ecrane, provideri riverpod, modele de UI
  app.dart          router + tema
test/
  contract/         fixture JSON comune cu modulul (copiate din repo-ul modulului)
```

### 5.3 Reguli

- Aplicatia nu face aritmetica pe bani. Afiseaza `formatted` primit de la server:
  pret, tiers, total cos, TVA, discount. Daca apare o inmultire pe un pret in Dart,
  e un bug.
- Ordinea sectiunilor de pe Acasa (hero, categorii rapide, promo, oferta, recomandate)
  e fixa in cod. Nu exista model de configurare pentru ea.
- Un singur apel `/home` la pornire, nu trei.
- Pozele vin ca URL-uri si se cacheaza prin HTTP; niciodata base64 in JSON.

## 6. Modulul Odoo `uportho_app`

### 6.1 Endpoint-uri v1

Toate sub `/api/app/v1`, `auth='user'`, `type='http'` cu raspuns JSON si cod HTTP real.

```
POST /auth/login                  {login, password}  -> sesiune (cookie) + profil
POST /auth/logout
GET  /home                        bannere + categorii rapide + recomandari
GET  /categories                  arbore
GET  /products?category_id=&q=&offset=&limit=
GET  /products/<id>               variante, tiers, pret Ortho Club, descriere, badge
GET  /cart
POST /cart/lines                  {product_id, quantity}; quantity 0 sterge linia
GET  /checkout                    adrese + curieri disponibili + totaluri
POST /checkout/address            {partner_id} sau adresa noua
POST /checkout/delivery           {carrier_id} -> totaluri recalculate
GET  /checkout/payment-methods
POST /checkout/confirm            {payment_method_id, idempotency_key}
GET  /orders                      lista cu status
GET  /orders/<id>
GET  /invoices
GET  /invoices/<id>/pdf
POST /devices                     {fcm_token, platform}
DELETE /devices/<fcm_token>
```

`/auth/login` e exceptia de la `auth='user'` (`auth='public'`), si foloseste
mecanismul standard de autentificare Odoo (`request.session.authenticate`).

### 6.2 Modele de continut (inlocuiesc Studio)

Model nou `uportho.app.banner`:

| Camp | Tip |
|---|---|
| `name` | Char, obligatoriu (titlu) |
| `subtitle` | Char |
| `cta_text` | Char, default "Vezi produse" |
| `image` | Image |
| `placement` | Selection: `hero`, `promo` |
| `link_type` | Selection: `category`, `url`, `none` |
| `category_id` | Many2one `product.public.category` |
| `external_url` | Char |
| `sequence` | Integer |
| `active` | Boolean (arhivare standard) |
| `date_start`, `date_end` | Date |
| `website_id` | Many2one `website` |

Campuri adaugate pe `product.public.category`: `app_home_visible` (Boolean),
`app_home_sequence` (Integer), `app_home_icon` (Image).

Campuri adaugate pe `product.template`: `app_badge_text` (Char), `app_badge_color`
(Selection: `orange`, `green`, `blue`, `purple`, `red`), `app_badge_date_end` (Date).

Modulul aduce vizualizari list/form si un meniu sub Website pentru bannere, plus
campurile pe formularele existente de categorie si produs. Continutul ramane editabil
din backend fara programator.

Model `uportho.app.device`: `user_id`, `fcm_token` (unic), `platform`
(`ios`/`android`), `last_seen`.

Model `uportho.app.campaign` (push manual): `name`, `title`, `body`, `link_type`,
`category_id`, `external_url`, `sent_at`, buton "Trimite".

### 6.3 Push

Modulul trimite prin FCM HTTP v1 (cont de serviciu Firebase in parametrii de sistem
Odoo). Declansatoare: schimbare de stare pe `sale.order` (confirmata, livrata) si
campanii manuale. FCM livreaza si pe iOS prin APNs, deci un singur canal.

### 6.4 Preturi

Modulul foloseste mecanismele Odoo de pricelist (`_get_combination_info` /
`price_compute` cu pricelist si cantitate) si de taxe. Nu reimplementeaza reguli.
Pentru fiecare produs intoarce: pretul la cantitatea 1 pe pricelist-ul userului,
pretul Ortho Club (pricelist 59) cand difera, si lista de tiers (praguri distincte de
`min_quantity`, cu pragurile 0 si 1 normalizate la "1+", si pragurile consecutive cu
acelasi pret eliminate — comportamentul site-ului, verificat pe produsul template
17210).

## 7. Contractul v1

- Versionare in cale. `v1` nu primeste schimbari incompatibile; cand e nevoie apare
  `v2` servit in paralel, ca aplicatiile deja instalate sa continue sa mearga.
- Preturi: obiect `{ "amount": 149.90, "currency": "RON", "formatted": "149,90 lei",
  "with_vat": true, "list_amount": 189.90, "discount_pct": 21 }`. Tiers: lista de
  `{ "min_qty", "amount", "formatted" }`.
- `idempotency_key` (UUID generat de client) la `/checkout/confirm`. Al doilea apel cu
  aceeasi cheie intoarce aceeasi comanda, nu creeaza alta. Cheile se pastreaza pe
  `sale.order` (camp `app_idempotency_key`, unic).
- Erori: `{ "error": { "code": "...", "message": "...", "details": {...} } }` cu cod
  HTTP (401 neautentificat, 404 negasit, 409 conflict, 422 validare, 500 intern).
  `message` e text pentru utilizator, tradus de Odoo.
- Fixture JSON: folder `contract/` in repo-ul modulului, cu cate un exemplu de raspuns
  per endpoint. Testele Python verifica raspunsurile reale contra lor; testele Flutter
  decodeaza aceleasi fisiere. O schimbare de forma pica intai pe server.

## 8. Autentificare si securitate

- Toate rutele (mai putin login) sunt `auth='user'`. Regulile de acces Odoo se aplica
  automat: un utilizator nu poate citi comenzile altuia pentru ca ORM-ul refuza.
- Sesiunea e cookie-ul standard Odoo, pastrat in secure storage. Parola nu se
  persista in aplicatie. La 401, aplicatia cere re-login.
- POST-urile au `csrf=False` (nu exista formulare) si cer header obligatoriu
  `X-UpOrtho-App: 1`. Un browser nu poate trimite headere custom cross-origin fara
  preflight CORS (pe care nu il permitem), deci un site ostil nu poate face cereri
  autentificate in numele utilizatorului.
- Deploy pe odoo.sh (dev, staging, productie) doar cu confirmarea explicita a lui
  Mihai, de fiecare data.

## 9. Plata

- Transfer bancar / ramburs: `confirm` creeaza comanda si intoarce
  `{ "order_ref", "payment": { "kind": "offline", "instructions": "..." } }`.
- Card: `confirm` creeaza tranzactia prin providerul configurat in Odoo si intoarce
  `{ "order_ref", "payment": { "kind": "redirect", "url": "...", "return_url_prefix":
  "..." } }`. Aplicatia deschide `url` in WebView si inchide fluxul cand URL-ul
  curent incepe cu `return_url_prefix`; apoi cere `/orders/<id>` pentru starea finala.
  Datele de card nu trec niciodata prin aplicatie.
- Apple Pay / Google Pay: v1.1, dupa ce se verifica (Faza 0) ce provider e configurat
  si daca le suporta.

## 10. Testare

- Python: `TransactionCase` pentru logica (filtrare bannere dupa date/website,
  preturi si tiers, idempotenta la confirm) si `HttpCase` pentru fiecare endpoint.
  odoo.sh le ruleaza automat la fiecare push pe branch de dev/staging.
- Flutter: teste unit pe decodarea fixture-urilor comune; teste widget pe componentele
  din `design_system`; un test de integrare pe fluxul login -> produs -> cos ->
  confirm, rulat contra staging-ului.
- Manual pe staging: o comanda completa pe fiecare metoda de plata. Niciodata pe
  productie.

## 11. Migrare Odoo 19 si rollback

1. Pe odoo.sh se cere un build de staging upgradat la 19 (productia nu se atinge).
2. Testele modulului ruleaza acolo; ce pica se repara in Python.
3. Aplicatia deja publicata, neschimbata, se indreapta spre staging-ul 19 (endpoint
   configurabil intr-un build intern) si se parcurge fluxul complet.
4. Daca `v1` tine, productia trece pe 19 fara release iOS/Android.

Rollback: modulul e in git; revert + redeploy. Contractul `v1` e acelasi inainte si
dupa, deci un rollback de modul nu cere release. Sesiunile utilizatorilor nu se ating.

## 12. Cunostinte pastrate din aplicatia SwiftUI

Codul din `Rezultate/UPorthoApp/` ramane in repo ca referinta. Ce s-a invatat acolo si
conteaza pentru modul:

- Pricelist: regula cea mai specifica castiga (`1_product` > `2_product_category` >
  `3_global`), la egalitate cea cu `min_quantity` cea mai mare; `compute_price` e
  `percentage` sau `fixed`. Tiers: praguri distincte, 0 si 1 afisate ca "1+",
  praguri consecutive cu pret identic eliminate. Modulul obtine acelasi rezultat prin
  API-ul Odoo, nu prin reimplementare, dar testele verifica exact acest comportament.
- Categorii de site: `product.public.category` filtrat pe `website_id = 11`;
  `categ_id` (categoria contabila) e alta decat `public_categ_ids` si e cea folosita
  de regulile de pricelist pe categorie.
- Checkout `website_sale` (Odoo 18): `/shop/cart/update_json`, `/shop/checkout`,
  `/shop/update_address`, `/shop/address/submit`, `/shop/set_delivery_method`,
  `/shop/get_delivery_rate`, `/shop/payment`, `/shop/payment/transaction`,
  `/payment/status`. Modulul apeleaza aceleasi metode de model pe care le folosesc
  aceste controllere (`sale.order._cart_update`, `_get_delivery_methods`,
  `set_delivery_line`, `payment.transaction`), nu rutele HTTP si nu HTML-ul.
- Descrierea produsului (`website_description`) contine sectiuni in mai multe limbi;
  se pastreaza doar cea in romana, convertita la text simplu. Se muta in modul.
- Poza de produs: `/web/image/product.template/<id>/image_512`.

## 13. Faze de livrare

| Faza | Continut | Livrabil |
|---|---|---|
| 0 Pregatire | Instalare Flutter, Android SDK, CocoaPods; `flutter doctor` verde. Cont Apple Developer si Google Play Console. Proiect Firebase (iOS + Android). Verificare provider de plata in Odoo. Export modul Studio in repo. Branch dev pe odoo.sh. | Mediu functional |
| 1 Fundatie | Modul schelet + `/auth` + `/home` + modele continut + ecrane editare + `/devices`. App: design system, login, Acasa. | App care se logheaza si arata Acasa din Odoo |
| 2 Catalog | `/categories`, `/products`, `/products/<id>` cu preturi Odoo. App: catalog, cautare, detaliu. | Catalog complet |
| 3 Cumparare | `/cart`, `/checkout/*`, `/confirm` cu idempotenta; plata offline + WebView card. App: cos, checkout, plata. | Comanda reala pe staging |
| 4 Cont | `/orders`, `/invoices`, PDF; push FCM din modul. App: cont, comenzi, facturi, notificari. | App complet |
| 5 Lansare | TestFlight + Internal Testing; listing-uri; publicare. | v1 in magazine |
| 6 Odoo 19 | Staging 19, teste, fix modul, switch productie. | Fara release in magazine |

Fiecare faza e utilizabila singura. Retragerea Studio (`x_app_banner`) se face dupa
Faza 1, cand bannerele sunt recreate manual in modelul nou si aplicatia le citeste.

## 14. In afara scopului v1

- Apple Pay / Google Pay (v1.1)
- Configurarea ordinii sectiunilor de pe Acasa din Odoo
- Migrare automata de date din modelul Studio (sunt cateva randuri, se refac manual)
- Mod offline / cache persistent de catalog
- Server intermediar (BFF) — daca vreodata e nevoie, se pune in spatele aceluiasi
  contract `v1`, fara schimbari in aplicatie
