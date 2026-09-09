# Pagina de produs — plan de implementare

> **Pentru agenti:** SUB-SKILL OBLIGATORIU: `superpowers:subagent-driven-development`.
> **Un singur implementer o data.** Doi agenti care scriu in acelasi worktree si-au
> inghitit reciproc fisierele in sesiunea de catalog; nu se repeta.

**Scop:** ruta `GET /products/<id>` in modulul Odoo si ecranul de detaliu in aplicatie,
cu tot ce se vede pe pagina de produs de pe uportho.ro.

**Arhitectura:** aplicatia nu reimplementeaza nimic din Odoo — preturile, variantele si
disponibilitatea vin din API-urile Odoo (`_get_combination_info`, `_get_product_price`),
iar tot ce e text formatat (sume, descriere) pleaca gata pregatit de pe server.

**Spec:** `docs/superpowers/specs/2026-09-07-uportho-flutter-odoo-design.md` (sectiunile
2, 6.4, 12, 13 — faza 2)

## Constrangeri globale

- Aplicatia **nu face aritmetica si nu formateaza sume**. Orice suma afisata vine ca sir
  gata format de la server (`formatted`, `list_formatted`, la fel ca in `/products`).
- Nicio scriere in Odoo real. Dezvoltare pe `http://localhost:8069`, baza `uportho_test`.
- Toate rutele: `type='http'`, coduri HTTP reale, eroare unica
  `{"error": {"code", "message", "details"}}`, header `X-UpOrtho-App: 1` pe non-GET.
- Contractul e sursa de adevar: `odoo/uportho_app/contract/*.json`, sincronizat in
  `app/test/contract/` cu `app/tool/sync_contract.sh`. Ambele suite il verifica.
- Niciun id de lista de preturi, de website sau de atribut nu se scrie in cod. Vine din
  parametri de sistem sau din inregistrare.
- Testele nu depind de datele preexistente din baza: fiecare test isi creeaza singur ce
  are nevoie si filtreaza pe id-urile proprii.
- Riverpod 3: fiecare provider al carui `build()` poate arunca primeste
  `retry: (retryCount, error) => null`.
- Zero pachete Flutter noi. Video-ul se deschide in exterior cu `url_launcher`, care e
  deja dependinta.

## Ce s-a numarat in baza reala (staging, 2026-09-09)

Cifrele astea decid ce e obligatoriu si ce e optional in randare. Din 619 produse
publicate pe website 11:

| Insusire | Produse |
|---|---|
| mai multe variante | 265 (43%) |
| linii de atribute | 618 |
| descriere web | 605 |
| poze suplimentare | 418 |
| mesaj de stoc (`out_of_stock_message`) | 579 |
| `show_availability` | 210 |
| ribbon Odoo (`website_ribbon_id`) | **0** |
| brand din modelul temei (`dr_brand_id`) | **0** |

Poze: 3157 in total, din care 135 cu `video_url`.
Praguri de cantitate: 75 de reguli pe lista publica (45), **0** pe lista Ortho Club (59).

Consecinte obligatorii:

1. **Fiecare sectiune e optionala.** 354 de produse n-au variante, 214 n-au praguri de
   cantitate, 14 n-au descriere. Ecranul nu are sloturi fixe: o sectiune fara date nu se
   deseneaza deloc (nu se deseneaza goala).
2. **Brandul e un atribut, nu un camp.** `dr_brand_id` e gol peste tot; "DB Orthodontics"
   vine din liniile de atribute. Blocul de brand si tabelul de specificatii se alimenteaza
   din aceeasi sursa — nu se citeste `dr_brand_id`.
3. **Ribbon-ul "Nou -20%" nu e `website_ribbon_id`** (zero produse il folosesc). Partea
   "-20%" se deduce din `discount_pct`, deja in contract; partea "Nou" vine din
   `app_badge_text`, campul nostru din Faza 1, editabil din Odoo.
4. **Tabelul de club are un singur rand azi.** Se construieste tot ca lista de praguri, ca
   sa nu se rupa cand se adauga praguri la o lista viitoare.

---

## Structura fisierelor

**Server** (`odoo/uportho_app/`)
- `controllers/product.py` — **nou**: `GET /products/<id>`, `GET /products/<id>/gallery/<image_id>`
- `controllers/catalog.py` — se refolosesc `serialize_price`, `_format_amount`,
  `_current_club_pricelist`; nimic duplicat
