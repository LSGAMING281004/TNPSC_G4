class CurrentAffairsModel {
  final String id;
  final String titleTamil;
  final String titleEnglish;
  final String contentTamil;
  final String contentEnglish;
  final String category;
  final String importance;
  final DateTime publishedAt;
  final List<String> tags;
  final bool hasQuiz;
  final String? imageUrl;

  CurrentAffairsModel({
    required this.id,
    required this.titleTamil,
    required this.titleEnglish,
    required this.contentTamil,
    required this.contentEnglish,
    required this.category,
    required this.importance,
    required this.publishedAt,
    required this.tags,
    required this.hasQuiz,
    this.imageUrl,
  });

  factory CurrentAffairsModel.fromMap(Map<String, dynamic> map, String id) {
    return CurrentAffairsModel(
      id: id,
      titleTamil: map['titleTamil'] ?? '',
      titleEnglish: map['titleEnglish'] ?? '',
      contentTamil: map['contentTamil'] ?? '',
      contentEnglish: map['contentEnglish'] ?? '',
      category: map['category'] ?? 'National',
      importance: map['importance'] ?? 'medium',
      publishedAt: map['publishedAt'] != null 
          ? DateTime.parse(map['publishedAt']) 
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
      hasQuiz: map['hasQuiz'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleTamil': titleTamil,
      'titleEnglish': titleEnglish,
      'contentTamil': contentTamil,
      'contentEnglish': contentEnglish,
      'category': category,
      'importance': importance,
      'publishedAt': publishedAt.toIso8601String(),
      'tags': tags,
      'hasQuiz': hasQuiz,
      'imageUrl': imageUrl,
    };
  }
}
