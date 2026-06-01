import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StudyMaterialsHomeScreen extends StatelessWidget {
  const StudyMaterialsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Materials'), backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            indicatorColor: AppColors.accentSaffron, labelColor: Colors.white, unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: 'Tamil'), Tab(text: 'General Studies'), Tab(text: 'Aptitude')],
          ),
          actions: [IconButton(icon: const Icon(Icons.download), onPressed: () {})],
        ),
        body: TabBarView(
          children: [
            _SubjectMaterialsList(subject: 'Tamil', chapters: ['Tamil Grammar', 'Tamil Literature', 'Tamil Comprehension', 'Thirukkural']),
            _SubjectMaterialsList(subject: 'GS', chapters: ['Indian History', 'Geography', 'Indian Polity', 'Economy', 'Science', 'Current Affairs']),
            _SubjectMaterialsList(subject: 'Aptitude', chapters: ['Number System', 'Percentage', 'Time & Distance', 'Coding-Decoding', 'Blood Relations']),
          ],
        ),
      ),
    );
  }
}

class _SubjectMaterialsList extends StatelessWidget {
  final String subject;
  final List<String> chapters;
  const _SubjectMaterialsList({required this.subject, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (_, i) {
        final downloaded = i < 2;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.accentSaffron.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.picture_as_pdf, color: AppColors.accentSaffron),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapters[i], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('${(i + 1) * 12} pages • ${(i + 1) * 2.5} MB', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  downloaded
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Read', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.download_rounded, color: AppColors.accentSaffron),
                          onPressed: () {},
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
