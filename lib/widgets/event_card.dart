import 'package:flutter/material.dart';
import '../models/feed_event.dart';

class EventCard extends StatelessWidget {
  final FeedEvent event;
  final VoidCallback? onReply;
  final VoidCallback? onBoost;
  final VoidCallback? onBroadcast;

  const EventCard({
    super.key,
    required this.event,
    this.onReply,
    this.onBoost,
    this.onBroadcast,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: event.author_picture != null
                      ? NetworkImage(event.author_picture!)
                      : null,
                  child: event.author_picture == null
                      ? Text(event.authorDisplayName.substring(0, 1).toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.authorDisplayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.author_about != null)
                        Text(
                          event.author_about!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  event.relativeTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Event content
            if (event.content.isNotEmpty)
              Text(
                event.content,
                style: const TextStyle(fontSize: 16),
              ),

            // Media content
            if (event.hasMedia)
              ...event.mediaUrls.map((url) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      );
                    },
                  ),
                ),
              )),

            // Hashtags
            if (event.hashtags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 4,
                  children: event.hashtags.map((tag) => Chip(
                    label: Text('#$tag'),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
              ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: onReply,
                  tooltip: 'Reply',
                ),
                Text('${event.reply_count}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: onBoost,
                  tooltip: 'Boost',
                ),
                Text('${event.boost_count}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.broadcast_on_personal),
                  onPressed: onBroadcast,
                  tooltip: 'Broadcast',
                ),
                if (event.external_viewer_url != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      // TODO: Open external viewer
                    },
                    tooltip: 'Open in external viewer',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
