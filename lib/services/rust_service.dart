import 'dart:convert';
import 'dart:math';
import '../ffi/nostr_ffi.dart';

/// Rust service for FFI communication with real Nostr backend
class RustService {
  static final Random _random = Random();
  static bool _useRealBackend = false;
  
  // Fallback sample data for when FFI is not available
  static final List<String> _sampleAuthors = [
    'Alice Johnson',
    'Bob Smith',
    'Charlie Brown',
    'Diana Prince',
    'Eve Wilson',
    'Frank Miller',
    'Grace Hopper',
    'Henry Ford',
  ];
  
  static final List<String> _sampleContent = [
    'Just discovered this amazing new protocol! 🚀',
    'Working on some exciting new features for the app.',
    'The future of decentralized communication is here!',
    'Had a great conversation with the team today.',
    'Building something incredible with Flutter and Rust.',
    'The Nostr protocol is revolutionizing how we communicate.',
    'Excited to share this new project with everyone!',
    'Learning so much about decentralized systems.',
    'The community response has been overwhelming!',
    'Can\'t wait to see what we build next.',
  ];

  /// Initialize the Rust service
  static Future<void> initialize() async {
    try {
      await NostrFFI.initialize();
      final result = await NostrFFI.initializeNostrClient();
      _useRealBackend = result['success'] == true;
      
      if (_useRealBackend) {
        print('✅ Connected to real Nostr backend');
      } else {
        print('⚠️ Using mock data (FFI not available)');
      }
    } catch (e) {
      print('⚠️ FFI initialization failed, using mock data: $e');
      _useRealBackend = false;
    }
  }

  /// Get feed events from Rust backend
  static Future<List<Map<String, dynamic>>> getFeedEvents({int limit = 100}) async {
    if (_useRealBackend) {
      try {
        final result = await NostrFFI.getFeedEvents(limit: limit);
        if (result['success'] == true && result['events'] != null) {
          return List<Map<String, dynamic>>.from(result['events']);
        } else {
          print('⚠️ Failed to get real events, falling back to mock data');
          return _generateMockEvents(limit);
        }
      } catch (e) {
        print('⚠️ Error getting real events, falling back to mock data: $e');
        return _generateMockEvents(limit);
      }
    } else {
      return _generateMockEvents(limit);
    }
  }

  /// Generate mock events for fallback
  static List<Map<String, dynamic>> _generateMockEvents(int limit) {
    return List.generate(limit, (index) {
      final author = _sampleAuthors[index % _sampleAuthors.length];
      final content = _sampleContent[index % _sampleContent.length];
      final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 - index * 3600;
      
      return {
        'id': 'event_${_generateRandomId()}',
        'pubkey': 'npub1${_generateRandomId()}',
        'created_at': createdAt,
        'kind': _getRandomKind(),
        'content': content,
        'tags': _generateRandomTags(),
        'sig': 'signature_${_generateRandomId()}',
        'author_name': author,
        'author_about': '${author.split(' ')[0]} is passionate about decentralized technology',
        'author_picture': null, // Disable network images in tests
        'reply_count': _random.nextInt(10),
        'boost_count': _random.nextInt(20),
        'external_viewer_url': index % 15 == 0 ? 'https://jumble.dev/event/event_$index' : null,
      };
    });
  }
  /// Get book structure from Rust backend
  static Future<Map<String, dynamic>?> getBookStructure(String bookId) async {
    // TODO: Implement actual Rust FFI call
    // For now, return sample book data
    if (bookId == 'featured' || bookId.startsWith('sample-')) {
      return _generateSampleBook(bookId);
    }
    return null;
  }

  /// Get chronological feed from Rust backend
  static Future<List<Map<String, dynamic>>> getChronologicalFeed({int limit = 100}) async {
    if (_useRealBackend) {
      try {
        final result = await NostrFFI.getChronologicalFeed(limit: limit);
        if (result['success'] == true && result['events'] != null) {
          return List<Map<String, dynamic>>.from(result['events']);
        } else {
          print('⚠️ Failed to get real chronological feed, falling back to mock data');
          return _generateMockEvents(limit);
        }
      } catch (e) {
        print('⚠️ Error getting real chronological feed, falling back to mock data: $e');
        return _generateMockEvents(limit);
      }
    } else {
      return _generateMockEvents(limit);
    }
  }

