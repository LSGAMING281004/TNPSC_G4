import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/question_model.dart';
import '../../providers/question_bank_providers.dart';

class QuestionBankHomeScreen extends ConsumerStatefulWidget {
  const QuestionBankHomeScreen({super.key});

  @override
  ConsumerState<QuestionBankHomeScreen> createState() => _QuestionBankHomeScreenState();
}

class _QuestionBankHomeScreenState extends ConsumerState<QuestionBankHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTamil = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(questionListProvider.notifier).loadMore();
      }
    });

    _searchController.addListener(() {
      ref.read(questionFilterProvider.notifier).updateQuery(_searchController.text);
      ref.read(questionListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: [
          Row(
            children: [
              const Text('EN', style: TextStyle(fontSize: 12)),
              Switch(
                value: _isTamil,
                onChanged: (val) => setState(() => _isTamil = val),
              ),
              const Text('TA', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search questions... / தேடுக...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Questions'),
                  Tab(text: 'Bookmarks'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllQuestionsTab(scrollController: _scrollController, isTamil: _isTamil),
          _BookmarksTab(isTamil: _isTamil),
        ],
      ),
    );
  }
}

class _AllQuestionsTab extends ConsumerWidget {
  final ScrollController scrollController;
  final bool isTamil;

  const _AllQuestionsTab({required this.scrollController, required this.isTamil});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionListProvider);

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(child: Text('No questions found matching your criteria.'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(questionListProvider.notifier).refresh();
          },
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: questions.length + 1, // +1 for loading indicator
            itemBuilder: (context, index) {
              if (index == questions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _QuestionCard(question: questions[index], isTamil: isTamil, index: index + 1);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _BookmarksTab extends ConsumerWidget {
  final bool isTamil;

  const _BookmarksTab({required this.isTamil});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedQuestionsProvider);

    return bookmarksAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(child: Text('You have no saved bookmarks.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return _QuestionCard(question: questions[index], isTamil: isTamil, index: index + 1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final QuestionModel question;
  final bool isTamil;
  final int index;

  const _QuestionCard({required this.question, required this.isTamil, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarkedIds.contains(question.id);

    final questionText = isTamil ? question.questionTamil : question.questionEnglish;
    final options = isTamil ? question.optionsTamil : question.optionsEnglish;
    final explanation = isTamil ? question.explanationTamil : question.explanationEnglish;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.subject.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                if (question.year > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${question.year}',
                      style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? const Color(0xFFE74C3C) : Colors.grey),
                  onPressed: () {
                    ref.read(bookmarksProvider.notifier).toggleBookmark(question.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Q$index. $questionText',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(4, (i) {
                  final isCorrect = i == question.correctOptionIndex;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect ? const Color(0xFF2ECC71).withValues(alpha: 0.1) : Colors.grey.shade50,
                      border: Border.all(color: isCorrect ? const Color(0xFF2ECC71) : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(String.fromCharCode(65 + i), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            options[i],
                            style: TextStyle(
                              color: isCorrect ? const Color(0xFF27AE60) : Colors.black87,
                              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCorrect) const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                if (explanation.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(explanation, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(questionFilterProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () {
                  ref.read(questionFilterProvider.notifier).clearFilters();
                  ref.read(questionListProvider.notifier).refresh();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),
                const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['general_tamil', 'general_english', 'general_knowledge', 'aptitude', 'mental_ability'].map((s) {
                    final isSelected = filter.subjects.contains(s);
                    return FilterChip(
                      label: Text(s.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (_) => ref.read(questionFilterProvider.notifier).toggleSubject(s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['easy', 'medium', 'hard'].map((d) {
                    final isSelected = filter.difficulties.contains(d);
                    return FilterChip(
                      label: Text(d.toUpperCase(), style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (_) => ref.read(questionFilterProvider.notifier).toggleDifficulty(d),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text('Previous Year Papers', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 2019, 2020, 2021, 2022, 2023, 2024].map((y) {
                    final isSelected = filter.years.contains(y);
                    return FilterChip(
                      label: Text(y == 0 ? 'New Questions' : '$y', style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (_) => ref.read(questionFilterProvider.notifier).toggleYear(y),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(questionListProvider.notifier).refresh();
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
