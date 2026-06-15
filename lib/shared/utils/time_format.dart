import 'package:cloud_firestore/cloud_firestore.dart';

/// Formats a date or timestamp as a relative time string (e.g. "5m ago").
/// Supports [Timestamp], [DateTime], and ISO 8601 [String] types.
String formatTimeAgo(dynamic input) {
  if (input == null) return '';

  DateTime date;
  if (input is Timestamp) {
    date = input.toDate();
  } else if (input is DateTime) {
    date = input;
  } else if (input is String) {
    try {
      date = DateTime.parse(input);
    } catch (_) {
      return '';
    }
  } else {
    return '';
  }

  final diff = DateTime.now().difference(date);
  if (diff.isNegative || diff.inSeconds < 60) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 30) {
    return '${diff.inDays}d ago';
  }
  final months = (diff.inDays / 30).floor();
  if (months < 12) {
    return '${months}mo ago';
  }
  final years = (diff.inDays / 365).floor();
  return '${years}y ago';
}
