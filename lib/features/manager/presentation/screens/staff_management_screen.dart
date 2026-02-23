import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We would typically watch a staffListProvider here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Management'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.userPlus()),
            onPressed: () {
              // Add new staff member
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Mock data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Text('EM'), // Initials placeholder
              ),
              title: Text(
                'Staff Member ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Bartender • £12.50/hr'),
              trailing: Chip(
                label: const Text('Active'),
                backgroundColor: Colors.green.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}
