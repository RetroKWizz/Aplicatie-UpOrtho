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
| `uportho_app.club_pricelist_id` | `59` | **Nu mai are efect aici.** Pe staging exista modulele clientului, deci lista Ortho Club se ia din bifa `is_compare_pricelist` (vezi mai jos). Parametrul ramane doar rezerva pentru bazele fara modulele lor (dezvoltare locala, teste); pe staging poate fi si sters |

### Lista Ortho Club: bifa clientului e sursa unica

Pe o instanta reala, lista Ortho Club e **prima lista de preturi activa bifata
`is_compare_pricelist`** (campul adaugat de `terrabit_prime_extension` pe
`product.pricelist`) — exact bifa dupa care magazinul isi alege lista de comparatie pe
pagina de produs. Asa pretul de club si tabelul de club de sub el nu pot arata liste
diferite. Inainte erau doua comutatoare independente (bifa lor + parametrul de sistem);
azi amandoua indica `59`, dar la aparitia unei liste "Ortho Club 2027" cine uita
parametrul ar fi vazut tabelul listei noi langa pretul celei vechi, fara nicio eroare.

- **Rollover anual:** se bifeaza lista noua, se debifeaza cea veche. Niciun parametru de
  atins.
- **Daca nicio lista nu e bifata:** `club_price` e null si apare un warning in
  `odoo.addons.uportho_app.controllers.catalog` — nu se cade inapoi pe parametru.
- **Regula de operare:** exact **o singura** lista poate purta fiecare din
  `is_public_pricelist` si `is_compare_pricelist`. Codul (si al lor, si al nostru) ia
  *prima* potrivire, iar "prima" e ordinea din baza: cu doua liste bifate, care castiga
  e imprevizibil si se poate schimba singur.

Continut de test creat: doua bannere (`uportho.app.banner`) si sase categorii marcate
`app_home_visible` (Bracketi, Tuburi si inele, Arcuri, Elastomeri, Adezivi, Instrumentar).

### Beneficiile de pe pagina de produs (`uportho.app.benefit`)

Blocurile de sub butonul de cos (Ortho Club, livrare, retur, plata) se editeaza din
**Site web → Aplicatie mobila → Beneficii**. Fiecare are titlu, subtitlu, ordine si
doua moduri de a arata un simbol:

- **Iconita** — o lista fixa (`club`, `delivery`, `return`, `payment`, `info`) desenata
  de aplicatie. E rezerva: se foloseste cand nu exista imagine.
- **Imagine** — un logo incarcat in Odoo. Blocurile echivalente de pe site arata
  logouri adevarate (curierul, siglele de card), nu iconite desenate. Cand exista
  imagine, aplicatia o arata pe ea. **Asa se schimba un curier sau un procesator de
  plati fara release in App Store**, ceea ce era chiar motivul modulului.

Imaginea se serveste prin ruta autentificata `/api/app/v1/benefits/<id>/image`, ca
bannerele si iconitele de categorie; URL-ul poarta `?unique=` din `write_date`, deci
o inlocuire in Odoo se vede in aplicatie fara sa astepte cache-ul.

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

## Cum se reface, de la zero, dupa ce build-ul dispare

Build-ul de staging se sterge pe **23 septembrie 2026**, iar fisierele copiate manual
dispar oricum la primul push al Terrabit pe ramura `staging`. Tot ce urmeaza e ce
trebuie refacut ca sa ajungem inapoi exact unde eram pe 11 septembrie 2026.

### Pasul 0 — de unde vine codul

Arhiva de desfasurare e chiar in repo: **`uportho_app.tar.gz`** din radacina. Contine
modulul intreg (60 de fisiere de cod), fara `__pycache__`. Se regenereaza cu:

```bash
tar czf uportho_app.tar.gz -C odoo --exclude='__pycache__' --exclude='*.pyc' uportho_app
```

Repo-ul e public, deci arhiva se poate lua direct de pe server, fara acreditari.

### Pasul 1 — modulul pe server

Din terminalul editorului odoo.sh (JupyterLab → Launcher → Terminal):

