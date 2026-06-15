import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/utils/time_format.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
              onPressed: () => _markAllRead(ref),
              child: const Text('Mark all read',
                  style: TextStyle(
                      color: AppColors.accentSaffron, fontSize: 12)))
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.accentSaffron)),
        error: (_, __) => Center(
            child: Text('Error loading notifications',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 64),
                const SizedBox(height: 12),
                Text('No notifications yet',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16)),
              ],
            ));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (_, i) {
              final n = notifications[i];
              final title = (n['title'] as String?) ?? 'Notification';
              final body = (n['body'] as String?) ?? '';
              final read = (n['read'] as bool?) ?? false;
              final status = (n['status'] as String?) ?? '';
              final timeAgo = formatTimeAgo(n['createdAt']);
              final icon = _notifIcon(n['type'] as String?);
              final color = _notifColor(n['type'] as String?);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: read
                      ? Theme.of(context).cardColor
                      : AppColors.accentSaffron.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: read
                      ? null
                      : Border.all(
                          color: AppColors.accentSaffron
                              .withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(title,
                              style: TextStyle(
                                  fontWeight:
                                      read ? FontWeight.w500 : FontWeight.w700,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(body,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(timeAgo,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                              if (status.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: status == 'Delivered'
                                          ? AppColors.success
                                              .withValues(alpha: 0.1)
                                          : AppColors.error
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(4)),
                                  child: Text(status,
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: status == 'Delivered'
                                              ? AppColors.success
                                              : AppColors.error)),
                                ),
                              ],
                            ],
                          ),
                        ])),
                    if (!read)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.accentSaffron,
                              shape: BoxShape.circle)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _markAllRead(WidgetRef ref) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  IconData _notifIcon(String? type) {
    switch (type) {
      case 'test':
        return Icons.assignment;
      case 'reminder':
        return Icons.timer;
      case 'achievement':
        return Icons.emoji_events;
      case 'current_affairs':
        return Icons.newspaper;
      case 'exam':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _notifColor(String? type) {
    switch (type) {
      case 'test':
        return AppColors.accentSaffron;
      case 'reminder':
        return AppColors.info;
      case 'achievement':
        return AppColors.warning;
      case 'current_affairs':
        return AppColors.tamilSubject;
      case 'exam':
        return AppColors.error;
      default:
        return AppColors.accentSaffron;
    }
  }
}
