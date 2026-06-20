import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAllAsRead(List<dynamic> notifications) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final n in notifications) {
      if (!(n.isRead)) {
        batch.update(
          FirebaseFirestore.instance.collection('notifications').doc(n.id),
          {'read': true},
        );
      }
    }
    await batch.commit();
  }

  Future<void> _deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> _markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(notifications),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.accentSaffron, fontSize: 12)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    _deleteNotification(n.id);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    tileColor: n.isRead ? Colors.transparent : AppColors.accentSaffron.withValues(alpha: 0.05),
                    leading: CircleAvatar(
                      backgroundColor: n.isRead
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : AppColors.accentSaffron.withValues(alpha: 0.2),
                      child: Icon(
                        _getIconForType(n.type),
                        color: n.isRead
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : AppColors.accentSaffron,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                        color: n.isRead
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(n.createdAt),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                              fontSize: 10),
                        ),
                      ],
                    ),
                    trailing: n.isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.accentSaffron, shape: BoxShape.circle),
                          ),
                    onTap: () {
                      if (!n.isRead) _markAsRead(n.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_content':
        return Icons.library_books;
      case 'current_affairs':
        return Icons.public;
      case 'test_reminder':
        return Icons.assignment;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }
}
