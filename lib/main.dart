import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/home_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/book_reader_screen.dart';
import 'screens/broadcast_screen.dart';
import 'screens/settings_screen.dart';
import 'services/rust_service.dart';
import 'services/notification_service.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await RustService.initialize();
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: AlexNativeApp(),
    ),
  );
}

class AlexNativeApp extends ConsumerWidget {
  const AlexNativeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Orange Relay',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/feed',
            name: 'feed',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/book/:bookId',
            name: 'book',
            builder: (context, state) {
              final bookId = state.pathParameters['bookId']!;
              return BookReaderScreen(bookId: bookId);
            },
          ),
          GoRoute(
            path: '/broadcast',
            name: 'broadcast',
            builder: (context, state) => const BroadcastScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// Main navigation shell with bottom navigation
class MainNavigationShell extends ConsumerWidget {
  final Widget child;
  
  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.broadcast_on_personal),
            label: 'Broadcast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/feed')) return 1;
    if (location.startsWith('/book')) return 2;
    if (location.startsWith('/broadcast')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/feed');
        break;
      case 2:
        context.go('/book/featured');
        break;
      case 3:
        context.go('/broadcast');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}