import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BookmarkedQuestionsScreen extends StatelessWidget {
  const BookmarkedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Questions'), backgroundColor: AppColors.primaryNavy,
        actions: [TextButton(onPressed: () {}, child: const Text('Quick Test', style: TextStyle(color: AppColors.accentSaffron)))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(backgroundColor: AppColors.accentSaffron.withValues(alpha: 0.1),
              child: Text('${i + 1}', style: const TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.bold))),
            title: Text('Bookmarked question ${i + 1}: Sample question text', style: const TextStyle(fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('General Studies • Medium', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ),
            trailing: IconButton(icon: const Icon(Icons.bookmark, color: AppColors.accentSaffron), onPressed: () {}),
          ),
        ),
      ),
    );
  }
}
