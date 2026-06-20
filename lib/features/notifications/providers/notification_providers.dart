import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/firestore_providers.dart';
import '../models/notification_model.dart';

/// Converts the raw map-based `notificationsStreamProvider` into typed
/// `NotificationModel` objects for screens that prefer the typed API.
final notificationsProvider = Provider.autoDispose<List<NotificationModel>>((ref) {
  final raw = ref.watch(notificationsStreamProvider).valueOrNull ?? [];
  return raw.map((map) {
    // Build a lightweight DocumentSnapshot-like conversion
    return NotificationModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      isRead: map['read'] as bool? ?? map['isRead'] as bool? ?? false,
      createdAt: _extractDateTime(map['createdAt']),
      payload: map['payload'] as Map<String, dynamic>? ?? {},
    );
  }).toList();
});

DateTime _extractDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  // Firestore Timestamp
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return DateTime.now();
  }
}

// Re-export unreadNotificationsCountProvider from the single source of truth
// so existing imports still work.  The canonical definition lives in
// shared/providers/firestore_providers.dart.
