import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/firestore_providers.dart';

class TodaysCurrentAffairsCard extends ConsumerWidget {
  const TodaysCurrentAffairsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affairsAsync = ref.watch(currentAffairsStreamProvider(3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Today's Current Affairs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
                onPressed: () => context.push(AppRoutes.currentAffairs),
                child: const Text('View All',
                    style: TextStyle(
                        color: AppColors.accentSaffron, fontSize: 13))),
          ],
        ),
        const SizedBox(height: 8),
        affairsAsync.when(
          loading: () => const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.accentSaffron),
          )),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Unable to load current affairs',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No current affairs yet.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              );
            }
            return Column(
              children: articles.map((article) {
                final category =
                    (article['category'] as String?) ?? 'General';
                final color = _categoryColor(category);
                final title = (article['title'] as String?) ?? 'Untitled';
                final timeAgo = _timeAgo(article['publishedAt']);
                return _NewsCard(
                    title: title,
                    category: category,
                    time: timeAgo,
                    color: color);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'economy':
        return AppColors.gsSubject;
      case 'education':
        return AppColors.success;
      case 'tnpsc':
        return AppColors.accentSaffron;
      case 'science':
        return AppColors.info;
      case 'sports':
      case 'tn politics':
        return AppColors.tamilSubject;
      default:
        return AppColors.warning;
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

class _NewsCard extends StatelessWidget {
  final String title, category, time;
  final Color color;
  const _NewsCard(
      {required this.title,
      required this.category,
      required this.time,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.currentAffairs),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.newspaper, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(category,
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(time,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
