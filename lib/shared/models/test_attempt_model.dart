import 'package:cloud_firestore/cloud_firestore.dart';

class TestAttemptModel {
  final String id;
  final String userId;
  final String testId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final int timeTakenSeconds;
  final Map<String, int> subjectScores;
  final List<Map<String, dynamic>> answers;
  final bool isCompleted;

  TestAttemptModel({
    required this.id,
    required this.userId,
    required this.testId,
    required this.startedAt,
    this.completedAt,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.skippedCount,
    required this.timeTakenSeconds,
    required this.subjectScores,
    required this.answers,
    required this.isCompleted,
  });

  factory TestAttemptModel.fromMap(Map<String, dynamic> map, String id) {
    final startedStr = map['startedAt'] ?? map['attemptedAt'];
    final completedStr = map['completedAt'] ?? map['attemptedAt'];
    
    DateTime started = DateTime.now();
    if (startedStr != null) {
      if (startedStr is Timestamp) {
        started = startedStr.toDate();
      } else {
        started = DateTime.tryParse(startedStr.toString()) ?? DateTime.now();
      }
    }
    
    DateTime? completed;
    if (completedStr != null) {
      if (completedStr is Timestamp) {
        completed = completedStr.toDate();
      } else {
        completed = DateTime.tryParse(completedStr.toString());
      }
    }

    final correct = map['correctCount'] ?? map['correctAnswers'] ?? 0;
    final incorrect = map['incorrectCount'] ?? map['wrongAnswers'] ?? 0;
    final skipped = map['skippedCount'] ?? map['unattempted'] ?? 0;
    
    final Map<String, int> subScores = {};
    if (map['subjectScores'] != null && map['subjectScores'] is Map) {
      (map['subjectScores'] as Map).forEach((k, v) {
        if (v is Map) {
          final percentageVal = v['percentage'] ?? 0.0;
          subScores[k.toString()] = (percentageVal is num) ? percentageVal.round() : 0;
        } else if (v is num) {
          subScores[k.toString()] = v.toInt();
        }
      });
    }

    return TestAttemptModel(
      id: id,
      userId: map['userId'] ?? '',
      testId: map['testId'] ?? '',
      startedAt: started,
      completedAt: completed,
      score: (map['score'] as num?)?.round() ?? 0,
      totalQuestions: map['totalQuestions']?.toInt() ?? 0,
      correctCount: (correct as num).toInt(),
      incorrectCount: (incorrect as num).toInt(),
      skippedCount: (skipped as num).toInt(),
      timeTakenSeconds: map['timeTakenSeconds']?.toInt() ?? 0,
      subjectScores: subScores,
      answers: map['answers'] is List 
          ? List<Map<String, dynamic>>.from(map['answers'])
          : [],
      isCompleted: map['isCompleted'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'testId': testId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'skippedCount': skippedCount,
      'timeTakenSeconds': timeTakenSeconds,
      'subjectScores': subjectScores,
      'answers': answers,
      'isCompleted': isCompleted,
    };
  }

  TestAttemptModel copyWith({
    String? id,
    String? userId,
    String? testId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? score,
    int? totalQuestions,
    int? correctCount,
    int? incorrectCount,
    int? skippedCount,
    int? timeTakenSeconds,
    Map<String, int>? subjectScores,
    List<Map<String, dynamic>>? answers,
    bool? isCompleted,
  }) {
    return TestAttemptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      skippedCount: skippedCount ?? this.skippedCount,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      subjectScores: subjectScores ?? this.subjectScores,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
