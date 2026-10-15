import 'package:freezed_annotation/freezed_annotation.dart';

part 'instagram_feed.freezed.dart';
part 'instagram_feed.g.dart';

/// Feedul de Instagram al magazinului, asa cum il are si pagina de start a site-ului.
///
/// Pozele nu trec prin Odoo: `embedUrl` e chiar adresa pe care o incarca iframe-ul de
/// pe site, iar aplicatia o deschide intr-un WebView. Contul e derivat pe server din
/// adresa de Instagram din setarile website-ului, deci feedul si iconita de Instagram
/// nu pot arata conturi diferite.
@freezed
abstract class InstagramFeed with _$InstagramFeed {
  const factory InstagramFeed({
    required String username,
    @JsonKey(name: 'embed_url') required String embedUrl,
    @JsonKey(name: 'profile_url') required String profileUrl,
  }) = _InstagramFeed;

  factory InstagramFeed.fromJson(Map<String, dynamic> json) => _$InstagramFeedFromJson(json);
}
