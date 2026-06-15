import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/providers/download_notifier.dart';

class DownloadManagerScreen extends ConsumerWidget {
  const DownloadManagerScreen({super.key});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return '${dBytes.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (_) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final downloadedList = ref.watch(downloadedMaterialsProvider);

    // Compute total bytes used
    final totalBytes = downloadedList.fold<int>(0, (sum, item) {
      final bytes = item['fileSizeBytes'] as int? ?? 0;
      return sum + bytes;
    });

    const maxCapacityBytes = 500 * 1024 * 1024; // 500 MB
    final exceedsCapacity = totalBytes > maxCapacityBytes;
    final progressFraction = (totalBytes / maxCapacityBytes).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: exceedsCapacity
                  ? AppColors.error.withValues(alpha: 0.08)
                  : AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.storage,
                      color: exceedsCapacity ? AppColors.error : AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Storage Used', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '${_formatBytes(totalBytes)} / 500 MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: exceedsCapacity
                                ? AppColors.error
                                : (isDark ? Colors.grey.shade400 : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (downloadedList.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Clear all downloads?',
                            message: 'This will remove all downloaded files from your device.',
                            confirmLabel: 'Clear All',
                            isDestructive: true,
                            icon: Icons.delete_sweep,
                          );
                          if (confirmed) {
                            if (context.mounted) {
                              await ref.read(activeDownloadsProvider.notifier).clearAll(context);
                            }
                          }
                        },
                        child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressFraction,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      exceedsCapacity ? AppColors.error : AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: downloadedList.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: downloadedList.length,
                    itemBuilder: (context, index) {
                      final item = downloadedList[index];
                      final title = item['title'] as String? ?? 'Study Material';
                      final bytes = item['fileSizeBytes'] as int? ?? 0;
                      final dateStr = item['downloadedAt'] as String? ?? '';
                      final materialId = item['materialId'] as String? ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: AppColors.accentSaffron),
                          title: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${_formatBytes(bytes)} • Downloaded on ${_formatDate(dateStr)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: 'Delete Download?',
                                message: 'Are you sure you want to delete "$title"?',
                                confirmLabel: 'Delete',
                                isDestructive: true,
                                icon: Icons.delete_outline,
                              );
                              if (confirmed) {
                                if (context.mounted) {
                                  await ref
                                      .read(activeDownloadsProvider.notifier)
                                      .deleteDownload(context, materialId);
                                }
                              }
                            },
                          ),
                          onTap: () {
                            if (materialId.isNotEmpty) {
                              context.push('/study/$materialId');
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_download_outlined,
                size: 64,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No downloads yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Study materials you download will appear here so you can read them offline anytime.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.library_books),
              label: const Text('Go to Study Materials'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.go('/home/materials');
              },
            ),
          ],
        ),
      ),
    );
  }
}