```bash
cd ~/src/user/custom_modules
tar czf ~/tmp/backup_uportho_app_$(date +%Y%m%d_%H%M).tar.gz uportho_app   # daca exista deja
curl -sSL -o /tmp/uportho_app.tar.gz \
  https://raw.githubusercontent.com/RetroKWizz/Aplicatie-UpOrtho/main/uportho_app.tar.gz
tar xzf /tmp/uportho_app.tar.gz -C . 2>/dev/null    # dezarhiveaza PESTE, nu se face rm
ls uportho_app/controllers                           # trebuie sa apara cart.py, checkout.py, account.py
```

`2>/dev/null` ascunde avertismentele `LIBARCHIVE.xattr` ale arhivelor facute pe macOS;
nu sunt erori.

Apoi, daca modulul e **deja instalat** in baza:

```bash
odoo-update uportho_app
```

Dureaza aproape un minut si nu scoate nimic pana la final. La **prima** instalare
`odoo-update` nu ajunge — el doar actualizeaza:

```bash
echo "env['ir.module.module'].search([('name','=','uportho_app')]).button_immediate_install(); env.cr.commit()" | odoo-bin shell
```

### Pasul 2 — parametrii de sistem

Setari → Tehnic → Parametri de sistem:

| Parametru | Valoare | Obligatoriu |
|---|---|---|
| `uportho_app.website_id` | `11` | **Da.** Fara el `/home` vine gol si pare o problema de continut |
| `uportho_app.club_pricelist_id` | — | Nu. Pe staging exista modulele clientului, deci lista Ortho Club se ia din bifa `is_compare_pricelist`. Parametrul e doar rezerva pentru bazele fara modulele lor |
| `uportho_app.offline_payment_codes` | — | Nu. Implicit `custom,on_delivery`. Se schimba doar daca Terrabit adauga alt provider care se incheie fara card |

### Pasul 3 — contul de test

`app.test@uportho.ro`, id utilizator **4213**, partener **30392**. Portal obisnuit, creat
special; **nu e contul niciunui client real**.

**Parola nu se scrie aici** — acest repo e public. Se pune una noua cand e nevoie:

```bash
cat > /tmp/cont.py <<'PY'
u = env['res.users'].browse(4213)
u.password = 'PAROLA-ALEASA-ACUM'
env.cr.commit()
print('gata:', u.login)
PY
odoo-bin shell -d $(psql -At -c "select current_database()") --no-http < /tmp/cont.py
```

**Contul are nevoie de adresa completa.** Fara tara si oras, `rate_shipment()` raspunde
"aceasta metoda de livrare nu este disponibila pentru aceasta adresa" si checkout-ul
ramane fara niciun curier. Adresa folosita la proba:

```bash
cat > /tmp/adr.py <<'PY'
p = env['res.partner'].browse(30392)
v = {'street': 'Str. Exemplu 12', 'zip': '400001', 'city': 'Cluj-Napoca',
     'country_id': 188, 'state_id': 721, 'phone': '+40700000000'}
if 'city_id' in p._fields:
    c = env['res.city'].search([('country_id','=',188),('name','ilike','Cluj-Napoca')], limit=1)
    if c: v['city_id'] = c.id
p.write(v); env.cr.commit()
print(p.street, p.city, p.zip, p.state_id.name, p.country_id.name)
PY
odoo-bin shell -d $(psql -At -c "select current_database()") --no-http < /tmp/adr.py
```

(`188` = Romania, `721` = judetul Cluj, `4258` = orasul Cluj-Napoca, pe baza de staging.)

### Pasul 4 — plata, doar cat tine proba

Odoo **dezactiveaza singur toti providerii de plata** pe o instanta de staging, ca sa nu
se incaseze bani reali dintr-o copie de productie. Fara ca cineva sa porneasca explicit
unul, `/checkout` intoarce lista de plati goala. Nu e un defect al modulului.

Pentru proba s-a folosit **"Transfer bancar/OP" (id 5)**, pornit in `test` si pus inapoi
pe `disabled` imediat dupa:

```bash
# pornit
echo "env['payment.provider'].browse(5).write({'state':'test','is_published':True}); env.cr.commit()" | odoo-bin shell
# oprit la loc
echo "env['payment.provider'].browse(5).write({'state':'disabled'}); env.cr.commit()" | odoo-bin shell
```

"Card Dummy" (id 30) era deja in `test` inainte sa atingem ceva; nu l-am modificat.

### Pasul 5 — reparatia din tema

Separat de modul, si **necesara ca pagina de produs sa primeasca datele temei**:
vizualizarea `theme_prime.product_extra_fields` are conditia

