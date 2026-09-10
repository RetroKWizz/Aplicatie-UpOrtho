// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  date: json['date'] as String?,
  dueDate: json['due_date'] as String?,
  state: json['state'] as String,
  stateLabel: json['state_label'] as String,
  paymentState: json['payment_state'] as String?,
  paymentStateLabel: json['payment_state_label'] as String?,
  total: Price.fromJson(json['total'] as Map<String, dynamic>),
  residual: Price.fromJson(json['residual'] as Map<String, dynamic>),
  pdfUrl: json['pdf_url'] as String,
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'date': instance.date,
  'due_date': instance.dueDate,
  'state': instance.state,
  'state_label': instance.stateLabel,
  'payment_state': instance.paymentState,
  'payment_state_label': instance.paymentStateLabel,
  'total': instance.total,
  'residual': instance.residual,
  'pdf_url': instance.pdfUrl,
};

_OrderPayment _$OrderPaymentFromJson(Map<String, dynamic> json) =>
    _OrderPayment(
      reference: json['reference'] as String,
      provider: json['provider'] as String,
      state: json['state'] as String,
      amount: Price.fromJson(json['amount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderPaymentToJson(_OrderPayment instance) =>
    <String, dynamic>{
      'reference': instance.reference,
      'provider': instance.provider,
      'state': instance.state,
      'amount': instance.amount,
    };

_OrderSummary _$OrderSummaryFromJson(Map<String, dynamic> json) =>
    _OrderSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      date: json['date'] as String?,
      state: json['state'] as String,
      stateLabel: json['state_label'] as String,
      total: Price.fromJson(json['total'] as Map<String, dynamic>),
      lineCount: (json['line_count'] as num?)?.toInt() ?? 0,
      deliveryMethod: json['delivery_method'] as String?,
      invoiceCount: (json['invoice_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrderSummaryToJson(_OrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date,
      'state': instance.state,
      'state_label': instance.stateLabel,
      'total': instance.total,
      'line_count': instance.lineCount,
      'delivery_method': instance.deliveryMethod,
      'invoice_count': instance.invoiceCount,
    };

_OrdersPage _$OrdersPageFromJson(Map<String, dynamic> json) => _OrdersPage(
  orders:
      (json['orders'] as List<dynamic>?)
          ?.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toInt() ?? 0,
  offset: (json['offset'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$OrdersPageToJson(_OrdersPage instance) =>
    <String, dynamic>{
      'orders': instance.orders,
      'total': instance.total,
      'offset': instance.offset,
      'limit': instance.limit,
    };

_InvoicesPage _$InvoicesPageFromJson(Map<String, dynamic> json) =>
    _InvoicesPage(
      invoices:
          (json['invoices'] as List<dynamic>?)
              ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$InvoicesPageToJson(_InvoicesPage instance) =>
    <String, dynamic>{
      'invoices': instance.invoices,
      'total': instance.total,
      'offset': instance.offset,
      'limit': instance.limit,
    };

_OrderDetail _$OrderDetailFromJson(Map<String, dynamic> json) => _OrderDetail(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  date: json['date'] as String?,
  state: json['state'] as String,
  stateLabel: json['state_label'] as String,
  total: Price.fromJson(json['total'] as Map<String, dynamic>),
  lineCount: (json['line_count'] as num?)?.toInt() ?? 0,
  deliveryMethod: json['delivery_method'] as String?,
  invoiceCount: (json['invoice_count'] as num?)?.toInt() ?? 0,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  amounts: CartAmounts.fromJson(json['amounts'] as Map<String, dynamic>),
  deliveryAddress: json['delivery_address'] == null
      ? null
      : Address.fromJson(json['delivery_address'] as Map<String, dynamic>),
  invoiceAddress: json['invoice_address'] == null
      ? null
      : Address.fromJson(json['invoice_address'] as Map<String, dynamic>),
  clientOrderRef: json['client_order_ref'] as String?,
  invoices:
      (json['invoices'] as List<dynamic>?)
          ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => OrderPayment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderDetailToJson(_OrderDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date,
      'state': instance.state,
      'state_label': instance.stateLabel,
      'total': instance.total,
      'line_count': instance.lineCount,
      'delivery_method': instance.deliveryMethod,
      'invoice_count': instance.invoiceCount,
      'lines': instance.lines,
      'amounts': instance.amounts,
      'delivery_address': instance.deliveryAddress,
      'invoice_address': instance.invoiceAddress,
      'client_order_ref': instance.clientOrderRef,
      'invoices': instance.invoices,
      'payments': instance.payments,
    };
