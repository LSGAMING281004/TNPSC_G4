import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../shared/models/question_model.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/providers/bookmark_actions.dart';

class BookmarkedQuestionsScreen extends ConsumerWidget {
  const BookmarkedQuestionsScreen({super.key});

  String _getQuestionText(QuestionModel question, String contentLang) {
    if (contentLang == 'ta') {
      return question.questionTamil.isNotEmpty ? question.questionTamil : question.questionEnglish;
    } else if (contentLang == 'en') {
      return question.questionEnglish.isNotEmpty ? question.questionEnglish : question.questionTamil;
    } else {
      if (question.questionTamil.isNotEmpty && question.questionEnglish.isNotEmpty) {
        return '${question.questionTamil} / ${question.questionEnglish}';
      }
      return question.questionTamil.isNotEmpty ? question.questionTamil : question.questionEnglish;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentLang = ref.watch(contentLangProvider);
    final bookmarkIdsAsync = ref.watch(userBookmarkedQuestionIdsOrderedProvider);

    return bookmarkIdsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Bookmarked Questions')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentSaffron),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Bookmarked Questions')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading bookmarks: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userBookmarkedQuestionIdsOrderedProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (bookmarkIds) {
        final hasBookmarks = bookmarkIds.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Bookmarked Questions'),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.play_arrow, color: AppColors.accentSaffron),
                label: const Text('Quick Test', style: TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.bold)),
                onPressed: hasBookmarks
                    ? () => context.push('/test/bookmarked-quick-test')
                    : null, // Disabled when no bookmarks
              ),
            ],
          ),
          body: bookmarkIds.isEmpty
              ? _buildEmptyState(context)
              : _buildBookmarksList(context, ref, bookmarkIds, contentLang, isDark),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentSaffron.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_outline,
                size: 64,
                color: AppColors.accentSaffron,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No bookmarked questions yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Questions you bookmark from the Question Bank or mock tests will appear here for quick review.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Explore Question Bank'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/question-bank'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(
    BuildContext context,
    WidgetRef ref,
    List<String> bookmarkIds,
    String contentLang,
    bool isDark,
  ) {
    final questionsAsync = ref.watch(questionsByIdsProvider(bookmarkIds));

    return questionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accentSaffron),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading questions: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(questionsByIdsProvider(bookmarkIds)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(child: Text('Questions could not be retrieved.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final questionText = _getQuestionText(question, contentLang);
            final subjectLabel = question.subject.replaceAll('_', ' ').toUpperCase();
            final difficultyLabel = question.difficulty.toUpperCase();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.accentSaffron.withValues(alpha: 0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.accentSaffron,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  questionText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '$subjectLabel • $difficultyLabel',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark, color: AppColors.accentSaffron),
                  onPressed: () => toggleBookmark(context, ref, question.id),
                ),
                onTap: () {
                  context.push('/question-detail?questionId=${question.id}');
                },
              ),
            );
          },
        );
      },
    );
  }
}
