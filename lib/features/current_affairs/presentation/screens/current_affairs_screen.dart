import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';

class CurrentAffairsScreen extends ConsumerWidget {
  const CurrentAffairsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Current Affairs'),
          backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            indicatorColor: AppColors.accentSaffron,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Monthly'),
              Tab(text: 'Search')
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DailyTab(), _MonthlyTab(), _SearchTab()],
        ),
      ),
    );
  }
}

class _DailyTab extends ConsumerWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affairsAsync = ref.watch(currentAffairsStreamProvider(20));

    return affairsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) => const Center(
          child: Text('Error loading articles',
              style: TextStyle(color: Colors.grey))),
      data: (articles) {
        if (articles.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.newspaper, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              Text('No current affairs yet',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (_, i) {
            final article = articles[i];
            final category =
                (article['category'] as String?) ?? 'General';
            final title =
                (article['title'] as String?) ?? 'News ${i + 1}';
            final body =
                (article['body'] as String?) ?? (article['summary'] as String?) ?? '';
            final color = _categoryColor(category);
            final timeAgo = _timeAgo(article['publishedAt']);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(category,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                        ),
                        const Spacer(),
                        Text(timeAgo,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(body,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tn politics':
        return AppColors.tamilSubject;
      case 'india':
        return AppColors.gsSubject;
      case 'economy':
        return AppColors.warning;
      case 'science':
        return AppColors.info;
      case 'sports':
        return AppColors.success;
      case 'education':
        return AppColors.aptitudeSubject;
      default:
        return AppColors.gsSubject;
    }
  }

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return '';
    }
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MonthlyTab extends ConsumerWidget {
  const _MonthlyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync =
        ref.watch(studyMaterialsStreamProvider('Current Affairs'));

    return materialsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) => const Center(
          child: Text('Error loading digests',
              style: TextStyle(color: Colors.grey))),
      data: (materials) {
        if (materials.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf,
                  color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              Text('No monthly digests yet',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (_, i) {
            final m = materials[i];
            final title =
                (m['title'] as String?) ?? 'Monthly Digest ${i + 1}';
            final pages = m['pages'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color:
                          AppColors.accentSaffron.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.picture_as_pdf,
                      color: AppColors.accentSaffron),
                ),
                title: Text(title),
                subtitle: Text(
                    pages > 0 ? '$pages pages' : '',
                    style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                    icon: const Icon(Icons.download_rounded,
                        color: AppColors.accentSaffron),
                    onPressed: () {}),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('current_affairs')
          .orderBy('publishedAt', descending: true)
          .limit(20)
          .get();
      final filtered = snap.docs
          .where((d) {
            final data = d.data();
            final title =
                (data['title'] as String?)?.toLowerCase() ?? '';
            final body =
                (data['body'] as String?)?.toLowerCase() ?? '';
            return title.contains(query.toLowerCase()) ||
                body.contains(query.toLowerCase());
          })
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
      setState(() => _results = filtered);
    } catch (_) {}
    setState(() => _searching = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search current affairs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: _search,
          ),
          const SizedBox(height: 16),
          if (_searching)
            const CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.accentSaffron)
          else if (_results.isEmpty)
            Column(children: [
              const SizedBox(height: 24),
              Icon(Icons.search, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Search for news topics',
                  style: TextStyle(color: Colors.grey.shade500)),
            ])
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final r = _results[i];
                  return ListTile(
                    title: Text((r['title'] as String?) ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        (r['category'] as String?) ?? '',
                        style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