```xml
<t t-if="is_view_active('website_sale.product_tags')">
```

care trebuie sa devina `False` (sau o verificare ce nu depinde de contextul de
frontend). Explicatia completa, cu de ce e sigura, e in `docs/PENTRU-TERRABIT.md`.
Modificarea facuta direct in vizualizare se pierde la prima actualizare a temei — de
aceea trebuie sa ajunga in modulul Terrabit.

Fara ea aplicatia merge oricum: ruta de produs prinde eroarea si cheama direct
implementarea standard din `website_sale` (vezi gotcha 7 din `CLAUDE.md`).

### Pasul 6 — verificarea ca totul a intrat

```bash
psql -At -F'|' -c "select name,state,latest_version from ir_module_module where name='uportho_app'"
B=https://uportho-staging-36862484.dev.odoo.com/api/app/v1
for r in ping cart checkout orders invoices addresses; do
  printf "%-10s " $r; curl -s -o /dev/null -w "%{http_code}\n" $B/$r
done
```

Toate trebuie sa dea **401** (`"Trebuie sa te autentifici."`) — ruta exista si cere
sesiune. Un **404** inseamna ca modulul nu s-a incarcat.

**Atentie:** `curl http://127.0.0.1:8069/...` din terminalul editorului da mereu `000`.
Acolo ruleaza doar jupyter-lab; serverul Odoo e in alt container. Testele de rute se fac
pe URL-ul public, tot din acel terminal. Baza de date si fisierele sunt insa comune,
deci `psql` si `odoo-bin shell` merg direct.

### Pasul 7 — proba completa, de la login la comanda

```bash
B=https://uportho-staging-36862484.dev.odoo.com/api/app/v1; J=/tmp/ck.txt; rm -f $J
curl -s -c $J -H 'Content-Type: application/json' -H 'X-UpOrtho-App: 1' \
     -d '{"login":"app.test@uportho.ro","password":"PAROLA"}' $B/auth/login
curl -s -b $J -c $J -H 'Content-Type: application/json' -H 'X-UpOrtho-App: 1' \
     -d '{"lines":[{"variant_id":41868,"add_qty":2}]}' $B/cart/lines
curl -s -b $J -c $J $B/checkout
curl -s -b $J -c $J -H 'Content-Type: application/json' -H 'X-UpOrtho-App: 1' \
     -d '{"carrier_id":4}' $B/checkout/delivery
curl -s -b $J -c $J -H 'Content-Type: application/json' -H 'X-UpOrtho-App: 1' \
     -d '{"payment_method_id":217,"provider_id":5}' $B/checkout/confirm
```

Aplicatia se porneste catre staging cu:

```bash
cd app && flutter run -d <simulator-id> \
  --dart-define=API_BASE_URL=https://uportho-staging-36862484.dev.odoo.com
```

## Ce s-a masurat pe staging (11 septembrie 2026)

- Login, Acasa, catalogul real (**619 produse** publicate pe website 11), pagina de
  produs, cos, checkout, comanda, contul.
- **Comenzi de proba lasate in baza:** `CMD42024` (125,77 lei) si `CMD42026` (528,01
  lei), amandoua pe contul de test, transfer bancar, ridicare din sediu. Comanda iese
  din ciorna (`state = sent`), tranzactia ramane `pending` si post-procesata, cosul se
  goleste.
- **Curieri pe website 11:** singurul ACTIV si publicat e "Ridicare din sediu" (id 4).
  Fan Courier (3) si Fan Courier ramburs (5) raman publicate dar **arhivate**
  (`active = false`) din 28 iulie 2026. "Caut Curier – Sameday" (31, 32) sunt legate de
  website 12. De verificat in productie daca asa trebuie sa fie.
- **Defect gasit si reparat aici, nu in teste:** pretul pe bucata ignora reducerea
  liniei (330,00 lei afisat, 264,00 incasat). Vezi commit-ul `fix(cos): pretul pe
  bucata include reducerea liniei`.

## Ce ramane de decis, si e decizia userului

- Daca modulul se **comite pe `staging`**, ca sa nu dispara la rebuild si sa-l poata
  vedea danila. Asta e schimbarea care ramane in repo-ul Terrabit.
- Cum intra mai departe catre productie — prin fluxul obisnuit al Terrabit, dupa ce
  danila se uita peste el.
