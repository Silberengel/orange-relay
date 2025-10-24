import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.edit,
                label: 'Write Note',
                onTap: () {
                  _showWriteNoteDialog(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.book,
                label: 'Read Book',
                onTap: () {
                  context.go('/books');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.broadcast_on_personal,
                label: 'Broadcast',
                onTap: () {
                  context.go('/broadcast');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showWriteNoteDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write Note'),
        content: TextField(
          controller: contentController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
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
              if (contentController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _publishNote(context, contentController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _publishNote(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Publishing note: ${content.substring(0, content.length > 50 ? 50 : content.length)}...'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _navigateToPublishedNote(content);
          },
        ),
      ),
    );
  }

  void _navigateToPublishedNote(String content) {
    // Navigate to the published note in the feed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing published note: ${content.substring(0, content.length > 30 ? 30 : content.length)}...'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
