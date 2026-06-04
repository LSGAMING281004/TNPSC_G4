import '../../shared/models/question_model.dart';

/// Placeholder models — replace with real imports when available
class CurrentAffairsModel {
  final String titleTa;
  final String titleEn;
  final String summaryTa;
  final String summaryEn;
  const CurrentAffairsModel({
    required this.titleTa, required this.titleEn,
    required this.summaryTa, required this.summaryEn,
  });
}

class StudyMaterialModel {
  final String titleTa;
  final String titleEn;
  const StudyMaterialModel({required this.titleTa, required this.titleEn});
}

class QuestionDisplayHelper {
  QuestionDisplayHelper._();

  // ─── Question text ────────────────────────────────────────────────────────
  static String? getQuestionText(QuestionModel q, String contentLang) {
    if (contentLang == 'both') return null;
    if (contentLang == 'ta') {
      return q.questionTa.isNotEmpty ? q.questionTa : q.questionEn;
    }
    return q.questionEn.isNotEmpty ? q.questionEn : q.questionTa;
  }

  // ─── Option text ──────────────────────────────────────────────────────────
  static String? getOptionText(OptionModel opt, String contentLang) {
    if (contentLang == 'both') return null;
    if (contentLang == 'ta') {
      return opt.textTa.isNotEmpty ? opt.textTa : opt.textEn;
    }
    return opt.textEn.isNotEmpty ? opt.textEn : opt.textTa;
  }

  // ─── Explanation ──────────────────────────────────────────────────────────
  static String? getExplanation(QuestionModel q, String contentLang) {
    if (contentLang == 'both') return null;
    if (contentLang == 'ta') {
      return q.explanationTa.isNotEmpty ? q.explanationTa : q.explanationEn;
    }
    return q.explanationEn.isNotEmpty ? q.explanationEn : q.explanationTa;
  }

  // ─── Current affairs ──────────────────────────────────────────────────────
  static String getArticleTitle(CurrentAffairsModel ca, String contentLang) {
    if (contentLang == 'ta') return ca.titleTa;
    return ca.titleEn; // en & both → English for card headline
  }

  static String getArticleSummary(CurrentAffairsModel ca, String contentLang) {
    if (contentLang == 'ta') return ca.summaryTa;
    return ca.summaryEn;
  }

  // ─── Study material ───────────────────────────────────────────────────────
  static String getMaterialTitle(StudyMaterialModel m, String contentLang) {
    if (contentLang == 'ta') return m.titleTa;
    return m.titleEn;
  }

  // ─── Helper ───────────────────────────────────────────────────────────────
  static bool showBilingualStack(String contentLang) => contentLang == 'both';

  /// Returns a fallback badge message when translation is missing
  static String missingTamilBadge() => 'Tamil translation pending / தமிழ் மொழிபெயர்ப்பு விரைவில்';
  static String missingEnglishBadge() => 'English translation pending';
}
