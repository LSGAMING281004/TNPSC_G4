import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/models/current_affairs_model.dart';
import '../../providers/current_affairs_providers.dart';

class CurrentAffairsScreen extends ConsumerStatefulWidget {
  const CurrentAffairsScreen({super.key});

  @override
  ConsumerState<CurrentAffairsScreen> createState() => _CurrentAffairsScreenState();
}

class _CurrentAffairsScreenState extends ConsumerState<CurrentAffairsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _periods = ['today', 'week', 'month', 'archive'];
  final List<String> _categories = ['All', 'TN_State', 'National', 'International', 'Economy', 'Science', 'Sports', 'Awards'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(caFilterProvider.notifier).setPeriod(_periods[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(caFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Affairs'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
            Tab(text: 'Archive'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = filter.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat.replaceAll('_', ' ')),
                    selected: isSelected,
                    onSelected: (_) => ref.read(caFilterProvider.notifier).setCategory(cat),
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          
          // List
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final asyncData = ref.watch(currentAffairsListProvider);
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currentAffairsListProvider);
                  },
                  child: asyncData.when(
                    data: (articles) {
                      if (articles.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('No articles found for the selected filters.')),
                          ],
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          return _CurrentAffairsCard(article: articles[index]);
                        },
                      );
                    },
                    loading: () => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      itemBuilder: (context, index) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    error: (e, _) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 100),
                        Center(child: Text('Error loading articles: $e\nPull to refresh.')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentAffairsCard extends StatelessWidget {
  final CurrentAffairsModel article;

  const _CurrentAffairsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    Color importanceColor = Colors.grey;
    if (article.importance == 'high') importanceColor = const Color(0xFFE74C3C);
    if (article.importance == 'medium') importanceColor = const Color(0xFFF5C518);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/current-affairs/${article.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.category.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.star, color: importanceColor, size: 16),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, yyyy').format(article.publishedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.titleTamil,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                article.titleEnglish,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (article.hasQuiz) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.quiz, size: 14, color: Color(0xFF2ECC71)),
                    const SizedBox(width: 4),
                    Text('Quiz Available', style: TextStyle(fontSize: 12, color: const Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
