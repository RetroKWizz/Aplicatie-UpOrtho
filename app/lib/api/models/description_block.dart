import 'package:freezed_annotation/freezed_annotation.dart';

part 'description_block.freezed.dart';
part 'description_block.g.dart';

/// Tipurile de bloc din descriere. Serverul trimite blocuri, niciodata HTML —
/// aplicatia nu are motor HTML si nu vrem sa introducem unul. Un tip necunoscut
/// (adaugat pe server dupa un release) se randeaza ca paragraf, nu arunca.
@JsonEnum(valueField: 'value')
enum DescriptionBlockType {
  heading('heading'),
  paragraph('paragraph'),
  bullets('bullets');

  const DescriptionBlockType(this.value);
  final String value;
}

/// O bucata de text cu formatarea ei. `bold`/`italic` vin din `strong`/`b` si
/// `em`/`i` din HTML-ul original, convertite pe server.
@freezed
abstract class DescriptionSpan with _$DescriptionSpan {
  const factory DescriptionSpan({
    @Default('') String text,
    @Default(false) bool bold,
    @Default(false) bool italic,
  }) = _DescriptionSpan;

  factory DescriptionSpan.fromJson(Map<String, dynamic> json) => _$DescriptionSpanFromJson(json);
}

/// Un element de lista: propriile lui span-uri.
@freezed
abstract class DescriptionBullet with _$DescriptionBullet {
  const factory DescriptionBullet({
    @Default([]) List<DescriptionSpan> spans,
  }) = _DescriptionBullet;

  factory DescriptionBullet.fromJson(Map<String, dynamic> json) => _$DescriptionBulletFromJson(json);
}

/// Un bloc de descriere. `heading` si `paragraph` folosesc `spans`; `bullets`
/// foloseste `items` — celalalt camp ramane gol, niciodata null.
@freezed
abstract class DescriptionBlock with _$DescriptionBlock {
  const factory DescriptionBlock({
    @JsonKey(unknownEnumValue: DescriptionBlockType.paragraph)
    @Default(DescriptionBlockType.paragraph)
    DescriptionBlockType type,
    @Default([]) List<DescriptionSpan> spans,
    @Default([]) List<DescriptionBullet> items,
  }) = _DescriptionBlock;

  factory DescriptionBlock.fromJson(Map<String, dynamic> json) => _$DescriptionBlockFromJson(json);
}
