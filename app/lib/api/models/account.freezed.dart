// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {

 int get id; String get name; String? get date;@JsonKey(name: 'due_date') String? get dueDate; String get state;@JsonKey(name: 'state_label') String get stateLabel;@JsonKey(name: 'payment_state') String? get paymentState;@JsonKey(name: 'payment_state_label') String? get paymentStateLabel; Price get total; Price get residual;@JsonKey(name: 'pdf_url') String get pdfUrl;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invoice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.stateLabel, _this.stateLabel) || other.stateLabel == _this.stateLabel)&&(identical(other.paymentState, _this.paymentState) || other.paymentState == _this.paymentState)&&(identical(other.paymentStateLabel, _this.paymentStateLabel) || other.paymentStateLabel == _this.paymentStateLabel)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.residual, _this.residual) || other.residual == _this.residual)&&(identical(other.pdfUrl, _this.pdfUrl) || other.pdfUrl == _this.pdfUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invoice;
  return Object.hash(runtimeType,_this.id,_this.name,_this.date,_this.dueDate,_this.state,_this.stateLabel,_this.paymentState,_this.paymentStateLabel,_this.total,_this.residual,_this.pdfUrl);
}

@override
String toString() {
  final _this = this as Invoice;
  return 'Invoice(id: ${_this.id}, name: ${_this.name}, date: ${_this.date}, dueDate: ${_this.dueDate}, state: ${_this.state}, stateLabel: ${_this.stateLabel}, paymentState: ${_this.paymentState}, paymentStateLabel: ${_this.paymentStateLabel}, total: ${_this.total}, residual: ${_this.residual}, pdfUrl: ${_this.pdfUrl})';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? date,@JsonKey(name: 'due_date') String? dueDate, String state,@JsonKey(name: 'state_label') String stateLabel,@JsonKey(name: 'payment_state') String? paymentState,@JsonKey(name: 'payment_state_label') String? paymentStateLabel, Price total, Price residual,@JsonKey(name: 'pdf_url') String pdfUrl
});


$PriceCopyWith<$Res> get total;$PriceCopyWith<$Res> get residual;

}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? date = freezed,Object? dueDate = freezed,Object? state = null,Object? stateLabel = null,Object? paymentState = freezed,Object? paymentStateLabel = freezed,Object? total = null,Object? residual = null,Object? pdfUrl = null,}) {
  return _then(Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateLabel: null == stateLabel ? _self.stateLabel : stateLabel // ignore: cast_nullable_to_non_nullable
as String,paymentState: freezed == paymentState ? _self.paymentState : paymentState // ignore: cast_nullable_to_non_nullable
as String?,paymentStateLabel: freezed == paymentStateLabel ? _self.paymentStateLabel : paymentStateLabel // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,residual: null == residual ? _self.residual : residual // ignore: cast_nullable_to_non_nullable
as Price,pdfUrl: null == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get residual {
  
  return $PriceCopyWith<$Res>(_self.residual, (value) {
    return _then(_self.copyWith(residual: value));
  });
}
}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? date, @JsonKey(name: 'due_date')  String? dueDate,  String state, @JsonKey(name: 'state_label')  String stateLabel, @JsonKey(name: 'payment_state')  String? paymentState, @JsonKey(name: 'payment_state_label')  String? paymentStateLabel,  Price total,  Price residual, @JsonKey(name: 'pdf_url')  String pdfUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.dueDate,_that.state,_that.stateLabel,_that.paymentState,_that.paymentStateLabel,_that.total,_that.residual,_that.pdfUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? date, @JsonKey(name: 'due_date')  String? dueDate,  String state, @JsonKey(name: 'state_label')  String stateLabel, @JsonKey(name: 'payment_state')  String? paymentState, @JsonKey(name: 'payment_state_label')  String? paymentStateLabel,  Price total,  Price residual, @JsonKey(name: 'pdf_url')  String pdfUrl)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.name,_that.date,_that.dueDate,_that.state,_that.stateLabel,_that.paymentState,_that.paymentStateLabel,_that.total,_that.residual,_that.pdfUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? date, @JsonKey(name: 'due_date')  String? dueDate,  String state, @JsonKey(name: 'state_label')  String stateLabel, @JsonKey(name: 'payment_state')  String? paymentState, @JsonKey(name: 'payment_state_label')  String? paymentStateLabel,  Price total,  Price residual, @JsonKey(name: 'pdf_url')  String pdfUrl)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.dueDate,_that.state,_that.stateLabel,_that.paymentState,_that.paymentStateLabel,_that.total,_that.residual,_that.pdfUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({required this.id, required this.name, this.date, @JsonKey(name: 'due_date') this.dueDate, required this.state, @JsonKey(name: 'state_label') required this.stateLabel, @JsonKey(name: 'payment_state') this.paymentState, @JsonKey(name: 'payment_state_label') this.paymentStateLabel, required this.total, required this.residual, @JsonKey(name: 'pdf_url') required this.pdfUrl});
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? date;
@override@JsonKey(name: 'due_date') final  String? dueDate;
@override final  String state;
@override@JsonKey(name: 'state_label') final  String stateLabel;
@override@JsonKey(name: 'payment_state') final  String? paymentState;
@override@JsonKey(name: 'payment_state_label') final  String? paymentStateLabel;
@override final  Price total;
@override final  Price residual;
@override@JsonKey(name: 'pdf_url') final  String pdfUrl;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.state, state) || other.state == state)&&(identical(other.stateLabel, stateLabel) || other.stateLabel == stateLabel)&&(identical(other.paymentState, paymentState) || other.paymentState == paymentState)&&(identical(other.paymentStateLabel, paymentStateLabel) || other.paymentStateLabel == paymentStateLabel)&&(identical(other.total, total) || other.total == total)&&(identical(other.residual, residual) || other.residual == residual)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,date,dueDate,state,stateLabel,paymentState,paymentStateLabel,total,residual,pdfUrl);
}

