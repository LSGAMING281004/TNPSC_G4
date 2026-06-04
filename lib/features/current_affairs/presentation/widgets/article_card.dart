import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/language/question_display_helper.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../shared/widgets/bilingual_text.dart';

// Temporary re-export of model — replace with real import
export '../../../../core/language/question_display_helper.dart'
    show CurrentAffairsModel;

class ArticleCard extends ConsumerWidget {
  final CurrentAffairsModel article;
  final String category;
  final String source;
  final String date;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.category = '',
    this.source = '',
    this.date = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentLang = ref.watch(contentLangProvider);
    final title = QuestionDisplayHelper.getArticleTitle(article, contentLang);
    final summary = QuestionDisplayHelper.getArticleSummary(article, contentLang);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category + source (always English)
              Row(children: [
                if (category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            fontSize: 11, color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600)),
                  ),
                const Spacer(),
                Text(date,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
              const SizedBox(height: 8),

              // Title
              // In 'both' mode, card shows English headline; detail screen shows bilingual
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),

              // Summary
              Text(summary,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),

              if (source.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Source: $source',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail screen shows bilingual title + summary + full content
class ArticleDetailBilingualHeader extends ConsumerWidget {
  final CurrentAffairsModel article;
  const ArticleDetailBilingualHeader({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentLang = ref.watch(contentLangProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualText(
          tamilText: article.titleTa,
          englishText: article.titleEn,
          contentLang: contentLang,
          primaryStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        BilingualText(
          tamilText: article.summaryTa,
          englishText: article.summaryEn,
          contentLang: contentLang,
          primaryStyle: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
