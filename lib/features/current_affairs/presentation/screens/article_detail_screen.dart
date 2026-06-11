import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/current_affairs_model.dart';
import '../../providers/current_affairs_providers.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const ArticleDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _isTamil = true;

  List<String> _extractKeyPoints(String text) {
    // Basic auto-extraction: splitting by newlines or formatting as bullets
    if (text.isEmpty) return [];
    final points = text.split('\n').where((s) => s.trim().length > 10).toList();
    if (points.length <= 1) {
      // fallback split by sentences
      return text.split('. ').where((s) => s.trim().length > 10).map((s) => s.endsWith('.') ? s : '$s.').toList();
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(currentAffairDetailProvider(widget.id));

    return Scaffold(
      body: articleAsync.when(
        data: (article) {
          final title = _isTamil ? article.titleTamil : article.titleEnglish;
          final content = _isTamil ? article.contentTamil : article.contentEnglish;
          final keyPoints = _extractKeyPoints(content);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(article.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).colorScheme.primary, const Color(0xFF152A4A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(child: Icon(Icons.newspaper, size: 80, color: Colors.white24)),
                        ),
                ),
                actions: [
                  Row(
                    children: [
                      const Text('EN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Switch(
                        value: _isTamil,
                        onChanged: (val) => setState(() => _isTamil = val),
                        activeThumbColor: Theme.of(context).colorScheme.secondary,
                      ),
                      const Text('TA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article.category.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(article.publishedAt),
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.4)),
                      const SizedBox(height: 24),
                      
                      // Key Points Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.psychology, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 8),
                                Text('Key Points', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...keyPoints.map((point) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(point, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
                      ),
                      const SizedBox(height: 100), // padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading article: $e')),
      ),
      floatingActionButton: articleAsync.hasValue && articleAsync.value!.hasQuiz
          ? FloatingActionButton.extended(
              onPressed: () {
                // Show quiz bottom sheet or navigate
                _showQuiz(context, articleAsync.value!);
              },
              backgroundColor: const Color(0xFF2ECC71),
              icon: const Icon(Icons.quiz, color: Colors.white),
              label: const Text('Take Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  void _showQuiz(BuildContext context, CurrentAffairsModel article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Quick Quiz', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Test your understanding of this article', style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 32),
              Expanded(
                child: Center(child: Text('Quiz module integration goes here...')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
