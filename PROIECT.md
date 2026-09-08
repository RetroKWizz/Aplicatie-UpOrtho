# Proiect: Aplicatie UpOrtho (Flutter, iOS + Android)

## Obiectiv

Aplicatie mobila de sine statatoare, cross-platform (Flutter, un singur cod pentru
iPhone si Android), pentru clientii uportho.ro. Foloseste Odoo ca backend (acelasi
cont client, aceleasi facturi, aceeasi structura de produse/categorii/preturi ca pe
site), printr-un modul Odoo propriu (`odoo/uportho_app/`) care expune un API JSON
(`/api/app/v1`), nu XML-RPC direct. Design vizual propriu, dar cu culorile reale de
brand ale site-ului. Verificare si lansare: **intai iOS**; Android ramane configurat,
neexercitat curent.

## Reguli critice

- **Niciodata nu se modifica ceva in Odoo real (uportho.ro / odoo.sh) fara acordul
  explicit al lui Mihai.** Toata dezvoltarea ruleaza contra unei instante Odoo locale
  in Docker. Doar citire pe Odoo real, pana la alta instructiune.
- Fara Apple Developer Account / Google Play Console inca — de facut inainte de
  publicarea in store (Faza 5).

## Decizii de arhitectura

- Motorul din spate a fost rescris ca modul Odoo propriu in loc de Odoo Studio +
  XML-RPC, ca sa existe un API JSON stabil, versionat, testat — o migrare Odoo 19
  (asteptata in 3-9 luni) se repara intr-un singur loc, in Python, fara release nou
  de aplicatie.
- Vechiul prototip nativ SwiftUI (`Rezultate/UPorthoApp/`) e arhivat, nu mai e
  produsul curent. A lasat mostenire comportamentul de pricelist si harta rutelor de
  checkout, preluate in spec-ul de design.

## Ce a ramas de facut din Faza 0-1

Lucrurile amanate constient sunt scrise in **`docs/DE-FACUT.md`**: setarile de
dezvoltare care trebuie scoase inainte de lansare (trafic HTTP in clar pe Android,
ruta de debug din modulul Odoo, semnarea Android cu chei de debug, numele de
placeholder ale aplicatiei) si datoria tehnica cunoscuta (cuplajul design system <->
modele API, parametrii de query lipsa din clientul API, contractul de preturi
inexistent). De citit inainte de Faza 2 si inainte de Faza 5.

## Faze (spec: `docs/superpowers/specs/2026-09-07-uportho-flutter-odoo-design.md`)

### Faza 0-1 — Fundatie (plan: `docs/superpowers/plans/2026-09-07-faza-0-1-fundatie.md`) — LIVRATA

- [x] Modul Odoo `uportho_app`: banner + categorii rapide, autentificare pe sesiune,
  `/home`, rute de imagine, model device pentru push (46 teste)
- [x] Editare continut din backend Odoo (Website → Aplicatie mobila), fara developer
- [x] Mediu local: Docker Odoo 18 + Postgres, `run-tests.sh`
- [x] Aplicatie Flutter: proiect, design system (culori/tipografie/tema din brand),
  login + restaurare sesiune, ecran Acasa, tab bar cu 4 taburi (80 teste,
  `flutter analyze` curat)
- [x] Contract JSON comun Odoo <-> Flutter, sincronizat prin `sync_contract.sh`
- [ ] Export Odoo Studio ca plasa de siguranta — **decizie deschisa a userului**
- [ ] Deploy pe odoo.sh — sarit deliberat, **decizie deschisa a userului**

### Faza 2 — Catalog

- [ ] `/categories`, `/products`, `/products/<id>` cu serializator de pret
  (pricelist-uri Odoo: Public 45 / Ortho Club 59, tiers normalizate)
- [ ] `recommended` in `/home`
- [ ] Ecrane catalog / cautare / detaliu, `PriceText`, badge-uri

### Faza 3 — Cumparare

- [ ] Cos, checkout, confirm cu idempotenta
- [ ] Plata offline + WebView card (provider `card` prov 8 / `wire_transfer` prov 5
  pe instanta), curieri Fan Courier 3/5, ridicare 4, `country_id` 188, judete 710-751
- [ ] **Trimiterea reala a unei comenzi necesita acord explicit inainte de implementare**

### Faza 4 — Cont

- [ ] Comenzi, facturi PDF
- [ ] Push FCM din modul (foloseste `uportho.app.device`, deja in modul)
- [ ] Proiect Firebase (deschis, nefacut inca)

### Faza 5 — Lansare

- [ ] Cont Apple Developer, cont Google Play Console (deschise, nefacute inca)
- [ ] Iconite, screenshots, descriere store

### Faza 6 — Migrare Odoo 19

- [ ] De executat cand Odoo 19 devine disponibil pe instanta; scop: schimbari izolate
  in modulul `uportho_app`, fara release de aplicatie
