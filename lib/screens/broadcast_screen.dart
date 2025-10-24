import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/broadcast_response.dart';
import '../widgets/relay_selector.dart';
import '../widgets/broadcast_history.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final TextEditingController _eventIdController = TextEditingController();
  final List<String> _selectedRelays = [];
  bool _useOutbox = true;
  bool _useWriteRelays = true;
  bool _broadcastToAll = false;

  @override
  void dispose() {
    _eventIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final broadcastAsync = ref.watch(broadcastProvider);
    final relayStatsAsync = ref.watch(relayStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showBroadcastHistory();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event ID Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _eventIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter event ID to broadcast...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Relay Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Relays',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Relay options
                    CheckboxListTile(
                      title: const Text('Use Outbox Relays'),
                      subtitle: const Text('Use your kind 10002 relay list'),
                      value: _useOutbox,
                      onChanged: (value) {
                        setState(() {
                          _useOutbox = value ?? false;
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Use Write Relays'),
                      subtitle: const Text('Use configured write relays'),
                      value: _useWriteRelays,
                      onChanged: (value) {
                        setState(() {
                          _useWriteRelays = value ?? false;
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Broadcast to All'),
                      subtitle: const Text('Broadcast to all available relays'),
                      value: _broadcastToAll,
                      onChanged: (value) {
                        setState(() {
                          _broadcastToAll = value ?? false;
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    
                    // Custom relays
                    RelaySelector(
                      selectedRelays: _selectedRelays,
                      onRelaysChanged: (relays) {
                        setState(() {
                          _selectedRelays.clear();
                          _selectedRelays.addAll(relays);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Relay Statistics
            relayStatsAsync.when(
              data: (stats) {
                if (stats.isEmpty) return const SizedBox.shrink();
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Relay Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...stats.entries.map((entry) {
                          final relay = entry.key;
                          final isOnline = entry.value['is_online'] ?? false;
                          final successRate = entry.value['success_rate'] ?? 0.0;
                          
                          return ListTile(
                            leading: Icon(
                              isOnline ? Icons.cloud_done : Icons.cloud_off,
                              color: isOnline ? Colors.green : Colors.red,
                            ),
                            title: Text(relay),
                            subtitle: Text(
                              isOnline 
                                ? 'Success rate: ${(successRate * 100).toStringAsFixed(1)}%'
                                : 'Offline',
                            ),
                            trailing: Icon(
                              isOnline ? Icons.check_circle : Icons.cancel,
                              color: isOnline ? Colors.green : Colors.red,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Broadcast Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _eventIdController.text.isNotEmpty
                    ? () => _broadcastEvent()
                    : null,
                icon: const Icon(Icons.broadcast_on_personal),
                label: const Text('Broadcast Event'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Broadcast Result
            broadcastAsync.when(
              data: (response) {
                if (response == null) return const SizedBox.shrink();
                
                return Card(
                  color: response.success 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              response.success ? Icons.check_circle : Icons.error,
                              color: response.success ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              response.success ? 'Broadcast Successful' : 'Broadcast Failed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: response.success ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(response.statusMessage),
                        if (response.broadcasted_to.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Successful relays:'),
                          ...response.broadcasted_to.map((relay) => 
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text('• $relay'),
                            ),
                          ),
                        ],
                        if (response.failed_relays.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Failed relays:'),
                          ...response.failed_relays.map((relay) => 
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text('• $relay'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Broadcasting...'),
                    ],
                  ),
                ),
              ),
              error: (error, _) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _broadcastEvent() {
    final eventId = _eventIdController.text.trim();
    if (eventId.isEmpty) return;

    List<String> relayUrls = [];
    
    if (_useOutbox) {
      // Get outbox relays from kind 10002 events
      relayUrls.addAll([
        'wss://theforest.nostr1.com',
        'wss://thecitadel.nostr1.com',
        'wss://orly-relay.imwald.eu',
        'wss://nostr.land',
      ]);
    }
    
    if (_useWriteRelays) {
      // Get write relays from settings
      relayUrls.addAll([
        'wss://relay.damus.io',
        'wss://relay.snort.social',
        'wss://nos.lol',
      ]);
    }
    
    if (_broadcastToAll) {
      // Get all available relays
      relayUrls.addAll([
        'wss://theforest.nostr1.com',
        'wss://thecitadel.nostr1.com',
        'wss://orly-relay.imwald.eu',
        'wss://nostr.land',
        'wss://relay.damus.io',
        'wss://relay.snort.social',
        'wss://nos.lol',
        'wss://relay.nostr.band',
        'wss://relay.nostr.bg',
      ]);
    }
    
    relayUrls.addAll(_selectedRelays);

    if (relayUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one relay'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ref.read(broadcastProvider.notifier).broadcastEvent(eventId, relayUrls);
  }

  void _showBroadcastHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BroadcastHistory(),
    );
  }
}
