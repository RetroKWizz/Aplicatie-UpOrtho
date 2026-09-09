// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'description_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DescriptionSpan _$DescriptionSpanFromJson(Map<String, dynamic> json) =>
    _DescriptionSpan(
      text: json['text'] as String? ?? '',
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
    );

Map<String, dynamic> _$DescriptionSpanToJson(_DescriptionSpan instance) =>
    <String, dynamic>{
      'text': instance.text,
      'bold': instance.bold,
      'italic': instance.italic,
    };

_DescriptionBullet _$DescriptionBulletFromJson(Map<String, dynamic> json) =>
    _DescriptionBullet(
      spans:
          (json['spans'] as List<dynamic>?)
              ?.map((e) => DescriptionSpan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DescriptionBulletToJson(_DescriptionBullet instance) =>
    <String, dynamic>{'spans': instance.spans};

_DescriptionBlock _$DescriptionBlockFromJson(Map<String, dynamic> json) =>
    _DescriptionBlock(
      type:
          $enumDecodeNullable(
            _$DescriptionBlockTypeEnumMap,
            json['type'],
            unknownValue: DescriptionBlockType.paragraph,
          ) ??
          DescriptionBlockType.paragraph,
      spans:
          (json['spans'] as List<dynamic>?)
              ?.map((e) => DescriptionSpan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => DescriptionBullet.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DescriptionBlockToJson(_DescriptionBlock instance) =>
    <String, dynamic>{
      'type': _$DescriptionBlockTypeEnumMap[instance.type]!,
      'spans': instance.spans,
      'items': instance.items,
    };

const _$DescriptionBlockTypeEnumMap = {
  DescriptionBlockType.heading: 'heading',
  DescriptionBlockType.paragraph: 'paragraph',
  DescriptionBlockType.bullets: 'bullets',
};
