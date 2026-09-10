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

# Campurile de pe `product.template` din care se citesc documentele produsului, in
# ordinea in care ajung in raspuns.
#
# - `product_document_ids` e standardul Odoo 18 (`product.document`) si exista mereu:
#   `product` e dependinta declarata a modulului.
# - `dr_document_ids` e al temei magazinului si NU exista pe o baza fara modulele lor
#   (dezvoltare locala, teste); prezenta lui se verifica, nu se presupune.
UPORTHO_DOCUMENT_FIELDS = ('product_document_ids', 'dr_document_ids')

# URL-ul de descarcare al unui document: ruta standard a Odoo pentru un atasament.
#
# Deliberat NU o ruta a acestui modul, spre deosebire de imagini. Un document nu se
# deseneaza in aplicatie, se deschide in exterior (browser/vizualizator de sistem), iar
# acolo aplicatia nu poate atasa cookie-ul de sesiune. Deci il servim exact cum il
# serveste Odoo si lasam regulile LUI de acces sa decida daca fisierul se descarca -
# decizie explicita a userului, nu o scapare.
UPORTHO_DOCUMENT_URL = '/web/content/%s?download=true'

# Campurile din care se citeste blocul de brand aratat pe pagina de produs a site-ului
# (logo + nume + descriere). Toate sunt ale modulelor magazinului si NU exista pe o
# baza fara ele; prezenta fiecaruia se verifica, nu se presupune.
#
# Brandul e o `product.attribute.value` (pe baza reala, brandul E un atribut - de aceea
# apare si in tabelul de specificatii, si acolo ramane): `dr_brand_value_id` de pe
# `product.template` arata catre ea, iar valoarea poarta logoul (`dr_image`) si textul
# (`dr_brand_description`, HTML). `brand_name` e numele gata calculat de ei pe produs.
UPORTHO_BRAND_VALUE_FIELD = 'dr_brand_value_id'
UPORTHO_BRAND_NAME_FIELD = 'brand_name'
UPORTHO_BRAND_DESCRIPTION_FIELD = 'dr_brand_description'
UPORTHO_BRAND_LOGO_FIELD = 'dr_image'


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


def _uportho_html_blocks(html_value):
    """Un camp HTML al Odoo transformat in blocurile block/span din contract -
    NICIODATA HTML, aplicatia nu are motor HTML.

    Folosit si pentru `website_description` (vezi `_uportho_description_blocks`) si
    pentru `bulk_info`-ul listelor de pret aratate pe pagina de produs de pe site
    (vezi `_uportho_price_tables_from_theme`): o singura cale de HTML, nu doua.

    Sectiunile in alte limbi decat romana se elimina (`data-visibility-value-lang`,
    vezi `_uportho_filter_romanian_sections`). Etichete acceptate: h1-h4 -> heading,
    p -> paragraph, ul/ol -> bullets. strong/b si em/i devin bold/italic pe span;
    orice alt tag inline (span, a, br...) se aplatizeaza la text simplu. HTML gol ->
    lista goala."""
    if not html_value:
        return []

    root = lxml.html.fromstring(f'<div>{html_value}</div>')
    _uportho_filter_romanian_sections(root)

    blocks = []

    def collect(container):
        """Parcurge structura in adancime, oprindu-se la primul bloc recunoscut de pe
        fiecare ramura; invelisurile (div, section...) se traverseaza mai departe.

        Fara multimi de elemente "deja consumate": lxml creeaza obiectele de element
        temporar, iar `id()`-ul lor se poate REFOLOSI dupa ce primul e eliberat, asa
        ca al doilea paragraf parea deja procesat si disparea. Efectul se vedea in
        aplicatie ca descriere trunchiata la primul paragraf."""
        for el in container:
            if not isinstance(el.tag, str):
                continue
            if el.tag in _HEADING_TAGS:
                spans = _uportho_spans(el)
                if spans:
                    blocks.append({'type': 'heading', 'spans': spans})
            elif el.tag == 'p':
                spans = _uportho_spans(el)
                if spans:
                    blocks.append({'type': 'paragraph', 'spans': spans})
            elif el.tag in _LIST_TAGS:
                items = [{'spans': item_spans}
                         for li in el.findall('li')
                         for item_spans in [_uportho_spans(li)] if item_spans]
                if items:
                    blocks.append({'type': 'bullets', 'items': items})
            else:
                collect(el)

    collect(root)

    if not blocks:
        spans = _uportho_spans(root)
        if spans:
            blocks.append({'type': 'paragraph', 'spans': spans})
    return blocks


