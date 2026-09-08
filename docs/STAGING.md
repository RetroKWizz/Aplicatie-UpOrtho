# Modulul pe staging — stare, configurare, cum se reface

Notite despre desfasurarea modulului `uportho_app` pe build-ul de staging al userului.
Scrise pe 2026-09-08. **Nimic din ce e aici nu se aplica productiei.**

## Regula care primeaza peste tot ce urmeaza

Instructiune explicita a userului: **nu se modifica nimic pe `main` (productie).**
Codul intra in Odoo-ul lor doar prin Terrabit. Ce e descris aici a fost facut pe
staging, cu acordul lui punctual, ca sa se poata testa.

## Unde e

- Proiect odoo.sh: `uportho`, repo `git@github.com:terrabit-ro/uportho.git` (al Terrabit, nu al userului)
- Branch: **`staging`** (Odoo 18), build `uportho-staging-36862484`
- URL: `https://uportho-staging-36862484.dev.odoo.com`
- Modulul: `~/src/user/custom_modules/uportho_app/`, langa `theme_prime`, `terrabit_prime_extension` etc.

**ATENTIE — nu e in git.** Fisierele au fost copiate pe discul build-ului, nu comise.
La orice rebuild dispar. Build-ul asta se sterge oricum pe **23 septembrie 2026**.
Daca dispare si vrei sa-l pui la loc, vezi "Cum se reface" mai jos.

## Configurare aplicata

Parametri de sistem (Setari > Tehnic > Parametri de sistem):

| Parametru | Valoare | De ce |
|---|---|---|
| `uportho_app.website_id` | `11` | Magazinul romanesc. Fara el, `/home` vine gol si arata a problema de continut, nu a bug |
| `uportho_app.club_pricelist_id` | (de setat) | Lista Ortho Club, pentru pretul afisat membrilor. Se schimba anual — de-aia e parametru, nu constanta in cod |

Continut de test creat: doua bannere (`uportho.app.banner`) si sase categorii marcate
`app_home_visible` (Bracketi, Tuburi si inele, Arcuri, Elastomeri, Adezivi, Instrumentar).

Cont de test, portal obisnuit, creat special — **nu e contul niciunui client real**:
`app.test@uportho.ro` — parola NU se scrie aici (repo-ul de transfer e public). E la user.

## Unde se editeaza continutul

**Site web** (aplicatia) -> bara de sus -> **Aplicatie mobila** -> **Bannere**.

Modulul nu are dala proprie in grila de aplicatii (`'application': False` in manifest).
Campurile de categorie si de eticheta de produs apar direct pe fisele respective,
intr-o sectiune "Aplicatie mobila".

## Fapte verificate direct in baza de staging (2026-09-08)

- `website_id = 11` = "uportho.ro 2025", 78 categorii publice. Al doilea magazin: 14
  ("uportho.com 2025", 55 categorii). Exista 9 website-uri in total.
- **14 liste de preturi active** (25 cu tot cu arhivate). Cele doua principale:
  - `45` = "Lista de preturi publica 2026"
  - `59` = "Lista de preturi Ortho Club 2026"
  - `73` = "Lista de preturi CAMPANIE Ortho Club 2026"
- **Capcana:** traducerile ENGLEZE ale numelor sunt ramase in urma (`45` apare ca
  "Public Pricelist 2025", `59` ca "UpOrtho CLUB 2024 Pricelist"). Se citeste
  `name->>'ro_RO'`, nu `en_US`, altfel tragi concluzii gresite despre ce an e curent.
- Catalog: **925 produse publicate**, **1246 reguli de pret**.
- Fiecare contact are lista lui de preturi alocata pe cont (confirmat de user), deci
  nici modulul nici aplicatia nu hardcodeaza vreun id de pricelist.

## Cum se reface, daca build-ul se reconstruieste

Din terminalul editorului odoo.sh (JupyterLab -> Launcher -> Terminal):

```bash
cd ~/src/user/custom_modules
git clone --depth 1 <repo-ul-cu-modulul> /tmp/up && cp -r /tmp/up/odoo/uportho_app . && rm -rf /tmp/up
odoo-update uportho_app          # improspateaza lista de aplicatii
echo "env['ir.module.module'].search([('name','=','uportho_app')]).button_immediate_install(); env.cr.commit()" | odoo-bin shell
```

Apoi se re-seteaza parametrii de sistem si continutul de test.

Note practice invatate pe drum:
- `odoo-update` **nu instaleaza** module noi, doar le actualizeaza si improspateaza lista.
  Instalarea se face din interfata (Apps) sau prin `odoo-bin shell`, ca mai sus.
- `odoosh-restart` cere numele serviciului: `odoosh-restart http`.
- Din containerul editorului **nu** se ajunge la `localhost:8069`. Testele de rute se
  fac pe URL-ul public al build-ului.
- Build-ul hiberneaza; se trezeste cu butonul **CONNECT** din odoo.sh sau accesand URL-ul.
- Atentie la `!` in parole cand scrii comenzi in bash — declanseaza expansiune de istoric.

## Ce ramane de decis, si e decizia userului

- Daca modulul se **comite pe `staging`**, ca sa nu dispara la rebuild si sa-l poata
  vedea danila. Asta e schimbarea care ramane in repo-ul Terrabit.
- Cum intra mai departe catre productie — prin fluxul obisnuit al Terrabit, dupa ce
  danila se uita peste el.
