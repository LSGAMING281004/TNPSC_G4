import 'package:cloud_firestore/cloud_firestore.dart';

/// Question model for Firestore.
class QuestionModel {
  final String? id;
  final String subject;
  final String chapter;
  final String topic;
  final String questionTa;
  final String questionEn;
  final String optionATa;
  final String optionAEn;
  final String optionBTa;
  final String optionBEn;
  final String optionCTa;
  final String optionCEn;
  final String optionDTa;
  final String optionDEn;
  final String correct; // A | B | C | D
  final String explanationTa;
  final String explanationEn;
  final String difficulty; // Easy | Medium | Hard
  final bool isPreviousYear;
  final int? year;
  final String? imageUrl;
  final List<String> tags;
  final List<String> searchTokens;
  final DateTime? createdAt;
  final String? createdBy;

  const QuestionModel({
    this.id,
    required this.subject,
    required this.chapter,
    this.topic = '',
    required this.questionTa,
    required this.questionEn,
    required this.optionATa,
    required this.optionAEn,
    required this.optionBTa,
    required this.optionBEn,
    required this.optionCTa,
    required this.optionCEn,
    required this.optionDTa,
    required this.optionDEn,
    required this.correct,
    this.explanationTa = '',
    this.explanationEn = '',
    this.difficulty = 'Medium',
    this.isPreviousYear = false,
    this.year,
    this.imageUrl,
    this.tags = const [],
    this.searchTokens = const [],
    this.createdAt,
    this.createdBy,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      subject: d['subject'] ?? '',
      chapter: d['chapter'] ?? '',
      topic: d['topic'] ?? '',
      questionTa: d['questionTa'] ?? '',
      questionEn: d['questionEn'] ?? '',
      optionATa: d['optionATa'] ?? '',
      optionAEn: d['optionAEn'] ?? '',
      optionBTa: d['optionBTa'] ?? '',
      optionBEn: d['optionBEn'] ?? '',
      optionCTa: d['optionCTa'] ?? '',
      optionCEn: d['optionCEn'] ?? '',
      optionDTa: d['optionDTa'] ?? '',
      optionDEn: d['optionDEn'] ?? '',
      correct: d['correct'] ?? 'A',
      explanationTa: d['explanationTa'] ?? '',
      explanationEn: d['explanationEn'] ?? '',
      difficulty: d['difficulty'] ?? 'Medium',
      isPreviousYear: d['isPreviousYear'] ?? false,
      year: d['year'],
      imageUrl: d['imageUrl'],
      tags: List<String>.from(d['tags'] ?? []),
      searchTokens: List<String>.from(d['searchTokens'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      createdBy: d['createdBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'chapter': chapter,
      'topic': topic,
      'questionTa': questionTa,
      'questionEn': questionEn,
      'optionATa': optionATa,
      'optionAEn': optionAEn,
      'optionBTa': optionBTa,
      'optionBEn': optionBEn,
      'optionCTa': optionCTa,
      'optionCEn': optionCEn,
      'optionDTa': optionDTa,
      'optionDEn': optionDEn,
      'correct': correct,
      'explanationTa': explanationTa,
      'explanationEn': explanationEn,
      'difficulty': difficulty,
      'isPreviousYear': isPreviousYear,
      'year': year,
      'imageUrl': imageUrl,
      'tags': tags,
      'searchTokens': _generateSearchTokens(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  List<String> _generateSearchTokens() {
    final tokens = <String>{};
    for (final text in [questionEn, questionTa, subject, chapter, topic]) {
      final words = text.toLowerCase().split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.length > 1) {
          tokens.add(word);
          // Prefix tokens for partial search
          for (var i = 1; i <= word.length; i++) {
            tokens.add(word.substring(0, i));
          }
        }
      }
    }
    return tokens.toList();
  }

  /// Parse a single CSV row into a QuestionModel.
  factory QuestionModel.fromCsvRow(List<String> row) {
    if (row.length < 18) {
      throw FormatException('Row needs at least 18 columns, got ${row.length}');
    }
    return QuestionModel(
      subject: row[0].trim(),
      chapter: row[1].trim(),
      topic: row[2].trim(),
      questionTa: row[3].trim(),
      questionEn: row[4].trim(),
      optionATa: row[5].trim(),
      optionAEn: row[6].trim(),
      optionBTa: row[7].trim(),
      optionBEn: row[8].trim(),
      optionCTa: row[9].trim(),
      optionCEn: row[10].trim(),
      optionDTa: row[11].trim(),
      optionDEn: row[12].trim(),
      correct: row[13].trim().toUpperCase(),
      explanationTa: row[14].trim(),
      explanationEn: row[15].trim(),
      difficulty: row[16].trim(),
      year: int.tryParse(row[17].trim()),
      isPreviousYear: (int.tryParse(row[17].trim()) ?? 0) > 0,
    );
  }
}
