import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DownloadManagerScreen extends StatelessWidget {
  const DownloadManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.storage, color: AppColors.info),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Storage Used', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('45 MB / 500 MB', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                  ],
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Clear All', style: TextStyle(color: AppColors.error))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.accentSaffron),
                  title: Text('Chapter ${i + 1} - Study Material'),
                  subtitle: Text('${(i + 1) * 5} MB • Downloaded on May ${20 + i}'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () {}),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
