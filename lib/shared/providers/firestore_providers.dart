import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';
import '../../features/mock_tests/data/models/mock_test_models.dart';
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

/// Streams a single question by its ID.
final singleQuestionProvider =
    StreamProvider.family<QuestionModel?, String>((ref, questionId) {
  return FirebaseFirestore.instance
      .collection(AppConstants.questionsCollection)
      .doc(questionId)
      .snapshots()
      .map((doc) => doc.exists ? QuestionModel.fromFirestore(doc) : null);
});

// Helper to normalized subject mapping for Firestore queries
List<String> _getSubjectQueryValues(String? testSubject) {
  if (testSubject == null) return [];
  final norm = testSubject.toLowerCase().trim();
  if (norm.contains('tamil')) {
    return ['Tamil', 'general_tamil'];
  } else if (norm.contains('studies') || norm.contains('knowledge') || norm.contains('gk') || norm.contains('gs')) {
    return ['General Studies', 'general_knowledge', 'general_studies'];
  } else if (norm.contains('aptitude') || norm.contains('mental') || norm.contains('math') || norm.contains('ability')) {
    return ['Aptitude & Mental Ability', 'aptitude', 'mental_ability'];
  } else if (norm.contains('english')) {
    return ['English', 'general_english'];
  }
  return [testSubject];
}

// Fetch a single question list helper
Future<List<QuestionModel>> _fetchQuestionsForSubject(List<String> subjects, int limit) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.questionsCollection)
      .where('subject', whereIn: subjects)
      .limit(limit)
      .get();
  return snap.docs
      .map((d) => QuestionModel.fromMap(d.data(), d.id))
      .toList();
}

/// Fetches a single MockTestModel by its ID from Firestore.
final singleMockTestProvider = FutureProvider.family<MockTestModel?, String>((ref, testId) async {
  final doc = await FirebaseFirestore.instance
      .collection(AppConstants.mockTestsCollection)
      .doc(testId)
      .get();
  return doc.exists ? MockTestModel.fromFirestore(doc) : null;
});

/// Fetches questions for a given MockTestModel from Firestore.
final mockTestQuestionsProvider = FutureProvider.family<List<QuestionModel>, MockTestModel>((ref, test) async {
  final firestore = FirebaseFirestore.instance;
  final List<QuestionModel> questions = [];
  
  if ((test.type == 'subject' || test.type == 'chapter') && test.subject != null) {
    final subValues = _getSubjectQueryValues(test.subject);
    Query query = firestore.collection(AppConstants.questionsCollection)
        .where('subject', whereIn: subValues);
    if (test.type == 'chapter' && test.chapter != null && test.chapter!.isNotEmpty) {
      query = query.where('chapter', isEqualTo: test.chapter);
    }
    final snap = await query.limit(test.questionCount).get();
    questions.addAll(snap.docs.map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
  } else {
    // For 'full' and 'daily' tests, pull proportionally from the 3 subjects
    final totalCount = test.questionCount;
    final tamilLimit = (totalCount * 0.5).round();
    final aptitudeLimit = (totalCount * 0.125).round();
    final gsLimit = totalCount - tamilLimit - aptitudeLimit;
    
    final results = await Future.wait([
      _fetchQuestionsForSubject(['Tamil', 'general_tamil'], tamilLimit),
      _fetchQuestionsForSubject(['Aptitude & Mental Ability', 'aptitude', 'mental_ability'], aptitudeLimit),
      _fetchQuestionsForSubject(['General Studies', 'general_knowledge', 'general_studies'], gsLimit),
    ]);
    
    for (var list in results) {
      questions.addAll(list);
    }
  }
  
  questions.shuffle();
  return questions;
});

/// Streams a single TestResultModel by its ID from Firestore.
final singleTestResultProvider = StreamProvider.family<TestResultModel?, String>((ref, attemptId) {
  return FirebaseFirestore.instance
      .collection(AppConstants.testAttemptsCollection)
      .doc(attemptId)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          return TestResultModel.fromFirestore(doc);
        }
        // Fallback to Hive cache if document is not found in Firestore yet (e.g. offline)
        try {
          final box = Hive.box(AppConstants.testResultsBox);
          final map = box.get(attemptId);
          if (map != null && map is Map) {
            final Map<String, dynamic> converted = Map<String, dynamic>.from(map);
            final subjectScoresObj = <String, SubjectScore>{};
            if (converted['subjectScores'] != null) {
              (converted['subjectScores'] as Map).forEach((k, v) {
                subjectScoresObj[k.toString()] = SubjectScore.fromMap(Map<String, dynamic>.from(v as Map));
              });
            }
            DateTime attemptedAtDate = DateTime.now();
            if (converted['attemptedAt'] is String) {
              attemptedAtDate = DateTime.parse(converted['attemptedAt'] as String);
            }
            return TestResultModel(
              id: attemptId,
              userId: converted['userId'] ?? '',
              testId: converted['testId'] ?? '',
              testType: converted['testType'] ?? '',
              totalQuestions: converted['totalQuestions'] ?? 0,
              correctAnswers: converted['correctAnswers'] ?? 0,
              wrongAnswers: converted['wrongAnswers'] ?? 0,
              unattempted: converted['unattempted'] ?? 0,
              score: (converted['score'] ?? 0.0).toDouble(),
              percentage: (converted['percentage'] ?? 0.0).toDouble(),
              timeTakenSeconds: converted['timeTakenSeconds'] ?? 0,
              subjectScores: subjectScoresObj,
              answers: Map<String, String>.from(converted['answers'] ?? {}),
              markedForReview: List<String>.from(converted['markedForReview'] ?? []),
              orderedQuestionIds: List<String>.from(converted['orderedQuestionIds'] ?? []),
              rank: converted['rank'] ?? 0,
              attemptedAt: attemptedAtDate,
            );
          }
        } catch (hiveError) {
          debugPrint('Hive fallback failed in stream: $hiveError');
        }
      });
});

/// Fetches the total count of test attempts for a given test ID.
final testAttemptsCountProvider = FutureProvider.family<int, String>((ref, testId) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.testAttemptsCollection)
      .where('testId', isEqualTo: testId)
      .get();
  return snap.size;
});

/// Fetches a list of QuestionModels by their IDs, chunked into batches of 30 due to Firestore whereIn limits.
final questionsByIdsProvider = FutureProvider.family<List<QuestionModel>, List<String>>((ref, ids) async {
  if (ids.isEmpty) return [];

  final firestore = FirebaseFirestore.instance;
  final List<QuestionModel> results = [];

  // Firestore whereIn supports up to 30 IDs
  const int batchSize = 30;
  final List<List<String>> batches = [];
  for (var i = 0; i < ids.length; i += batchSize) {
    batches.add(ids.sublist(i, i + batchSize > ids.length ? ids.length : i + batchSize));
  }

  // Fetch each batch
  final fetchFutures = batches.map((batch) {
    return firestore
        .collection(AppConstants.questionsCollection)
        .where(FieldPath.documentId, whereIn: batch)
        .get();
  });

  final snapshots = await Future.wait(fetchFutures);
  for (final snap in snapshots) {
    for (final doc in snap.docs) {
      results.add(QuestionModel.fromFirestore(doc));
    }
  }

  // Order results by the input list of IDs
  final idMap = {for (var i = 0; i < ids.length; i++) ids[i]: i};
  results.sort((a, b) {
    final indexA = idMap[a.id] ?? 999999;
    final indexB = idMap[b.id] ?? 999999;
    return indexA.compareTo(indexB);
  });

  return results;
});



