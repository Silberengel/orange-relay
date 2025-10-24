import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
      // Don't rethrow - let the app continue
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap
  }

  /// Show broadcast success notification
  static Future<void> showBroadcastSuccess({
    required String eventId,
    required int successCount,
    required int totalCount,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'broadcast_channel',
      'Broadcast Notifications',
      channelDescription: 'Notifications for event broadcasting',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      eventId.hashCode,
      'Broadcast Successful',
      'Event broadcasted to $successCount/$totalCount relays',
      details,
      payload: 'broadcast_success:$eventId',
    );
  }

  /// Show broadcast failure notification
  static Future<void> showBroadcastFailure({
    required String eventId,
    required String error,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'broadcast_channel',
      'Broadcast Notifications',
      channelDescription: 'Notifications for event broadcasting',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      eventId.hashCode,
      'Broadcast Failed',
      error,
      details,
      payload: 'broadcast_failure:$eventId',
    );
  }

  /// Show new event notification
  static Future<void> showNewEvent({
    required String author,
    required String content,
    required String eventId,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'events_channel',
      'New Events',
      channelDescription: 'Notifications for new events',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      eventId.hashCode,
      'New Event from $author',
      content.length > 100 ? '${content.substring(0, 100)}...' : content,
      details,
      payload: 'new_event:$eventId',
    );
  }

  /// Show book reading progress notification
  static Future<void> showBookProgress({
    required String bookTitle,
    required int currentChapter,
    required int totalChapters,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'books_channel',
      'Book Reading',
      channelDescription: 'Notifications for book reading progress',
      importance: Importance.low,
      priority: Priority.low,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      bookTitle.hashCode,
      'Reading Progress',
      '$bookTitle: Chapter $currentChapter/$totalChapters',
      details,
      payload: 'book_progress:$bookTitle',
    );
  }
}
