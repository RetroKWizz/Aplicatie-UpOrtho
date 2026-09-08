# Setup Odoo Studio — DEPASIT, pastrat pentru retragerea lui `x_app_banner`

> **Nu mai urma acest ghid pentru continut nou.** Abordarea prin Odoo Studio a fost
> inlocuita de modulul `odoo/uportho_app/`, care defineste aceleasi lucruri ca modele si
> campuri in cod, versionate in git, cu ecrane proprii de editare sub
> **Website → Aplicatie mobila**. Vezi `CLAUDE.md` si
> `docs/superpowers/specs/2026-09-07-uportho-flutter-odoo-design.md`.
>
> Modulul acopera continutul asa:
> - bannerele → modelul `uportho.app.banner`
> - categoriile rapide de pe Acasa → campuri `app_home_visible` / `app_home_sequence` /
>   `app_home_icon` pe `product.public.category` (nu un model separat)
> - etichetele de produs → campuri `app_badge_text` / `app_badge_color` /
>   `app_badge_date_end` pe `product.template` (nu un model separat)
> - ordinea sectiunilor de pe Acasa → fixa in codul aplicatiei, fara model
>
> **De ce fisierul asta ramane totusi:** `x_app_banner` inca exista in Odoo de productie,
> iar exportul customizarilor Studio (plasa de siguranta) **nu a fost facut inca**.
> Nu retrage `x_app_banner` inainte sa existe exportul — modulul nou nu migreaza datele
> vechi. Pana atunci, procedura de mai jos ramane referinta pentru ce e acolo.
>
> Modelele 2, 3 si 4 de mai jos **nu au fost create si nu trebuie create** — sunt
> inlocuite de campurile enumerate mai sus.

**Status istoric:**
- ✅ Model 1 — `x_app_banner` — creat in Studio, inca prezent in productie
- ⬜ Model 2 — `x_app_home_category` — abandonat, inlocuit de campuri pe categorie
- ⬜ Model 3 — `x_app_home_section` — abandonat, ordinea e in codul aplicatiei
- ⬜ Model 4 — `x_app_product_badge` — abandonat, inlocuit de campuri pe produs

---

## Cum deschizi Studio (verificat, functioneaza)

1. Intra intr-o aplicatie oarecare din Odoo (ex. **Contacte**) — NU ramane pe grid-ul
   de aplicatii, Studio nu apare acolo.
2. In bara de sus, langa numele companiei, e o **iconita de cheie/surubelnita**
   (wrench) — click pe ea. Se activeaza Studio (bara de sus devine
   "Editeaza meniul | Model nou | Inchide").

## Cum creezi un model nou

1. Click **"Model nou"**
2. Scrie numele modelului (ex. "App Home Category")
3. Click **"Configureaza Model"**
4. Apare ecranul **"Functii sugerate pentru noul tau model"** — bifeaza:
   - **Imagine** (daca modelul are nevoie de o poza — vezi lista per model mai jos)
   - **Sortare personalizata** (de obicei bifat automat) — iti da GRATIS un camp de
     ordine (`sequence`), cu drag&drop in lista, NU mai trebuie adaugat manual
   - **Arhivare** (de obicei bifat automat) — iti da GRATIS un camp Activ
     (`x_active`), NU mai trebuie adaugat manual
   - Restul (Chatter, Alocare utilizator, etc.) — NU sunt necesare, poti sa le lasi
     bifate sau nu, nu strica, doar aglomereaza formularul
5. Click **"Creeaza Model"**

## Cum adaugi campuri pe formular

Dupa "Creeaza Model", Studio deschide DIRECT formularul gol, cu panou de campuri in
STANGA (Text, Selectie, Data, Many2one, Imagine etc.) si canvas-ul formularului in
mijloc.

- **Titlul mare din varful formularului** ("Descriere") e campul OBLIGATORIU de nume
  al oricarei inregistrari Odoo (numele tehnic ramane `x_name`, indiferent cum il
  redenumesti). Click pe el si redenumeste-l in eticheta relevanta pt fiecare model
  (vezi tabelele de mai jos — uneori il refolosim direct ca "titlu"/"eticheta"
  principala, ca sa nu mai adaugam un camp Text separat de pomana).
- Pt fiecare camp nou: tragi widget-ul potrivit din stanga pe formular, ii pui
  eticheta (label) exact cum scrie in tabel.
- La campuri de tip **Selectie**: dupa ce tragi widget-ul, se deschide un popup
  "Specificati toate valorile posibile" — adaugi fiecare valoare din lista, apoi
  **Confirma**.
