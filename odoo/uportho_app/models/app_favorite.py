from odoo import fields, models


class AppFavorite(models.Model):
    """Un produs pus la favorite din aplicatie.

    **Magazinul nu are lista de favorite**: modulul Odoo care o aduce
    (`website_sale_wishlist`) nu e instalat pe instanta reala, deci nu exista nimic in
    magazin cu care sa se sincronizeze si nici un ecran de pe site care sa arate altceva.
    Favoritele traiesc deci in acest model, legate de partenerul comercial al contului -
    la fel ca adresele si comenzile, un cabinet cu mai multi utilizatori vede aceeasi
    lista.

    Daca magazinul primeste vreodata `website_sale_wishlist`, aici e locul din care se
    trece pe `product.wishlist`, ca sa nu existe doua liste."""

    _name = 'uportho.app.favorite'
    _description = 'Produs favorit in aplicatia mobila'
    _order = 'create_date desc, id desc'

    partner_id = fields.Many2one(
        'res.partner', required=True, ondelete='cascade', index=True,
        string='Client (partener comercial)')
    product_tmpl_id = fields.Many2one(
        'product.template', required=True, ondelete='cascade', index=True, string='Produs')

    _sql_constraints = [
        ('favorite_unique', 'unique(partner_id, product_tmpl_id)',
         'Produsul e deja la favorite.'),
    ]
