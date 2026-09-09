import re

import lxml.html

from odoo import fields, models

from ..pricing import serialize_price

BADGE_COLORS = [
    ('orange', 'Portocaliu'), ('green', 'Verde'), ('blue', 'Albastru'),
    ('purple', 'Mov'), ('red', 'Rosu'),
]

# Etichete de bloc acceptate in `_uportho_description_blocks`: orice altceva (div,
# section, span, a, br...) se aplatizeaza - fie ignorat ca sursa de bloc (containere),
# fie tratat ca text simplu, fara formatare, la nivel de span (vezi `_uportho_spans`).
_HEADING_TAGS = {'h1', 'h2', 'h3', 'h4'}
_LIST_TAGS = {'ul', 'ol'}
_BOLD_TAGS = {'b', 'strong'}
_ITALIC_TAGS = {'i', 'em'}
_COLLAPSE_WHITESPACE = re.compile(r'\s+')


def _uportho_filter_romanian_sections(root):
    """Elimina din `root` orice element cu atributul `data-visibility-value-lang`
    care nu contine 'ro_RO' (alta limba, ex. en_US); pastreaza elementele taguite
    cu 'ro_RO' si orice continut fara acest atribut (comun, netaguit).

    `website_description` poate contine sectiuni pentru mai multe limbi, separate
    doar prin CSS pe site (vezi spec sectiunea 12, comportament descoperit empiric
    in prototipul SwiftUI arhivat) - serverul trimite ambele, filtrarea trebuie
    facuta aici."""
    for tagged in root.xpath('.//*[@data-visibility-value-lang]'):
        lang_attr = tagged.get('data-visibility-value-lang') or ''
        if 'ro_RO' not in lang_attr:
            parent = tagged.getparent()
            if parent is not None:
                parent.remove(tagged)
    return root


def _uportho_spans(el):
    """Span-urile text (cu bold/italic) din continutul inline al lui `el`, in
    ordinea din document. Doar strong/b si em/i seteaza formatare; orice alt tag
    inline (span, a, br...) se aplatizeaza la text simplu, mostenind formatarea
    stratului in care se afla (nu adauga si nu elimina bold/italic)."""
    fragments = []  # [(text, bold, italic), ...]

    def walk(node, bold, italic):
        if node.text:
            fragments.append((node.text, bold, italic))
        for child in node:
            walk(child, bold or child.tag in _BOLD_TAGS, italic or child.tag in _ITALIC_TAGS)
            if child.tail:
                fragments.append((child.tail, bold, italic))

    walk(el, False, False)

    spans = []
    for text, bold, italic in fragments:
        cleaned = _COLLAPSE_WHITESPACE.sub(' ', text)
        if not cleaned.strip():
            continue
        if spans and spans[-1]['bold'] == bold and spans[-1]['italic'] == italic:
            spans[-1]['text'] += cleaned
        else:
            spans.append({'text': cleaned, 'bold': bold, 'italic': italic})

    if spans:
        spans[0]['text'] = spans[0]['text'].lstrip()
        spans[-1]['text'] = spans[-1]['text'].rstrip()
        spans = [span for span in spans if span['text']]
    return spans


def _uportho_html_to_text(value):
    """Textul simplu dintr-un camp Html al Odoo (ex. `out_of_stock_message`), sau
    None cand nu ramane nimic vizibil. Aplicatia nu are motor HTML - nici aici, ca
    si la descriere, nu se trimite HTML catre ea."""
    if not value:
        return None
    text = lxml.html.fromstring(f'<div>{value}</div>').text_content()
    return _COLLAPSE_WHITESPACE.sub(' ', text).strip() or None


