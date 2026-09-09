from odoo import api, fields, models

ICONS = [
    ('club', 'Ortho Club'),
    ('delivery', 'Livrare'),
    ('return', 'Retur'),
    ('payment', 'Plata'),
    ('info', 'Info'),
]


class AppBenefit(models.Model):
    _name = 'uportho.app.benefit'
    _description = 'Beneficiu magazin, aratat pe pagina de produs in aplicatia mobila'
    _order = 'sequence, id'

    name = fields.Char(string='Titlu', required=True)
    text = fields.Char(string='Subtitlu')
    icon = fields.Selection(ICONS, string='Iconita', required=True, default='info')
    sequence = fields.Integer(string='Ordine', default=10)
    active = fields.Boolean(default=True)

    @api.model
    def _search_active(self):
        """Beneficiile de aratat in app, in ordinea de afisare. Arhivarea standard
        Odoo (`active=False`) le exclude automat din `search()`; metoda exista ca
        punct unic pe care controller-ul rutei de produs il apeleaza, la fel cum
        `uportho.app.banner._search_active_now` e punctul unic pentru bannere."""
        return self.search([], order='sequence, id')
