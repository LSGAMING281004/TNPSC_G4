import 'package:cloud_firestore/cloud_firestore.dart';

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
    String category = map['category'] ?? 'National';
    // Align admin category strings with client category strings
    if (category == 'Tamil Nadu') category = 'TN_State';
    if (category == 'India') category = 'National';
    if (category == 'Science & Tech') category = 'Science';

    return CurrentAffairsModel(
      id: id,
      titleTamil: map['titleTamil'] ?? map['titleTa'] ?? '',
      titleEnglish: map['titleEnglish'] ?? map['titleEn'] ?? '',
      contentTamil: map['contentTamil'] ?? map['contentTa'] ?? map['summaryTa'] ?? '',
      contentEnglish: map['contentEnglish'] ?? map['contentEn'] ?? map['summaryEn'] ?? '',
      category: category,
      importance: map['importance'] ?? 'medium',
      publishedAt: map['publishedAt'] != null 
          ? (map['publishedAt'] is Timestamp 
              ? (map['publishedAt'] as Timestamp).toDate() 
              : DateTime.tryParse(map['publishedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
      hasQuiz: map['hasQuiz'] ?? false,
      imageUrl: map['imageUrl'] ?? map['coverImageUrl'],
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