def _uportho_document_attachment(document):
    """`ir.attachment`-ul din spatele unui document de produs, sau un recordset gol.

    `product.document` (standardul Odoo 18) e un `_inherits` peste `ir.attachment` si
    isi poarta atasamentul in `ir_attachment_id`; asa il citeste si pagina de produs de
    pe site, si ruta de documente din `website_sale`. Modelul temei magazinului nu e
    cunoscut aici, deci se accepta si un document care E el insusi un atasament. Orice
    alta forma intoarce gol - documentul dispare din lista, nu devine o eroare.

    Atasamentul e si numele fisierului, si tinta URL-ului de descarcare
    (`/web/content/<id>`). Continutul lui nu se citeste niciodata aici: daca fisierul
    exista si daca utilizatorul are voie sa-l ia decide Odoo, la deschidere.

    `sudo`: documentele nu sunt citibile de un utilizator portal - nici sablonul
    magazinului nu le citeste altfel (`product.sudo().product_document_ids`). Sudo-ul
    e doar pentru a putea LISTA documentele; descarcarea trece prin `/web/content`,
    adica prin drepturile obisnuite ale userului."""
    record = document.sudo()
    if record._name == 'ir.attachment':
        return record
    attachment = getattr(record, 'ir_attachment_id', None)
    if getattr(attachment, '_name', None) == 'ir.attachment':
        return attachment
    return record.env['ir.attachment'].browse()


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
        br...) se aplatizeaza la text simplu. HTML gol -> lista goala.

        Conversia propriu-zisa sta in `_uportho_html_blocks`, ca sa fie o singura cale
        de HTML in modul (o foloseste si nota tabelelor de pret)."""
        self.ensure_one()
        return _uportho_html_blocks(self.website_description)

    def _uportho_specs(self):
        """Perechi nume/valoare din `attribute_line_ids`, in ordinea lor. Brandul
        apare aici pentru ca brandul ESTE un atribut pe baza reala (`dr_brand_id` e
        gol peste tot - vezi numaratoarea din planul Fazei 2), nu un camp separat."""
        self.ensure_one()
        return [
            {'name': line.attribute_id.name, 'value': ', '.join(line.value_ids.mapped('name'))}
            for line in self.attribute_line_ids
        ]

    def _uportho_brand_value(self):
        """Valoarea de atribut care poarta brandul produsului (`dr_brand_value_id`),
        sau un recordset gol.

        Prezenta campului se VERIFICA, nu se presupune: e al modulelor magazinului si
        lipseste pe o baza fara ele (dezvoltare locala, teste), unde citirea lui ar fi
        o eroare. Se verifica si tipul a ce s-a citit: daca vreodata campul ar arata
        catre alt model, blocul de brand dispare in loc sa produca o eroare.

        `sudo`: valorile de atribut nu sunt neaparat citibile de un utilizator portal.

        Metoda exista separat si ca sa fie punctul unic in care se poate simula, in
        teste, prezenta campului."""
        self.ensure_one()
        Value = self.env['product.attribute.value']
        if UPORTHO_BRAND_VALUE_FIELD not in self._fields:
            return Value.browse()
        value = self.sudo()[UPORTHO_BRAND_VALUE_FIELD]
        if getattr(value, '_name', None) != Value._name:
            return Value.browse()
        return value

    def _uportho_brand(self):
        """Blocul de brand al paginii de produs (nume + descriere + valoarea care
        poarta logoul), sau None cand produsul n-are brand ori campurile nu exista.

        Numele: `brand_name` de pe produs cand exista (asa il calculeaza magazinul),
        altfel numele valorii de atribut. Fara nume nu exista bloc - un chenar cu un
        logo si nimic altceva n-ar spune nimic.

        Descrierea e HTML pe `dr_brand_description` si trece prin aceeasi conversie ca
        descrierea produsului (`_uportho_html_blocks`) - blocuri, niciodata HTML,
        aplicatia nu are motor HTML. Citita cu `getattr`, ca `bulk_info`-ul listelor de
        pret: lipsa campului inseamna exact acelasi lucru ca lipsa textului.

        Brandul ramane si in tabelul de specificatii (`_uportho_specs`, unde intra ca
        atribut): site-ul il arata in amandoua locurile.

        `value` din raspuns e inregistrarea din care controllerul construieste URL-ul
        logoului - are nevoie si de `write_date`-ul ei, pentru `?unique=`."""
        self.ensure_one()
        value = self._uportho_brand_value()
        if not value:
            return None
        name = (getattr(self.sudo(), UPORTHO_BRAND_NAME_FIELD, None) or value.name or '').strip()
        if not name:
            return None
        return {
            'value': value,
            'name': name,
            'description': _uportho_html_blocks(
                getattr(value, UPORTHO_BRAND_DESCRIPTION_FIELD, None)),
        }

    def _uportho_document_records(self, field_name):
        """Documentele produsului dintr-un camp de documente, in sudo, sau un recordset
        gol cand campul nu exista pe baza asta.

        Prezenta campului se VERIFICA, nu se presupune: `dr_document_ids` e al temei
        magazinului si lipseste pe o baza fara modulele lor, iar citirea unui camp
        inexistent ar fi o eroare (aceeasi regula ca la `_uportho_availability` si la
        bifele de pricelist).

        Recordset-ul gol de intoarcere e de `product.document` chiar si cand campul
        lipsa era al temei - apelantul doar itereaza peste el.

        Metoda exista separat si ca sa fie punctul unic in care se poate simula, in
        teste, prezenta campului temei."""
        self.ensure_one()
        if field_name not in self._fields:
            return self.env['product.document'].browse()
        return self.sudo()[field_name]

    def _uportho_documents(self):
        """Documentele aratate in tabul "Documente" al paginii de produs, in ordinea de
        acolo: intai cele standard, apoi cele ale temei (vezi `UPORTHO_DOCUMENT_FIELDS`).

        Se trimite exact ce arata site-ul, nu mai mult: doar documentele publicate pe
        pagina de produs (`shown_on_product_page`, campul adaugat de `website_sale`,
        dupa care filtreaza si sablonul lui). Un document intern, nepublicat, nu are
        voie sa apara in aplicatie doar pentru ca ea nu are ecran de administrare.

        URL-ul e ruta standard a Odoo pentru atasamentul din spatele documentului
        (`/web/content/<id>?download=true`), nu una a acestui modul: documentul se
        deschide in exterior, unde aplicatia nu poate atasa cookie-ul de sesiune, deci
        decizia daca fisierul se descarca ramane a Odoo si a regulilor lui de acces.
        Nu se citeste nici continutul, nici marimea: existenta fisierului o stabileste
        tot Odoo, la deschidere.

        Un document care apare in ambele campuri (acelasi atasament) se trimite o
        singura data. Unul fara atasament de care sa se agate URL-ul e sarit - n-ar
        avea ce deschide.

        `id` e id-ul atasamentului, adica exact cel din URL: doua surse de documente
        pot avea acelasi id de inregistrare, dar fisierul din spate e unul singur."""
        self.ensure_one()
        documents = []
        seen_attachments = set()
        for field_name in UPORTHO_DOCUMENT_FIELDS:
            for record in self._uportho_document_records(field_name):
                if 'shown_on_product_page' in record._fields and not record.shown_on_product_page:
                    continue
                attachment = _uportho_document_attachment(record)
                if not attachment or attachment.id in seen_attachments:
                    continue
                seen_attachments.add(attachment.id)
                name = (getattr(record, 'name', None) or attachment.name or '').strip()
                file_name = (attachment.name or name or '').strip()
                documents.append({
                    'id': attachment.id,
                    'name': name or file_name,
                    'file_name': file_name or name,
                    'url': UPORTHO_DOCUMENT_URL % attachment.id,
                })
        return documents

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
                    # Combinatia de trimis inapoi in `?values=` la apasarea pe aceasta
                    # valoare. Fara ea aplicatia ar avea doar id-uri de valoare si nicio
                    # cale sa ceara varianta rezultata - exact gaura care facea ca
                    # fiecare apasare pe o marime sa dea 422.
                    'combination': candidate.ids,
                })
            attributes.append({
                'id': line.attribute_id.id,
                'name': line.attribute_id.name,
                'values': values,
            })
        # `selected`: combinatia activa acum, ca aplicatia sa poata desena starea de
        # selectie dupa o re-cerere fara sa o deduca din altceva.
        return {'selected': combination.ids, 'attributes': attributes}

    def _uportho_variant_rows(self, pricelist, partner, fiscal_position=None):
        """Randurile tabelului de comanda pe variante - ce arata site-ul pe pagina
        unui produs cu mai multe variante: cate un rand per varianta, cu valorile ei
        de atribut, codul, disponibilitatea si pretul unitar.

        Lista goala pentru un produs cu o singura varianta: acolo tabelul nu are ce
        arata (un singur rand ar repeta pretul deja afisat deasupra), iar ecranul
        pastreaza forma dinainte.

        Pretul fiecarui rand vine tot de la Odoo, pe calea proprie modulului
        (`_uportho_price_amounts_for` cu `variant`), la cantitatea 1: asa intra in
        pret si `price_extra`-ul valorilor de atribut ("Complet +20 lei"), pe care
        magazinul il arata. Subtotalurile de dupa prima apasare pe plus NU se
        calculeaza aici - ele depind de cantitatile alese in aplicatie si se cer prin
        `POST /products/<id>/prices`, pentru ca o cantitate mai mare poate trece un
        prag de pret.

        Randul poarta insa subtotalul de PORNIRE (`_uportho_zero_amount`): tabelul se
        deschide cu toate cantitatile pe zero si aplicatia nu are voie sa scrie ea
        "0,00 lei" - nu formateaza si nu calculeaza bani (CLAUDE.md). Fara suma asta in
        raspuns, coloana Subtotal si Totalul ar arata "—" pana la prima apasare pe
        plus, desi valoarea lor e cunoscuta din primul moment."""
        self.ensure_one()
        variants = self.product_variant_ids
        if len(variants) < 2:
            return []
        if fiscal_position is None:
            fiscal_position = self.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)

        rows = []
        for variant in variants:
            amount, list_amount = self._uportho_price_amounts_for(
                pricelist, partner, fiscal_position=fiscal_position, variant=variant)
            rows.append({
                'variant_id': variant.id,
                'attributes': [
                    {'name': ptav.attribute_id.name, 'value': ptav.name}
                    for ptav in variant.product_template_attribute_value_ids
                ],
                'default_code': variant.default_code or None,
                'availability': self._uportho_availability(variant=variant),
                'price': serialize_price(amount, list_amount, pricelist.currency_id),
                'subtotal': self._uportho_zero_amount(pricelist.currency_id),
            })
        return rows

    def _uportho_zero_amount(self, currency):
        """Suma zero, formatata de server, in forma standard de pret al API-ului.

        E subtotalul unui rand necomandat si totalul unui tabel proaspat deschis -
        aceleasi sume pe care le intoarce `POST /products/<id>/prices` cu toate
        cantitatile pe zero (`currency.round(pret * 0)`), doar ca aici nu se mai cere
        niciun pret ca sa se ajunga la ele. Fara pret taiat: un zero n-a fost niciodata
        redus de la altceva."""
        return serialize_price(0.0, None, currency)

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

    def _uportho_price_tables_from_theme(self, combination_info, fallback_currency):
        """Tabelele de pret ale paginii de produs, CITITE din ce a calculat deja
        magazinul - nu recalculate de noi.

        Modulul clientului (`terrabit_prime_extension`) suprascrie
        `_get_combination_info` si pune in dictionarul intors `other_bulk_prices`:
        cate o intrare per lista de pret aratata pe pagina de produs
        (`is_public_pricelist` si `is_compare_pricelist`, doua campuri adaugate de ei
        pe `product.pricelist`), fiecare cu:
        - `name`: titlul aratat pe site (pe productie, al doilea e un nume de
          campanie pe care aplicatia nu are cum sa-l ghiceasca - de aceea titlurile
          vin de la server, nu sunt scrise in app);
        - `bulk_info`: HTML de pe lista de pret;
        - `prices`: `qty` + `price` (cu taxe, in valuta afisata) + `formatted_price`
          (HTML).
        Ruta noastra cheama oricum `_get_combination_info`, deci daca datele sunt
        acolo le citim - sunt exact ce a calculat magazinul pentru pagina lui.

        ATENTIE: pe serverul clientului nu ajung niciodata aici. Acolo
        `_get_combination_info` arunca la fiecare cerere (tema randeaza inauntrul lui
        un template QWeb de website - vezi `controllers/product._resolve_combination`),
        deci `combination_info` e gol si calea care functioneaza in realitate e cea
        directa: `_uportho_site_pricelists` + `_uportho_site_price_tables`. Metoda asta
        ramane prima incercata pentru ca, atunci cand merge, e sursa cea mai apropiata
        de site.

        Doua lucruri NU se preiau ca atare:
        - `formatted_price` e Markup (HTML). Aplicatia n-are motor HTML, deci suma se
          formateaza cu `serialize_price`, formatorul modulului - o singura forma de
          pret in tot API-ul.
        - `bulk_info` trece prin `_uportho_html_blocks`, aceeasi conversie ca
          descrierea produsului, tot ca sa nu plece HTML catre aplicatie.

        Valuta: cea afisata de magazin (`combination_info['currency']`, in care tema
        si-a convertit deja sumele); `fallback_currency` doar cand lipseste.

        Cod strain: un `other_bulk_prices` absent, gol sau stricat nu are voie sa
        transforme pagina de produs in 500 - se intoarce ce se poate citi, eventual
        lista goala, iar apelantul cade pe `_uportho_price_tiers`."""
        self.ensure_one()
        entries = (combination_info or {}).get('other_bulk_prices') or []
        currency = (combination_info or {}).get('currency') or fallback_currency
        tables = []
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            rows = []
            for row in entry.get('prices') or []:
                if not isinstance(row, dict):
                    continue
                try:
                    # `qty = 0` e implicitul Odoo pentru "fara minim", nu un prag
                    # real - aceeasi normalizare ca in `_uportho_price_tiers`.
                    min_qty = max(int(row.get('qty') or 1), 1)
                    amount = float(row['price'])
                except (KeyError, TypeError, ValueError):
                    continue
                rows.append({
                    'min_qty': min_qty,
                    'label': '1+' if min_qty == 1 else f'{min_qty}+',
                    'price': serialize_price(amount, None, currency),
                })
            if not rows:
                continue
            tables.append({
                'title': (entry.get('name') or '').strip() or None,
                'note': _uportho_html_blocks(entry.get('bulk_info')),
                'entries': rows,
            })
        return tables

    def _uportho_site_pricelist_for(self, flag):
        """Prima lista de pret activa marcata cu `flag`, sau un recordset gol.

        `flag` e unul din campurile pe care modulul clientului
        (`terrabit_prime_extension`) le adauga pe `product.pricelist`. Pe o baza fara
        modulele lor - baza locala de dezvoltare - campul nu exista, iar o cautare pe
        un camp inexistent ar fi o eroare: de aceea prezenta lui se VERIFICA, nu se
        presupune (aceeasi regula ca la campurile din `website_sale_stock`, vezi
        `_uportho_availability`).

        `sudo`: listele de pret nu sunt neaparat citibile de un utilizator portal, la
        fel ca lista Ortho Club (vezi `_current_club_pricelist`)."""
        Pricelist = self.env['product.pricelist'].sudo()
        if flag not in Pricelist._fields:
            return Pricelist.browse()
        return Pricelist.search([(flag, '=', True)], limit=1)

    def _uportho_site_pricelists(self):
        """Listele de pret pe care magazinul le arata pe pagina de produs, in ordinea
        de acolo: intai cea publica, apoi cea de comparatie.

        Selectia e cea din `terrabit_prime_extension/models/product_template.py`
        ("Show first Public PL if found", apoi "Show first Compare PL if found"), doar
        ca noi o facem direct, nu prin `_get_combination_info`: pe serverul clientului
        acel apel randeaza inauntrul lui un template QWeb de website al temei
        (`droggol_theme_common` -> `theme_prime.product_extra_fields`), care are nevoie
        de un context complet de randare de website. Un request JSON nu are asa ceva,
        deci apelul arunca de fiecare data si `other_bulk_prices` nu se poate citi
        niciodata de acolo.

        O lista marcata cu ambele campuri apare o singura data: doua tabele identice
        unul sub altul n-ar spune nimic in plus (codul lor ar adauga-o de doua ori)."""
        self.ensure_one()
        # Acumulatorul porneste in sudo: reuniunea de recordseturi pastreaza mediul
        # celui din stanga, deci un `browse()` obisnuit aici ar sterge tacut sudo-ul
        # listelor gasite si citirea lor ar putea pica pe drepturi de portal.
        pricelists = self.env['product.pricelist'].sudo().browse()
        for flag in ('is_public_pricelist', 'is_compare_pricelist'):
            pricelists |= self._uportho_site_pricelist_for(flag)
        return pricelists

    def _uportho_site_price_tables(self, pricelists, partner, fiscal_position=None, variant=None):
        """Tabelele de pret ale paginii, cate unul per lista din `pricelists`.

        Titlul e numele listei (pe productie, al doilea e un nume de campanie, imposibil
        de ghicit din aplicatie - de aceea titlurile vin mereu de la server), nota e
        campul HTML `bulk_info` de pe lista, trecut prin aceeasi conversie ca descrierea
        produsului (`_uportho_html_blocks`) - niciodata HTML catre aplicatie.

        Pragurile si preturile trec pe calea proprie modulului (`_uportho_price_tiers`
        -> `_uportho_price_amounts_for` -> `pricelist._compute_price_rule` + taxe):
        pragurile sunt `min_quantity`-urile regulilor aplicabile, normalizate cu
        `max(1, int(...))` - exact normalizarea din codul clientului - iar preturile le
        da Odoo, nu le calculam noi.

        `pricelists` se primeste ca parametru (nu se cauta aici) ca selectia si
        construirea sa fie testabile separat: campurile dupa care se face selectia nu
        exista pe baza locala, pragurile si preturile insa da."""
        self.ensure_one()
        tables = []
        for pricelist in pricelists:
            entries = self._uportho_price_tiers(
                pricelist, partner, fiscal_position=fiscal_position, variant=variant)
            if not entries:
                continue
            tables.append({
                'title': (pricelist.name or '').strip() or None,
                'note': self._uportho_pricelist_note(pricelist),
                'entries': entries,
            })
        return tables

    def _uportho_pricelist_note(self, pricelist):
        """Nota de sub tabel: campul HTML `bulk_info` de pe lista de pret, adaugat tot
        de modulul clientului. Trece prin aceeasi conversie ca descrierea produsului -
        blocuri, niciodata HTML, aplicatia nu are motor HTML.

        Citit cu `getattr`, nu prin `_fields`: aici e o simpla citire de camp (nu un
        domeniu de cautare, ca la campurile de selectie), iar lipsa campului inseamna
        exact acelasi lucru ca lipsa modulului - nota goala, niciodata o eroare."""
        return _uportho_html_blocks(getattr(pricelist, 'bulk_info', None))

    def _uportho_price_tiers(self, pricelist, partner, fiscal_position=None, variant=None):
        """Pragurile de cantitate pentru acest produs pe `pricelist`. Pretul de la
        fiecare prag vine de la Odoo (prin `_uportho_price_amounts_multi`, acelasi
        mecanism ca in catalog.py, doar cu `quantity` diferit de 1 la fiecare pas) -
        NU se recalculeaza procente in Python.

        Reguli (plan Faza 2, Task 2):
        1. praguri candidate = valorile distincte `min_quantity` din regulile listei
           aplicabile produsului, normalizate cu `max(1, ...)`; pragul 1 se adauga doar
           cand nu exista nicio regula;
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
        # `min_quantity = 0` e valoarea implicita Odoo pentru "fara minim", nu un prag
        # real de cantitate. Pretuit chiar la cantitatea 0, Odoo nu aplica regula si
        # intoarce pretul nereduse: pe staging asta a produs doua randuri "1+" in
        # tabel, primul cu pretul public (22.430,00) langa cel al clientului
        # (15.701,00). Pragul 0 se normalizeaza la 1 inainte de pretuire, nu doar la
        # etichetare.
        #
        # Pragul 1 se adauga doar cand nu exista nicio regula - exact
        # `sorted({max(1, int(rule.min_quantity)) for rule in rules}) or [1]` din codul
        # clientului. Adaugat mereu (cum era inainte), pe o lista a carei cea mai mica
        # regula porneste de la 5 aparea in aplicatie un rand "1+" pe care site-ul nu-l
        # arata.
        thresholds = sorted({max(q, 1.0) for q in rules.mapped('min_quantity')}) or [1.0]

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
