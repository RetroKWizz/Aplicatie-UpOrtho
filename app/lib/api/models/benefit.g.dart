// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Benefit _$BenefitFromJson(Map<String, dynamic> json) => _Benefit(
  icon: $enumDecode(
    _$BenefitIconEnumMap,
    json['icon'],
    unknownValue: BenefitIcon.info,
  ),
  title: json['title'] as String,
  text: json['text'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$BenefitToJson(_Benefit instance) => <String, dynamic>{
  'icon': _$BenefitIconEnumMap[instance.icon]!,
  'title': instance.title,
  'text': instance.text,
  'image_url': instance.imageUrl,
};

const _$BenefitIconEnumMap = {
  BenefitIcon.club: 'club',
  BenefitIcon.delivery: 'delivery',
  BenefitIcon.returns: 'return',
  BenefitIcon.payment: 'payment',
  BenefitIcon.info: 'info',
};
