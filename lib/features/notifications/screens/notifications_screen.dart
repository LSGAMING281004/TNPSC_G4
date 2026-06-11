import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAllAsRead(WidgetRef ref, String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _deleteNotification(String uid, String notificationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> _markAsRead(String uid, String notificationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final uid = ref.watch(currentUserProvider)?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (uid != null)
            TextButton(
              onPressed: () => _markAllAsRead(ref, uid),
              child: const Text('Mark all read', style: TextStyle(color: AppColors.accentSaffron, fontSize: 12)),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron)),
        error: (_, __) => const Center(child: Text('Error loading notifications', style: TextStyle(color: Colors.grey))),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
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
                  if (uid != null) _deleteNotification(uid, n.id);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: n.isRead ? Colors.transparent : AppColors.accentSaffron.withValues(alpha: 0.05),
                  leading: CircleAvatar(
                    backgroundColor: n.isRead ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200) : AppColors.accentSaffron.withValues(alpha: 0.2),
                    child: Icon(
                      _getIconForType(n.type),
                      color: n.isRead ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600) : AppColors.accentSaffron,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                      color: n.isRead ? (isDark ? Colors.grey.shade400 : Colors.grey.shade800) : (isDark ? Colors.white : Colors.black),
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(n.body, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(n.createdAt),
                        style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 10),
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
                    if (uid != null && !n.isRead) _markAsRead(uid, n.id);
                  },
                ),
              );
            },
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
