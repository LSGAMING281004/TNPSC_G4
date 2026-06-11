class QuestionModel {
  final String id;
  final String questionTamil;
  final String questionEnglish;
  final List<String> optionsTamil;
  final List<String> optionsEnglish;
  final int correctOptionIndex;
  final String explanationTamil;
  final String explanationEnglish;
  final String subject;
  final String topic;
  final String chapter;
  final String difficulty;
  final int year;
  final List<String> tags;
  final bool isVerified;

  QuestionModel({
    required this.id,
    required this.questionTamil,
    required this.questionEnglish,
    required this.optionsTamil,
    required this.optionsEnglish,
    required this.correctOptionIndex,
    required this.explanationTamil,
    required this.explanationEnglish,
    required this.subject,
    required this.topic,
    required this.chapter,
    required this.difficulty,
    required this.year,
    required this.tags,
    required this.isVerified,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      questionTamil: map['questionTamil'] ?? '',
      questionEnglish: map['questionEnglish'] ?? '',
      optionsTamil: List<String>.from(map['optionsTamil'] ?? []),
      optionsEnglish: List<String>.from(map['optionsEnglish'] ?? []),
      correctOptionIndex: map['correctOptionIndex']?.toInt() ?? 0,
      explanationTamil: map['explanationTamil'] ?? '',
      explanationEnglish: map['explanationEnglish'] ?? '',
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '',
      chapter: map['chapter'] ?? '',
      difficulty: map['difficulty'] ?? 'medium',
      year: map['year']?.toInt() ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      isVerified: map['isVerified'] ?? false,
    );
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json, [String? id]) => QuestionModel.fromMap(json, id ?? json['id'] ?? '');

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionTamil': questionTamil,
      'questionEnglish': questionEnglish,
      'optionsTamil': optionsTamil,
      'optionsEnglish': optionsEnglish,
      'correctOptionIndex': correctOptionIndex,
      'explanationTamil': explanationTamil,
      'explanationEnglish': explanationEnglish,
      'subject': subject,
      'topic': topic,
      'chapter': chapter,
      'difficulty': difficulty,
      'year': year,
      'tags': tags,
      'isVerified': isVerified,
    };
  }
}
