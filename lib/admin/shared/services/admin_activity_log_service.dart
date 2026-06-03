import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/admin_constants.dart';

/// Logs admin actions to admin_activity_log collection.
class AdminActivityLogService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log an action performed by the current admin.
  static Future<void> log({
    required String action,
    required String targetCollection,
    String? targetId,
    Map<String, dynamic>? extra,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection(AdminConstants.adminActivityLogCollection)
        .add({
      'adminUid': uid,
      'action': action,
      'targetCollection': targetCollection,
      'targetId': targetId ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      if (extra != null) ...extra,
    });
  }
}
