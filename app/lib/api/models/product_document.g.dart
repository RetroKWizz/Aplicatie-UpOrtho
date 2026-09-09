// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductDocument _$ProductDocumentFromJson(Map<String, dynamic> json) =>
    _ProductDocument(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fileName: json['file_name'] as String?,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ProductDocumentToJson(_ProductDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'file_name': instance.fileName,
      'url': instance.url,
    };
