import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/product_detail.dart';

Map<String, dynamic> detailFixture() =>
    jsonDecode(File('test/contract/product_detail.json').readAsStringSync()) as Map<String, dynamic>;

List<dynamic> benefitsFixture() =>
    jsonDecode(File('test/contract/benefits.json').readAsStringSync()) as List<dynamic>;

/// Produsul "sarac": 354 din 619 produse reale n-au variante, 214 n-au praguri,
/// 14 n-au descriere. Decodarea nu are voie sa arunce pentru niciunul dintre ele.
Map<String, dynamic> bareDetailJson() => {
      'id': 7,
      'variant_id': null,
      'name': 'Arc NiTi termic .014',
      'default_code': null,
      'badge': null,
      'images': <dynamic>[],
      'price': {
        'amount': 25.0,
        'currency': 'RON',
        'formatted': '25,00 lei',
        'with_vat': true,
        'list_amount': null,
        'list_formatted': null,
        'discount_pct': null,
      },
      'club_price': null,
      'price_tables': <dynamic>[],
      'variants': null,
      'specs': <dynamic>[],
      'description': <dynamic>[],
      'availability': null,
      'rating': {'average': 0.0, 'count': 0},
      'reviews': <dynamic>[],
      'similar': <dynamic>[],
      'benefits': <dynamic>[],
    };

