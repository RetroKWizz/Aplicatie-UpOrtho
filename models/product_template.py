import re

import lxml.html

from odoo import fields, models

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

    def _uportho_price_tiers(self, pricelist, partner, fiscal_position=None):
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

        # Import intarziat (nu la nivel de modul): `models/` se incarca inaintea
        # `controllers/` in __init__.py-ul modulului, deci un import la nivel de
        # modul aici ar depinde de ordinea de incarcare. `serialize_price` (si
        # `_format_amount` pe care il foloseste) raman singura sursa a formei
        # pretului si a calculului de discount_pct - nu se duplica aici.
        from odoo.addons.uportho_app.controllers.catalog import serialize_price

        date = fields.Datetime.now()
        rules = pricelist._get_applicable_rules(self, date)
        thresholds = sorted({1.0} | set(rules.mapped('min_quantity')))

        tiers = []
        for qty in thresholds:
            amount, list_amount = self._uportho_price_amounts_multi(
                pricelist, partner, fiscal_position=fiscal_position, quantity=qty)[self.id]
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

    def _uportho_price_amounts(self, pricelist, partner):
        """Pretul acestui SINGUR produs (cantitate 1) pe un anume pricelist - vezi
        `_uportho_price_amounts_multi` pentru mecanismul complet si documentat.
        Pastrat separat (nu doar apelat direct de controller) pentru ruta de detaliu
        de produs (felia urmatoare), care are un singur template si nu justifica
        asamblarea unui recordset doar ca sa foloseasca varianta batch."""
        self.ensure_one()
        return self._uportho_price_amounts_multi(pricelist, partner)[self.id]

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
        Item = self.env['product.pricelist.item']
        currency = pricelist.currency_id
        date = fields.Date.context_today(self)

        price_rules = pricelist._compute_price_rule(self, quantity, currency=currency)
        if fiscal_position is None:
            fiscal_position = self.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)

        results = {}
        for template in self:
            price, rule_id = price_rules[template.id]
            list_price = price
            pricelist_item = Item.browse(rule_id)
            if pricelist_item._show_discount_on_shop():
                base_price = pricelist_item._compute_price_before_discount(
                    product=template, quantity=quantity, date=date, uom=template.uom_id, currency=currency)
                if currency.compare_amounts(base_price, price) == 1:
                    list_price = base_price

            product_taxes = template.sudo().taxes_id._filter_taxes_by_company(self.env.company)
            taxes = fiscal_position.map_tax(product_taxes) if product_taxes else product_taxes

            def with_vat(amount, product_taxes=product_taxes, taxes=taxes):
                if not product_taxes:
                    return currency.round(amount)
                adapted = self.env['product.product']._get_tax_included_unit_price_from_price(
                    amount, product_taxes, product_taxes_after_fp=taxes)
                return taxes.compute_all(adapted, currency, 1, template, partner)['total_included']

            amount = with_vat(price)
            list_amount = with_vat(list_price) if currency.compare_amounts(list_price, price) == 1 else None
            results[template.id] = (amount, list_amount)
        return results
