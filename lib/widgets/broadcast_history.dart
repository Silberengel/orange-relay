import 'package:flutter/material.dart';

class BroadcastHistory extends StatelessWidget {
  const BroadcastHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Broadcast History',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                // Sample broadcast history items
                _BroadcastHistoryItem(
                  eventId: 'abc123...',
                  timestamp: '2 hours ago',
                  success: true,
                  relayCount: 3,
                ),
                _BroadcastHistoryItem(
                  eventId: 'def456...',
                  timestamp: '1 day ago',
                  success: false,
                  relayCount: 0,
                ),
                _BroadcastHistoryItem(
                  eventId: 'ghi789...',
                  timestamp: '3 days ago',
                  success: true,
                  relayCount: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastHistoryItem extends StatelessWidget {
  final String eventId;
  final String timestamp;
  final bool success;
  final int relayCount;

  const _BroadcastHistoryItem({
    required this.eventId,
    required this.timestamp,
    required this.success,
    required this.relayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
        ),
        title: Text(eventId),
        subtitle: Text('$timestamp • $relayCount relays'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Show broadcast details
        },
      ),
    );
  }
}