@override
String toString() {
    return 'Invoice(id: $id, name: $name, date: $date, dueDate: $dueDate, state: $state, stateLabel: $stateLabel, paymentState: $paymentState, paymentStateLabel: $paymentStateLabel, total: $total, residual: $residual, pdfUrl: $pdfUrl)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? date,@JsonKey(name: 'due_date') String? dueDate, String state,@JsonKey(name: 'state_label') String stateLabel,@JsonKey(name: 'payment_state') String? paymentState,@JsonKey(name: 'payment_state_label') String? paymentStateLabel, Price total, Price residual,@JsonKey(name: 'pdf_url') String pdfUrl
});


@override $PriceCopyWith<$Res> get total;@override $PriceCopyWith<$Res> get residual;

}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? date = freezed,Object? dueDate = freezed,Object? state = null,Object? stateLabel = null,Object? paymentState = freezed,Object? paymentStateLabel = freezed,Object? total = null,Object? residual = null,Object? pdfUrl = null,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateLabel: null == stateLabel ? _self.stateLabel : stateLabel // ignore: cast_nullable_to_non_nullable
as String,paymentState: freezed == paymentState ? _self.paymentState : paymentState // ignore: cast_nullable_to_non_nullable
as String?,paymentStateLabel: freezed == paymentStateLabel ? _self.paymentStateLabel : paymentStateLabel // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,residual: null == residual ? _self.residual : residual // ignore: cast_nullable_to_non_nullable
as Price,pdfUrl: null == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get residual {
  
  return $PriceCopyWith<$Res>(_self.residual, (value) {
    return _then(_self.copyWith(residual: value));
  });
}
}


/// @nodoc
mixin _$OrderPayment {

 String get reference; String get provider; String get state; Price get amount;
/// Create a copy of OrderPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderPaymentCopyWith<OrderPayment> get copyWith => _$OrderPaymentCopyWithImpl<OrderPayment>(this as OrderPayment, _$identity);

  /// Serializes this OrderPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderPayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderPayment&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderPayment;
  return Object.hash(runtimeType,_this.reference,_this.provider,_this.state,_this.amount);
}

