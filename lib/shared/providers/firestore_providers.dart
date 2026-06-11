import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

// ─────────────────────────────────────────────
//  CORE: Current User Stream (real-time profile)
// ─────────────────────────────────────────────

/// Streams the current user's Firestore profile in real time.
/// Automatically updates `currentUserProvider` so every screen stays fresh.
final userProfileStreamProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) {
    Future.microtask(() {
      ref.read(currentUserProvider.notifier).state = null;
    });
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists) return null;
    final user = UserModel.fromMap(snap.data() as Map<String, dynamic>, snap.id);
    // Keep the StateProvider in sync for backward compat
    ref.read(currentUserProvider.notifier).state = user;
    return user;
  });
});

// ─────────────────────────────────────────────
//  MOCK TESTS
// ─────────────────────────────────────────────

/// Streams all mock tests, optionally filtered by type.
final mockTestsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, type) {
  Query query = FirebaseFirestore.instance
      .collection(AppConstants.mockTestsCollection)
      .orderBy('createdAt', descending: true);

  if (type != null && type.isNotEmpty) {
    query = query.where('type', isEqualTo: type);
  }

  return query.snapshots().map((snap) => snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList());
});

// ─────────────────────────────────────────────
//  QUESTIONS
// ─────────────────────────────────────────────

/// Streams questions with optional subject and difficulty filters.
final questionsStreamProvider = StreamProvider.family<
    List<Map<String, dynamic>>,
    ({String? subject, String? difficulty, String? search})>((ref, filters) {
  Query query = FirebaseFirestore.instance
      .collection(AppConstants.questionsCollection)
      .orderBy('createdAt', descending: true)
      .limit(50);

  if (filters.subject != null &&
      filters.subject!.isNotEmpty &&
      filters.subject != 'All') {
    query = query.where('subject', isEqualTo: filters.subject);
  }
  if (filters.difficulty != null &&
      filters.difficulty!.isNotEmpty &&
      filters.difficulty != 'All') {
    query = query.where('difficulty',
        isEqualTo: filters.difficulty!.toLowerCase());
  }

  return query.snapshots().map((snap) => snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList());
});

// ─────────────────────────────────────────────
//  STUDY MATERIALS
// ─────────────────────────────────────────────

/// Streams study materials by subject.
final studyMaterialsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, subject) {
  Query query = FirebaseFirestore.instance
      .collection(AppConstants.studyMaterialsCollection)
      .orderBy('createdAt', descending: true);

  if (subject != null && subject.isNotEmpty) {
    query = query.where('subject', isEqualTo: subject);
  }

  return query.snapshots().map((snap) => snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList());
});

// ─────────────────────────────────────────────
//  CURRENT AFFAIRS
// ─────────────────────────────────────────────

/// Streams current affairs articles, latest first.
final currentAffairsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, int>((ref, limit) {
  return FirebaseFirestore.instance
      .collection(AppConstants.currentAffairsCollection)
      .orderBy('publishedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList());
});

// ─────────────────────────────────────────────
//  NOTIFICATIONS
// ─────────────────────────────────────────────

/// Streams user-facing notifications (latest 20).
final notificationsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.notificationsCollection)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList());
});

// ─────────────────────────────────────────────
//  LEADERBOARD
// ─────────────────────────────────────────────

/// Streams leaderboard entries sorted by score.
final leaderboardStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.leaderboardCollection)
      .orderBy('totalPoints', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList());
});

// ─────────────────────────────────────────────
//  TEST ATTEMPTS (for analytics / history)
// ─────────────────────────────────────────────

/// Streams the current user's test attempts.
final userTestAttemptsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(AppConstants.testAttemptsCollection)
      .where('userId', isEqualTo: uid)
      .orderBy('completedAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList());
});

/// Streams today's test attempts count for daily target.
final todayAttemptsCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return Stream.value(0);

  final todayStart = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  return FirebaseFirestore.instance
      .collection(AppConstants.testAttemptsCollection)
      .where('userId', isEqualTo: uid)
      .where('completedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
      .snapshots()
      .map((snap) => snap.size);
});
