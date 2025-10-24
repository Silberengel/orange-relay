import 'package:json_annotation/json_annotation.dart';

part 'feed_event.g.dart';

@JsonSerializable()
class FeedEvent {
  final String id;
  final String pubkey;
  final int created_at;
  final int kind;
  final List<List<String>> tags;
  final String content;
  final String sig;
  final String? author_name;
  final String? author_about;
  final String? author_picture;
  final List<FeedEvent>? replies;
  final bool is_reply;
  final String? external_viewer_url;
  final int reply_count;
  final int boost_count;

  const FeedEvent({
    required this.id,
    required this.pubkey,
    required this.created_at,
    required this.kind,
    required this.tags,
    required this.content,
    required this.sig,
    this.author_name,
    this.author_about,
    this.author_picture,
    this.replies,
    this.is_reply = false,
    this.external_viewer_url,
    this.reply_count = 0,
    this.boost_count = 0,
  });

  factory FeedEvent.fromJson(Map<String, dynamic> json) => _$FeedEventFromJson(json);
  Map<String, dynamic> toJson() => _$FeedEventToJson(this);

  /// Get display name for author
  String get authorDisplayName {
    return author_name ?? pubkey.substring(0, 8);
  }

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - created_at;
    
    if (diff < 60) return 'now';
    if (diff < 3600) return '${diff ~/ 60}m';
    if (diff < 86400) return '${diff ~/ 3600}h';
    if (diff < 2592000) return '${diff ~/ 86400}d';
    return '${diff ~/ 2592000}mo';
  }

  /// Check if event is a reply
  bool get isReplyEvent {
    return tags.any((tag) => tag.isNotEmpty && tag[0] == 'e');
  }

  /// Get reply to event ID
  String? get replyToEventId {
    for (final tag in tags) {
      if (tag.isNotEmpty && tag[0] == 'e') {
        return tag[1];
      }
    }
    return null;
  }

  /// Get mentioned pubkeys
  List<String> get mentionedPubkeys {
    return tags
        .where((tag) => tag.isNotEmpty && tag[0] == 'p')
        .map((tag) => tag[1])
        .toList();
  }

  /// Get hashtags
  List<String> get hashtags {
    return tags
        .where((tag) => tag.isNotEmpty && tag[0] == 't')
        .map((tag) => tag[1])
        .toList();
  }

  /// Get content preview (first 100 characters)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// Check if content contains media
  bool get hasMedia {
    return content.contains('http') && 
           (content.contains('.jpg') || 
            content.contains('.png') || 
            content.contains('.gif') ||
            content.contains('.mp4') ||
            content.contains('.webm'));
  }

  /// Get media URLs from content
  List<String> get mediaUrls {
    final urls = <String>[];
    final words = content.split(' ');
    
    for (final word in words) {
      if (word.startsWith('http') && 
          (word.contains('.jpg') || 
           word.contains('.png') || 
           word.contains('.gif') ||
           word.contains('.mp4') ||
           word.contains('.webm'))) {
        urls.add(word);
      }
    }
    
    return urls;
  }
}
