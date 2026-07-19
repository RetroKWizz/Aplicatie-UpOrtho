# Proiect: Aplicatie iOS UpOrtho

## Obiectiv

Aplicatie de sine statatoare pentru iOS (nativa, SwiftUI), descarcabila din App Store,
pentru clientii uportho.ro. Foloseste Odoo ca backend (acelasi cont client, aceleasi
facturi, aceeasi structura de produse/categorii/preturi ca pe site), dar cu un design
vizual propriu, diferit de site — inspirat si din emag.ro pentru UX (navigare, home
cu banner, categorii rapide).

## Reguli critice

- **Niciodata nu se modifica ceva in Odoo fara acordul explicit al lui Mihai.**
  Doar citire/read-only pana la alta instructiune.
- Fara Apple Developer Account inca — de facut inainte de publicarea in App Store.

## Scope MVP (faza 1 — in lucru)

- [x] Scaffold aplicatie SwiftUI (XcodeGen, MVVM)
- [x] Home: banner rotativ, categorii rapide, sectiuni recomandari
- [x] Catalog: grid produse, filtrare pe categorii
- [x] Detaliu produs: tiers de pret pe cantitate, pret Ortho Club, variante (SKU)
- [x] Cos + Checkout (demo, fara integrare reala inca)
- [x] Cont (ecran de baza)
- [x] Tab bar cu 4 sectiuni (Acasa / Catalog / Cos / Cont)
- [ ] Integrare reala Odoo (read-only): categorii, produse, preturi, cont, facturi
- [ ] Push notifications functionale (in prezent doar schela de cod e pregatita)

## Scope faza 2 (dupa validarea MVP)

- [ ] Checkout real (trimitere comanda in Odoo) — **necesita acord explicit inainte de implementare**
- [ ] Autentificare cont real (login cu credentialele de portal client Odoo)
- [ ] Facturi reale (listare + descarcare PDF din Odoo)
- [ ] Cautare functionala + filtre avansate in catalog
- [ ] Push notifications reale (status comanda, oferte, memento facturi scadente)
- [ ] Pregatire pentru App Store: cont Apple Developer, iconite, screenshots, descriere

## Ce ne trebuie de la Odoo (in asteptare)

- Host / URL instanta Odoo
- Numele bazei de date (necesar pentru XML-RPC/JSON-RPC)
- Cheie API generata din profilul propriu (avatar > My Profile > Account Security > New API Key)
- Confirmare ca API-ul extern (XML-RPC/JSON-RPC) e activat pentru cont

## Note / decizii

- Design diferit de site, dar structura de date identica (categorii, subcategorii,
  tiers de pret pe cantitate, pret membru Ortho Club)
- Toate produsele mock au acum pret Ortho Club valid (pentru inaltime uniforma a cardurilor)
- Proiectul Xcode traieste in `Rezultate/UPorthoApp/`
