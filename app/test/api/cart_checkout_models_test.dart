import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/account.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/contract/$name').readAsStringSync()) as Map<String, dynamic>;

List<dynamic> listFixture(String name) =>
    jsonDecode(File('test/contract/$name').readAsStringSync()) as List<dynamic>;

void main() {
  test('Cart decodeaza cart.json', () {
    final cart = Cart.fromJson(fixture('cart.json'));

    expect(cart.orderId, 5001);
    expect(cart.quantity, 11);
    expect(cart.lines.single.variantId, 41868);
    expect(cart.lines.single.variantName, 'Dinte: 11');
    expect(cart.lines.single.quantity, 4);
    // Subtotalul vine gata calculat: 4 x 70,00 la pragul aplicat de server.
    expect(cart.lines.single.subtotal.formatted, '280,00 lei');
    expect(cart.amounts.total.formatted, '280,00 lei');
    expect(cart.freeDelivery!.remaining.formatted, '220,00 lei');
    expect(cart.freeDelivery!.reached, isFalse);
  });

  test('un cos gol decodeaza fara linii si fara progres de livrare', () {
    final json = fixture('cart.json');
    final cart = Cart.fromJson({
      ...json,
      'order_id': null,
      'quantity': 0,
      'lines': <dynamic>[],
      'free_delivery': null,
    });

    expect(cart.orderId, isNull);
    expect(cart.isEmpty, isTrue);
    expect(cart.freeDelivery, isNull);
    // `warnings` lipseste din raspunsul lui GET /cart: nu are voie sa fie null.
    expect(cart.warnings, isEmpty);
  });

  test('Checkout decodeaza checkout.json', () {
    final checkout = Checkout.fromJson(fixture('checkout.json'));

    expect(checkout.orderId, 5001);
    expect(checkout.addresses.deliveryId, 7001);
    expect(checkout.addresses.available.single.city, 'Cluj-Napoca');
    expect(checkout.deliveryMethods.length, 2);
    expect(checkout.deliveryMethods.first.price.formatted, '24,99 lei');
    expect(checkout.deliveryMethods.last.free, isTrue);
    expect(checkout.selectedDeliveryMethodId, 3);
    expect(checkout.blockers, isEmpty);
    expect(checkout.canConfirm, isTrue);
  });

  test('metoda offline se distinge de cea care cere WebView', () {
    final checkout = Checkout.fromJson(fixture('checkout.json'));
    final offline = checkout.paymentOptions.firstWhere((o) => o.isOffline);
    final card = checkout.paymentOptions.firstWhere((o) => !o.isOffline);

    expect(offline.code, 'custom');
    // Instructiunile vin ca blocuri, nu ca HTML - aplicatia nu are motor HTML.
    expect(offline.instructions.single.spans.single.text, contains('RO00'));
    expect(card.kind, 'webview');
    expect(card.instructions, isEmpty);
  });

  test('un blocaj de checkout tine butonul de trimitere inchis', () {
    final json = fixture('checkout.json');
    final checkout = Checkout.fromJson({
      ...json,
      'blockers': [
        {'code': 'no_carrier_selected', 'message': 'Alege metoda de livrare.'}
      ],
    });

    expect(checkout.canConfirm, isFalse);
    expect(checkout.blockers.single.code, 'no_carrier_selected');
  });

  test('confirmarea offline aduce instructiunile si referinta', () {
    final confirmation = CheckoutConfirmation.fromJson(fixture('checkout_confirm_offline.json'));

    expect(confirmation.orderRef, 'S12345');
    expect(confirmation.payment.isOffline, isTrue);
    expect(confirmation.payment.reference, 'S12345-1');
    expect(confirmation.payment.instructions, isNotEmpty);
  });

  test('confirmarea cu card aduce adresa paginii de plata si prefixul de intoarcere', () {
    final confirmation = CheckoutConfirmation.fromJson(fixture('checkout_confirm_webview.json'));

    expect(confirmation.payment.isOffline, isFalse);
    expect(confirmation.payment.url, '/shop/payment');
    expect(confirmation.payment.returnUrlPrefix, '/shop/confirmation');
  });

  test('OrdersPage si OrderDetail decodeaza fixture-urile de comenzi', () {
    final page = OrdersPage.fromJson(fixture('orders.json'));
    expect(page.orders.single.name, 'S12345');
    expect(page.orders.single.stateLabel, 'Confirmata');
    expect(page.orders.single.total.formatted, '304,99 lei');

    final detail = OrderDetail.fromJson(fixture('order.json'));
    expect(detail.lines, isNotEmpty);
    expect(detail.amounts.total.formatted, isNotEmpty);
    expect(detail.invoices.single.pdfUrl, '/api/app/v1/invoices/8001/pdf');
    expect(detail.payments.single.provider, 'Transfer bancar/OP');
    expect(detail.deliveryAddress!.name, 'Cabinet Dentar Exemplu SRL');
  });

  test('InvoicesPage si adresele decodeaza fixture-urile lor', () {
    final invoices = InvoicesPage.fromJson(fixture('invoices.json'));
    expect(invoices.invoices.single.name, 'FACT/2026/0042');
    expect(invoices.invoices.single.paymentStateLabel, 'Neplatita');
    expect(invoices.invoices.single.residual.formatted, '333,20 lei');

    final addresses = [
      for (final item in listFixture('addresses.json'))
        Address.fromJson(item as Map<String, dynamic>)
    ];
    expect(addresses.single.oneLine, contains('Cluj-Napoca'));
  });

  test('adresa fara strada nu produce virgule goale pe randul de afisare', () {
    final address = Address.fromJson({
      ...listFixture('addresses.json').first as Map<String, dynamic>,
      'street': null,
      'street2': null,
      'zip': null,
    });

    expect(address.oneLine, 'Cluj-Napoca, Cluj');
  });
}
