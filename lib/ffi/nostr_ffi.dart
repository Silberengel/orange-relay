import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI bindings for the Rust Nostr backend
class NostrFFI {
  static late DynamicLibrary _lib;
  static bool _initialized = false;

  /// Initialize the FFI library
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('liborange_relay_backend.so');
      } else if (Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else if (Platform.isLinux) {
        _lib = DynamicLibrary.open('liborange_relay_backend.so');
      } else if (Platform.isWindows) {
        _lib = DynamicLibrary.open('orange_relay_backend.dll');
      } else if (Platform.isMacOS) {
        _lib = DynamicLibrary.open('liborange_relay_backend.dylib');
      } else {
        throw UnsupportedError('Platform not supported');
      }

      _initialized = true;
    } catch (e) {
      print('Failed to load FFI library: $e');
      // Fall back to mock implementation
      _initialized = false;
    }
  }

  /// Initialize the Nostr client
  static Future<Map<String, dynamic>> initializeNostrClient() async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final initializeFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('initialize_nostr_client');

      final resultPtr = initializeFunc();
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      freeString(resultPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to initialize Nostr client: $e'
      };
    }
  }

  /// Get feed events from relays
  static Future<Map<String, dynamic>> getFeedEvents({int limit = 100}) async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final getEventsFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(Int32),
          Pointer<Utf8> Function(int)>('get_feed_events');

      final resultPtr = getEventsFunc(limit);
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      freeString(resultPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get feed events: $e'
      };
    }
  }

  /// Get chronological feed
  static Future<Map<String, dynamic>> getChronologicalFeed({int limit = 100}) async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final getChronologicalFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(Int32),
          Pointer<Utf8> Function(int)>('get_chronological_feed');

      final resultPtr = getChronologicalFunc(limit);
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      freeString(resultPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get chronological feed: $e'
      };
    }
  }

  /// Broadcast event to relays
  static Future<Map<String, dynamic>> broadcastEvent(
    String eventId,
    List<String> relayUrls,
  ) async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final broadcastFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>)>('broadcast_event');

      final eventIdPtr = eventId.toNativeUtf8();
      final relayUrlsJson = Uri.splitQueryString(
        Uri.encodeComponent(relayUrls.join(','))
      );
      final relayUrlsPtr = relayUrlsJson.toString().toNativeUtf8();

      final resultPtr = broadcastFunc(eventIdPtr, relayUrlsPtr);
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      
      freeString(resultPtr);
      malloc.free(eventIdPtr);
      malloc.free(relayUrlsPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to broadcast event: $e'
      };
    }
  }

  /// Get broadcast history
  static Future<Map<String, dynamic>> getBroadcastHistory() async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final getHistoryFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('get_broadcast_history');

      final resultPtr = getHistoryFunc();
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      freeString(resultPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get broadcast history: $e'
      };
    }
  }

  /// Get relay statistics
  static Future<Map<String, dynamic>> getRelayStats() async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final getStatsFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('get_relay_stats');

      final resultPtr = getStatsFunc();
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      freeString(resultPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get relay stats: $e'
      };
    }
  }

  /// Get default write relays
  static Future<Map<String, dynamic>> getDefaultWriteRelays() async {
    if (!_initialized) {
      return {
        'success': false,
        'error': 'FFI not initialized'
      };
    }

    try {
      final getWriteRelaysFunc = _lib.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('get_default_write_relays');

      final resultPtr = getWriteRelaysFunc();
      final resultStr = resultPtr.cast<Utf8>().toDartString();
      freeString(resultPtr);

      return Map<String, dynamic>.from(
        Uri.splitQueryString(resultStr)
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get default write relays: $e'
      };
    }
  }

  /// Free memory allocated by Rust
  static void freeString(Pointer<Utf8> ptr) {
    if (!ptr.isNull) {
      final freeFunc = _lib.lookupFunction<
          Void Function(Pointer<Utf8>),
          void Function(Pointer<Utf8>)>('free_string');
      freeFunc(ptr);
    }
  }
}