  /// Broadcast event to relays
  static Future<Map<String, dynamic>> broadcastEvent(String eventId, List<String> relayUrls) async {
    if (_useRealBackend) {
      try {
        final result = await NostrFFI.broadcastEvent(eventId, relayUrls);
        if (result['success'] == true) {
          return result;
        } else {
          print('⚠️ Failed to broadcast to real relays, falling back to simulation');
          return _simulateBroadcast(eventId, relayUrls);
        }
      } catch (e) {
        print('⚠️ Error broadcasting to real relays, falling back to simulation: $e');
        return _simulateBroadcast(eventId, relayUrls);
      }
    } else {
      return _simulateBroadcast(eventId, relayUrls);
    }
  }

  /// Simulate broadcast for fallback
  static Future<Map<String, dynamic>> _simulateBroadcast(String eventId, List<String> relayUrls) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(2000)));
    
    final successfulRelays = <String>[];
    final failedRelays = <String>[];
    
    for (final url in relayUrls) {
      // Simulate 80% success rate
      if (_random.nextDouble() < 0.8) {
        successfulRelays.add(url);
      } else {
        failedRelays.add(url);
      }
    }
    
    return {
      'success': successfulRelays.isNotEmpty,
      'broadcasted_to': successfulRelays,
      'failed_relays': failedRelays,
      'total_success': successfulRelays.length,
      'total_failed': failedRelays.length,
      'error': failedRelays.isNotEmpty && successfulRelays.isEmpty ? 'All relays failed' : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Get broadcast history
  static Future<List<Map<String, dynamic>>> getBroadcastHistory() async {
    if (_useRealBackend) {
      try {
        final result = await NostrFFI.getBroadcastHistory();
        if (result['success'] == true && result['history'] != null) {
          return List<Map<String, dynamic>>.from(result['history']);
        } else {
          print('⚠️ Failed to get real broadcast history, falling back to mock data');
          return _generateMockHistory();
        }
      } catch (e) {
        print('⚠️ Error getting real broadcast history, falling back to mock data: $e');
        return _generateMockHistory();
      }
    } else {
      return _generateMockHistory();
    }
  }

  /// Generate mock broadcast history for fallback
  static List<Map<String, dynamic>> _generateMockHistory() {
    return List.generate(10, (index) => {
      'event_id': 'event_${_generateRandomId()}',
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000 - index * 3600,
      'success': _random.nextDouble() > 0.2,
      'relay_count': 2 + _random.nextInt(5),
      'successful_relays': 1 + _random.nextInt(4),
    });
  }

  /// Get relay statistics
  static Future<Map<String, dynamic>> getRelayStats() async {
    if (_useRealBackend) {
      try {
        final result = await NostrFFI.getRelayStats();
        if (result['success'] == true && result['stats'] != null) {
          return Map<String, dynamic>.from(result['stats']);
        } else {
          print('⚠️ Failed to get real relay stats, falling back to mock data');
          return _generateMockRelayStats();
        }
      } catch (e) {
        print('⚠️ Error getting real relay stats, falling back to mock data: $e');
        return _generateMockRelayStats();
      }
    } else {
      return _generateMockRelayStats();
    }
  }

  /// Generate mock relay stats for fallback
  static Map<String, dynamic> _generateMockRelayStats() {
    return {
      'wss://relay.damus.io': {
        'is_online': true,
        'success_rate': 0.95,
        'average_response_time_ms': 150 + _random.nextInt(100),
      },
      'wss://relay.snort.social': {
        'is_online': true,
        'success_rate': 0.88,
        'average_response_time_ms': 200 + _random.nextInt(150),
      },
      'wss://nos.lol': {
        'is_online': _random.nextDouble() > 0.1,
        'success_rate': 0.92,
        'average_response_time_ms': 180 + _random.nextInt(120),
      },
      'wss://theforest.nostr1.com': {
        'is_online': true,
        'success_rate': 0.90,
        'average_response_time_ms': 220 + _random.nextInt(200),
      },
      'wss://thecitadel.nostr1.com': {
        'is_online': _random.nextDouble() > 0.05,
        'success_rate': 0.85,
        'average_response_time_ms': 300 + _random.nextInt(250),
      },
      'wss://orly-relay.imwald.eu': {
        'is_online': true,
        'success_rate': 0.93,
        'average_response_time_ms': 160 + _random.nextInt(80),
      },
      'wss://nostr.land': {
        'is_online': _random.nextDouble() > 0.15,
        'success_rate': 0.87,
        'average_response_time_ms': 250 + _random.nextInt(150),
      },
      'wss://relay.nostr.band': {
        'is_online': true,
        'success_rate': 0.91,
        'average_response_time_ms': 190 + _random.nextInt(100),
      },
    };
  }

  // Helper methods
  static String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(_random.nextInt(chars.length)))
    );
  }

  static int _getRandomKind() {
    final kinds = [1, 6, 7, 30040];
    return kinds[_random.nextInt(kinds.length)];
  }

  static List<List<String>> _generateRandomTags() {
    final tags = <List<String>>[];
    
    // Random p tags (mentions)
    if (_random.nextDouble() < 0.3) {
      tags.add(['p', 'npub1${_generateRandomId()}']);
    }
    
    // Random t tags (hashtags)
    if (_random.nextDouble() < 0.4) {
      final hashtags = ['nostr', 'flutter', 'rust', 'decentralized', 'privacy'];
      final tag = hashtags[_random.nextInt(hashtags.length)];
      tags.add(['t', tag]);
    }
    
    return tags;
  }

  static Map<String, dynamic> _generateSampleBook(String bookId) {
    final chapters = List.generate(5, (index) => {
      'id': 'chapter_${index + 1}',
      'title': 'Chapter ${index + 1}: ${_getChapterTitle(index)}',
      'content': _getChapterContent(index),
      'order': index,
      'summary': 'This is a summary of chapter ${index + 1}',
      'tags': ['nostr', 'protocol', 'decentralized'],
      'word_count': 500 + _random.nextInt(1000),
      'reading_time_minutes': 2 + _random.nextInt(8),
      'metadata': {
        'difficulty': 'beginner',
        'topics': ['nostr', 'protocol'],
      },
    });

    return {
      'id': bookId,
      'title': 'The Complete Guide to Nostr Protocol',
      'summary': 'A comprehensive guide to understanding and using the Nostr protocol',
      'description': 'This book covers everything you need to know about the Nostr protocol, from basic concepts to advanced implementation details.',
      'author': 'Nostr Community',
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 - 86400,
      'chapters': chapters,
      'metadata': {
        'isbn': '978-0-123456-78-9',
        'publisher': 'Nostr Publishing',
        'language': 'en',
        'genres': ['Technology', 'Cryptography', 'Decentralization'],
        'cover_image': 'https://picsum.photos/300/400?random=${bookId.hashCode}',
        'license': 'CC BY-SA 4.0',
      },
      'total_chapters': chapters.length,
      'current_chapter': 0,
    };
  }

  static String _getChapterTitle(int index) {
    final titles = [
      'Introduction to Nostr',
      'Setting Up Your First Client',
      'Understanding Events and Kinds',
      'Relays and Network Architecture',
      'Advanced Features and Best Practices',
    ];
    return titles[index % titles.length];
  }

  static String _getChapterContent(int index) {
    final contents = [
      'Nostr is a simple, open protocol that enables global, decentralized, and censorship-resistant social media.',
      'In this chapter, we\'ll walk through setting up your first Nostr client and connecting to the network.',
      'Events are the fundamental building blocks of Nostr. Each event has a kind, content, and various tags.',
      'Relays are the backbone of the Nostr network, providing storage and routing for events.',
      'Now that you understand the basics, let\'s explore some advanced features and best practices.',
    ];
    return contents[index % contents.length];
  }
}