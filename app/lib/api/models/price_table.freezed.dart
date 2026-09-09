// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_table.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceTable {

 String? get title; List<DescriptionBlock> get note; List<PriceTier> get entries;
/// Create a copy of PriceTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceTableCopyWith<PriceTable> get copyWith => _$PriceTableCopyWithImpl<PriceTable>(this as PriceTable, _$identity);

  /// Serializes this PriceTable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceTable;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceTable&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.note, _this.note)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceTable;
  return Object.hash(runtimeType,_this.title,const DeepCollectionEquality().hash(_this.note),const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as PriceTable;
  return 'PriceTable(title: ${_this.title}, note: ${_this.note}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $PriceTableCopyWith<$Res>  {
  factory $PriceTableCopyWith(PriceTable value, $Res Function(PriceTable) _then) = _$PriceTableCopyWithImpl;
@useResult
$Res call({
 String? title, List<DescriptionBlock> note, List<PriceTier> entries
});




}
/// @nodoc
class _$PriceTableCopyWithImpl<$Res>
    implements $PriceTableCopyWith<$Res> {
  _$PriceTableCopyWithImpl(this._self, this._then);

  final PriceTable _self;
  final $Res Function(PriceTable) _then;

/// Create a copy of PriceTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? note = null,Object? entries = null,}) {
  return _then(PriceTable(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PriceTier>,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceTable].
extension PriceTablePatterns on PriceTable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceTable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceTable value)  $default,){
final _that = this;
switch (_that) {
case _PriceTable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceTable value)?  $default,){
final _that = this;
switch (_that) {
case _PriceTable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  List<DescriptionBlock> note,  List<PriceTier> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceTable() when $default != null:
return $default(_that.title,_that.note,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  List<DescriptionBlock> note,  List<PriceTier> entries)  $default,) {final _that = this;
switch (_that) {
case _PriceTable():
return $default(_that.title,_that.note,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  List<DescriptionBlock> note,  List<PriceTier> entries)?  $default,) {final _that = this;
switch (_that) {
case _PriceTable() when $default != null:
return $default(_that.title,_that.note,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceTable implements PriceTable {
  const _PriceTable({this.title,  List<DescriptionBlock> note = const [],  List<PriceTier> entries = const []}): _note = note,_entries = entries;
  factory _PriceTable.fromJson(Map<String, dynamic> json) => _$PriceTableFromJson(json);

@override final  String? title;
 final  List<DescriptionBlock> _note;
@override@JsonKey() List<DescriptionBlock> get note {
  if (_note is EqualUnmodifiableListView) return _note;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_note);
}

 final  List<PriceTier> _entries;
@override@JsonKey() List<PriceTier> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of PriceTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceTableCopyWith<_PriceTable> get copyWith => __$PriceTableCopyWithImpl<_PriceTable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceTableToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceTable&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.note, _note)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_note),const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'PriceTable(title: $title, note: $note, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$PriceTableCopyWith<$Res> implements $PriceTableCopyWith<$Res> {
  factory _$PriceTableCopyWith(_PriceTable value, $Res Function(_PriceTable) _then) = __$PriceTableCopyWithImpl;
@override @useResult
$Res call({
 String? title, List<DescriptionBlock> note, List<PriceTier> entries
});




}
/// @nodoc
class __$PriceTableCopyWithImpl<$Res>
    implements _$PriceTableCopyWith<$Res> {
  __$PriceTableCopyWithImpl(this._self, this._then);

  final _PriceTable _self;
  final $Res Function(_PriceTable) _then;

/// Create a copy of PriceTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? note = null,Object? entries = null,}) {
  return _then(_PriceTable(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self._note : note // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PriceTier>,
  ));
}


}

// dart format on
