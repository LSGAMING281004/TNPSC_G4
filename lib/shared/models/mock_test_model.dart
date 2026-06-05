class MockTestModel {
  final String id;
  final String nameTamil;
  final String nameEnglish;
  final String type;
  final int questionCount;
  final int durationMinutes;
  final String? subject;
  final String? chapter;
  final List<String> questionIds;
  final bool isActive;

  MockTestModel({
    required this.id,
    required this.nameTamil,
    required this.nameEnglish,
    required this.type,
    required this.questionCount,
    required this.durationMinutes,
    this.subject,
    this.chapter,
    required this.questionIds,
    required this.isActive,
  });

  factory MockTestModel.fromMap(Map<String, dynamic> map, String id) {
    return MockTestModel(
      id: id,
      nameTamil: map['nameTamil'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      type: map['type'] ?? 'full',
      questionCount: map['questionCount']?.toInt() ?? 0,
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      subject: map['subject'],
      chapter: map['chapter'],
      questionIds: List<String>.from(map['questionIds'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameTamil': nameTamil,
      'nameEnglish': nameEnglish,
      'type': type,
      'questionCount': questionCount,
      'durationMinutes': durationMinutes,
      'subject': subject,
      'chapter': chapter,
      'questionIds': questionIds,
      'isActive': isActive,
    };
  }
}
