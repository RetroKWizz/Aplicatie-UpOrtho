# Magazinul fara cont (varianta B) — design

Scris pe 15 octombrie 2026, dupa ce Apple a cerut ca aplicatia sa arate ceva inainte de
autentificare. Design-ul vizual aprobat de Mihai: **varianta B** din panza
`https://claude.ai/artifact/UBQXK6vgXKzByueXDPBk7F`.

## Ce vrem

Aplicatia porneste **in magazin**, nu in ecranul de autentificare. Un om fara cont vede
produsele, categoriile, brandurile si bannerele — dar nu preturile. In antet, sus-dreapta,
un buton **Contul meu**; sub antet, o banda cu "Intra in cont ca sa vezi preturile si sa
comanzi". Contul se poate si crea din aplicatie, cu acelasi formular ca pe site.

Scopul nu e o functie noua, ci: (1) App Review sa poata vedea aplicatia fara cont,
(2) un cabinet care abia descopera UpOrtho sa poata rasfoi inainte sa ceara cont.

## Ce e deja adevarat (verificat pe copia de staging, 15 octombrie 2026)

Nu presupunem nimic despre magazin; astea sunt masurate:

- **Catalogul magazinului e deja public.** `GET /shop` fara nicio sesiune intoarce 200 si
  listeaza 622 de produse, cu categoriile si sortarea.
- **Preturile NU se vad fara cont.** Pe pagina unui produs, un vizitator primeste `0,00 lei`
  peste tot. E regula B2B a temei (`website._dr_has_b2b_access()` din `droggol_theme_common`
  intoarce fals pentru utilizatorul public), nu o alegere a noastra.
- **Inregistrarea libera e pornita.** `GET /web/signup` intoarce formularul cu exact patru
  campuri: `login` (email), `name`, `password`, `confirm_password`.
- Un cont nou e un portal obisnuit: **vede preturile imediat**, fara aprobare manuala,
  pentru ca accesul B2B al temei inseamna doar "utilizator autentificat".

**Consecinta acceptata de user:** contul nou vede lista **publica**, nu preturile negociate
ale unui cabinet existent. Preturile de cabinet le are doar un cont legat de partenerul
potrivit. E comportamentul site-ului; nu-l schimbam.

## Principiul care decide cazurile nespuse

**Aplicatia arata unui vizitator exact ce arata site-ul unui vizitator — nici mai mult,
nici mai putin.** Daca magazinul ascunde pretul, il ascunde si aplicatia. Daca magazinul il
arata intr-o zi (B2B oprit), aplicatia il arata in aceeasi zi, fara release: pretul vine de
la server, nu dintr-o regula scrisa in Dart.

## Partea de server

### Rute care devin publice

`app_route` stie deja `auth='public'` (ruta e inregistrata public in Odoo, iar
`auth='user'` e verificat in wrapper). Deci schimbarea e, pe fiecare ruta, un parametru:

| Devine public | Ramane pe cont |
|---|---|
| `GET /home` | tot `/cart`, `/checkout`, `/orders`, `/invoices` |
| `GET /categories` | `/account/*`, `/addresses*`, `/favorites*`, `/loyalty` |
| `GET /products`, `GET /products/<id>` | `POST /products/<id>/prices` |
| rutele de imagine: banner, iconita de categorie, logo de brand, imagine si document de produs | `/payment-methods`, `/devices` |

`POST /auth/login`, `POST /auth/logout` raman cum sunt.

### Preturile pentru un vizitator

**Nu se trimite niciun pret.** In loc sa inventam o lista publica, campul lipseste:

- `price` devine **nullable** in `serialize_product` si in `/products/<id>`; `club_price`,
  `price_tables` si tabelul de variante la fel.
- Se adauga, pe raspunsurile de catalog, un bloc scurt:
  `"pricing": {"visible": false, "reason": "sign_in_required"}` — ca aplicatia sa stie **de ce**
  lipseste pretul si sa nu ghiceasca din `null`. Pentru un client autentificat:
  `{"visible": true, "reason": null}`.
- `_customer_pricelist` nu se mai cheama deloc fara cont (azi ar arunca 503
  `pricelist_unavailable`), si nici calculul de preturi.

Asta e singura schimbare de contract care **rupe** aplicatia veche: un build mai vechi din
magazin ar primi `price: null` si ar cadea la decodare. De aceea blocul `pricing` se adauga
odata cu versiunea noua a aplicatiei, iar build-ul vechi nu mai ajunge la utilizatori
(TestFlight, nu App Store). Daca ar fi fost in magazin, raspunsul ar fi trebuit sa ramana
compatibil.

### Crearea contului

Rutа noua **`POST /auth/signup`**, cu `auth='public'`, in `controllers/auth.py`:

- Controllerul nostru **mosteneste `AuthSignupHome`** (`auth_signup`), exact cum
  `controllers/address.py` mosteneste `WebsiteSale` si `profile.py` mosteneste
  `CustomerPortal`. Chemam `self._signup_with_values(token=None, values)`, metoda prin care
  trece si pagina `/web/signup`: asa primim regulile lor de parola, mesajele lor de eroare
  si orice override pus de modulele clientului.
