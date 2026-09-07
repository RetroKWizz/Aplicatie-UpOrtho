from odoo import api, fields, models


class ProductPublicCategory(models.Model):
    _inherit = 'product.public.category'

    app_home_visible = fields.Boolean(string='Vizibila pe Acasa (app)', default=False)
    app_home_sequence = fields.Integer(string='Ordine pe Acasa (app)', default=10)
    app_home_icon = fields.Image(string='Iconita (app)', max_width=512, max_height=512)

    @api.model
    def _search_app_home(self, website):
        """Categoriile rapide de pe Acasa: bifate `app_home_visible`, pe website-ul dat
        sau fara website, ordonate dupa `app_home_sequence`."""
        domain = [
            ('app_home_visible', '=', True),
            '|', ('website_id', '=', False), ('website_id', '=', website.id),
        ]
        return self.search(domain, order='app_home_sequence, id')