- `models/app_benefit.py` — **nou**: `uportho.app.benefit` (blocurile de magazin)
- `models/product_template.py` — descriere in blocuri, praguri de cantitate, specificatii
- `views/app_benefit_views.xml` — **nou**: ecran de editare + intrare de meniu
- `security/ir.model.access.csv` — acces la modelul nou
- `contract/product_detail.json`, `contract/benefits.json` — **noi**
- `tests/test_controllers_product.py`, `tests/test_app_benefit.py` — **noi**

**Aplicatie** (`app/`)
- `lib/api/models/product_detail.dart`, `variant.dart`, `price_tier.dart`,
  `description_block.dart`, `spec.dart`, `benefit.dart`, `product_review.dart` — **noi**
- `lib/features/product/product_repository.dart`, `product_controller.dart`,
  `product_screen.dart` — **noi**
- `lib/design_system/widgets/image_gallery.dart`, `price_tier_table.dart`,
  `description_view.dart`, `variant_picker.dart` — **noi**
- `lib/features/catalog/catalog_screen.dart` — apasarea pe card deschide detaliul
- `lib/router.dart` — ruta `/catalog/:id`

---

## Contract: `GET /products/<id>`

Parametru optional `variant_id` — id de `product.product`. Fara el, serverul intoarce
combinatia implicita. Aplicatia il retrimite cand utilizatorul schimba o varianta.

```json
{
  "id": 101,
  "variant_id": 501,
  "name": "Cleste Tie Back mare (.016 - .021x.025) Ixion",
  "default_code": "IX954",
  "badge": { "text": "Nou", "color": "blue" },
  "images": [
    { "id": 11, "url": "/api/app/v1/products/101/gallery/11?unique=3a1f9c2", "kind": "image" },
    { "id": 14, "url": "/api/app/v1/products/101/gallery/14?unique=9b2e1d0",
      "kind": "video", "video_url": "https://www.youtube.com/watch?v=xxxx" }
  ],
  "price": {
    "amount": 1120.0, "currency": "RON", "formatted": "1.120,00 lei", "with_vat": true,
    "list_amount": 1399.99, "list_formatted": "1.399,99 lei", "discount_pct": 20
  },
  "club_price": {
    "amount": 1120.0, "currency": "RON", "formatted": "1.120,00 lei", "with_vat": true,
    "list_amount": null, "list_formatted": null, "discount_pct": null
  },
  "tiers": [
    { "min_qty": 1, "label": "1+", "price": { "formatted": "1.399,99 lei", "amount": 1399.99, "currency": "RON", "with_vat": true, "list_amount": null, "list_formatted": null, "discount_pct": null } },
    { "min_qty": 3, "label": "3+", "price": { "formatted": "1.120,00 lei", "amount": 1120.0, "currency": "RON", "with_vat": true, "list_amount": null, "list_formatted": null, "discount_pct": null } }
  ],
  "club_tiers": [
    { "min_qty": 1, "label": "1+", "price": { "formatted": "1.120,00 lei", "amount": 1120.0, "currency": "RON", "with_vat": true, "list_amount": null, "list_formatted": null, "discount_pct": null } }
  ],
  "variants": {
    "attributes": [
      { "id": 7, "name": "Marime",
        "values": [
          { "id": 1357, "name": "Mare", "selected": true, "available": true },
          { "id": 1358, "name": "Mic", "selected": false, "available": true }
        ] }
    ]
  },
  "specs": [ { "name": "Brand", "value": "DB Orthodontics" } ],
  "description": [
    { "type": "heading", "spans": [ { "text": "Cleste Tie Back pentru arcuri groase", "bold": true } ] },
    { "type": "paragraph", "spans": [ { "text": "Clestele este conceput pentru...", "bold": false } ] },
    { "type": "bullets", "items": [
      { "spans": [ { "text": "Falci zimtate care asigura o prindere ferma.", "bold": false } ] }
    ] }
  ],
  "availability": { "message": "Precomanda. Livrare incepand cu 1 August", "in_stock": true },
  "rating": { "average": 0.0, "count": 0 },
  "reviews": [
    { "author": "Ana P.", "rating": 5, "date": "2026-02-14", "text": "Foarte bun." }
  ],
  "similar": [ { "id": 102, "name": "...", "default_code": null, "image_url": null,
                 "price": {}, "club_price": null, "badge": null } ],
  "benefits": [
    { "icon": "club", "title": "Alatura-te Ortho Club", "text": "pentru extra beneficii" },
    { "icon": "delivery", "title": "Livrare gratuita", "text": "pentru comenzi de peste 400 lei" },
    { "icon": "return", "title": "Retur gratuit", "text": "30 de zile" },
    { "icon": "payment", "title": "Plata online sigura", "text": "prin Stripe" }
  ]
}
```

