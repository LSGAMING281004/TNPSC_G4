import 'package:cloud_firestore/cloud_firestore.dart';

/// Question model with bilingual support
class QuestionModel {
  final String id;
  final String subject;
  final String chapter;
  final String topic;
  final String questionTa;
  final String questionEn;
  final List<OptionModel> options;
  final String correctOptionId;
  final String explanationTa;
  final String explanationEn;
  final String difficulty;
  final int? year;
  final String? imageUrl;
  final List<String> tags;

  const QuestionModel({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.topic,
    required this.questionTa,
    required this.questionEn,
    required this.options,
    required this.correctOptionId,
    required this.explanationTa,
    required this.explanationEn,
    required this.difficulty,
    this.year,
    this.imageUrl,
    this.tags = const [],
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      subject: data['subject'] ?? '',
      chapter: data['chapter'] ?? '',
      topic: data['topic'] ?? '',
      questionTa: data['questionTa'] ?? '',
      questionEn: data['questionEn'] ?? '',
      options: (data['options'] as List<dynamic>?)
              ?.map((o) => OptionModel.fromMap(o as Map<String, dynamic>))
              .toList() ?? [],
      correctOptionId: data['correctOptionId'] ?? '',
      explanationTa: data['explanationTa'] ?? '',
      explanationEn: data['explanationEn'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      year: data['year'],
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'subject': subject, 'chapter': chapter, 'topic': topic,
    'questionTa': questionTa, 'questionEn': questionEn,
    'options': options.map((o) => o.toMap()).toList(),
    'correctOptionId': correctOptionId,
    'explanationTa': explanationTa, 'explanationEn': explanationEn,
    'difficulty': difficulty, 'year': year, 'imageUrl': imageUrl, 'tags': tags,
  };

  Map<String, dynamic> toMap() => toFirestore()..['id'] = id;

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '', subject: map['subject'] ?? '',
      chapter: map['chapter'] ?? '', topic: map['topic'] ?? '',
      questionTa: map['questionTa'] ?? '', questionEn: map['questionEn'] ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((o) => OptionModel.fromMap(o as Map<String, dynamic>))
              .toList() ?? [],
      correctOptionId: map['correctOptionId'] ?? '',
      explanationTa: map['explanationTa'] ?? '',
      explanationEn: map['explanationEn'] ?? '',
      difficulty: map['difficulty'] ?? 'medium',
      year: map['year'], imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

class OptionModel {
  final String id;
  final String textTa;
  final String textEn;

  const OptionModel({required this.id, required this.textTa, required this.textEn});

  factory OptionModel.fromMap(Map<String, dynamic> map) => OptionModel(
    id: map['id'] ?? '', textTa: map['textTa'] ?? '', textEn: map['textEn'] ?? '',
  );

  Map<String, dynamic> toMap() => {'id': id, 'textTa': textTa, 'textEn': textEn};
}
