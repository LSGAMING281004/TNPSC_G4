import 'package:cloud_firestore/cloud_firestore.dart';

/// Mock test model
class MockTestModel {
  final String id;
  final String title;
  final String titleTa;
  final String type; // 'full', 'subject', 'chapter', 'daily'
  final String? subject;
  final String? chapter;
  final int questionCount;
  final int durationMinutes;
  final String difficulty;
  final double avgScore;
  final int totalAttempts;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? scheduledAt;

  const MockTestModel({
    required this.id, required this.title, required this.titleTa,
    required this.type, this.subject, this.chapter,
    required this.questionCount, required this.durationMinutes,
    required this.difficulty, this.avgScore = 0.0,
    this.totalAttempts = 0, this.isActive = true,
    required this.createdAt, this.scheduledAt,
  });

  factory MockTestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MockTestModel(
      id: doc.id, title: data['title'] ?? '', titleTa: data['titleTa'] ?? '',
      type: data['type'] ?? 'full', subject: data['subject'],
      chapter: data['chapter'],
      questionCount: data['questionCount'] ?? 100,
      durationMinutes: data['durationMinutes'] ?? 90,
      difficulty: data['difficulty'] ?? 'medium',
      avgScore: (data['avgScore'] ?? 0.0).toDouble(),
      totalAttempts: data['totalAttempts'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title, 'titleTa': titleTa, 'type': type,
    'subject': subject, 'chapter': chapter,
    'questionCount': questionCount, 'durationMinutes': durationMinutes,
    'difficulty': difficulty, 'avgScore': avgScore,
    'totalAttempts': totalAttempts, 'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
    'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
  };
}

/// Test attempt result model
class TestResultModel {
  final String id;
  final String userId;
  final String testId;
  final String testType;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unattempted;
  final double score;
  final double percentage;
  final int timeTakenSeconds;
  final Map<String, SubjectScore> subjectScores;
  final Map<String, String> answers; // questionId -> selectedOptionId
  final List<String> markedForReview;
  final List<String> orderedQuestionIds;
  final int rank;
  final DateTime attemptedAt;

  const TestResultModel({
    required this.id, required this.userId, required this.testId,
    required this.testType, required this.totalQuestions,
    required this.correctAnswers, required this.wrongAnswers,
    required this.unattempted, required this.score,
    required this.percentage, required this.timeTakenSeconds,
    this.subjectScores = const {}, this.answers = const {},
    this.markedForReview = const [], this.orderedQuestionIds = const [], this.rank = 0,
    required this.attemptedAt,
  });

  factory TestResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final subjectScoresMap = <String, SubjectScore>{};
    if (data['subjectScores'] != null) {
      (data['subjectScores'] as Map<String, dynamic>).forEach((key, value) {
        subjectScoresMap[key] = SubjectScore.fromMap(value as Map<String, dynamic>);
      });
    }
    return TestResultModel(
      id: doc.id, userId: data['userId'] ?? '', testId: data['testId'] ?? '',
      testType: data['testType'] ?? '', totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      unattempted: data['unattempted'] ?? 0,
      score: (data['score'] ?? 0.0).toDouble(),
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      timeTakenSeconds: data['timeTakenSeconds'] ?? 0,
      subjectScores: subjectScoresMap,
      answers: Map<String, String>.from(data['answers'] ?? {}),
      markedForReview: List<String>.from(data['markedForReview'] ?? []),
      orderedQuestionIds: List<String>.from(data['orderedQuestionIds'] ?? []),
      rank: data['rank'] ?? 0,
      attemptedAt: (data['attemptedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId, 'testId': testId, 'testType': testType,
    'totalQuestions': totalQuestions, 'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers, 'unattempted': unattempted,
    'score': score, 'percentage': percentage,
    'timeTakenSeconds': timeTakenSeconds,
    'subjectScores': subjectScores.map((k, v) => MapEntry(k, v.toMap())),
    'answers': answers, 'markedForReview': markedForReview,
    'orderedQuestionIds': orderedQuestionIds, 'rank': rank,
    'attemptedAt': Timestamp.fromDate(attemptedAt),
  };

  Map<String, dynamic> toMap() => toFirestore()..['id'] = id;
}

class SubjectScore {
  final String subject;
  final int total;
  final int correct;
  final int wrong;
  final double percentage;

  const SubjectScore({
    required this.subject, required this.total, required this.correct,
    required this.wrong, required this.percentage,
  });

  factory SubjectScore.fromMap(Map<String, dynamic> map) => SubjectScore(
    subject: map['subject'] ?? '', total: map['total'] ?? 0,
    correct: map['correct'] ?? 0, wrong: map['wrong'] ?? 0,
    percentage: (map['percentage'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'subject': subject, 'total': total, 'correct': correct,
    'wrong': wrong, 'percentage': percentage,
  };
}