Reguli de forma, obligatorii:

- `club_price`, `variants`, `availability`, `badge` sunt `null` cand nu se aplica.
- `tiers`, `club_tiers`, `specs`, `description`, `reviews`, `similar`, `benefits`,
  `images` sunt liste; goale, niciodata `null`.
- Elementele din `similar` au **exact** forma unui produs din `/products` — acelasi
  serializator, ca sa se refoloseasca `ProductCard` fara conversii.
- 404 daca produsul nu e publicat sau nu apartine website-ului configurat.
- `variant_id` care nu apartine produsului: 422, nu 500.

---

## Task 1: model `uportho.app.benefit` + ecran de editare

**Fisiere:** creeaza `models/app_benefit.py`, `views/app_benefit_views.xml`,
`tests/test_app_benefit.py`, `contract/benefits.json`; modifica `models/__init__.py`,
`security/ir.model.access.csv`, `views/menus.xml`, `__manifest__.py`.

Campuri: `name` (titlu, obligatoriu), `text` (subtitlu), `icon` (Selection:
`club`, `delivery`, `return`, `payment`, `info`), `sequence` (integer, default 10),
`active` (boolean, default True).

Intrare de meniu langa Bannere, sub **Website → Aplicatie mobila → Beneficii**.
Acces: citire pentru `base.group_user`, scriere pentru `website.group_website_designer`
— aceleasi grupuri ca la `uportho.app.banner`, se copiaza de acolo.

- [ ] Test intai: un beneficiu inactiv nu apare in citirea folosita de controller;
      ordinea respecta `sequence`; testul isi creeaza propriile inregistrari si
      filtreaza pe id-urile lor.
- [ ] Model + view + securitate + meniu.
- [ ] `contract/benefits.json` cu forma listei.
- [ ] Rulare `odoo/run-tests.sh`, apoi commit.

## Task 2: descriere in blocuri + specificatii + praguri de cantitate

**Fisiere:** modifica `models/product_template.py`; testeaza in
`tests/test_product_template.py`.

Trei metode noi pe `product.template`:

`_uportho_description_blocks()` — ia `website_description`, pastreaza doar sectiunea in
romana (spec sectiunea 12) si o transforma in blocurile din contract. Etichete acceptate:
`h1`-`h4` → `heading`, `p` → `paragraph`, `ul`/`ol` → `bullets`. `strong`/`b` si `em`/`i`
devin `bold`/`italic` pe span. Orice altceva se aplatizeaza la text. HTML gol → lista
goala. **Nu se trimite HTML catre aplicatie** — aplicatia nu are motor HTML si nu vrem
sa introducem unul.

`_uportho_specs()` — perechi nume/valoare din `attribute_line_ids`, in ordinea lor.
Aici apare si brandul, pentru ca brandul **este** un atribut (vezi cifrele de mai sus).

`_uportho_price_tiers(pricelist, partner, fiscal_position)` — pragurile:
1. praguri candidate = valorile distincte `min_quantity` din regulile listei aplicabile
   produsului, plus `1`;
2. pentru fiecare prag, pretul se cere de la Odoo cu acea cantitate (aceeasi cale ca in
   `catalog.py`, cu `quantity=prag`) — **nu se recalculeaza procente in Python**;
3. praguri consecutive cu pret identic se elimina, pastrandu-l pe cel mai mic;
4. daca ramane un singur prag si acesta e 1, lista are un singur element (nu se
   intoarce goala — tabelul de club arata exact asa azi);
5. eticheta: `min_qty` 0 sau 1 → `"1+"`, altfel `"<n>+"`.

- [ ] Teste intai, cate unul pe regula de mai sus. Pentru punctul 3 un test cu trei
      praguri din care doua au acelasi pret.
- [ ] Implementare.
- [ ] `odoo/run-tests.sh`, commit.

## Task 3: ruta `GET /products/<id>`

**Fisiere:** creeaza `controllers/product.py`, `tests/test_controllers_product.py`,
`contract/product_detail.json`; modifica `controllers/__init__.py`.

- Variantele: `product.template._get_combination_info(...)` — API-ul pe care il
  foloseste si site-ul. `available` pe valoare vine din combinatiile posibile, nu se
  deduce singur. Produs fara `attribute_line_ids` cu mai multe valori → `variants: null`.
