from odoo import fields, models


class AppDevice(models.Model):
    _name = 'uportho.app.device'
    _description = 'Dispozitiv (token FCM) al unui utilizator al aplicatiei'

    user_id = fields.Many2one('res.users', required=True, ondelete='cascade', index=True)
    fcm_token = fields.Char(required=True, index=True)
    platform = fields.Selection([('ios', 'iOS'), ('android', 'Android')], required=True)
    last_seen = fields.Datetime(default=fields.Datetime.now)

    _sql_constraints = [
        ('fcm_token_unique', 'unique(fcm_token)', 'Token-ul FCM trebuie sa fie unic.'),
    ]

    def _register_device(self, user, fcm_token, platform):
        """Creeaza sau actualizeaza inregistrarea pentru token; un token apartine
        intotdeauna ultimului utilizator logat pe acel dispozitiv.

        Nota: brief-ul numeste acest helper `_register`, dar acel nume este un
        atribut rezervat pe odoo.models.BaseModel (flag intern folosit de
        metaclasa ORM la inregistrarea modelelor, vezi BaseModel._register).
        Apelul `recordset._register(...)` rezolva la boolean-ul respectiv, nu la
        metoda noastra, si arunca `TypeError: 'bool' object is not callable`.
        Redenumit in `_register_device` pentru a evita coliziunea.
        """
        device = self.sudo().search([('fcm_token', '=', fcm_token)], limit=1)
        values = {'user_id': user.id, 'platform': platform, 'last_seen': fields.Datetime.now()}
        if device:
            device.write(values)
            return device
        return self.sudo().create(dict(values, fcm_token=fcm_token))
