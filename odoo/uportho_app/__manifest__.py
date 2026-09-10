{
    'name': 'UpOrtho App API',
    'version': '18.0.1.0.0',
    'summary': 'API JSON /api/app/v1 pentru aplicatia mobila UpOrtho (iOS + Android)',
    'category': 'Website/eCommerce',
    'license': 'LGPL-3',
    'depends': ['website_sale', 'sale', 'product', 'portal', 'delivery', 'payment_custom'],
    'data': [
        'security/ir.model.access.csv',
        'views/app_banner_views.xml',
        'views/app_benefit_views.xml',
        'views/product_public_category_views.xml',
        'views/product_template_views.xml',
        'views/menus.xml',
    ],
    'installable': True,
    'application': False,
}
