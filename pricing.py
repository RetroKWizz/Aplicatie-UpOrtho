"""Serializarea preturilor pentru API-ul aplicatiei.

Modul fara dependente in modul (nici controller, nici model): atat controllerele
(`controllers/catalog.py`, `controllers/product.py`) cat si modelele
(`models/product_template.py`) au nevoie de aceeasi forma de pret. Inainte,
`product.template._uportho_price_tiers` importa `serialize_price` din
`controllers/catalog.py` in interiorul metodei, ca sa ocoleasca ordinea de
incarcare `models/` inainte de `controllers/` - un model care depinde de un
controller, adica exact invers decat trebuie. Aici e locul comun, importabil
normal, la inceput de fisier, din ambele directii.
"""


def _format_amount(amount, currency):
    """Formatare romaneasca a unei sume monetare: virgula zecimala, punct pentru mii
    ('148,50 lei', '1.234,00 lei'). Nu folosim formatarea de limba din Odoo
    (`formatLang`) ca sa nu depindem de ce limbi/traduceri sunt instalate pe o baza
    anume - separatorii sunt o cerinta de contract, nu o optiune. Numarul de zecimale
    si pozitia simbolului insa NU sunt fixe: modulul are in domeniu si liste de pret
    in alte valute decat RON (ex. "Euro Discount" pe baza reala) - se iau din
    `currency.decimal_places` / `currency.position`, nu se presupun (corect pentru
    RON azi, dar RON nu e singura valuta posibila aici)."""
    rounded = currency.round(amount)
    decimals = currency.decimal_places
    text = f'{rounded:,.{decimals}f}'
    if '.' in text:
        integer_part, decimal_part = text.split('.')
    else:
        integer_part, decimal_part = text, ''
    integer_part = integer_part.replace(',', '.')
    number = f'{integer_part},{decimal_part}' if decimal_part else integer_part
    if currency.position == 'before':
        return f'{currency.symbol}{number}'
    return f'{number} {currency.symbol}'


def serialize_price(amount, list_amount, currency):
    discount_pct = None
    if list_amount is not None and list_amount > amount:
        discount_pct = round((list_amount - amount) / list_amount * 100)
    return {
        'amount': amount,
        'currency': currency.name,
        'formatted': _format_amount(amount, currency),
        'with_vat': True,
        'list_amount': list_amount,
        'list_formatted': _format_amount(list_amount, currency) if list_amount is not None else None,
        'discount_pct': discount_pct,
    }
