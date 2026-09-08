from odoo import api, fields, models
from odoo.exceptions import ValidationError


class AppBanner(models.Model):
    _name = 'uportho.app.banner'
    _description = 'Banner aplicatie mobila UpOrtho'
    _order = 'sequence, id'

    name = fields.Char(string='Titlu', required=True)
    subtitle = fields.Char(string='Subtitlu')
    cta_text = fields.Char(string='Text buton', default='Vezi produse')
    image = fields.Image(string='Imagine', max_width=1600, max_height=1600)
    placement = fields.Selection(
        [('hero', 'Hero'), ('promo', 'Promo')], string='Plasare', required=True, default='hero')
    link_type = fields.Selection(
        [('category', 'Categorie'), ('url', 'URL extern'), ('none', 'Fara link')],
        string='Tip link', required=True, default='none')
    # Categoria trebuie sa fie rezolvabila de aplicatie pe website-ul pe care apare
    # bannerul: fie o categorie fara website (valabila peste tot), fie una de pe exact
    # acelasi website. Un banner fara website apare pe toate website-urile, deci poate
    # tinti doar categorii fara website. Fara acest domeniu, /home ar putea emite un
    # category_id pe care catalogul (Faza 2) nu il gaseste.
    category_id = fields.Many2one(
        'product.public.category', string='Categorie',
        domain="['|', ('website_id', '=', False), ('website_id', '=', website_id)]")
    external_url = fields.Char(string='URL extern')
    sequence = fields.Integer(string='Ordine', default=10)
    active = fields.Boolean(default=True)
    date_start = fields.Date(string='Activ de la')
    date_end = fields.Date(string='Activ pana la')
    website_id = fields.Many2one('website', string='Website')

    @api.constrains('link_type', 'category_id', 'external_url')
    def _check_link_target(self):
        for banner in self:
            if banner.link_type == 'category' and not banner.category_id:
                raise ValidationError('Alege o categorie pentru un banner cu link de tip Categorie.')
            if banner.link_type == 'url' and not banner.external_url:
                raise ValidationError('Completeaza URL-ul pentru un banner cu link de tip URL extern.')

    @api.model
    def _search_active_now(self, website):
        """Bannerele vizibile ACUM pentru website-ul dat: activ (arhivarea e filtrata automat),
        in fereastra de date (limite inclusive, lipsa = fara limita), si fie fara website,
        fie pe website-ul cerut."""
        today = fields.Date.context_today(self)
        domain = [
            '|', ('date_start', '=', False), ('date_start', '<=', today),
            '|', ('date_end', '=', False), ('date_end', '>=', today),
            '|', ('website_id', '=', False), ('website_id', '=', website.id),
        ]
        return self.search(domain)
