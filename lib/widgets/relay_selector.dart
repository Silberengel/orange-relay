import 'package:flutter/material.dart';

class RelaySelector extends StatefulWidget {
  final List<String> selectedRelays;
  final Function(List<String>) onRelaysChanged;

  const RelaySelector({
    super.key,
    required this.selectedRelays,
    required this.onRelaysChanged,
  });

  @override
  State<RelaySelector> createState() => _RelaySelectorState();
}

class _RelaySelectorState extends State<RelaySelector> {
  final TextEditingController _relayController = TextEditingController();

  @override
  void dispose() {
    _relayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Relays',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _relayController,
                decoration: const InputDecoration(
                  hintText: 'wss://relay.example.com',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addRelay,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (widget.selectedRelays.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedRelays.map((relay) => Chip(
              label: Text(relay),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _removeRelay(relay),
            )).toList(),
          ),
        ],
      ],
    );
  }

  void _addRelay() {
    final relay = _relayController.text.trim();
    if (relay.isNotEmpty && !widget.selectedRelays.contains(relay)) {
      final newRelays = [...widget.selectedRelays, relay];
      widget.onRelaysChanged(newRelays);
      _relayController.clear();
    }
  }

  void _removeRelay(String relay) {
    final newRelays = widget.selectedRelays.where((r) => r != relay).toList();
    widget.onRelaysChanged(newRelays);
  }
}
