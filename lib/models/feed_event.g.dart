// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedEvent _$FeedEventFromJson(Map<String, dynamic> json) => FeedEvent(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      created_at: (json['created_at'] as num).toInt(),
      kind: (json['kind'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      content: json['content'] as String,
      sig: json['sig'] as String,
      author_name: json['author_name'] as String?,
      author_about: json['author_about'] as String?,
      author_picture: json['author_picture'] as String?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => FeedEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      is_reply: json['is_reply'] as bool? ?? false,
      external_viewer_url: json['external_viewer_url'] as String?,
      reply_count: (json['reply_count'] as num?)?.toInt() ?? 0,
      boost_count: (json['boost_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FeedEventToJson(FeedEvent instance) => <String, dynamic>{
      'id': instance.id,
      'pubkey': instance.pubkey,
      'created_at': instance.created_at,
      'kind': instance.kind,
      'tags': instance.tags,
      'content': instance.content,
      'sig': instance.sig,
      'author_name': instance.author_name,
      'author_about': instance.author_about,
      'author_picture': instance.author_picture,
      'replies': instance.replies,
      'is_reply': instance.is_reply,
      'external_viewer_url': instance.external_viewer_url,
      'reply_count': instance.reply_count,
      'boost_count': instance.boost_count,
    };