@override
String toString() {
  final _this = this as OrderPayment;
  return 'OrderPayment(reference: ${_this.reference}, provider: ${_this.provider}, state: ${_this.state}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $OrderPaymentCopyWith<$Res>  {
  factory $OrderPaymentCopyWith(OrderPayment value, $Res Function(OrderPayment) _then) = _$OrderPaymentCopyWithImpl;
@useResult
$Res call({
 String reference, String provider, String state, Price amount
});


$PriceCopyWith<$Res> get amount;

}
/// @nodoc
class _$OrderPaymentCopyWithImpl<$Res>
    implements $OrderPaymentCopyWith<$Res> {
  _$OrderPaymentCopyWithImpl(this._self, this._then);

  final OrderPayment _self;
  final $Res Function(OrderPayment) _then;

/// Create a copy of OrderPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reference = null,Object? provider = null,Object? state = null,Object? amount = null,}) {
  return _then(OrderPayment(
reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}
/// Create a copy of OrderPayment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get amount {
  
  return $PriceCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderPayment].
extension OrderPaymentPatterns on OrderPayment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderPayment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderPayment value)  $default,){
final _that = this;
switch (_that) {
case _OrderPayment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderPayment value)?  $default,){
final _that = this;
switch (_that) {
case _OrderPayment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reference,  String provider,  String state,  Price amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderPayment() when $default != null:
return $default(_that.reference,_that.provider,_that.state,_that.amount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reference,  String provider,  String state,  Price amount)  $default,) {final _that = this;
switch (_that) {
case _OrderPayment():
return $default(_that.reference,_that.provider,_that.state,_that.amount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reference,  String provider,  String state,  Price amount)?  $default,) {final _that = this;
switch (_that) {
case _OrderPayment() when $default != null:
return $default(_that.reference,_that.provider,_that.state,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderPayment implements OrderPayment {
  const _OrderPayment({required this.reference, required this.provider, required this.state, required this.amount});
  factory _OrderPayment.fromJson(Map<String, dynamic> json) => _$OrderPaymentFromJson(json);

@override final  String reference;
@override final  String provider;
@override final  String state;
@override final  Price amount;

/// Create a copy of OrderPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderPaymentCopyWith<_OrderPayment> get copyWith => __$OrderPaymentCopyWithImpl<_OrderPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderPayment&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.state, state) || other.state == state)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reference,provider,state,amount);
}

@override
String toString() {
    return 'OrderPayment(reference: $reference, provider: $provider, state: $state, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$OrderPaymentCopyWith<$Res> implements $OrderPaymentCopyWith<$Res> {
  factory _$OrderPaymentCopyWith(_OrderPayment value, $Res Function(_OrderPayment) _then) = __$OrderPaymentCopyWithImpl;
@override @useResult
$Res call({
 String reference, String provider, String state, Price amount
});


@override $PriceCopyWith<$Res> get amount;

}
/// @nodoc
class __$OrderPaymentCopyWithImpl<$Res>
    implements _$OrderPaymentCopyWith<$Res> {
  __$OrderPaymentCopyWithImpl(this._self, this._then);

  final _OrderPayment _self;
  final $Res Function(_OrderPayment) _then;

/// Create a copy of OrderPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reference = null,Object? provider = null,Object? state = null,Object? amount = null,}) {
  return _then(_OrderPayment(
reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}

/// Create a copy of OrderPayment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get amount {
  
  return $PriceCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// @nodoc
mixin _$OrderSummary {

 int get id; String get name; String? get date; String get state;@JsonKey(name: 'state_label') String get stateLabel; Price get total;@JsonKey(name: 'line_count') int get lineCount;@JsonKey(name: 'delivery_method') String? get deliveryMethod;@JsonKey(name: 'invoice_count') int get invoiceCount;
/// Create a copy of OrderSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderSummaryCopyWith<OrderSummary> get copyWith => _$OrderSummaryCopyWithImpl<OrderSummary>(this as OrderSummary, _$identity);

  /// Serializes this OrderSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.stateLabel, _this.stateLabel) || other.stateLabel == _this.stateLabel)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.deliveryMethod, _this.deliveryMethod) || other.deliveryMethod == _this.deliveryMethod)&&(identical(other.invoiceCount, _this.invoiceCount) || other.invoiceCount == _this.invoiceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderSummary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.date,_this.state,_this.stateLabel,_this.total,_this.lineCount,_this.deliveryMethod,_this.invoiceCount);
}

@override
String toString() {
  final _this = this as OrderSummary;
  return 'OrderSummary(id: ${_this.id}, name: ${_this.name}, date: ${_this.date}, state: ${_this.state}, stateLabel: ${_this.stateLabel}, total: ${_this.total}, lineCount: ${_this.lineCount}, deliveryMethod: ${_this.deliveryMethod}, invoiceCount: ${_this.invoiceCount})';
}


}

/// @nodoc
abstract mixin class $OrderSummaryCopyWith<$Res>  {
  factory $OrderSummaryCopyWith(OrderSummary value, $Res Function(OrderSummary) _then) = _$OrderSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? date, String state,@JsonKey(name: 'state_label') String stateLabel, Price total,@JsonKey(name: 'line_count') int lineCount,@JsonKey(name: 'delivery_method') String? deliveryMethod,@JsonKey(name: 'invoice_count') int invoiceCount
});


$PriceCopyWith<$Res> get total;

}
/// @nodoc
class _$OrderSummaryCopyWithImpl<$Res>
    implements $OrderSummaryCopyWith<$Res> {
  _$OrderSummaryCopyWithImpl(this._self, this._then);

  final OrderSummary _self;
  final $Res Function(OrderSummary) _then;

/// Create a copy of OrderSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? date = freezed,Object? state = null,Object? stateLabel = null,Object? total = null,Object? lineCount = null,Object? deliveryMethod = freezed,Object? invoiceCount = null,}) {
  return _then(OrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateLabel: null == stateLabel ? _self.stateLabel : stateLabel // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,deliveryMethod: freezed == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as String?,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of OrderSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderSummary].
extension OrderSummaryPatterns on OrderSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderSummary value)  $default,){
final _that = this;
switch (_that) {
case _OrderSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OrderSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? date,  String state, @JsonKey(name: 'state_label')  String stateLabel,  Price total, @JsonKey(name: 'line_count')  int lineCount, @JsonKey(name: 'delivery_method')  String? deliveryMethod, @JsonKey(name: 'invoice_count')  int invoiceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderSummary() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.state,_that.stateLabel,_that.total,_that.lineCount,_that.deliveryMethod,_that.invoiceCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? date,  String state, @JsonKey(name: 'state_label')  String stateLabel,  Price total, @JsonKey(name: 'line_count')  int lineCount, @JsonKey(name: 'delivery_method')  String? deliveryMethod, @JsonKey(name: 'invoice_count')  int invoiceCount)  $default,) {final _that = this;
switch (_that) {
case _OrderSummary():
return $default(_that.id,_that.name,_that.date,_that.state,_that.stateLabel,_that.total,_that.lineCount,_that.deliveryMethod,_that.invoiceCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? date,  String state, @JsonKey(name: 'state_label')  String stateLabel,  Price total, @JsonKey(name: 'line_count')  int lineCount, @JsonKey(name: 'delivery_method')  String? deliveryMethod, @JsonKey(name: 'invoice_count')  int invoiceCount)?  $default,) {final _that = this;
switch (_that) {
case _OrderSummary() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.state,_that.stateLabel,_that.total,_that.lineCount,_that.deliveryMethod,_that.invoiceCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderSummary implements OrderSummary {
  const _OrderSummary({required this.id, required this.name, this.date, required this.state, @JsonKey(name: 'state_label') required this.stateLabel, required this.total, @JsonKey(name: 'line_count') this.lineCount = 0, @JsonKey(name: 'delivery_method') this.deliveryMethod, @JsonKey(name: 'invoice_count') this.invoiceCount = 0});
  factory _OrderSummary.fromJson(Map<String, dynamic> json) => _$OrderSummaryFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? date;
@override final  String state;
@override@JsonKey(name: 'state_label') final  String stateLabel;
@override final  Price total;
@override@JsonKey(name: 'line_count') final  int lineCount;
@override@JsonKey(name: 'delivery_method') final  String? deliveryMethod;
@override@JsonKey(name: 'invoice_count') final  int invoiceCount;

/// Create a copy of OrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderSummaryCopyWith<_OrderSummary> get copyWith => __$OrderSummaryCopyWithImpl<_OrderSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.state, state) || other.state == state)&&(identical(other.stateLabel, stateLabel) || other.stateLabel == stateLabel)&&(identical(other.total, total) || other.total == total)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,date,state,stateLabel,total,lineCount,deliveryMethod,invoiceCount);
}

@override
String toString() {
    return 'OrderSummary(id: $id, name: $name, date: $date, state: $state, stateLabel: $stateLabel, total: $total, lineCount: $lineCount, deliveryMethod: $deliveryMethod, invoiceCount: $invoiceCount)';
}


}

/// @nodoc
abstract mixin class _$OrderSummaryCopyWith<$Res> implements $OrderSummaryCopyWith<$Res> {
  factory _$OrderSummaryCopyWith(_OrderSummary value, $Res Function(_OrderSummary) _then) = __$OrderSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? date, String state,@JsonKey(name: 'state_label') String stateLabel, Price total,@JsonKey(name: 'line_count') int lineCount,@JsonKey(name: 'delivery_method') String? deliveryMethod,@JsonKey(name: 'invoice_count') int invoiceCount
});


@override $PriceCopyWith<$Res> get total;

}
/// @nodoc
class __$OrderSummaryCopyWithImpl<$Res>
    implements _$OrderSummaryCopyWith<$Res> {
  __$OrderSummaryCopyWithImpl(this._self, this._then);

  final _OrderSummary _self;
  final $Res Function(_OrderSummary) _then;

/// Create a copy of OrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? date = freezed,Object? state = null,Object? stateLabel = null,Object? total = null,Object? lineCount = null,Object? deliveryMethod = freezed,Object? invoiceCount = null,}) {
  return _then(_OrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateLabel: null == stateLabel ? _self.stateLabel : stateLabel // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,deliveryMethod: freezed == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as String?,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of OrderSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// @nodoc
mixin _$OrdersPage {

 List<OrderSummary> get orders; int get total; int get offset; int get limit;
/// Create a copy of OrdersPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersPageCopyWith<OrdersPage> get copyWith => _$OrdersPageCopyWithImpl<OrdersPage>(this as OrdersPage, _$identity);

  /// Serializes this OrdersPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrdersPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersPage&&const DeepCollectionEquality().equals(other.orders, _this.orders)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.offset, _this.offset) || other.offset == _this.offset)&&(identical(other.limit, _this.limit) || other.limit == _this.limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrdersPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.orders),_this.total,_this.offset,_this.limit);
}

@override
String toString() {
  final _this = this as OrdersPage;
  return 'OrdersPage(orders: ${_this.orders}, total: ${_this.total}, offset: ${_this.offset}, limit: ${_this.limit})';
}


}

/// @nodoc
abstract mixin class $OrdersPageCopyWith<$Res>  {
  factory $OrdersPageCopyWith(OrdersPage value, $Res Function(OrdersPage) _then) = _$OrdersPageCopyWithImpl;
@useResult
$Res call({
 List<OrderSummary> orders, int total, int offset, int limit
});




}
/// @nodoc
class _$OrdersPageCopyWithImpl<$Res>
    implements $OrdersPageCopyWith<$Res> {
  _$OrdersPageCopyWithImpl(this._self, this._then);

  final OrdersPage _self;
  final $Res Function(OrdersPage) _then;

/// Create a copy of OrdersPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orders = null,Object? total = null,Object? offset = null,Object? limit = null,}) {
  return _then(OrdersPage(
orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderSummary>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrdersPage].
extension OrdersPagePatterns on OrdersPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrdersPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrdersPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrdersPage value)  $default,){
final _that = this;
switch (_that) {
case _OrdersPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrdersPage value)?  $default,){
final _that = this;
switch (_that) {
case _OrdersPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OrderSummary> orders,  int total,  int offset,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrdersPage() when $default != null:
return $default(_that.orders,_that.total,_that.offset,_that.limit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OrderSummary> orders,  int total,  int offset,  int limit)  $default,) {final _that = this;
switch (_that) {
case _OrdersPage():
return $default(_that.orders,_that.total,_that.offset,_that.limit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OrderSummary> orders,  int total,  int offset,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _OrdersPage() when $default != null:
return $default(_that.orders,_that.total,_that.offset,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrdersPage implements OrdersPage {
  const _OrdersPage({ List<OrderSummary> orders = const [], this.total = 0, this.offset = 0, this.limit = 20}): _orders = orders;
  factory _OrdersPage.fromJson(Map<String, dynamic> json) => _$OrdersPageFromJson(json);

 final  List<OrderSummary> _orders;
@override@JsonKey() List<OrderSummary> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int offset;
@override@JsonKey() final  int limit;

/// Create a copy of OrdersPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrdersPageCopyWith<_OrdersPage> get copyWith => __$OrdersPageCopyWithImpl<_OrdersPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrdersPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrdersPage&&const DeepCollectionEquality().equals(other.orders, _orders)&&(identical(other.total, total) || other.total == total)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_orders),total,offset,limit);
}

@override
String toString() {
    return 'OrdersPage(orders: $orders, total: $total, offset: $offset, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$OrdersPageCopyWith<$Res> implements $OrdersPageCopyWith<$Res> {
  factory _$OrdersPageCopyWith(_OrdersPage value, $Res Function(_OrdersPage) _then) = __$OrdersPageCopyWithImpl;
@override @useResult
$Res call({
 List<OrderSummary> orders, int total, int offset, int limit
});




}
/// @nodoc
class __$OrdersPageCopyWithImpl<$Res>
    implements _$OrdersPageCopyWith<$Res> {
  __$OrdersPageCopyWithImpl(this._self, this._then);

  final _OrdersPage _self;
  final $Res Function(_OrdersPage) _then;

/// Create a copy of OrdersPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orders = null,Object? total = null,Object? offset = null,Object? limit = null,}) {
  return _then(_OrdersPage(
orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderSummary>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$InvoicesPage {

 List<Invoice> get invoices; int get total; int get offset; int get limit;
/// Create a copy of InvoicesPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoicesPageCopyWith<InvoicesPage> get copyWith => _$InvoicesPageCopyWithImpl<InvoicesPage>(this as InvoicesPage, _$identity);

  /// Serializes this InvoicesPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InvoicesPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoicesPage&&const DeepCollectionEquality().equals(other.invoices, _this.invoices)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.offset, _this.offset) || other.offset == _this.offset)&&(identical(other.limit, _this.limit) || other.limit == _this.limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InvoicesPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.invoices),_this.total,_this.offset,_this.limit);
}

@override
String toString() {
  final _this = this as InvoicesPage;
  return 'InvoicesPage(invoices: ${_this.invoices}, total: ${_this.total}, offset: ${_this.offset}, limit: ${_this.limit})';
}


}

/// @nodoc
abstract mixin class $InvoicesPageCopyWith<$Res>  {
  factory $InvoicesPageCopyWith(InvoicesPage value, $Res Function(InvoicesPage) _then) = _$InvoicesPageCopyWithImpl;
@useResult
$Res call({
 List<Invoice> invoices, int total, int offset, int limit
});




}
/// @nodoc
class _$InvoicesPageCopyWithImpl<$Res>
    implements $InvoicesPageCopyWith<$Res> {
  _$InvoicesPageCopyWithImpl(this._self, this._then);

  final InvoicesPage _self;
  final $Res Function(InvoicesPage) _then;

/// Create a copy of InvoicesPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invoices = null,Object? total = null,Object? offset = null,Object? limit = null,}) {
  return _then(InvoicesPage(
invoices: null == invoices ? _self.invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoicesPage].
extension InvoicesPagePatterns on InvoicesPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoicesPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoicesPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoicesPage value)  $default,){
final _that = this;
switch (_that) {
case _InvoicesPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoicesPage value)?  $default,){
final _that = this;
switch (_that) {
case _InvoicesPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Invoice> invoices,  int total,  int offset,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoicesPage() when $default != null:
return $default(_that.invoices,_that.total,_that.offset,_that.limit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Invoice> invoices,  int total,  int offset,  int limit)  $default,) {final _that = this;
switch (_that) {
case _InvoicesPage():
return $default(_that.invoices,_that.total,_that.offset,_that.limit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Invoice> invoices,  int total,  int offset,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _InvoicesPage() when $default != null:
return $default(_that.invoices,_that.total,_that.offset,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoicesPage implements InvoicesPage {
  const _InvoicesPage({ List<Invoice> invoices = const [], this.total = 0, this.offset = 0, this.limit = 20}): _invoices = invoices;
  factory _InvoicesPage.fromJson(Map<String, dynamic> json) => _$InvoicesPageFromJson(json);

 final  List<Invoice> _invoices;
@override@JsonKey() List<Invoice> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int offset;
@override@JsonKey() final  int limit;

/// Create a copy of InvoicesPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoicesPageCopyWith<_InvoicesPage> get copyWith => __$InvoicesPageCopyWithImpl<_InvoicesPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoicesPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoicesPage&&const DeepCollectionEquality().equals(other.invoices, _invoices)&&(identical(other.total, total) || other.total == total)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_invoices),total,offset,limit);
}

@override
String toString() {
    return 'InvoicesPage(invoices: $invoices, total: $total, offset: $offset, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$InvoicesPageCopyWith<$Res> implements $InvoicesPageCopyWith<$Res> {
  factory _$InvoicesPageCopyWith(_InvoicesPage value, $Res Function(_InvoicesPage) _then) = __$InvoicesPageCopyWithImpl;
@override @useResult
$Res call({
 List<Invoice> invoices, int total, int offset, int limit
});




}
/// @nodoc
class __$InvoicesPageCopyWithImpl<$Res>
    implements _$InvoicesPageCopyWith<$Res> {
  __$InvoicesPageCopyWithImpl(this._self, this._then);

  final _InvoicesPage _self;
  final $Res Function(_InvoicesPage) _then;

/// Create a copy of InvoicesPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invoices = null,Object? total = null,Object? offset = null,Object? limit = null,}) {
  return _then(_InvoicesPage(
invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrderDetail {

 int get id; String get name; String? get date; String get state;@JsonKey(name: 'state_label') String get stateLabel; Price get total;@JsonKey(name: 'line_count') int get lineCount;@JsonKey(name: 'delivery_method') String? get deliveryMethod;@JsonKey(name: 'invoice_count') int get invoiceCount; List<CartLine> get lines; CartAmounts get amounts;@JsonKey(name: 'delivery_address') Address? get deliveryAddress;@JsonKey(name: 'invoice_address') Address? get invoiceAddress;@JsonKey(name: 'client_order_ref') String? get clientOrderRef; List<Invoice> get invoices; List<OrderPayment> get payments;
/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDetailCopyWith<OrderDetail> get copyWith => _$OrderDetailCopyWithImpl<OrderDetail>(this as OrderDetail, _$identity);

  /// Serializes this OrderDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.stateLabel, _this.stateLabel) || other.stateLabel == _this.stateLabel)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.deliveryMethod, _this.deliveryMethod) || other.deliveryMethod == _this.deliveryMethod)&&(identical(other.invoiceCount, _this.invoiceCount) || other.invoiceCount == _this.invoiceCount)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.amounts, _this.amounts) || other.amounts == _this.amounts)&&(identical(other.deliveryAddress, _this.deliveryAddress) || other.deliveryAddress == _this.deliveryAddress)&&(identical(other.invoiceAddress, _this.invoiceAddress) || other.invoiceAddress == _this.invoiceAddress)&&(identical(other.clientOrderRef, _this.clientOrderRef) || other.clientOrderRef == _this.clientOrderRef)&&const DeepCollectionEquality().equals(other.invoices, _this.invoices)&&const DeepCollectionEquality().equals(other.payments, _this.payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderDetail;
  return Object.hash(runtimeType,_this.id,_this.name,_this.date,_this.state,_this.stateLabel,_this.total,_this.lineCount,_this.deliveryMethod,_this.invoiceCount,const DeepCollectionEquality().hash(_this.lines),_this.amounts,_this.deliveryAddress,_this.invoiceAddress,_this.clientOrderRef,const DeepCollectionEquality().hash(_this.invoices),const DeepCollectionEquality().hash(_this.payments));
}

@override
String toString() {
  final _this = this as OrderDetail;
  return 'OrderDetail(id: ${_this.id}, name: ${_this.name}, date: ${_this.date}, state: ${_this.state}, stateLabel: ${_this.stateLabel}, total: ${_this.total}, lineCount: ${_this.lineCount}, deliveryMethod: ${_this.deliveryMethod}, invoiceCount: ${_this.invoiceCount}, lines: ${_this.lines}, amounts: ${_this.amounts}, deliveryAddress: ${_this.deliveryAddress}, invoiceAddress: ${_this.invoiceAddress}, clientOrderRef: ${_this.clientOrderRef}, invoices: ${_this.invoices}, payments: ${_this.payments})';
}


}

/// @nodoc
abstract mixin class $OrderDetailCopyWith<$Res>  {
  factory $OrderDetailCopyWith(OrderDetail value, $Res Function(OrderDetail) _then) = _$OrderDetailCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? date, String state,@JsonKey(name: 'state_label') String stateLabel, Price total,@JsonKey(name: 'line_count') int lineCount,@JsonKey(name: 'delivery_method') String? deliveryMethod,@JsonKey(name: 'invoice_count') int invoiceCount, List<CartLine> lines, CartAmounts amounts,@JsonKey(name: 'delivery_address') Address? deliveryAddress,@JsonKey(name: 'invoice_address') Address? invoiceAddress,@JsonKey(name: 'client_order_ref') String? clientOrderRef, List<Invoice> invoices, List<OrderPayment> payments
});


$PriceCopyWith<$Res> get total;$CartAmountsCopyWith<$Res> get amounts;$AddressCopyWith<$Res>? get deliveryAddress;$AddressCopyWith<$Res>? get invoiceAddress;

}
/// @nodoc
class _$OrderDetailCopyWithImpl<$Res>
    implements $OrderDetailCopyWith<$Res> {
  _$OrderDetailCopyWithImpl(this._self, this._then);

  final OrderDetail _self;
  final $Res Function(OrderDetail) _then;

/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? date = freezed,Object? state = null,Object? stateLabel = null,Object? total = null,Object? lineCount = null,Object? deliveryMethod = freezed,Object? invoiceCount = null,Object? lines = null,Object? amounts = null,Object? deliveryAddress = freezed,Object? invoiceAddress = freezed,Object? clientOrderRef = freezed,Object? invoices = null,Object? payments = null,}) {
  return _then(OrderDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateLabel: null == stateLabel ? _self.stateLabel : stateLabel // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,deliveryMethod: freezed == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as String?,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as CartAmounts,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Address?,invoiceAddress: freezed == invoiceAddress ? _self.invoiceAddress : invoiceAddress // ignore: cast_nullable_to_non_nullable
as Address?,clientOrderRef: freezed == clientOrderRef ? _self.clientOrderRef : clientOrderRef // ignore: cast_nullable_to_non_nullable
as String?,invoices: null == invoices ? _self.invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<OrderPayment>,
  ));
}
/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartAmountsCopyWith<$Res> get amounts {
  
  return $CartAmountsCopyWith<$Res>(_self.amounts, (value) {
    return _then(_self.copyWith(amounts: value));
  });
}/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get invoiceAddress {
    if (_self.invoiceAddress == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.invoiceAddress!, (value) {
    return _then(_self.copyWith(invoiceAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderDetail].
extension OrderDetailPatterns on OrderDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderDetail value)  $default,){
final _that = this;
switch (_that) {
case _OrderDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderDetail value)?  $default,){
final _that = this;
switch (_that) {
case _OrderDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? date,  String state, @JsonKey(name: 'state_label')  String stateLabel,  Price total, @JsonKey(name: 'line_count')  int lineCount, @JsonKey(name: 'delivery_method')  String? deliveryMethod, @JsonKey(name: 'invoice_count')  int invoiceCount,  List<CartLine> lines,  CartAmounts amounts, @JsonKey(name: 'delivery_address')  Address? deliveryAddress, @JsonKey(name: 'invoice_address')  Address? invoiceAddress, @JsonKey(name: 'client_order_ref')  String? clientOrderRef,  List<Invoice> invoices,  List<OrderPayment> payments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderDetail() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.state,_that.stateLabel,_that.total,_that.lineCount,_that.deliveryMethod,_that.invoiceCount,_that.lines,_that.amounts,_that.deliveryAddress,_that.invoiceAddress,_that.clientOrderRef,_that.invoices,_that.payments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? date,  String state, @JsonKey(name: 'state_label')  String stateLabel,  Price total, @JsonKey(name: 'line_count')  int lineCount, @JsonKey(name: 'delivery_method')  String? deliveryMethod, @JsonKey(name: 'invoice_count')  int invoiceCount,  List<CartLine> lines,  CartAmounts amounts, @JsonKey(name: 'delivery_address')  Address? deliveryAddress, @JsonKey(name: 'invoice_address')  Address? invoiceAddress, @JsonKey(name: 'client_order_ref')  String? clientOrderRef,  List<Invoice> invoices,  List<OrderPayment> payments)  $default,) {final _that = this;
switch (_that) {
case _OrderDetail():
return $default(_that.id,_that.name,_that.date,_that.state,_that.stateLabel,_that.total,_that.lineCount,_that.deliveryMethod,_that.invoiceCount,_that.lines,_that.amounts,_that.deliveryAddress,_that.invoiceAddress,_that.clientOrderRef,_that.invoices,_that.payments);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? date,  String state, @JsonKey(name: 'state_label')  String stateLabel,  Price total, @JsonKey(name: 'line_count')  int lineCount, @JsonKey(name: 'delivery_method')  String? deliveryMethod, @JsonKey(name: 'invoice_count')  int invoiceCount,  List<CartLine> lines,  CartAmounts amounts, @JsonKey(name: 'delivery_address')  Address? deliveryAddress, @JsonKey(name: 'invoice_address')  Address? invoiceAddress, @JsonKey(name: 'client_order_ref')  String? clientOrderRef,  List<Invoice> invoices,  List<OrderPayment> payments)?  $default,) {final _that = this;
switch (_that) {
case _OrderDetail() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.state,_that.stateLabel,_that.total,_that.lineCount,_that.deliveryMethod,_that.invoiceCount,_that.lines,_that.amounts,_that.deliveryAddress,_that.invoiceAddress,_that.clientOrderRef,_that.invoices,_that.payments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderDetail implements OrderDetail {
  const _OrderDetail({required this.id, required this.name, this.date, required this.state, @JsonKey(name: 'state_label') required this.stateLabel, required this.total, @JsonKey(name: 'line_count') this.lineCount = 0, @JsonKey(name: 'delivery_method') this.deliveryMethod, @JsonKey(name: 'invoice_count') this.invoiceCount = 0,  List<CartLine> lines = const [], required this.amounts, @JsonKey(name: 'delivery_address') this.deliveryAddress, @JsonKey(name: 'invoice_address') this.invoiceAddress, @JsonKey(name: 'client_order_ref') this.clientOrderRef,  List<Invoice> invoices = const [],  List<OrderPayment> payments = const []}): _lines = lines,_invoices = invoices,_payments = payments;
  factory _OrderDetail.fromJson(Map<String, dynamic> json) => _$OrderDetailFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? date;
@override final  String state;
@override@JsonKey(name: 'state_label') final  String stateLabel;
@override final  Price total;
@override@JsonKey(name: 'line_count') final  int lineCount;
@override@JsonKey(name: 'delivery_method') final  String? deliveryMethod;
@override@JsonKey(name: 'invoice_count') final  int invoiceCount;
 final  List<CartLine> _lines;
@override@JsonKey() List<CartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  CartAmounts amounts;
@override@JsonKey(name: 'delivery_address') final  Address? deliveryAddress;
@override@JsonKey(name: 'invoice_address') final  Address? invoiceAddress;
@override@JsonKey(name: 'client_order_ref') final  String? clientOrderRef;
 final  List<Invoice> _invoices;
@override@JsonKey() List<Invoice> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}

 final  List<OrderPayment> _payments;
@override@JsonKey() List<OrderPayment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}


/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDetailCopyWith<_OrderDetail> get copyWith => __$OrderDetailCopyWithImpl<_OrderDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.state, state) || other.state == state)&&(identical(other.stateLabel, stateLabel) || other.stateLabel == stateLabel)&&(identical(other.total, total) || other.total == total)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.amounts, amounts) || other.amounts == amounts)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.invoiceAddress, invoiceAddress) || other.invoiceAddress == invoiceAddress)&&(identical(other.clientOrderRef, clientOrderRef) || other.clientOrderRef == clientOrderRef)&&const DeepCollectionEquality().equals(other.invoices, _invoices)&&const DeepCollectionEquality().equals(other.payments, _payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,date,state,stateLabel,total,lineCount,deliveryMethod,invoiceCount,const DeepCollectionEquality().hash(_lines),amounts,deliveryAddress,invoiceAddress,clientOrderRef,const DeepCollectionEquality().hash(_invoices),const DeepCollectionEquality().hash(_payments));
}

@override
String toString() {
    return 'OrderDetail(id: $id, name: $name, date: $date, state: $state, stateLabel: $stateLabel, total: $total, lineCount: $lineCount, deliveryMethod: $deliveryMethod, invoiceCount: $invoiceCount, lines: $lines, amounts: $amounts, deliveryAddress: $deliveryAddress, invoiceAddress: $invoiceAddress, clientOrderRef: $clientOrderRef, invoices: $invoices, payments: $payments)';
}


}

/// @nodoc
abstract mixin class _$OrderDetailCopyWith<$Res> implements $OrderDetailCopyWith<$Res> {
  factory _$OrderDetailCopyWith(_OrderDetail value, $Res Function(_OrderDetail) _then) = __$OrderDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? date, String state,@JsonKey(name: 'state_label') String stateLabel, Price total,@JsonKey(name: 'line_count') int lineCount,@JsonKey(name: 'delivery_method') String? deliveryMethod,@JsonKey(name: 'invoice_count') int invoiceCount, List<CartLine> lines, CartAmounts amounts,@JsonKey(name: 'delivery_address') Address? deliveryAddress,@JsonKey(name: 'invoice_address') Address? invoiceAddress,@JsonKey(name: 'client_order_ref') String? clientOrderRef, List<Invoice> invoices, List<OrderPayment> payments
});


@override $PriceCopyWith<$Res> get total;@override $CartAmountsCopyWith<$Res> get amounts;@override $AddressCopyWith<$Res>? get deliveryAddress;@override $AddressCopyWith<$Res>? get invoiceAddress;

}
/// @nodoc
class __$OrderDetailCopyWithImpl<$Res>
    implements _$OrderDetailCopyWith<$Res> {
  __$OrderDetailCopyWithImpl(this._self, this._then);

  final _OrderDetail _self;
  final $Res Function(_OrderDetail) _then;

/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? date = freezed,Object? state = null,Object? stateLabel = null,Object? total = null,Object? lineCount = null,Object? deliveryMethod = freezed,Object? invoiceCount = null,Object? lines = null,Object? amounts = null,Object? deliveryAddress = freezed,Object? invoiceAddress = freezed,Object? clientOrderRef = freezed,Object? invoices = null,Object? payments = null,}) {
  return _then(_OrderDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateLabel: null == stateLabel ? _self.stateLabel : stateLabel // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,deliveryMethod: freezed == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as String?,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as CartAmounts,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Address?,invoiceAddress: freezed == invoiceAddress ? _self.invoiceAddress : invoiceAddress // ignore: cast_nullable_to_non_nullable
as Address?,clientOrderRef: freezed == clientOrderRef ? _self.clientOrderRef : clientOrderRef // ignore: cast_nullable_to_non_nullable
as String?,invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<OrderPayment>,
  ));
}

/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartAmountsCopyWith<$Res> get amounts {
  
  return $CartAmountsCopyWith<$Res>(_self.amounts, (value) {
    return _then(_self.copyWith(amounts: value));
  });
}/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of OrderDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get invoiceAddress {
    if (_self.invoiceAddress == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.invoiceAddress!, (value) {
    return _then(_self.copyWith(invoiceAddress: value));
  });
}
}

// dart format on
