import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/features/notifications.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationServiceProvider).markAllAsRead(uid);
            },
            child: const Text('Read all'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];

              final id = item['id'] as String;

              final title = item['title'] ?? 'Notification';

              final body = item['body'] ?? '';

              final read = item['read'] ?? false;

              return _NotificationCard(
                id: id,
                title: title,
                body: body,
                read: read,
                uid: uid,
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.uid,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Icon(read ? Icons.notifications_none : Icons.notifications),
        title: Text(
          title.toString(),
          style: TextStyle(
            fontWeight: read ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body.toString()),
        ),
        trailing: read ? null : const CircleAvatar(radius: 5),
        onTap: () {
          if (!read) {
            ref.read(notificationServiceProvider).markAsRead(uid, id);
          }
        },
      ),
    );
  }
}
