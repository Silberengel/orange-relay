import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../widgets/event_card.dart';
import '../widgets/book_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/orange_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const OrangeLogoSmall(),
            const SizedBox(width: 8),
            const Text('Orange Relay'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(feedProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: QuickActions(),
              ),
            ),

            // Recent Events Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/feed'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Feed Events
            feedAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const OrangeLogo(size: 64),
                            SizedBox(height: 16),
                            Text(
                              'No events yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Connect to relays to see events',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= events.length) return null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: EventCard(event: events[index]),
                      );
                    },
                    childCount: events.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading events',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[700],
                          ),
                        ),
                        Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(feedProvider.notifier).refresh();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Featured Books Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Books',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/book/featured'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Books Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Load books from the database
                    ref.read(booksProvider.notifier).loadBooks();
                    return BookCard(
                      title: 'Sample Book ${index + 1}',
                      author: 'Author ${index + 1}',
                      coverUrl: null,
                      onTap: () => context.go('/book/sample-${index + 1}'),
                    );
                  },
                  childCount: 4, // Show 4 sample books
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by npub, naddr, nevent, content...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (query) {
                Navigator.of(context).pop();
                _performSearch(context, query);
              },
            ),
            const SizedBox(height: 16),
            const Text('Search by:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildSearchChip('npub', () => _performSearch(context, 'npub:')),
                _buildSearchChip('naddr', () => _performSearch(context, 'naddr:')),
                _buildSearchChip('nevent', () => _performSearch(context, 'nevent:')),
                _buildSearchChip('kind:1', () => _performSearch(context, 'kind:1')),
                _buildSearchChip('kind:30040', () => _performSearch(context, 'kind:30040')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.orange.shade100,
    );
  }

  void _performSearch(BuildContext context, String query) {
    // Navigate to search results or filter current feed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $query'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Implement search functionality
    _executeSearch(context, query);
  }

  void _executeSearch(BuildContext context, String query) {
    // Filter events based on search query
    if (query.startsWith('npub:')) {
      _searchByNpub(context, query.substring(5));
    } else if (query.startsWith('naddr:')) {
      _searchByNaddr(context, query.substring(6));
    } else if (query.startsWith('nevent:')) {
      _searchByNevent(context, query.substring(7));
    } else if (query.startsWith('kind:')) {
      _searchByKind(context, query.substring(5));
    } else {
      _searchByContent(context, query);
    }
  }

  void _searchByNpub(BuildContext context, String npub) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for npub: $npub'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _searchByNaddr(BuildContext context, String naddr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for naddr: $naddr'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _searchByNevent(BuildContext context, String nevent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for nevent: $nevent'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _searchByKind(BuildContext context, String kind) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for kind: $kind'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _searchByContent(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for content: $content'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.orange),
              title: const Text('New events received'),
              subtitle: const Text('5 new events in your feed'),
              trailing: const Text('2m ago'),
            ),
            ListTile(
              leading: const Icon(Icons.broadcast_on_personal, color: Colors.orange),
              title: const Text('Broadcast completed'),
              subtitle: const Text('Event published to 3 relays'),
              trailing: const Text('5m ago'),
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.orange),
              title: const Text('New book available'),
              subtitle: const Text('"Nostr Protocol Guide" by npub1...'),
              trailing: const Text('1h ago'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark All as Read'),
            ),
          ],
        ),
      ),
    );
  }
}
