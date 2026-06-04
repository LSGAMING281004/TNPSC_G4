import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for an Audio Book
class AudioBookModel {
  final String id;
  final String titleTa;
  final String titleEn;
  final String descriptionTa;
  final String descriptionEn;
  final String subject;
  final String chapter;
  final String audioUrl;       // Firebase Storage URL
  final String? coverImageUrl;
  final int durationSeconds;   // total audio length
  final String narrator;
  final bool isPremium;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int playCount;
  final List<String> tags;

  const AudioBookModel({
    required this.id,
    required this.titleTa,
    required this.titleEn,
    required this.descriptionTa,
    required this.descriptionEn,
    required this.subject,
    required this.chapter,
    required this.audioUrl,
    this.coverImageUrl,
    required this.durationSeconds,
    this.narrator = '',
    this.isPremium = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.playCount = 0,
    this.tags = const [],
  });

  factory AudioBookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AudioBookModel(
      id: doc.id,
      titleTa: data['titleTa'] ?? '',
      titleEn: data['titleEn'] ?? '',
      descriptionTa: data['descriptionTa'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      subject: data['subject'] ?? '',
      chapter: data['chapter'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      durationSeconds: data['durationSeconds'] ?? 0,
      narrator: data['narrator'] ?? '',
      isPremium: data['isPremium'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      playCount: data['playCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'titleTa': titleTa,
    'titleEn': titleEn,
    'descriptionTa': descriptionTa,
    'descriptionEn': descriptionEn,
    'subject': subject,
    'chapter': chapter,
    'audioUrl': audioUrl,
    'coverImageUrl': coverImageUrl,
    'durationSeconds': durationSeconds,
    'narrator': narrator,
    'isPremium': isPremium,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'playCount': playCount,
    'tags': tags,
  };

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }

  AudioBookModel copyWith({
    String? titleTa, String? titleEn,
    String? descriptionTa, String? descriptionEn,
    String? subject, String? chapter,
    String? audioUrl, String? coverImageUrl,
    int? durationSeconds, String? narrator,
    bool? isPremium, bool? isActive,
    int? playCount, List<String>? tags,
  }) => AudioBookModel(
    id: id,
    titleTa: titleTa ?? this.titleTa,
    titleEn: titleEn ?? this.titleEn,
    descriptionTa: descriptionTa ?? this.descriptionTa,
    descriptionEn: descriptionEn ?? this.descriptionEn,
    subject: subject ?? this.subject,
    chapter: chapter ?? this.chapter,
    audioUrl: audioUrl ?? this.audioUrl,
    coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    narrator: narrator ?? this.narrator,
    isPremium: isPremium ?? this.isPremium,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    playCount: playCount ?? this.playCount,
    tags: tags ?? this.tags,
  );
}