- La campuri de tip **Many2... (Many2one)** — ATENTIE, sunt DOUA widget-uri
  asemanatoare in panou: primul (langa "One2M...") e Many2one (corect, un singur
  link), al doilea (langa "Imagine") e Many2Many (gresit pt cazul nostru — NU il
  folosi). Dupa ce tragi Many2one, alege modelul legat exact cum scrie in tabel.

## Cum verifici numele tehnice exacte (dupa ce ai terminat un model)

Nu trebuie sa notezi manual fiecare nume tehnic in timp ce lucrezi. La final:

1. **Settings** → jos de tot → **"Activeaza modul dezvoltator"** (daca nu-i activat)
2. **Settings → Tehnic → Structura baza de date → Modele**
3. Cauta modelul (ex. `x_app_home_category`), deschide-l
4. Tab **"Campuri"** — tabel cu toate campurile si numele lor tehnice exacte

Trimite-mi (mie, Claude) un screenshot cu tabelul ala dupa fiecare model — din el iau
numele exacte si scriu codul Swift care il citeste.

**Nota tehnica** (doar ca sa stii, nu trebuie sa faci nimic): daca incerci acelasi
nume de camp de doua ori (ex. ai sters si reintrodus un camp), Studio poate adauga
un sufix `_1` la numele tehnic (asa a fost la "Activ de la" -> `x_studio_activ_de_la_1`
pe modelul de banner) — nu e o eroare, doar verific numele REAL din tabelul de mai sus,
nu presupun.

## Cum testezi un model

1. Inchide Studio (buton **"Inchide"**)
2. Gaseste aplicatia noua (ex. "App Home Category") — de obicei apare direct dupa ce
   inchizi Studio, sau in lista de aplicatii Odoo
3. **Nou** → completezi campurile cu date de test → salvezi
4. Verifici ca salveaza fara eroare si apare in lista

---

## Model 2 — `App Home Category` (categorii rapide de pe Acasa)

La "Functii sugerate": bifeaza **Imagine** (pt iconita), **Sortare personalizata**,
**Arhivare**.

Pe formular:
| Ce faci | Detalii |
|---|---|
| Redenumeste titlul default | **"Nume"** — poti pune acolo orice, ex. numele categoriei, doar reper vizual intern |
| Imaginea (deja pusa din bifa) | Daca ti se cere eticheta, pune **"Iconita"** |
| Trage **Many2...** (primul, NU Many2Many) | Eticheta **"Categorie"**, model legat: **Product Category** (sau **Website Product Category**) — obligatoriu |

Atat — Ordine si Activ le ai deja automat. Testeaza cu 1-2 categorii reale + o poza
de test.

---

## Model 3 — `App Home Section` (ordine/vizibilitate sectiuni Acasa)

La "Functii sugerate": bifeaza **Sortare personalizata**, **Arhivare** (NU ai nevoie
de Imagine aici).

Pe formular:
| Ce faci | Detalii |
|---|---|
| Redenumeste titlul default | **"Nume"** |
| Trage **Selectie** | Eticheta **"Cheie sectiune"**, valori: **Hero Banner**, **Categorii rapide**, **Bannere promo**, **Oferta zilei**, **Recomandate** |

Atat. Ordine si Activ automate. Testeaza cu 5 randuri (cate unul per valoare de mai
sus), pui ordinea prin drag&drop in lista.

---

## Model 4 — `App Product Badge` (etichete custom pe produse)

La "Functii sugerate": bifeaza **Arhivare** doar daca vrei sa poti "dezactiva" un
badge fara sa-l stergi (recomandat) — NU ai nevoie de Imagine/Sortare aici (badge-urile
nu au nevoie de ordine intre ele).

Pe formular:
| Ce faci | Detalii |
|---|---|
| Redenumeste titlul default | **"Eticheta"** — aici scrii direct textul badge-ului (ex. "Nou", "Popular") — NU mai adaugi un camp Text separat |
| Trage **Many2...** (primul, NU Many2Many) | Eticheta **"Produs"**, model legat: **Product Template** — obligatoriu |
| Trage **Selectie** | Eticheta **"Culoare"**, valori: **Portocaliu**, **Verde**, **Albastru**, **Mov**, **Rosu** |
| Trage **Data** | Eticheta **"Activ pana la"** (optional, poate ramane gol) |

Testeaza cu 1-2 produse reale + o eticheta de test.

---

## Dupa fiecare model

Trimite-mi screenshot cu tab-ul **"Campuri"** (Settings → Tehnic → Structura baza de
date → Modele → modelul respectiv) — scriu codul Swift de fetch pe loc, la fel cum am
facut la bannere.
