import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// Rust FFI bindings
typedef InitializeRustNative = Int32 Function();
typedef InitializeRustNativeDart = int Function();

typedef GetFeedEventsNative = Pointer<Utf8> Function(Int32 limit);
typedef GetFeedEventsNativeDart = Pointer<Utf8> Function(int limit);

typedef GetBookStructureNative = Pointer<Utf8> Function(Pointer<Utf8> bookId);
typedef GetBookStructureNativeDart = Pointer<Utf8> Function(Pointer<Utf8> bookId);

typedef BroadcastEventNative = Pointer<Utf8> Function(Pointer<Utf8> eventId, Pointer<Utf8> relays);
typedef BroadcastEventNativeDart = Pointer<Utf8> Function(Pointer<Utf8> eventId, Pointer<Utf8> relays);

typedef GetRelayStatsNative = Pointer<Utf8> Function();
typedef GetRelayStatsNativeDart = Pointer<Utf8> Function();

class RustService {
  static DynamicLibrary? _dylib;
  static late InitializeRustNativeDart _initializeRust;
  static late GetFeedEventsNativeDart _getFeedEvents;
  static late GetBookStructureNativeDart _getBookStructure;
  static late BroadcastEventNativeDart _broadcastEvent;
  static late GetRelayStatsNativeDart _getRelayStats;

  static Future<void> initialize() async {
    try {
      if (Platform.isAndroid) {
        _dylib = DynamicLibrary.open('libalex_native.so');
      } else if (Platform.isIOS) {
        _dylib = DynamicLibrary.process();
      } else {
        throw UnsupportedError('Platform not supported');
      }

      _initializeRust = _dylib!
          .lookup<NativeFunction<InitializeRustNative>>('initialize_rust')
          .asFunction();
      
      _getFeedEvents = _dylib!
          .lookup<NativeFunction<GetFeedEventsNative>>('get_feed_events')
          .asFunction();
      
      _getBookStructure = _dylib!
          .lookup<NativeFunction<GetBookStructureNative>>('get_book_structure')
          .asFunction();
      
      _broadcastEvent = _dylib!
          .lookup<NativeFunction<BroadcastEventNative>>('broadcast_event')
          .asFunction();
      
      _getRelayStats = _dylib!
          .lookup<NativeFunction<GetRelayStatsNative>>('get_relay_stats')
          .asFunction();

      // Initialize Rust backend
      final result = _initializeRust();
      if (result != 0) {
        throw Exception('Failed to initialize Rust backend');
      }

      debugPrint('Rust service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Rust service: $e');
      rethrow;
    }
  }

  /// Get chronological feed events
  static Future<List<Map<String, dynamic>>> getFeedEvents({int limit = 100}) async {
    try {
      final result = _getFeedEvents(limit);
      final jsonString = result.toDartString();
      free(result);
      
      if (jsonString.isEmpty) {
        return [];
      }
      
      // Parse JSON response
      final List<dynamic> jsonList = jsonString.split('\n')
          .where((line) => line.isNotEmpty)
          .map((line) => line.trim())
          .toList();
      
      return jsonList.map((json) => Map<String, dynamic>.from(json)).toList();
    } catch (e) {
      debugPrint('Error getting feed events: $e');
      return [];
    }
  }

  /// Get book structure for reading
  static Future<Map<String, dynamic>?> getBookStructure(String bookId) async {
    try {
      final bookIdPtr = bookId.toNativeUtf8();
      final result = _getBookStructure(bookIdPtr);
      free(bookIdPtr);
      
      final jsonString = result.toDartString();
      free(result);
      
      if (jsonString.isEmpty) {
        return null;
      }
      
      return Map<String, dynamic>.from(jsonString);
    } catch (e) {
      debugPrint('Error getting book structure: $e');
      return null;
    }
  }

  /// Broadcast event to relays
  static Future<Map<String, dynamic>> broadcastEvent(
    String eventId,
    List<String> relayUrls,
  ) async {
    try {
      final eventIdPtr = eventId.toNativeUtf8();
      final relaysJson = relayUrls.join(',');
      final relaysPtr = relaysJson.toNativeUtf8();
      
      final result = _broadcastEvent(eventIdPtr, relaysPtr);
      free(eventIdPtr);
      free(relaysPtr);
      
      final jsonString = result.toDartString();
      free(result);
      
      return Map<String, dynamic>.from(jsonString);
    } catch (e) {
      debugPrint('Error broadcasting event: $e');
      return {
        'success': false,
        'error': e.toString(),
        'broadcasted_to': <String>[],
        'failed_relays': <String>[],
      };
    }
  }

  /// Get relay statistics
  static Future<Map<String, dynamic>> getRelayStats() async {
    try {
      final result = _getRelayStats();
      final jsonString = result.toDartString();
      free(result);
      
      if (jsonString.isEmpty) {
        return {};
      }
      
      return Map<String, dynamic>.from(jsonString);
    } catch (e) {
      debugPrint('Error getting relay stats: $e');
      return {};
    }
  }
}
