import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/rust_service.dart';
import '../models/feed_event.dart';
import '../models/book_structure.dart';
import '../models/broadcast_response.dart';

// Feed provider
final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedEvent>>>((ref) {
  return FeedNotifier();
});

// Books provider
final booksProvider = StateNotifierProvider<BooksNotifier, AsyncValue<List<BookStructure>>>((ref) {
  return BooksNotifier();
});

class FeedNotifier extends StateNotifier<AsyncValue<List<FeedEvent>>> {
  FeedNotifier() : super(const AsyncValue.loading()) {
    loadFeed();
  }

  Future<void> loadFeed({int limit = 100}) async {
    state = const AsyncValue.loading();
    try {
      final events = await RustService.getFeedEvents(limit: limit);
      final feedEvents = events.map((json) => FeedEvent.fromJson(json)).toList();
      state = AsyncValue.data(feedEvents);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await loadFeed();
  }

  Future<void> loadMore() async {
    // Load more events for pagination
    try {
      // TODO: Implement actual pagination
      await Future.delayed(const Duration(seconds: 1));
    } catch (e, stackTrace) {
      // Handle error silently for now
    }
  }
}

// Book provider
final bookProvider = StateNotifierProvider.family<BookNotifier, AsyncValue<BookStructure?>, String>((ref, bookId) {
  return BookNotifier(bookId);
});

class BookNotifier extends StateNotifier<AsyncValue<BookStructure?>> {
  final String bookId;
  
  BookNotifier(this.bookId) : super(const AsyncValue.loading()) {
    loadBook();
  }

  Future<void> loadBook() async {
    state = const AsyncValue.loading();
    try {
      final bookData = await RustService.getBookStructure(bookId);
      if (bookData != null) {
        final book = BookStructure.fromJson(bookData);
        state = AsyncValue.data(book);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setCurrentChapter(int chapterIndex) {
    if (state.hasValue && state.value != null) {
      final book = state.value!;
      final updatedBook = BookStructure(
        id: book.id,
        title: book.title,
        author: book.author,
        description: book.description,
        created_at: book.created_at,
        chapters: book.chapters,
        total_chapters: book.total_chapters,
        current_chapter: chapterIndex,
      );
      state = AsyncValue.data(updatedBook);
    }
  }
}

// Broadcast provider
final broadcastProvider = StateNotifierProvider<BroadcastNotifier, AsyncValue<BroadcastResponse?>>((ref) {
  return BroadcastNotifier();
});

class BroadcastNotifier extends StateNotifier<AsyncValue<BroadcastResponse?>> {
  BroadcastNotifier() : super(const AsyncValue.data(null));

  Future<void> broadcastEvent(String eventId, List<String> relayUrls) async {
    state = const AsyncValue.loading();
    try {
      final response = await RustService.broadcastEvent(eventId, relayUrls);
      final broadcastResponse = BroadcastResponse.fromJson(response);
      state = AsyncValue.data(broadcastResponse);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void clearResponse() {
    state = const AsyncValue.data(null);
  }
}

// Relay stats provider
final relayStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await RustService.getRelayStats();
});

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  SettingsNotifier() : super({
    'theme': 'system',
    'notifications': true,
    'biometric_auth': false,
    'auto_broadcast': false,
    'default_relays': <String>[],
  });

  void updateSetting(String key, dynamic value) {
    state = {...state, key: value};
  }

  void updateSettings(Map<String, dynamic> newSettings) {
    state = {...state, ...newSettings};
  }
}

// Router provider
class BooksNotifier extends StateNotifier<AsyncValue<List<BookStructure>>> {
  BooksNotifier() : super(const AsyncValue.loading()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    if (state.isLoading) return; // Prevent multiple simultaneous loads
    
    state = const AsyncValue.loading();
    try {
      // Load books from Rust backend
      // For now, return sample data with realistic book structures
      await Future.delayed(const Duration(seconds: 1));
      final books = List.generate(10, (index) => BookStructure(
        id: 'book-$index',
        title: 'Sample Book ${index + 1}',
        author: 'Author ${index + 1}',
        description: 'This is a sample book description for book ${index + 1}.',
        created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        chapters: [],
        total_chapters: 0,
        current_chapter: 0,
      ));
      state = AsyncValue.data(books);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadBooks();
  }
}


