import 'package:flutter/material.dart';
import '../models/feed_event.dart';

class EventCard extends StatefulWidget {
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
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
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
                  backgroundImage: widget.event.author_picture != null
                      ? NetworkImage(widget.event.author_picture!)
                      : null,
                  child: widget.event.author_picture == null
                      ? Text(widget.event.authorDisplayName.substring(0, 1).toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.authorDisplayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.event.author_about != null)
                        Text(
                          widget.event.author_about!,
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
                  widget.event.relativeTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Event content
            if (widget.event.content.isNotEmpty)
              Text(
                widget.event.content,
                style: const TextStyle(fontSize: 16),
              ),

            // Media content
            if (widget.event.hasMedia)
              ...widget.event.mediaUrls.map((url) => Padding(
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
            if (widget.event.hashtags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 4,
                  children: widget.event.hashtags.map((tag) => Chip(
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
                  onPressed: widget.onReply,
                  tooltip: 'Reply',
                ),
                Text('${widget.event.reply_count}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: widget.onBoost,
                  tooltip: 'Boost',
                ),
                Text('${widget.event.boost_count}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.broadcast_on_personal),
                  onPressed: widget.onBroadcast,
                  tooltip: 'Broadcast',
                ),
                if (widget.event.external_viewer_url != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      _openExternalViewer(context, widget.event.external_viewer_url!);
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

  void _openExternalViewer(BuildContext context, String url) {
    // Open external viewer URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Viewer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This would open the external viewer:'),
            const SizedBox(height: 8),
            SelectableText(
              url,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchUrl(url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) {
    // In a real implementation, this would use url_launcher
    // For now, show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening external viewer: $url'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
