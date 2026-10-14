from odoo import api, fields, models
from odoo.exceptions import ValidationError


class AppSection(models.Model):
    """Un rand de produse de pe Acasa, in aplicatie.

    Pana acum Acasa n-avea niciun produs: bannere, categorii, si atat. Sectiunea e
    locul in care se spune, din Odoo, ce produse se vad acolo si sub ce titlu, fara
    release in store.

    Produsele NU se aleg aici intr-un al doilea fel decat le alege catalogul: ce intra
    in rand trece prin acelasi domeniu ca `/products` (publicat, pe website-ul potrivit)
    si prin aceeasi ordine a magazinului. Un produs depublicat dispare din rand fara sa
    stearga nimeni nimic."""

    _name = 'uportho.app.section'
    _description = 'Sectiune pe Acasa (aplicatie mobila UpOrtho)'
    _order = 'sequence, id'

    name = fields.Char(string='Titlu', required=True, help='Titlul randului, asa cum il vede clientul.')
    source = fields.Selection(
        [
            ('category', 'Produsele unei categorii'),
            ('manual', 'Produse alese de mana'),
            ('offers', 'Produsele cu eticheta de oferta'),
        ],
        string='Ce produse', required=True, default='category')
    category_id = fields.Many2one(
        'product.public.category', string='Categorie',
        domain="['|', ('website_id', '=', False), ('website_id', '=', website_id)]")
    product_ids = fields.Many2many('product.template', string='Produse')
    limit = fields.Integer(
        string='Cate produse', default=8,
        help='Cate produse se arata in rand. Randul se trage lateral, deci nu trebuie '
             'sa incapa toate pe ecran deodata.')
    sequence = fields.Integer(string='Ordine', default=10)
    active = fields.Boolean(default=True)
    date_start = fields.Date(string='Activa de la')
    date_end = fields.Date(string='Activa pana la')
    website_id = fields.Many2one('website', string='Website')

    @api.constrains('source', 'category_id', 'product_ids')
    def _check_source(self):
        for section in self:
            if section.source == 'category' and not section.category_id:
                raise ValidationError('Alege o categorie pentru o sectiune cu produsele unei categorii.')
            if section.source == 'manual' and not section.product_ids:
                raise ValidationError('Alege cel putin un produs pentru o sectiune cu produse de mana.')

    @api.constrains('limit')
    def _check_limit(self):
        for section in self:
            if section.limit <= 0:
                raise ValidationError('Numarul de produse trebuie sa fie cel putin 1.')

    @api.model
    def _search_active_now(self, website):
        """Sectiunile vizibile ACUM pentru website-ul dat. Aceeasi regula ca la bannere:
        activa, in fereastra de date (limite inclusive, lipsa = fara limita), si fie
        fara website, fie pe website-ul cerut."""
        today = fields.Date.context_today(self)
        return self.search([
            '|', ('date_start', '=', False), ('date_start', '<=', today),
            '|', ('date_end', '=', False), ('date_end', '>=', today),
            '|', ('website_id', '=', False), ('website_id', '=', website.id),
        ])

    def _extra_domain(self):
        """Ce adauga sectiunea peste domeniul catalogului, sau `None` cand sectiunea nu
        poate produce nimic.

        `offers` se sprijina pe eticheta magazinului (`dr_label_id` din
        `droggol_theme_common`): pe o baza fara tema campul nu exista, iar o cautare pe
        un camp inexistent ar fi o eroare - sectiunea ramane atunci goala si nu se
        deseneaza, nu se inventeaza alt inteles pentru "oferta"."""
        self.ensure_one()
        if self.source == 'category':
            return [('public_categ_ids', 'child_of', self.category_id.id)]
        if self.source == 'manual':
            return [('id', 'in', self.product_ids.ids)]
        if 'dr_label_id' not in self.env['product.template']._fields:
            return None
        return [('dr_label_id', '!=', False)]
