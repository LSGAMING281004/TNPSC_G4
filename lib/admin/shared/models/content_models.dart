import 'package:cloud_firestore/cloud_firestore.dart';

/// Study material model.
class StudyMaterialModel {
  final String? id;
  final String titleTa;
  final String titleEn;
  final String descTa;
  final String descEn;
  final String subject;
  final String chapter;
  final String topic;
  final String storageRef;
  final String downloadUrl;
  final int fileSize;
  final String contentType;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final int downloadCount;
  final bool isActive;

  const StudyMaterialModel({
    this.id,
    required this.titleTa,
    required this.titleEn,
    this.descTa = '',
    this.descEn = '',
    required this.subject,
    required this.chapter,
    this.topic = '',
    required this.storageRef,
    required this.downloadUrl,
    this.fileSize = 0,
    this.contentType = 'application/pdf',
    this.uploadedBy,
    this.uploadedAt,
    this.downloadCount = 0,
    this.isActive = true,
  });

  factory StudyMaterialModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StudyMaterialModel(
      id: doc.id,
      titleTa: d['titleTa'] ?? '',
      titleEn: d['titleEn'] ?? '',
      descTa: d['descTa'] ?? '',
      descEn: d['descEn'] ?? '',
      subject: d['subject'] ?? '',
      chapter: d['chapter'] ?? '',
      topic: d['topic'] ?? '',
      storageRef: d['storageRef'] ?? '',
      downloadUrl: d['downloadUrl'] ?? '',
      fileSize: d['fileSize'] ?? 0,
      contentType: d['contentType'] ?? 'application/pdf',
      uploadedBy: d['uploadedBy'],
      uploadedAt: (d['uploadedAt'] as Timestamp?)?.toDate(),
      downloadCount: d['downloadCount'] ?? 0,
      isActive: d['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titleTa': titleTa,
      'titleEn': titleEn,
      'descTa': descTa,
      'descEn': descEn,
      'subject': subject,
      'chapter': chapter,
      'topic': topic,
      'storageRef': storageRef,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'contentType': contentType,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt != null
          ? Timestamp.fromDate(uploadedAt!)
          : FieldValue.serverTimestamp(),
      'downloadCount': downloadCount,
      'isActive': isActive,
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Current affairs article model.
class CurrentAffairsModel {
  final String? id;
  final DateTime? publishedAt;
  final String category;
  final String titleTa;
  final String titleEn;
  final String summaryTa;
  final String summaryEn;
  final String contentTa;
  final String contentEn;
  final String sourceName;
  final String sourceUrl;
  final String? coverImageUrl;
  final List<String> tags;
  final bool isQuiz;
  final String? optionATa;
  final String? optionAEn;
  final String? optionBTa;
  final String? optionBEn;
  final String? optionCTa;
  final String? optionCEn;
  final String? optionDTa;
  final String? optionDEn;
  final String? correctAnswer;
  final String? quizExplanationTa;
  final String? quizExplanationEn;
  final String status; // Draft | Published | Archived
  final DateTime? scheduleAt;
  final int viewCount;

  const CurrentAffairsModel({
    this.id,
    this.publishedAt,
    required this.category,
    required this.titleTa,
    required this.titleEn,
    this.summaryTa = '',
    this.summaryEn = '',
    this.contentTa = '',
    this.contentEn = '',
    this.sourceName = '',
    this.sourceUrl = '',
    this.coverImageUrl,
    this.tags = const [],
    this.isQuiz = false,
    this.optionATa,
    this.optionAEn,
    this.optionBTa,
    this.optionBEn,
    this.optionCTa,
    this.optionCEn,
    this.optionDTa,
    this.optionDEn,
    this.correctAnswer,
    this.quizExplanationTa,
    this.quizExplanationEn,
    this.status = 'Draft',
    this.scheduleAt,
    this.viewCount = 0,
  });

  factory CurrentAffairsModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CurrentAffairsModel(
      id: doc.id,
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate(),
      category: d['category'] ?? '',
      titleTa: d['titleTa'] ?? '',
      titleEn: d['titleEn'] ?? '',
      summaryTa: d['summaryTa'] ?? '',
      summaryEn: d['summaryEn'] ?? '',
      contentTa: d['contentTa'] ?? '',
      contentEn: d['contentEn'] ?? '',
      sourceName: d['sourceName'] ?? '',
      sourceUrl: d['sourceUrl'] ?? '',
      coverImageUrl: d['coverImageUrl'],
      tags: List<String>.from(d['tags'] ?? []),
      isQuiz: d['isQuiz'] ?? false,
      optionATa: d['optionATa'],
      optionAEn: d['optionAEn'],
      optionBTa: d['optionBTa'],
      optionBEn: d['optionBEn'],
      optionCTa: d['optionCTa'],
      optionCEn: d['optionCEn'],
      optionDTa: d['optionDTa'],
      optionDEn: d['optionDEn'],
      correctAnswer: d['correctAnswer'],
      quizExplanationTa: d['quizExplanationTa'],
      quizExplanationEn: d['quizExplanationEn'],
      status: d['status'] ?? 'Draft',
      scheduleAt: (d['scheduleAt'] as Timestamp?)?.toDate(),
      viewCount: d['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'publishedAt': publishedAt != null
          ? Timestamp.fromDate(publishedAt!)
          : FieldValue.serverTimestamp(),
      'category': category,
      'titleTa': titleTa,
      'titleEn': titleEn,
      'summaryTa': summaryTa,
      'summaryEn': summaryEn,
      'contentTa': contentTa,
      'contentEn': contentEn,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
      'coverImageUrl': coverImageUrl,
      'tags': tags,
      'isQuiz': isQuiz,
      if (isQuiz) ...{
        'optionATa': optionATa,
        'optionAEn': optionAEn,
        'optionBTa': optionBTa,
        'optionBEn': optionBEn,
        'optionCTa': optionCTa,
        'optionCEn': optionCEn,
        'optionDTa': optionDTa,
        'optionDEn': optionDEn,
        'correctAnswer': correctAnswer,
        'quizExplanationTa': quizExplanationTa,
        'quizExplanationEn': quizExplanationEn,
      },
      'status': status,
      'scheduleAt':
          scheduleAt != null ? Timestamp.fromDate(scheduleAt!) : null,
      'viewCount': viewCount,
    };
  }
}
