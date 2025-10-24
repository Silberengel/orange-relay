// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orange_relay/main.dart';

void main() {
  testWidgets('Orange Relay app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AlexNativeApp()));

    // Just pump once to avoid async timer issues
    await tester.pump();

    // Verify that the app loads with Orange Relay title
    expect(find.text('Orange Relay'), findsOneWidget);
    
    // Verify that the orange logo is present
    expect(find.byIcon(Icons.local_drink), findsOneWidget);
  });
}
