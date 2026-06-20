import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'new_content', 'current_affairs', 'test_reminder', 'achievement', 'general'
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.payload = const {},
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      isRead: data['read'] ?? data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      payload: data['payload'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'read': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'payload': payload,
    };
  }
}
