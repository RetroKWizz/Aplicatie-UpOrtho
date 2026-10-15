import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_link.freezed.dart';
part 'social_link.g.dart';

/// O retea sociala a magazinului: numele retelei si adresa ei.
///
/// Adresele nu sunt scrise nicaieri in aplicatie - vin din setarile website-ului,
/// aceleasi pe care site-ul le arata in subsol. Numele retelei (`facebook`,
/// `instagram`, ...) e cheia dupa care aplicatia alege iconita si culoarea; o retea
/// pe care nu o cunoaste tot se arata, cu o iconita de link.
@freezed
abstract class SocialLink with _$SocialLink {
  const factory SocialLink({
    required String network,
    required String url,
  }) = _SocialLink;

  factory SocialLink.fromJson(Map<String, dynamic> json) => _$SocialLinkFromJson(json);
}
