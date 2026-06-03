import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';

class StudyMaterialsHomeScreen extends ConsumerWidget {
  const StudyMaterialsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Materials'),
          backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            indicatorColor: AppColors.accentSaffron,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Tamil'),
              Tab(text: 'General Studies'),
              Tab(text: 'Aptitude')
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.download), onPressed: () {})
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
      error: (_, __) => const Center(
          child: Text('Error loading materials',
              style: TextStyle(color: Colors.grey))),
      data: (materials) {
        if (materials.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined,
                  color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              Text('No materials available yet',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Study materials will appear here once added',
                  style:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13)),
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
                onTap: () {},
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
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      if (isDownloadable)
                        IconButton(
                          icon: const Icon(Icons.download_rounded,
                              color: AppColors.accentSaffron),
                          onPressed: () {},
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