- Campurile acceptate sunt **exact cele patru ale formularului lor**: `login`, `name`,
  `password`, `confirm_password`. O lista scrisa explicit, ca la adrese — nu "orice camp
  scriibil".
- Daca inregistrarea e **oprita** in Odoo (`auth_signup.invitation_scope` != `b2c`), ruta
  intoarce `403 signup_disabled` cu un mesaj clar, iar aplicatia ascunde butonul "Creeaza
  cont". Nu ocolim setarea magazinului.
- Dupa creare, serverul **autentifica sesiunea pe loc** si intoarce acelasi corp ca
  `/auth/login`, ca aplicatia sa continue fara al doilea pas.
- Ce NU face: nu creeaza companie, nu completeaza CUI, nu leaga contul de un partener
  existent. Un cont de cabinet real tot UpOrtho il creeaza.

### Cosul unui vizitator

Nu exista. `website.sale_get_order()` ar crea un cos pe utilizatorul public, iar
`_cart_update` al temei **goleste cosul** cand lipseste accesul B2B — deci un cos de
vizitator s-ar pierde tacut la autentificare. Rutele de cos raman pe cont, iar aplicatia
duce la autentificare inainte de prima adaugare.

## Partea de aplicatie

### Pornire si navigare

- `router.dart`: redirect-ul `if (!signedIn) return '/login'` **dispare**. Ramane doar
  redirectul invers (un om autentificat nu sta pe `/login`).
- Rutele cu cont (`/cart`, `/checkout`, `/account/*`) pastreaza o paza proprie: un vizitator
  ajuns acolo e dus la `/login`.
- `/signup` devine ruta noua.
- `SignedOut` nu mai e o stare de eroare: e starea obisnuita a unui vizitator.

### Providerii

Regula din CLAUDE.md ("orice provider cu date ale contului incepe cu
`await ref.watch(authControllerProvider.future)`") ramane, dar capata un al doilea pas:
providerii de **cos, comenzi, facturi, adrese, favorite, carduri** se opresc devreme cand
starea nu e `SignedIn` si intorc gol, in loc sa ceara serverul si sa ia 401. Altfel fiecare
pornire de aplicatie ar produce patru 401-uri in loguri.

`homeControllerProvider` si catalogul **nu** mai asteapta autentificarea ca sa ceara date —
dar tot asculta schimbarea ei, ca sa reincarce cu preturi dupa login.

### Ecrane

1. **Antet**: butonul de iesire e inlocuit cu **Contul meu** (iconita + text, 44px
   inaltime). Pentru un om autentificat duce la tabul Cont; pentru un vizitator, la fel —
   ecranul Cont e cel care se schimba.
2. **Banda de invitatie** (varianta B): sub antet, pe Acasa si in catalog, o singura linie
   cu lacat, text si butonul "Intra". Se desenează **doar cand `pricing.visible` e fals** —
   nu dupa starea locala de autentificare, ca sa nu existe doua adevaruri.
3. **Cardul de produs si pagina de produs**: unde era pretul, textul "Pretul se vede in
   cont", gri, fara buton. Butonul "Adauga in cos" devine "Intra in cont".
4. **Ecranul Cont, pentru vizitator**: card cu "Intra in contul tau UpOrtho", doua butoane
   (Intra / Creeaza cont) si lista scurta a ce obtine cu cont.
5. **Ecranul de inregistrare**: nume, email, parola, confirmare — exact ca pe site. Erorile
   vin de la server si se arata sub campul lor.
6. **Tabul Cos pentru vizitator**: acelasi card de invitatie, nu un cos gol.

### Ce NU se schimba

Catalogul, filtrele, pagina de produs, cosul si checkout-ul unui client autentificat raman
identice. Temele raman doua. Nicio schimbare in fluxul de plata.

## Cum se verifica

- **Teste Odoo**: fiecare ruta publica raspunde 200 fara sesiune; fiecare ruta de cont
  raspunde 401; `price` e null si `pricing.visible` fals fara sesiune, iar cu sesiune e
  neschimbat fata de azi; `/auth/signup` creeaza contul si deschide sesiunea; cu
  inregistrarea oprita da 403; un camp in plus in corp e ignorat.
- **Teste Flutter**: aplicatia porneste pe Acasa fara sesiune; banda apare doar cand
  `pricing.visible` e fals; cardul arata "Pretul se vede in cont"; "Adauga in cos" duce la
  autentificare; dupa login, aceeasi grila arata preturi; providerii de cont nu cer serverul
  cat timp nu exista sesiune.
- **Pe staging**: parcurs fara cont de la pornire pana la crearea unui cont nou si prima
  comanda, pe simulator.

## Ce ramane in afara

- Preturile negociate pentru conturi noi (raman cele publice) — decis de user.
- Cos de vizitator pastrat peste autentificare.
- Autentificare cu Apple / Google.
- Notificari push (tot nefacute).