class ProductTemplate(models.Model):
    _inherit = 'product.template'

    app_badge_text = fields.Char(string='Eticheta (app)')
    app_badge_color = fields.Selection(BADGE_COLORS, string='Culoare eticheta (app)', default='purple')
    app_badge_date_end = fields.Date(string='Eticheta activa pana la (app)')

    def _app_badge_active(self):
        """Eticheta de afisat in app pentru acest produs, sau None daca nu exista sau a expirat."""
        self.ensure_one()
        if not self.app_badge_text:
            return None
        today = fields.Date.context_today(self)
        if self.app_badge_date_end and self.app_badge_date_end < today:
            return None
        return {'text': self.app_badge_text, 'color': self.app_badge_color or 'purple'}

    def _uportho_description_blocks(self):
        """Descrierea web (`website_description`) transformata in blocurile
        block/span din contract - NICIODATA HTML, aplicatia nu are motor HTML.

        `website_description` poate contine sectiuni pentru mai multe limbi,
        separate doar prin CSS pe site (`data-visibility-value-lang` pe elementul
        de sectiune - vezi spec sectiunea 12, mostenit din prototipul SwiftUI care a
        descoperit asta empiric). Pastram doar continutul taguit `ro_RO` plus orice
        continut netaguit (comun); eliminam alte limbi.

        Etichete acceptate: h1-h4 -> heading, p -> paragraph, ul/ol -> bullets.
        strong/b si em/i devin bold/italic pe span; orice alt tag inline (span, a,
        br...) se aplatizeaza la text simplu. HTML gol -> lista goala."""
        self.ensure_one()
        html_value = self.website_description
        if not html_value:
            return []

        root = lxml.html.fromstring(f'<div>{html_value}</div>')
        _uportho_filter_romanian_sections(root)

        blocks = []
        consumed = set()

        def is_inside_consumed(el):
            node = el.getparent()
            while node is not None:
                if id(node) in consumed:
                    return True
                node = node.getparent()
            return False

        for el in root.iter():
            if el is root or not isinstance(el.tag, str) or is_inside_consumed(el):
                continue
            if el.tag in _HEADING_TAGS:
                spans = _uportho_spans(el)
                if spans:
                    blocks.append({'type': 'heading', 'spans': spans})
                consumed.add(id(el))
            elif el.tag == 'p':
                spans = _uportho_spans(el)
                if spans:
                    blocks.append({'type': 'paragraph', 'spans': spans})
                consumed.add(id(el))
            elif el.tag in _LIST_TAGS:
                items = [{'spans': item_spans}
                         for li in el.findall('li')
                         for item_spans in [_uportho_spans(li)] if item_spans]
                if items:
                    blocks.append({'type': 'bullets', 'items': items})
                consumed.add(id(el))
        return blocks

    def _uportho_specs(self):
        """Perechi nume/valoare din `attribute_line_ids`, in ordinea lor. Brandul
        apare aici pentru ca brandul ESTE un atribut pe baza reala (`dr_brand_id` e
        gol peste tot - vezi numaratoarea din planul Fazei 2), nu un camp separat."""
        self.ensure_one()
        return [
            {'name': line.attribute_id.name, 'value': ', '.join(line.value_ids.mapped('name'))}
            for line in self.attribute_line_ids
        ]

    def _uportho_variants(self, variant=None, combination=None):
        """Selectorul de variante: cate un grup de valori per atribut cu mai multe
        valori, fiecare cu `selected` si `available`.

        `available` NU se deduce aici: pentru fiecare valoare candidata se intreaba
        Odoo (`_is_combination_possible`) daca combinatia rezultata din inlocuirea
        valorii curente a acelui atribut e posibila - acelasi API pe care il
        foloseste si pagina de produs de pe site pentru a dezactiva valorile excluse.

        `combination` e combinatia curenta (recordset de
        `product.template.attribute.value`), asa cum o intoarce
        `_get_combination_info`; daca nu e data, se ia de pe varianta ceruta sau de
        la prima combinatie posibila.

        None cand produsul nu are nicio linie de atribut cu mai multe valori (354 din
        619 produse reale) - ecranul nu deseneaza selectorul deloc."""
        self.ensure_one()
        lines = [line for line in self.attribute_line_ids
                 if len(line.product_template_value_ids._only_active()) > 1]
        if not lines:
            return None
        if combination is None:
            combination = (variant.product_template_attribute_value_ids if variant
                           else self._get_first_possible_combination())

        attributes = []
        for line in lines:
            values = []
            for ptav in line.product_template_value_ids._only_active():
                candidate = (combination - line.product_template_value_ids) + ptav
                values.append({
                    'id': ptav.id,
                    'name': ptav.name,
                    'selected': ptav in combination,
                    'available': bool(self._is_combination_possible(combination=candidate)),
                })
            attributes.append({
                'id': line.attribute_id.id,
                'name': line.attribute_id.name,
                'values': values,
            })
        return {'attributes': attributes}

    def _uportho_availability(self, variant=None):
        """Mesajul de disponibilitate si starea de stoc, sau None cand produsul n-are
        mesaj si nici `show_availability`.

        `out_of_stock_message` / `show_availability` / `_is_sold_out` vin din
        `website_sale_stock`, care NU e in dependintele acestui modul (si nu e
        instalat pe baza locala de test). De aceea prezenta lor se verifica, nu se
        presupune: fara modulul de stoc raspunsul e pur si simplu None, nu o eroare."""
        self.ensure_one()
        message = None
        if 'out_of_stock_message' in self._fields:
            message = _uportho_html_to_text(self.out_of_stock_message)
        show_availability = bool(
            self.show_availability if 'show_availability' in self._fields else False)
        if not message and not show_availability:
            return None

        record = variant or self.product_variant_id
        in_stock = True
        if record and hasattr(record, '_is_sold_out'):
            in_stock = not record.sudo()._is_sold_out()
        return {'message': message, 'in_stock': in_stock}

    def _uportho_price_tiers(self, pricelist, partner, fiscal_position=None, variant=None):
        """Pragurile de cantitate pentru acest produs pe `pricelist`. Pretul de la
        fiecare prag vine de la Odoo (prin `_uportho_price_amounts_multi`, acelasi
        mecanism ca in catalog.py, doar cu `quantity` diferit de 1 la fiecare pas) -
        NU se recalculeaza procente in Python.

        Reguli (plan Faza 2, Task 2):
        1. praguri candidate = valorile distincte `min_quantity` din regulile listei
           aplicabile produsului, plus 1;
        2. pretul fiecarui prag se cere la Odoo cu acea cantitate;
        3. praguri consecutive cu pret identic se elimina, pastrandu-l pe cel mai mic;
        4. daca ramane un singur prag si acesta e 1, lista are un singur element (nu
           se intoarce goala - tabelul de club arata exact asa azi);
        5. eticheta: min_qty 0 sau 1 -> '1+', altfel '<n>+'."""
        self.ensure_one()
        if not pricelist:
            return []
        if fiscal_position is None:
            fiscal_position = self.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)

        # `serialize_price` (si `_format_amount` pe care il foloseste) traiesc in
        # `pricing.py`, un modul fara dependente in modul, tocmai ca sa fie o singura
        # sursa a formei pretului si a calculului de discount_pct, importabila si de
        # aici si din controllere - nu se duplica.
        date = fields.Datetime.now()
        rules = pricelist._get_applicable_rules(variant or self, date)
        thresholds = sorted({1.0} | set(rules.mapped('min_quantity')))

        tiers = []
        for qty in thresholds:
            amount, list_amount = self._uportho_price_amounts_for(
                pricelist, partner, fiscal_position=fiscal_position, quantity=qty, variant=variant)
            price = serialize_price(amount, list_amount, pricelist.currency_id)
            if tiers and pricelist.currency_id.compare_amounts(
                    price['amount'], tiers[-1]['price']['amount']) == 0:
                continue
            min_qty = int(qty)
            tiers.append({
                'min_qty': min_qty,
                'label': '1+' if min_qty in (0, 1) else f'{min_qty}+',
                'price': price,
            })
        return tiers

    def _uportho_price_amounts_for(self, pricelist, partner, fiscal_position=None, quantity=1.0,
                                   variant=None):
        """Pretul acestui SINGUR produs pe un anume pricelist - vezi
        `_uportho_price_amounts_multi` pentru mecanismul complet si documentat.

        `variant` (un `product.product` al acestui template) schimba ce se pretuieste:
        pagina de produs cere pretul VARIANTEI alese, nu al template-ului, pentru ca
        altfel un `price_extra` de pe o valoare de atribut ("Mare +50 lei") nu s-ar
        vedea in app, desi magazinul il arata. Odoo pretuieste la fel un template si o
        varianta (`_compute_price_rule` accepta si una si alta), deci diferenta e doar
        ce record ii dam."""
        self.ensure_one()
        record = variant or self
        currency = pricelist.currency_id
        price, rule_id = pricelist._compute_price_rule(record, quantity, currency=currency)[record.id]
        if fiscal_position is None:
            fiscal_position = self.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)
        return self._uportho_amounts_with_vat(
            record, price, rule_id, pricelist, partner, fiscal_position, quantity)

    def _uportho_amounts_with_vat(self, record, price, rule_id, pricelist, partner, fiscal_position,
                                  quantity):
        """(amount, list_amount) cu TVA inclus pentru UN record (`product.template` sau
        `product.product`), pornind de la pretul brut si regula de pricelist deja
        calculate de Odoo. Locul unic in care se aplica pretul taiat si taxele - il
        folosesc si calea batch (catalog) si cea single (pagina de produs), ca cele doua
        sa nu poata devia una de alta."""
        currency = pricelist.currency_id
        date = fields.Date.context_today(self)
        pricelist_item = self.env['product.pricelist.item'].browse(rule_id)

        list_price = price
        if pricelist_item._show_discount_on_shop():
            base_price = pricelist_item._compute_price_before_discount(
                product=record, quantity=quantity, date=date, uom=record.uom_id, currency=currency)
            if currency.compare_amounts(base_price, price) == 1:
                list_price = base_price

        product_taxes = record.sudo().taxes_id._filter_taxes_by_company(self.env.company)
        taxes = fiscal_position.map_tax(product_taxes) if product_taxes else product_taxes

        def with_vat(amount):
            if not product_taxes:
                return currency.round(amount)
            adapted = self.env['product.product']._get_tax_included_unit_price_from_price(
                amount, product_taxes, product_taxes_after_fp=taxes)
            return taxes.compute_all(adapted, currency, 1, record, partner)['total_included']

        amount = with_vat(price)
        list_amount = with_vat(list_price) if currency.compare_amounts(list_price, price) == 1 else None
        return amount, list_amount

    def _uportho_price_amounts_multi(self, pricelist, partner, fiscal_position=None, quantity=1.0):
        """Pretul (implicit la cantitate 1, sau la `quantity` daca e data - vezi
        `_uportho_price_tiers`, care cere aici pretul la fiecare prag de cantitate)
        pe un anume pricelist, cu taxe incluse - asa cum le arata site-ul ('Taxe
        incluse') - pentru TOATE template-urile din `self` deodata. Foloseste API-ul
        de pricelist si de taxe al Odoo, exact mecanismele
        pe care le foloseste `website_sale` insusi in `_get_additionnal_combination_info`
        / `_apply_taxes_to_price`, dar cu un pricelist explicit primit ca parametru, nu
        `website.pricelist_id` (care ar rezolva lista din sesiune/geoip, gresita cand
        vrem doi clienti diferiti - lista proprie a userului si lista Ortho Club - in
        acelasi raspuns):
        - `product.pricelist._compute_price_rule` calculeaza pretul si regula aplicata
          pentru tot recordset-ul dintr-o singura interogare a regulilor de pricelist
          (nu recalculam regulile noi insine) - exact ce foloseste grila magazinului
          (`website_sale/models/product_template.py:270`), in loc de
          `_get_product_price_rule` chemat o data per produs (care ar repeta acea
          interogare de reguli o data per produs - N interogari in loc de 1);
        - `product.pricelist.item._show_discount_on_shop` / `_compute_price_before_discount`
          (din `website_sale`) decid daca si cat de mult sa aratam ca pret "de lista"
          taiat, exact cum decide magazinul;
        - `product.product._get_tax_included_unit_price_from_price` +
          `account.tax.compute_all(...)['total_included']` fac trecerea la pret cu
          taxe incluse (nu recalculam TVA-ul noi insine).

        `fiscal_position` e optional: pozitia fiscala depinde doar de `partner` (nu de
        produs sau de pricelist), deci apelantul o poate calcula o singura data pentru
        un intreg request si o poate da aici gata calculata, in loc sa fie recalculata
        per produs; daca nu e data, se calculeaza aici (comportament identic cu
        varianta single-produs de mai sus).

        Returneaza {template_id: (amount, list_amount)}, rotunjite cu rotunjirea
        monetara a valutei pricelist-ului; `list_amount` e None cand nu exista
        reducere de aratat."""
        if not self:
            return {}
        price_rules = pricelist._compute_price_rule(self, quantity, currency=pricelist.currency_id)
        if fiscal_position is None:
            fiscal_position = self.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)

        return {
            template.id: self._uportho_amounts_with_vat(
                template, *price_rules[template.id], pricelist, partner, fiscal_position, quantity)
            for template in self
        }
