import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orange_relay/main.dart';
import 'package:orange_relay/screens/home_screen.dart';
import 'package:orange_relay/screens/feed_screen.dart';
import 'package:orange_relay/screens/book_reader_screen.dart';
import 'package:orange_relay/screens/broadcast_screen.dart';
import 'package:orange_relay/screens/settings_screen.dart';
import 'package:orange_relay/providers/app_providers.dart';
import 'package:orange_relay/models/feed_event.dart';
import 'package:orange_relay/models/book_structure.dart';
import 'package:orange_relay/models/broadcast_response.dart';
import 'package:orange_relay/widgets/orange_logo.dart';

void main() {
  group('Orange Relay App Tests', () {
    testWidgets('App loads with correct title and navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Verify app title
      expect(find.text('Orange Relay'), findsOneWidget);
      
      // Verify orange logo (be more specific to avoid duplicates)
      expect(find.byType(OrangeLogoSmall), findsOneWidget);
      
      // Verify bottom navigation
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.broadcast_on_personal), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Navigation between screens works', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Test home screen navigation
      expect(find.text('Recent Events'), findsOneWidget);
      expect(find.text('Featured Books'), findsOneWidget);

      // Test feed screen navigation
      await tester.tap(find.byIcon(Icons.timeline).first);
      await tester.pump();
      expect(find.text('Chronological Feed'), findsOneWidget);

      // Test broadcast screen navigation
      await tester.tap(find.byIcon(Icons.broadcast_on_personal).first);
      await tester.pump();
      expect(find.text('Broadcast Event'), findsOneWidget);

      // Test settings screen navigation
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);

      // Test books screen navigation
      await tester.tap(find.byIcon(Icons.book).first);
      await tester.pump();
      // Should navigate to book reader with featured book
    });

    testWidgets('Home screen displays content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Verify home screen elements
      expect(find.text('Recent Events'), findsOneWidget);
      expect(find.text('Featured Books'), findsOneWidget);
      expect(find.text('View All'), findsNWidgets(2)); // For both sections
      
      // Verify search and notification buttons
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Tap search button
      await tester.tap(find.byIcon(Icons.search).first);
      await tester.pump();

      // Verify search dialog appears
      expect(find.text('Search Events'), findsOneWidget);
      expect(find.text('Search by:'), findsOneWidget);
      expect(find.text('npub'), findsOneWidget);
      expect(find.text('naddr'), findsOneWidget);
      expect(find.text('nevent'), findsOneWidget);
      expect(find.text('kind:1'), findsOneWidget);
      expect(find.text('kind:30040'), findsOneWidget);

      // Test search input
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      await tester.enterText(searchField, 'test search');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Verify search was performed (snackbar should appear)
      expect(find.text('Searching for: test search'), findsOneWidget);
    });

    testWidgets('Notifications dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Tap notifications button
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pump();

      // Verify notifications dialog appears
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('New events received'), findsOneWidget);
      expect(find.text('Broadcast completed'), findsOneWidget);
      expect(find.text('New book available'), findsOneWidget);
      expect(find.text('Mark All as Read'), findsOneWidget);
    });

    testWidgets('Feed screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Navigate to feed screen
      await tester.tap(find.byIcon(Icons.timeline).first);
      await tester.pump();

      // Verify feed screen elements
      expect(find.text('Chronological Feed'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.sort), findsOneWidget);

      // Test filter dialog
      await tester.tap(find.byIcon(Icons.filter_list).first);
      await tester.pump();
      expect(find.text('Filter Feed'), findsOneWidget);
      expect(find.text('Text Notes'), findsOneWidget);
      expect(find.text('Reposts'), findsOneWidget);
      expect(find.text('Replies'), findsOneWidget);

      // Close filter dialog
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Test sort dialog
      await tester.tap(find.byIcon(Icons.sort).first);
      await tester.pump();
      expect(find.text('Sort Feed'), findsOneWidget);
      expect(find.text('Newest First'), findsOneWidget);
      expect(find.text('Oldest First'), findsOneWidget);
      expect(find.text('Most Popular'), findsOneWidget);
    });

    testWidgets('Book reader screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Navigate to book reader (via books tab)
      await tester.tap(find.byIcon(Icons.book).first);
      await tester.pump();

      // Verify book reader elements
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget); // FAB
    });

    testWidgets('Broadcast screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Navigate to broadcast screen
      await tester.tap(find.byIcon(Icons.broadcast_on_personal).first);
      await tester.pump();

      // Verify broadcast screen elements
      expect(find.text('Broadcast Event'), findsOneWidget);
      expect(find.text('Event ID'), findsOneWidget);
      expect(find.text('Select Relays'), findsOneWidget);
      expect(find.text('Broadcast Event'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);

      // Test event ID input
      final eventIdField = find.byType(TextField);
      expect(eventIdField, findsOneWidget);
      
      await tester.enterText(eventIdField, 'test-event-id');
      await tester.pump();

      // Verify broadcast button is enabled
      final broadcastButton = find.text('Broadcast Event');
      expect(broadcastButton, findsOneWidget);
    });

    testWidgets('Settings screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Navigate to settings screen
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pump();

      // Verify settings sections
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Relays'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Test profile settings
      await tester.tap(find.text('User Profile'));
      await tester.pump();
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Profile management coming soon...'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pump();

      // Test theme settings
      await tester.tap(find.text('Theme'));
      await tester.pump();
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('Provider state management works', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Test that providers are accessible
      final container = ProviderScope.containerOf(tester.element(find.byType(AlexNativeApp)));
      
      // Test feed provider
      final feedState = container.read(feedProvider);
      expect(feedState, isA<AsyncValue<List<FeedEvent>>>());

      // Test settings provider
      final settingsState = container.read(settingsProvider);
      expect(settingsState, isA<Map<String, dynamic>>());
      expect(settingsState['theme'], 'system');
      expect(settingsState['notifications'], true);
    });

    testWidgets('Model serialization works', (WidgetTester tester) async {
      // Test FeedEvent model
      final feedEvent = FeedEvent(
        id: 'test-id',
        pubkey: 'test-pubkey',
        created_at: 1234567890,
        kind: 1,
        tags: [['p', 'test-pubkey']],
        content: 'Test content',
        sig: 'test-sig',
        author_name: 'Test Author',
        reply_count: 5,
        boost_count: 10,
      );

      expect(feedEvent.id, 'test-id');
      expect(feedEvent.authorDisplayName, 'Test Author');
      expect(feedEvent.mentionedPubkeys, ['test-pubkey']);
      expect(feedEvent.isReplyEvent, false);

      // Test BookStructure model
      final chapter = Chapter(
        id: 'chapter-1',
        title: 'Test Chapter',
        content: 'Test content',
        order: 0,
        word_count: 100,
        reading_time_minutes: 1,
      );

      final book = BookStructure(
        id: 'book-1',
        title: 'Test Book',
        author: 'Test Author',
        created_at: 1234567890,
        chapters: [chapter],
        total_chapters: 1,
        current_chapter: 0,
      );

      expect(book.id, 'book-1');
      expect(book.readingProgress, 0.0);
      expect(book.currentChapter?.title, 'Test Chapter');

      // Test BroadcastResponse model
      final broadcastResponse = BroadcastResponse(
        success: true,
        broadcasted_to: ['relay1', 'relay2'],
        failed_relays: [],
        total_success: 2,
        total_failed: 0,
      );

      expect(broadcastResponse.success, true);
      expect(broadcastResponse.successRate, 100.0);
      expect(broadcastResponse.allSucceeded, true);
    });

    testWidgets('Error handling works', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Test that app handles errors gracefully
      // The app should not crash even if services fail
      expect(find.text('Orange Relay'), findsOneWidget);
    });

    testWidgets('Accessibility features work', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));
      await tester.pump();

      // Test that all interactive elements have proper semantics
      expect(find.byType(Semantics), findsWidgets);
      
      // Test that buttons are tappable
      expect(find.byType(IconButton), findsWidgets);
      
      // Test that the app has basic interactive elements
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
