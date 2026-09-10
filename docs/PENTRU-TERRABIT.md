# Pentru Terrabit — o reparatie de o conditie in tema

Document de predare. Scris pe 10 septembrie 2026, dupa ce reparatia a fost
**verificata pe staging** (`uportho-staging-36862484`, Odoo 18, website 11).

## Pe scurt

`product.template._get_combination_info` arunca eroare la **orice** apel care nu vine
din randarea unei pagini web. Nu doar pentru aplicatia mobila: orice ERP, marketplace,
feed de preturi sau integrare de partener care cere date de produs primeste aceeasi
eroare.

Reparatia e o singura conditie intr-un sablon al temei.

## Eroarea

```
TypeError: 'NoneType' object is not callable
```

Traceback, de pe staging:

```
File ".../uportho_app/controllers/product.py", in _resolve_combination
    combination_info = template._get_combination_info(...)
File ".../terrabit_prime_extension/models/product_template.py", line 8
    combination_info = super()._get_combination_info(...)
File ".../droggol_theme_common/models/product_template.py", line 249
    combination_info['tp_extra_fields'] = IrUiView._render_template(
        'theme_prime.product_extra_fields', values={...})
File ".../web_studio/models/ir_ui_view.py", in _render_template
...
TypeError: 'NoneType' object is not callable
```

## Cauza

`droggol_theme_common/models/product_template.py` (~linia 249) randeaza un **sablon de
pagina web in interiorul unei metode care doar calculeaza date**.

Sablonul `theme_prime.product_extra_fields` contine:

```xml
<t t-if="is_view_active('website_sale.product_tags')">
```

`is_view_active` **nu** e o functie globala de QWeb. `website/models/ir_qweb.py` o pune
in valorile de randare (`is_view_active=lazy(lambda: current_website.is_view_active)`)
din `_prepare_frontend_environment`, iar `http_routing/models/ir_qweb.py` intra pe acea
metoda **doar daca `request.is_frontend` e adevarat**:

```python
if not irQweb.env.context.get('minimal_qcontext') and request:
    if not hasattr(request, 'is_frontend'):
        _logger.warning(BAD_REQUEST, stack_info=True)
    elif request.is_frontend:
        return irQweb._prepare_frontend_environment(values)
```

O ruta JSON obisnuita (`type='http'`, fara `website=True`) primeste de la
`ir_http._match` `is_frontend = False`. Numele iese `None` din context, iar apelul
devine `None(...)`.

Verificat prin eliminare, pe staging, in acelasi sablon: `slug(...)`,
`filtered('visible_on_ecommerce')`, `any([...])` si toate citirile de campuri
functioneaza. Lipseste exact acest ajutor.

## Reparatia verificata

In `theme_prime.product_extra_fields`, conditia care deschide blocul de etichete:

```xml
<!-- inainte -->
<t t-if="is_view_active('website_sale.product_tags')">

<!-- dupa -->
<t t-if="False">
```

Ideal, in modulul temei se pune o verificare care nu depinde de contextul de frontend
(de exemplu citirea directa a starii vizualizarii), nu `False` — dar efectul practic e
acelasi, pentru ca:

**pe uportho zero produse au etichete de e-commerce setate.** Blocul nu afiseaza nimic
azi. Verificat pe toate cele 619 produse publicate pe website 11.

## Ce s-a masurat dupa reparatie

```
APELUL PRIN TEMA MERGE | pret: 15701.0 | lista: 22430.0
chei aduse de tema: other_bulk_prices, bulk_price, other_pricelist_name,
                    tp_extra_fields, has_b2b_access
tabel: Lista de preturi publica 2026 | praguri: [1, 2]
tabel: Lista de preturi Ortho Club 2026 | praguri: [1]
tp_extra_fields lungime: 600
```

`tp_extra_fields` (tabelul "Cod produs" de pe pagina de produs) se randeaza in
continuare — deci **nimic nu dispare de pe site**.

## Ce NU rezolva problema

Marcarea cererii ca fiind de frontend din partea apelantului. Ar cere si
`request.website`, iar `website_sale` filtreaza atunci lista de preturi a clientului
prin `_is_available_on_website`. Pe uportho **niciuna** din cele 14 liste de preturi
active nu trece filtrul (toate au `selectable = False`), deci preturile clientilor
s-ar schimba sau cererea ar esua. Verificat pe staging.

## De ce merita facuta in modul

Modificarea facuta direct in vizualizare (Setari → Tehnic → Vizualizari) se pierde la
prima actualizare a temei — Odoo avertizeaza chiar el asta pe formular. Reparatia
trebuie sa ajunga in `droggol_theme_common` sau intr-un modul de corectie al Terrabit,
ca sa supravietuiasca.

## Ce castigam

Cat timp metoda arunca, aplicatia mobila **reproduce** regulile de pret ale
magazinului (selectia listelor publica/comparatie, pragurile `max(1, min_quantity)`,
cumularea cantitatilor pe tabelul de variante) in loc sa le apeleze. Daca Terrabit
schimba vreodata *regula*, aplicatia si site-ul ar arata preturi diferite fara ca
nimeni sa primeasca eroare.

Cu reparatia, aplicatia cheama codul lor si copia dispare.
