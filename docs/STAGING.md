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

**Site web** (aplicatia) -> bara de sus -> **Configurare** -> **Aplicatie mobila**:

| Meniu | Ce face |
|---|---|
| **Bannere** | Caruselul de sus (`Plasare = Hero`) si randul "Oferte" de jos (`Plasare = Promo`). Titlu, subtitlu, text de buton, imagine, link (categorie / URL / fara), ordine, activ intre doua date, website. Bifa **"Imaginea contine deja textul"** = aplicatia arata doar poza, fara sa scrie nimic peste ea. |
| **Sectiuni pe Acasa** | Randurile de produse. Titlu, de unde vin produsele (o categorie / alese de mana / cele cu eticheta de oferta), cate, ordine, perioada, website. |
| **Beneficii** | Blocul de avantaje de pe pagina de produs. |

Pe **fisa categoriei** (Site web -> eCommerce -> Categorii), grupul "Aplicatie mobila":
bifa **Vizibila pe Acasa**, **Ordine pe Acasa**, **Iconita (app)**. Fara iconita proprie
se foloseste poza categoriei din magazin.

Pe **fisa produsului**, grupul "Aplicatie mobila": eticheta de rezerva (`app_badge_*`).
Eticheta reala vine din eticheta temei (`dr_label_id`), adica se pune ca pe site.

Nimic din toate astea nu cere release in store.


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
modulul intreg (**72 de fisiere**, ~200 KB), fara `__pycache__`. Se regenereaza cu:

```bash
COPYFILE_DISABLE=1 tar czf uportho_app.tar.gz -C odoo --exclude='__pycache__' --exclude='*.pyc' uportho_app
```

Repo-ul e public, deci arhiva se poate lua direct de pe server, fara acreditari.

`COPYFILE_DISABLE=1` nu e cosmetic: fara el, `tar` de pe macOS pune in arhiva si
fisierele AppleDouble (`._nume`) cu atributele extinse ale fiecarui fisier. Dezarhivate
pe Linux, ele ajung pe disc langa cele reale — pe 13 octombrie 2026 au iesit **78 de
fisiere `._*` pe langa cele 72 reale**, inclusiv `._manifest__.py` in radacina
modulului. Odoo le ignora (citeste doar `__manifest__.py` si ce listeaza el), deci n-au
stricat nimic, dar nu au ce cauta pe server. Verificarea de mai jos numara fisierele
tocmai ca sa se vada daca reapar.

**Arhiva e verificata, nu presupusa.** Inainte de fiecare urcare se dezarhiveaza intr-un
folder temporar si se compara cu sursa; ultima verificare (14 septembrie 2026) a iesit
identica, iar `sha256` era
`1f4be50ba0abf8ef4da9343a0d3a87b408d8a818e0b35cf227b1806194301f4b`:

```bash
COPYFILE_DISABLE=1 tar czf uportho_app.tar.gz -C odoo --exclude='__pycache__' --exclude='*.pyc' uportho_app
T=$(mktemp -d); tar xzf uportho_app.tar.gz -C $T 2>/dev/null
diff -r --exclude='__pycache__' --exclude='*.pyc' odoo/uportho_app $T/uportho_app && echo OK
```

Chiar daca build-ul de staging dispare cu totul, modulul se reface din acest repo: codul,
arhiva si reteta de mai jos sunt tot ce trebuie. Istoricul git tine si versiunile vechi
ale arhivei, deci se poate reveni la orice zi.

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
psql -At -c "select count(*) from uportho_app_favorite"   # tabela modelului de favorite
B=https://uportho-staging-36862484.dev.odoo.com/api/app/v1
for r in ping cart checkout orders invoices addresses addresses/options \
         account/profile account/password loyalty favorites; do
  printf "%-18s " $r; curl -s -o /dev/null -w "%{http_code}\n" $B/$r
