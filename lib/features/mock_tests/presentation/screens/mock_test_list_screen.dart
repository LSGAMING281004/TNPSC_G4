import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/models/mock_test_model.dart';
import '../../providers/test_providers.dart';

class MockTestListScreen extends ConsumerStatefulWidget {
  const MockTestListScreen({super.key});

  @override
  ConsumerState<MockTestListScreen> createState() => _MockTestListScreenState();
}

class _MockTestListScreenState extends ConsumerState<MockTestListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Tests'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Full Tests\n(100Q/90m)'),
            Tab(text: 'Subject Tests\n(50Q/45m)'),
            Tab(text: 'Chapter Tests\n(25Q/20m)'),
            Tab(text: 'Daily Quiz\n(10Q/10m)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TestListTab(testType: 'full'),
          _TestListTab(testType: 'subject'),
          _TestListTab(testType: 'chapter'),
          _TestListTab(testType: 'daily'),
        ],
      ),
    );
  }
}

class _TestListTab extends ConsumerWidget {
  final String testType;

  const _TestListTab({required this.testType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testListProvider(testType));

    return testsAsync.when(
      data: (tests) {
        if (tests.isEmpty) {
          return const Center(child: Text('No tests available in this category yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            test.nameEnglish,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Hard', // Example static difficulty
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(test.nameTamil, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.help_outline, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${test.questionCount} Qs', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 16),
                        Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${test.durationMinutes} mins', style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => context.push('/test/${test.id}'),
                          child: const Text('Start Test'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
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
      error: (e, _) => Center(child: Text('Error loading tests: $e')),
    );
  }
}
