// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InstagramFeed _$InstagramFeedFromJson(Map<String, dynamic> json) =>
    _InstagramFeed(
      username: json['username'] as String,
      embedUrl: json['embed_url'] as String,
      profileUrl: json['profile_url'] as String,
    );

Map<String, dynamic> _$InstagramFeedToJson(_InstagramFeed instance) =>
    <String, dynamic>{
      'username': instance.username,
      'embed_url': instance.embedUrl,
      'profile_url': instance.profileUrl,
    };
