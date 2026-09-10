from odoo import models
from odoo.http import request


class Website(models.Model):
    _inherit = 'website'

    def is_public_user(self):
        """Raspunde intrebarea "e utilizatorul curent vizitatorul anonim?" folosind
        website-ul pe care e chemata metoda, cand cererea nu are unul.

        Implementarea standard din `website` compara mereu cu `request.website`:

            return request.env.user.id == request.website._get_cached('user_id')

        Rutele acestui modul sunt `type='http'` simple, deci nu primesc `request.website`
        (vezi gotcha 7 din CLAUDE.md pentru ce s-ar strica daca l-ar primi: cu el pus,
        `website_sale` filtreaza lista de preturi a clientului prin
        `_is_available_on_website`, iar pe uportho **niciuna** din listele active nu
        trece filtrul - preturile clientilor s-ar schimba). Fara el, apelul crapa cu
        `AttributeError: 'Request' object has no attribute 'website'` - si crapa pe un
        drum de care avem nevoie: `website.sale_get_order()`, adica **crearea cosului**,
        il cheama prin `_prepare_sale_order_values`.

        Metoda e chemata pe un recordset de website (`self`), care in cazul nostru e
        chiar magazinul rezolvat de modul. Deci raspunsul se poate da din `self`, fara
        `request.website`. Cand cererea ARE website (paginile site-ului), nu se schimba
        nimic: se cheama implementarea standard.

        Efectul concret: pentru utilizatorii aplicatiei raspunsul e mereu False -
        rutele sunt `auth='user'`, deci nu exista cerere de la vizitatorul anonim - iar
        `_prepare_sale_order_values` nu mai forteaza pozitia fiscala a website-ului
        peste cea a clientului."""
        if request and not hasattr(request, 'website') and self:
            return request.env.user.id == self.sudo()._get_cached('user_id')
        return super().is_public_user()
