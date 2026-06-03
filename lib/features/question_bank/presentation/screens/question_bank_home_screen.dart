import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/firestore_providers.dart';

class QuestionBankHomeScreen extends ConsumerStatefulWidget {
  const QuestionBankHomeScreen({super.key});

  @override
  ConsumerState<QuestionBankHomeScreen> createState() =>
      _QuestionBankHomeScreenState();
}

class _QuestionBankHomeScreenState
    extends ConsumerState<QuestionBankHomeScreen> {
  String _selectedSubject = 'All';
  String _selectedDifficulty = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsStreamProvider((
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      search: _searchController.text,
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () => context.push(AppRoutes.bookmarks)),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                    label: 'All',
                    selected: _selectedSubject == 'All',
                    onTap: () =>
                        setState(() => _selectedSubject = 'All')),
                _FilterChip(
                    label: 'Tamil',
                    selected: _selectedSubject == 'Tamil',
                    onTap: () =>
                        setState(() => _selectedSubject = 'Tamil')),
                _FilterChip(
                    label: 'General Studies',
                    selected: _selectedSubject == 'General Studies',
                    onTap: () => setState(
                        () => _selectedSubject = 'General Studies')),
                _FilterChip(
                    label: 'Aptitude',
                    selected:
                        _selectedSubject == 'Aptitude & Mental Ability',
                    onTap: () => setState(() =>
                        _selectedSubject = 'Aptitude & Mental Ability')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Easy',
                    selected: _selectedDifficulty == 'Easy',
                    onTap: () =>
                        setState(() => _selectedDifficulty = 'Easy'),
                    color: AppColors.difficultyEasy),
                _FilterChip(
                    label: 'Medium',
                    selected: _selectedDifficulty == 'Medium',
                    onTap: () =>
                        setState(() => _selectedDifficulty = 'Medium'),
                    color: AppColors.difficultyMedium),
                _FilterChip(
                    label: 'Hard',
                    selected: _selectedDifficulty == 'Hard',
                    onTap: () =>
                        setState(() => _selectedDifficulty = 'Hard'),
                    color: AppColors.difficultyHard),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Questions list
          Expanded(
            child: questionsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accentSaffron)),
              error: (_, __) => const Center(
                  child: Text('Error loading questions',
                      style: TextStyle(color: Colors.grey))),
              data: (questions) {
                if (questions.isEmpty) {
                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.quiz_outlined,
                          color: Colors.grey.shade300, size: 64),
                      const SizedBox(height: 12),
                      Text('No questions found',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  ));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final subject =
                        (q['subject'] as String?) ?? 'General';
                    final difficulty =
                        (q['difficulty'] as String?) ?? 'medium';
                    final questionText = (q['questionText'] as String?) ??
                        (q['question'] as String?) ??
                        'Question ${index + 1}';
                    final chapter = (q['chapter'] as String?) ?? '';
                    final subjectColor = _subjectColor(subject);
                    final diffColor = _difficultyColor(difficulty);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        onTap: () => context.push(
                            '${AppRoutes.questionDetail}?questionId=${q['id']}'),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: subjectColor
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    child: Text(subject,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: subjectColor)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: diffColor
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    child: Text(difficulty.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: diffColor)),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      icon: Icon(Icons.bookmark_border,
                                          size: 20,
                                          color: Colors.grey.shade400),
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints()),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Q${index + 1}. $questionText',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis),
                              if (chapter.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Chapter: $chapter',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _subjectColor(String subject) {
    if (subject.contains('Tamil')) return AppColors.tamilSubject;
    if (subject.contains('General')) return AppColors.gsSubject;
    return AppColors.aptitudeSubject;
  }

  Color _difficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy':
        return AppColors.difficultyEasy;
      case 'hard':
        return AppColors.difficultyHard;
      default:
        return AppColors.difficultyMedium;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accentSaffron;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? c.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? c : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? c : Colors.grey.shade600)),
        ),
      ),
    );
  }
}