void main() {
  test('ProductDetail decodeaza product_detail.json in intregime', () {
    final detail = ProductDetail.fromJson(detailFixture());

    expect(detail.id, 101);
    expect(detail.variantId, 501);
    expect(detail.name, 'Cleste Tie Back mare (.016 - .021x.025) Ixion');
    expect(detail.defaultCode, 'IX954');
    expect(detail.badge?.text, 'Nou');
    expect(detail.badge?.color, ProductBadgeColor.blue);

    expect(detail.price.formatted, '1.120,00 lei');
    expect(detail.price.listFormatted, '1.399,99 lei');
    expect(detail.price.discountPct, 20);
    expect(detail.clubPrice?.formatted, '1.120,00 lei');

    expect(detail.rating.average, 0.0);
    expect(detail.rating.count, 0);
    expect(detail.availability?.message, 'Precomanda. Livrare incepand cu 1 August');
    expect(detail.availability?.inStock, isTrue);
  });

  test('imaginile: intrarea principala are id 0, cea de tip video poarta video_url', () {
    final images = ProductDetail.fromJson(detailFixture()).images;
    expect(images, hasLength(2));

    expect(images[0].id, 0);
    expect(images[0].url, '/api/app/v1/products/101/gallery/0?unique=3a1f9c2');
    expect(images[0].kind, ProductImageKind.image);
    expect(images[0].videoUrl, isNull);

    expect(images[1].kind, ProductImageKind.video);
    expect(images[1].videoUrl, 'https://www.youtube.com/watch?v=xxxx');
  });

  test('o intrare de galerie fara poza (doar video) are url null, nu arunca', () {
    final json = detailFixture();
    (json['images'] as List)[1]['url'] = null;
    final images = ProductDetail.fromJson(json).images;
    expect(images[1].url, isNull);
    expect(images[1].videoUrl, 'https://www.youtube.com/watch?v=xxxx');
  });

  test('tabelele de pret: titlul, nota si pragurile vin toate de la server', () {
    final detail = ProductDetail.fromJson(detailFixture());
    expect(detail.priceTables, hasLength(2));

    final first = detail.priceTables[0];
    expect(first.title, 'Pret pe cantitate');
    expect(first.note, isEmpty);
    expect(first.entries, hasLength(2));
    expect(first.entries[0].minQty, 1);
    expect(first.entries[0].label, '1+');
    expect(first.entries[0].price.formatted, '1.399,99 lei');
    expect(first.entries[1].minQty, 3);
    expect(first.entries[1].label, '3+');
    expect(first.entries[1].price.formatted, '1.120,00 lei');

    // Al doilea titlu e un nume de campanie: aplicatia nu are cum sa-l stie, il
    // trimite serverul. De aceea tabelele sunt o lista, nu doua campuri fixe.
    final second = detail.priceTables[1];
    expect(second.title, 'Campanie Toamna 2026');
    expect(second.note.single.type, DescriptionBlockType.paragraph);
    expect(second.note.single.spans.single.text, 'Pret valabil pentru membrii Ortho Club.');
    expect(second.entries.single.price.formatted, '1.050,00 lei');
  });

  test('un tabel fara titlu si fara nota decodeaza fara eroare', () {
    final json = detailFixture();
    json['price_tables'] = [
      {
        'title': null,
        'entries': [
          {
            'min_qty': 1,
            'label': '1+',
            'price': (bareDetailJson()['price'] as Map<String, dynamic>),
          },
        ],
      },
    ];
    final table = ProductDetail.fromJson(json).priceTables.single;
    expect(table.title, isNull);
    expect(table.note, isEmpty);
    expect(table.entries.single.label, '1+');
  });

  test('variantele: un atribut cu doua valori, una selectata, ambele disponibile', () {
    final variants = ProductDetail.fromJson(detailFixture()).variants;
    expect(variants, isNotNull);
    expect(variants!.attributes, hasLength(1));

    final attribute = variants.attributes.single;
    expect(attribute.id, 7);
    expect(attribute.name, 'Marime');
    expect(attribute.values, hasLength(2));
    expect(attribute.values[0].id, 1357);
    expect(attribute.values[0].name, 'Mare');
    expect(attribute.values[0].selected, isTrue);
    expect(attribute.values[0].available, isTrue);
    expect(attribute.values[1].selected, isFalse);

    // Combinatia de trimis inapoi la apasare vine de la server, pe fiecare valoare,
    // plus combinatia activa acum - aplicatia nu compune niciun id singura.
    expect(variants.selected, [1357]);
    expect(attribute.values[0].combination, [1357]);
    expect(attribute.values[1].combination, [1358]);
  });

  test('o valoare fara `combination` in raspuns decodeaza cu lista goala', () {
    // Camp adaugat dupa Faza 2: un server mai vechi nu-l trimite, iar ecranul nu are
    // voie sa crape pe el.
    final value = VariantValue.fromJson(const {'id': 9, 'name': 'Mare'});
    expect(value.combination, isEmpty);
  });

  test('descrierea: heading/paragraph/bullets, cu bold si italic pe span', () {
    final blocks = ProductDetail.fromJson(detailFixture()).description;
    expect(blocks, hasLength(3));

    expect(blocks[0].type, DescriptionBlockType.heading);
    expect(blocks[0].spans.single.text, 'Cleste Tie Back pentru arcuri groase');
    expect(blocks[0].spans.single.bold, isTrue);
    expect(blocks[0].spans.single.italic, isFalse);

    expect(blocks[1].type, DescriptionBlockType.paragraph);
    expect(blocks[1].spans.single.bold, isFalse);

    expect(blocks[2].type, DescriptionBlockType.bullets);
    expect(blocks[2].spans, isEmpty);
    expect(blocks[2].items, hasLength(1));
    expect(blocks[2].items.single.spans.single.text, 'Falci zimtate care asigura o prindere ferma.');
  });

  test('un tip de bloc necunoscut cade pe paragraph, nu arunca', () {
    final json = detailFixture();
    (json['description'] as List)[0]['type'] = 'table';
    final blocks = ProductDetail.fromJson(json).description;
    expect(blocks[0].type, DescriptionBlockType.paragraph);
  });

  test('brandul: nume, descriere in blocuri si URL de logo', () {
    final brand = ProductDetail.fromJson(detailFixture()).brand;
    expect(brand, isNotNull);
    expect(brand!.name, 'DB Orthodontics');
    expect(brand.logoUrl, '/api/app/v1/products/101/brand/logo?unique=7e2b4c1');
    expect(brand.description.single.type, DescriptionBlockType.paragraph);
    expect(brand.description.single.spans.single.text,
        'Producator britanic de produse ortodontice.');
  });

  test('un produs fara brand decodeaza cu brand null', () {
    final json = detailFixture()..['brand'] = null;
    expect(ProductDetail.fromJson(json).brand, isNull);

    // Server mai vechi, care nici nu trimite campul.
    expect(ProductDetail.fromJson(detailFixture()..remove('brand')).brand, isNull);
  });

  test('un brand fara logo si fara descriere decodeaza fara eroare', () {
    final json = detailFixture()
      ..['brand'] = {'name': 'Ixion', 'description': <dynamic>[], 'logo_url': null};
    final brand = ProductDetail.fromJson(json).brand!;
    expect(brand.name, 'Ixion');
    expect(brand.logoUrl, isNull);
    expect(brand.description, isEmpty);
  });

  test('documentele: nume, nume de fisier si URL-ul standard Odoo al fisierului', () {
    final document = ProductDetail.fromJson(detailFixture()).documents.single;
    expect(document.id, 4821);
    expect(document.name, 'Fisa tehnica.pdf');
    expect(document.fileName, 'Fisa tehnica.pdf');
    // Ruta Odoo, nu una a modulului: documentul se deschide in afara aplicatiei.
    expect(document.url, '/web/content/4821?download=true');
  });

  test('un raspuns fara `documents` decodeaza cu lista goala', () {
    // Camp adaugat dupa prima versiune a paginii de produs: un server mai vechi nu-l
    // trimite, iar ecranul nu are voie sa crape pe el.
    final json = detailFixture()..remove('documents');
    expect(ProductDetail.fromJson(json).documents, isEmpty);
  });

  test('specificatiile sunt perechi nume/valoare', () {
    final specs = ProductDetail.fromJson(detailFixture()).specs;
    expect(specs.single.name, 'Brand');
    expect(specs.single.value, 'DB Orthodontics');
  });

  test('recenziile decodeaza, iar autorul poate lipsi', () {
    final json = detailFixture();
    final review = ProductDetail.fromJson(json).reviews.single;
    expect(review.author, 'Ana P.');
    expect(review.rating, 5);
    expect(review.date, '2026-02-14');
    expect(review.text, 'Foarte bun.');

    (json['reviews'] as List)[0]['author'] = null;
    (json['reviews'] as List)[0]['date'] = null;
    final anonymous = ProductDetail.fromJson(json).reviews.single;
    expect(anonymous.author, isNull);
    expect(anonymous.date, isNull);
  });

  test('produsele similare au exact forma unui produs din /products', () {
    final similar = ProductDetail.fromJson(detailFixture()).similar.single;
    expect(similar.id, 102);
    expect(similar.name, 'Cleste Tie Back mic Ixion');
    expect(similar.defaultCode, isNull);
    expect(similar.imageUrl, isNull);
    expect(similar.price.formatted, '25,00 lei');
    expect(similar.clubPrice, isNull);
    expect(similar.badge, isNull);
  });

  test('beneficiile decodeaza, inclusiv iconita "return" (cuvant rezervat in Dart)', () {
    final benefits = ProductDetail.fromJson(detailFixture()).benefits;
    expect(benefits, hasLength(4));
    expect(benefits[0].icon, BenefitIcon.club);
    expect(benefits[0].title, 'Alatura-te Ortho Club');
    expect(benefits[0].text, 'pentru extra beneficii');
    expect(benefits[1].icon, BenefitIcon.delivery);
    expect(benefits[2].icon, BenefitIcon.returns);
    expect(benefits[3].icon, BenefitIcon.payment);
  });

  test('Benefit decodeaza si benefits.json (array la nivelul radacinii)', () {
    final benefits = benefitsFixture().map((e) => Benefit.fromJson(e as Map<String, dynamic>)).toList();
    expect(benefits, hasLength(4));
    expect(benefits.last.title, 'Plata online sigura');
  });

  test('iconita de beneficiu necunoscuta cade pe info, iar textul poate lipsi', () {
    final benefit = Benefit.fromJson({'icon': 'unicorn', 'title': 'Ceva nou', 'text': null});
    expect(benefit.icon, BenefitIcon.info);
    expect(benefit.text, isNull);
  });

  test('produs fara variante, praguri, descriere sau disponibilitate decodeaza fara eroare', () {
    final detail = ProductDetail.fromJson(bareDetailJson());
    expect(detail.variantId, isNull);
    expect(detail.defaultCode, isNull);
    expect(detail.badge, isNull);
    expect(detail.images, isEmpty);
    expect(detail.clubPrice, isNull);
    expect(detail.priceTables, isEmpty);
    expect(detail.variants, isNull);
    expect(detail.specs, isEmpty);
    expect(detail.description, isEmpty);
    expect(detail.availability, isNull);
    expect(detail.reviews, isEmpty);
    expect(detail.similar, isEmpty);
    expect(detail.benefits, isEmpty);
  });

  test('availability poate avea mesaj null, dar sa fie prezenta', () {
    final json = detailFixture();
    json['availability'] = {'message': null, 'in_stock': false};
    final availability = ProductDetail.fromJson(json).availability;
    expect(availability, isNotNull);
    expect(availability!.message, isNull);
    expect(availability.inStock, isFalse);
  });

  test('fara tabele de pret, lista e goala, niciodata null', () {
    final json = detailFixture();
    json['club_price'] = null;
    json['price_tables'] = <dynamic>[];
    final detail = ProductDetail.fromJson(json);
    expect(detail.clubPrice, isNull);
    expect(detail.priceTables, isEmpty);
  });
}
