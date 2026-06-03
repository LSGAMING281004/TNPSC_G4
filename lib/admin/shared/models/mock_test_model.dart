import 'package:cloud_firestore/cloud_firestore.dart';

/// Mock test model for Firestore.
class MockTestModel {
  final String? id;
  final String titleTa;
  final String titleEn;
  final String type; // Full Mock | Subject-wise | Chapter-wise | Daily Challenge
  final String? subject;
  final int durationMinutes;
  final int totalQuestions;
  final List<String> questionIds;
  final Map<String, int> difficultyDist; // {Easy: 30, Medium: 50, Hard: 20}
  final int passingScore; // percentage
  final String status; // Draft | Active | Archived
  final DateTime? publishAt;
  final String? createdBy;
  final DateTime? createdAt;

  const MockTestModel({
    this.id,
    required this.titleTa,
    required this.titleEn,
    required this.type,
    this.subject,
    this.durationMinutes = 90,
    this.totalQuestions = 100,
    this.questionIds = const [],
    this.difficultyDist = const {'Easy': 30, 'Medium': 50, 'Hard': 20},
    this.passingScore = 40,
    this.status = 'Draft',
    this.publishAt,
    this.createdBy,
    this.createdAt,
  });

  factory MockTestModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MockTestModel(
      id: doc.id,
      titleTa: d['title_ta'] ?? '',
      titleEn: d['title_en'] ?? '',
      type: d['type'] ?? 'Full Mock',
      subject: d['subject'],
      durationMinutes: d['durationMinutes'] ?? 90,
      totalQuestions: d['totalQuestions'] ?? 100,
      questionIds: List<String>.from(d['questionIds'] ?? []),
      difficultyDist: Map<String, int>.from(d['difficultyDist'] ?? {}),
      passingScore: d['passingScore'] ?? 40,
      status: d['status'] ?? 'Draft',
      publishAt: (d['publishAt'] as Timestamp?)?.toDate(),
      createdBy: d['createdBy'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title_ta': titleTa,
      'title_en': titleEn,
      'type': type,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'totalQuestions': totalQuestions,
      'questionIds': questionIds,
      'difficultyDist': difficultyDist,
      'passingScore': passingScore,
      'status': status,
      'publishAt':
          publishAt != null ? Timestamp.fromDate(publishAt!) : null,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
