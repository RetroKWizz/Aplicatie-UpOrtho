from odoo import fields, models

BADGE_COLORS = [
    ('orange', 'Portocaliu'), ('green', 'Verde'), ('blue', 'Albastru'),
    ('purple', 'Mov'), ('red', 'Rosu'),
]


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

    def _uportho_price_amounts(self, pricelist, partner):
        """Pretul acestui produs (cantitate 1) pe un anume pricelist, cu taxe incluse -
        asa cum le arata site-ul ('Taxe incluse'). Foloseste API-ul de pricelist si de
        taxe al Odoo, exact mecanismele pe care le foloseste `website_sale` insusi in
        `_get_additionnal_combination_info` / `_apply_taxes_to_price`, dar cu un
        pricelist explicit primit ca parametru, nu `website.pricelist_id` (care ar
        rezolva lista din sesiune/geoip, gresita cand vrem doi clienti diferiti - lista
        proprie a userului si lista Ortho Club - in acelasi raspuns):
        - `product.pricelist._get_product_price_rule` calculeaza pretul si regula
          aplicata (nu recalculam regulile de pricelist noi insine);
        - `product.pricelist.item._show_discount_on_shop` / `_compute_price_before_discount`
          (din `website_sale`) decid daca si cat de mult sa aratam ca pret "de lista"
          taiat, exact cum decide magazinul;
        - `product.product._get_tax_included_unit_price_from_price` +
          `account.tax.compute_all(...)['total_included']` fac trecerea la pret cu
          taxe incluse (nu recalculam TVA-ul noi insine).

        Returneaza (amount, list_amount), rotunjite cu rotunjirea monetara a valutei
        pricelist-ului; `list_amount` e None cand nu exista reducere de aratat."""
        self.ensure_one()
        Item = self.env['product.pricelist.item']
        currency = pricelist.currency_id
        date = fields.Date.context_today(self)

        price, rule_id = pricelist._get_product_price_rule(self, 1.0, currency=currency)
        list_price = price
        pricelist_item = Item.browse(rule_id)
        if pricelist_item._show_discount_on_shop():
            base_price = pricelist_item._compute_price_before_discount(
                product=self, quantity=1.0, date=date, uom=self.uom_id, currency=currency)
            if currency.compare_amounts(base_price, price) == 1:
                list_price = base_price

        product_taxes = self.sudo().taxes_id._filter_taxes_by_company(self.env.company)
        fiscal_position = self.env['account.fiscal.position'].sudo()._get_fiscal_position(partner)
        taxes = fiscal_position.map_tax(product_taxes) if product_taxes else product_taxes

        def with_vat(amount):
            if not product_taxes:
                return currency.round(amount)
            adapted = self.env['product.product']._get_tax_included_unit_price_from_price(
                amount, product_taxes, product_taxes_after_fp=taxes)
            return taxes.compute_all(adapted, currency, 1, self, partner)['total_included']

        amount = with_vat(price)
        list_amount = with_vat(list_price) if currency.compare_amounts(list_price, price) == 1 else None
        return amount, list_amount