done
```

Toate trebuie sa dea **401** (`"Trebuie sa te autentifici."`) — ruta exista si cere
sesiune. Un **404** inseamna ca modulul nu s-a incarcat. `account/password` si
`favorites` sunt rute POST, deci la un GET raspund tot 401 cat timp nu esti conectat;
dupa autentificare `POST /account/password` fara corp da 422, nu 404.

Daca interogarea pe `uportho_app_favorite` da eroarea "relation does not exist",
modulul a fost doar copiat, nu si actualizat: ruleaza `odoo-update uportho_app`, care
creeaza tabela modelului nou.

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

## Starea de pe staging, recitita pe 14 septembrie 2026

Asa arata configurarea in momentul ultimei salvari a modulului; daca se reface baza,
astea sunt valorile la care trebuie sa se ajunga:

- Parametri de sistem: **doar** `uportho_app.website_id = 11`. `club_pricelist_id` nu e
  setat si nici nu trebuie: pe instanta reala lista de club se ia din bifa clientului.
- Liste de preturi bifate: **59** "Lista de prețuri Ortho Club 2026"
  (`is_compare_pricelist`) si **45** "Lista de prețuri publica 2026"
  (`is_public_pricelist`). Cate una din fiecare, cum cere regula de operare.
- Toti providerii de plata sunt `disabled`, inclusiv Stripe (8, 21) si "Transfer bancar
  / OP" (22). Asa ii lasa Odoo pe o copie de productie; se porneste unul in mod test
  doar cat tine o proba si se pune inapoi.

## Ce s-a adaugat dupa 11 septembrie 2026

Toate sunt in arhiva si intra odata cu `odoo-update`:

- **Editarea adreselor** (`GET /addresses/<id>`, `POST /addresses/<id>`), cu validarea
  magazinului chemata cu partenerul existent.
- **Schimbarea parolei** (`POST /account/password`), prin `CustomerPortal._update_password`.
- **Favorite** (`GET|POST /favorites`, `DELETE /favorites/<id>`) si modelul
  `uportho.app.favorite` — singura lista care nu vine din magazin, fiindca
  `website_sale_wishlist` nu e instalat acolo. **Model nou = tabela noua**, deci dupa
  copiere e obligatoriu `odoo-update`.
- **Etichetele produsului** citite din `dr_label_id` (tema) si **nota din recenzii** pe
  cardurile din catalog.
- **Adresele impartite** in facturare si livrare (`for_billing`, `for_delivery`), cu
  regula din `_prepare_checkout_page_values`.
- **Blocaj nou la checkout**: `no_payment_method`, cand magazinul nu ofera nicio metoda
  de plata (pe staging, unde toti providerii sunt dezactivati, apare mereu).

## Transportul gratuit — cum e facut in magazin (verificat 14 septembrie 2026)

Nu prin bifa "gratuit peste" de pe curier: `free_over` e fals pe toti curierii, iar
reguli de pret de livrare (`delivery.price.rule`) nu exista deloc. Magazinul adauga pe
comanda un **produs** "Livrare gratuită" (id 58236) la 0 lei, cu `is_delivery = false`.
Vazut pe comanda 42073, de 528,01 lei, adica peste pragul de 400 lei.

Consecinta pentru aplicatie: linia apare in cos ca produs normal, cu cantitate si buton
de stergere, exact ca pe site — pentru ca filtrul e chiar `_show_in_cart` al lui Odoo,
care ascunde doar liniile de transport adevarate. Nu e un defect al aplicatiei.

## Ce ramane de decis, si e decizia userului

- Daca modulul se **comite pe `staging`**, ca sa nu dispara la rebuild si sa-l poata
  vedea danila. Asta e schimbarea care ramane in repo-ul Terrabit.
- Cum intra mai departe catre productie — prin fluxul obisnuit al Terrabit, dupa ce
  danila se uita peste el.

## Unde am ramas — 14 octombrie 2026

Tot ce urmeaza e **in repo-ul nostru** (`main`) si in `uportho_app.tar.gz`, deci se
reface pe orice build nou cu reteta de mai sus. Nimic nu depinde de build-ul de staging.

**Modul Odoo — ce s-a adaugat in octombrie**

- **Filtre si sortare in catalog**: `/products` accepta `attribute_value=<attrId>-<valId>`
  (repetabil), `min_price`, `max_price`, `sort`, si intoarce blocul `filters` cu
  numaratori contextuale. Sectiunile se ordoneaza dupa cate produse acopera atributul.
- **Ortho Club in cont**: blocul `club` din `/account/profile`, calculat din
  `has_valid_subscription` + `subscription_end_date` (`terrabit_subscription_extension`)
  **comparate cu ziua curenta** — bifa nu se stinge singura; pe staging, 882 de parteneri
  o aveau pusa si 56 aveau data trecuta.
- **Iconita categoriei** cade pe poza din magazin (`image_1920`) cand `app_home_icon` e gol.
- **Economia din cos**: `savings` in `/cart`, adunat din diferentele de pe randuri.
- **Sectiuni pe Acasa**: modelul `uportho.app.section` (tabela noua -> `odoo-update`
  obligatoriu dupa copiere).
- **Banner cu textul in imagine**: campul `image_only` pe `uportho.app.banner`.
- **Cardurile salvate**: `GET /payment-methods` (pe magazin: 1017 carduri, 414 cabinete).

**Aplicatie — ce s-a schimbat**

- Acasa cu **carusel** de bannere (puncte doar cand sunt mai multe) si randuri de produse.
- Catalog cu **Filtre / Sorteaza**, glisor de pret pe **scara logaritmica** (catalogul
  real merge de la 2 la 322.500 lei), liste lungi strunse la 8 valori.
- Cont refacut: card de membru Ortho Club, randuri cu numere, adrese cu etichete de rol,
  **Cardurile mele**, **Aspect**.
- Cos cu "Ai economisit" si rezumat lipit jos; **finalizare pe pasi** (Adrese / Livrare / Plata).
- **Doua teme** (Alb / Negru / Setarile telefonului), paleta ca `InheritedWidget`.
- Bara de jos **plutitoare, pe sticla**.

**Verificat pe staging, pe date reale**: comanda **CMD44069** (297,01 lei, ridicare din
sediu, transfer bancar, livrare la "Cabinet Test Livrare", factura pe "App Test UpOrtho"),
tranzactie `pending` post-procesata, comanda iesita din ciorna.

**Teste**: 445 Odoo, 410 Flutter, `flutter analyze` curat.

**Ramas de facut**, in ordinea in care merita luat:
1. Providerii de plata 5, 35, 30 sunt in **mod test** pe staging — de hotarat daca raman.
2. Doua liste de preturi poarta `is_public_pricelist` (45 in lei, 76 in euro pentru
   site-ul .com). Azi castiga cea in lei (secventa 1), deci nu arde, dar e la noroc.
3. Reparatia de o linie in tema Terrabit (`theme_prime.product_extra_fields`).
4. Modulul e **copie temporara** pe staging; permanent inseamna sa intre in repo-ul lor.
5. Notificari push (modelul si rutele exista, trimiterea nu).
6. `docs/DE-FACUT.md` inainte de lansare, apoi TestFlight si App Store.