- `similar`: `alternative_product_ids` daca sunt setate, altfel produsele din aceeasi
  `public_categ_ids`, maxim 10, fara produsul curent, doar publicate pe website-ul
  configurat. Se serializeaza cu **acelasi** serializator ca `/products`.
- `availability`: `out_of_stock_message` (curatat de HTML) si starea de stoc; `null`
  cand produsul n-are mesaj si `show_availability` e fals.
- `rating` / `reviews`: din `rating.rating` legate de produs; maxim 20 de recenzii,
  cele mai noi primele. Fara recenzii → `rating` cu zerouri si `reviews: []`.
- `benefits`: din `uportho.app.benefit`, active, ordonate.
- Imaginile: ruta `/products/<id>/gallery/<image_id>` autentificata, cu `?unique=` din
  `write_date`, exact ca rutele de imagine existente. Nu se citeste tot campul binar ca
  sa se decida daca exista o imagine — se verifica prin `ir.attachment`, ca in
  `catalog.py`.

- [ ] Teste intai: forma completa contra `contract/product_detail.json`; 404 pentru
      produs nepublicat; 422 pentru `variant_id` strain; produs fara variante /
      fara praguri / fara descriere — fiecare cu campul corect gol sau `null`.
- [ ] Implementare.
- [ ] `odoo/run-tests.sh`, `app/tool/sync_contract.sh`, commit.

## Task 4: modele si repository in aplicatie

**Fisiere:** modelele noi din `lib/api/models/`, `lib/features/product/product_repository.dart`,
teste in `test/api/product_detail_models_test.dart`.

`freezed` 4.x: `abstract class X with _$X`. Dupa editare:
`dart run build_runner build --delete-conflicting-outputs`.

- [ ] Teste intai, care citesc `test/contract/product_detail.json`.
- [ ] Modele + repository (`getProduct(int id, {int? variantId})`).
- [ ] `flutter test`, `flutter analyze`, commit.

## Task 5: widgeturi de design system

**Fisiere:** `image_gallery.dart`, `price_tier_table.dart`, `description_view.dart`,
`variant_picker.dart` + teste.

- Galeria: poze pe orizontala cu indicator; elementul `kind: "video"` arata miniatura cu
  buton de redare si deschide `video_url` in exterior cu `url_launcher`. **Fara pachet
  video nou.**
- Tabelul de praguri: doua sau mai multe coloane, derulabil orizontal daca nu incape.
  Randul curent (cantitatea 1) evidentiat.
- `description_view`: randeaza blocurile din contract. Fara HTML.
- `variant_picker`: cate un grup de butoane per atribut; valorile indisponibile aratate
  dezactivat, nu ascunse.

Fiecare widget primeste un test care il pune intr-un card ingust cu text romanesc lung —
acolo au aparut si data trecuta depasirile de latime.

- [ ] Teste intai, implementare, `flutter test`, commit.

## Task 6: ecranul de produs + navigare

**Fisiere:** `product_controller.dart`, `product_screen.dart`, `router.dart`,
`catalog_screen.dart` + teste.

Ordinea pe ecran, de sus in jos, ca pe site: galerie, badge, titlu, stele + numar
recenzii, pret + pret taiat + procent + "Taxe incluse", tabel cantitati, tabel Ortho
Club, selector de variante, mesaj de disponibilitate, buton **Adauga in cos dezactivat**
cu textul "Disponibil la pasul urmator", beneficii, cod produs, descriere, specificatii,
recenzii, produse similare.

- Schimbarea unei variante recere produsul cu `variant_id` si actualizeaza pret, cod si
  galerie, fara sa reincarce tot ecranul.
- Apasarea pe un produs similar deschide detaliul lui.
- `retry: (retryCount, error) => null` pe provider.
- **Fiecare sectiune fara date dispare complet.** Test explicit pentru un produs fara
  variante, fara praguri si fara descriere — 354 din 619 produse arata asa.

- [ ] Teste intai, implementare, `flutter test`, `flutter analyze`, commit.

## Task 7: verificare pe staging

- [ ] Urcare modul pe staging (procedura din `docs/STAGING.md`), `odoo-update`,
      `odoosh-restart http`.
- [ ] Creare beneficii in Odoo, cu textele de pe site.
- [ ] Aplicatia pe simulator contra staging; capturi pentru: produs cu variante, produs
      fara variante, produs cu praguri de cantitate, produs cu video.
- [ ] Actualizare `docs/STAGING.md` si `CLAUDE.md` cu ce s-a schimbat.
