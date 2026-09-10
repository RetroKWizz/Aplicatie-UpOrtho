import 'package:freezed_annotation/freezed_annotation.dart';

import 'checkout.dart';

export 'checkout.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// O factura a contului. `pdfUrl` e o ruta autentificata a modulului: se descarca
/// prin acelasi transport ca restul cererilor (cookie de sesiune + header de
/// aplicatie) si se deschide apoi cu vizualizatorul telefonului. Deschisa direct in
/// browserul telefonului ar da "Not Found", pentru ca acolo nu exista sesiunea.
@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required int id,
    required String name,
    String? date,
    @JsonKey(name: 'due_date') String? dueDate,
    required String state,
    @JsonKey(name: 'state_label') required String stateLabel,
    @JsonKey(name: 'payment_state') String? paymentState,
    @JsonKey(name: 'payment_state_label') String? paymentStateLabel,
    required Price total,
    required Price residual,
    @JsonKey(name: 'pdf_url') required String pdfUrl,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
}

/// O plata legata de comanda (tranzactie Odoo).
@freezed
abstract class OrderPayment with _$OrderPayment {
  const factory OrderPayment({
    required String reference,
    required String provider,
    required String state,
    required Price amount,
  }) = _OrderPayment;

  factory OrderPayment.fromJson(Map<String, dynamic> json) => _$OrderPaymentFromJson(json);
}

/// O comanda in lista de comenzi. `stateLabel` vine tradus de la server, ca
/// vocabularul sa se poata schimba fara release in store.
@freezed
abstract class OrderSummary with _$OrderSummary {
  const factory OrderSummary({
    required int id,
    required String name,
    String? date,
    required String state,
    @JsonKey(name: 'state_label') required String stateLabel,
    required Price total,
    @JsonKey(name: 'line_count') @Default(0) int lineCount,
    @JsonKey(name: 'delivery_method') String? deliveryMethod,
    @JsonKey(name: 'invoice_count') @Default(0) int invoiceCount,
  }) = _OrderSummary;

  factory OrderSummary.fromJson(Map<String, dynamic> json) => _$OrderSummaryFromJson(json);
}

@freezed
abstract class OrdersPage with _$OrdersPage {
  const factory OrdersPage({
    @Default([]) List<OrderSummary> orders,
    @Default(0) int total,
    @Default(0) int offset,
    @Default(20) int limit,
  }) = _OrdersPage;

  factory OrdersPage.fromJson(Map<String, dynamic> json) => _$OrdersPageFromJson(json);
}

@freezed
abstract class InvoicesPage with _$InvoicesPage {
  const factory InvoicesPage({
    @Default([]) List<Invoice> invoices,
    @Default(0) int total,
    @Default(0) int offset,
    @Default(20) int limit,
  }) = _InvoicesPage;

  factory InvoicesPage.fromJson(Map<String, dynamic> json) => _$InvoicesPageFromJson(json);
}

/// Detaliul unei comenzi: aceleasi campuri ca in lista, plus liniile, totalurile,
/// adresele, facturile emise si platile.
@freezed
abstract class OrderDetail with _$OrderDetail {
  const factory OrderDetail({
    required int id,
    required String name,
    String? date,
    required String state,
    @JsonKey(name: 'state_label') required String stateLabel,
    required Price total,
    @JsonKey(name: 'line_count') @Default(0) int lineCount,
    @JsonKey(name: 'delivery_method') String? deliveryMethod,
    @JsonKey(name: 'invoice_count') @Default(0) int invoiceCount,
    @Default([]) List<CartLine> lines,
    required CartAmounts amounts,
    @JsonKey(name: 'delivery_address') Address? deliveryAddress,
    @JsonKey(name: 'invoice_address') Address? invoiceAddress,
    @JsonKey(name: 'client_order_ref') String? clientOrderRef,
    @Default([]) List<Invoice> invoices,
    @Default([]) List<OrderPayment> payments,
  }) = _OrderDetail;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => _$OrderDetailFromJson(json);
}
