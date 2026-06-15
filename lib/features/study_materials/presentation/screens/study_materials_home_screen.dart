import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/providers/download_notifier.dart';

class StudyMaterialsHomeScreen extends ConsumerWidget {
  const StudyMaterialsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Materials'),
          bottom: TabBar(
            indicatorColor: AppColors.accentSaffron,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Tamil'),
              Tab(text: 'General Studies'),
              Tab(text: 'Aptitude')
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => context.push('/download-manager'),
            )
          ],
        ),
        body: const TabBarView(
          children: [
            _SubjectMaterialsList(subject: 'Tamil'),
            _SubjectMaterialsList(subject: 'General Studies'),
            _SubjectMaterialsList(subject: 'Aptitude & Mental Ability'),
          ],
        ),
      ),
    );
  }
}

class _SubjectMaterialsList extends ConsumerWidget {
  final String subject;
  const _SubjectMaterialsList({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(studyMaterialsStreamProvider(subject));

    return materialsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) => Center(
          child: Text('Error loading materials',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))),
      data: (materials) {
        if (materials.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 64),
              const SizedBox(height: 12),
              Text('No materials available yet',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16)),
              const SizedBox(height: 4),
              Text('Study materials will appear here once added',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (_, i) {
            final material = materials[i];
            final title = (material['title'] as String?) ??
                (material['chapter'] as String?) ??
                'Study Material ${i + 1}';
            final pages = material['pages'] ?? 0;
            final sizeMB = material['sizeMB'] ?? 0;
            final fileUrl = material['fileUrl'] as String?;
            final isDownloadable = fileUrl != null && fileUrl.isNotEmpty;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: InkWell(
                onTap: () => context.push('/study/${material['id']}'),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color:
                                AppColors.accentSaffron.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(
                          material['type'] == 'video'
                              ? Icons.play_circle_fill
                              : Icons.picture_as_pdf,
                          color: AppColors.accentSaffron,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                                '${pages > 0 ? '$pages pages • ' : ''}${sizeMB > 0 ? '$sizeMB MB' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      if (isDownloadable)
                        Builder(
                          builder: (context) {
                            final progress = ref.watch(materialDownloadProgressProvider(material['id']));
                            final isDownloaded = ref.watch(isMaterialDownloadedProvider(material['id']));

                            if (progress != null) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 2.5,
                                    color: AppColors.accentSaffron,
                                  ),
                                ),
                              );
                            }

                            return IconButton(
                              icon: Icon(
                                isDownloaded ? Icons.download_done : Icons.download_rounded,
                                color: isDownloaded ? AppColors.success : AppColors.accentSaffron,
                              ),
                              onPressed: () {
                                ref.read(activeDownloadsProvider.notifier).download(
                                      context: context,
                                      materialId: material['id'],
                                      title: title,
                                      fileUrl: fileUrl,
                                    );
                              },
                            );
                          }
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color:
                                  AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('Read',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
