import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/app_providers.dart';
import '../widgets/event_card.dart';
import '../models/feed_event.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more events when 80% scrolled
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    // Load more events with pagination
    await ref.read(feedProvider.notifier).loadMore();
    _loadController.loadComplete();
  }

  Future<void> _onRefresh() async {
    await ref.read(feedProvider.notifier).refresh();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronological Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _loadMore,
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: const ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
        ),
        child: feedAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No events in feed',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Pull down to refresh',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: EventCard(
                    event: event,
                    onReply: () => _showReplyDialog(event),
                    onBoost: () => _boostEvent(event),
                    onBroadcast: () => _broadcastEvent(event),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading feed',
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
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Feed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Text Notes'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Reposts'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Replies'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Feed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Newest First'),
              value: 'newest',
              groupValue: 'newest',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Oldest First'),
              value: 'oldest',
              groupValue: 'newest',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Most Popular'),
              value: 'popular',
              groupValue: 'newest',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(FeedEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Event'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _replyToEvent(event);
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  void _boostEvent(FeedEvent event) {
    // Create a boost event (kind 6)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Boosting event ${event.id}...'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _navigateToEvent(event.id);
          },
        ),
      ),
    );
  }

  void _broadcastEvent(FeedEvent event) {
    // Navigate to broadcast screen with event pre-selected
    context.go('/broadcast?eventId=${event.id}');
  }

  void _replyToEvent(FeedEvent event) {
    // Show reply dialog
    final TextEditingController replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Event'),
        content: TextField(
          controller: replyController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _publishReply(event, replyController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  void _publishReply(FeedEvent event, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Publishing reply to ${event.id}...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navigateToEvent(String eventId) {
    // Navigate to event details or show in feed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing event: $eventId'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
