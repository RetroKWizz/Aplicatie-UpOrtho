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
