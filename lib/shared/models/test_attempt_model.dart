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
    return TestAttemptModel(
      id: id,
      userId: map['userId'] ?? '',
      testId: map['testId'] ?? '',
      startedAt: DateTime.parse(map['startedAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      score: map['score']?.toInt() ?? 0,
      totalQuestions: map['totalQuestions']?.toInt() ?? 0,
      correctCount: map['correctCount']?.toInt() ?? 0,
      incorrectCount: map['incorrectCount']?.toInt() ?? 0,
      skippedCount: map['skippedCount']?.toInt() ?? 0,
      timeTakenSeconds: map['timeTakenSeconds']?.toInt() ?? 0,
      subjectScores: Map<String, int>.from(map['subjectScores'] ?? {}),
      answers: List<Map<String, dynamic>>.from(map['answers'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
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
