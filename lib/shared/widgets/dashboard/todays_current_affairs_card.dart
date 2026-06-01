import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TodaysCurrentAffairsCard extends StatelessWidget {
  const TodaysCurrentAffairsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Today's Current Affairs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppColors.accentSaffron, fontSize: 13))),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(3, (i) => _NewsCard(
          title: ['Tamil Nadu Budget 2026 Highlights', 'New Education Policy Updates', 'TNPSC Exam Date Announced'][i],
          category: ['Economy', 'Education', 'TNPSC'][i],
          time: ['2h ago', '4h ago', '6h ago'][i],
          color: [AppColors.gsSubject, AppColors.success, AppColors.accentSaffron][i],
        )),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final Color color;

  const _NewsCard({required this.title, required this.category, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.newspaper, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(category, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
