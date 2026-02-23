import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ShiftSwapsScreen extends ConsumerWidget {
  const ShiftSwapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app we'd fetch pending swaps via a provider
    return Scaffold(
      appBar: AppBar(title: const Text('Shift Swaps')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Mock data
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Text('JG',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          const Text('John G.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, size: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: const Text('SM',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          const Text('Sarah M.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shift Details',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEE, MMM d • 09:00 - 17:00').format(
                                DateTime.now().add(Duration(days: index + 1))),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Chip(
                        label: const Text('Pending'),
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.orange),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Decline logic
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Approve logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
