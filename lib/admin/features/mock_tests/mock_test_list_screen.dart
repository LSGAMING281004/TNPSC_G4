import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/models/mock_test_model.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

final mockTestsStreamProvider = StreamProvider<List<MockTestModel>>((ref) {
  return _fs.collection(AdminConstants.mockTestsCollection)
      .orderBy('createdAt', descending: true).snapshots()
      .map((s) => s.docs.map((d) => MockTestModel.fromFirestore(d)).toList());
});

class MockTestListScreen extends ConsumerStatefulWidget {
  const MockTestListScreen({super.key});
  @override
  ConsumerState<MockTestListScreen> createState() => _MockTestListScreenState();
}

class _MockTestListScreenState extends ConsumerState<MockTestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Mock Tests';
    });
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(mockTestsStreamProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ElevatedButton.icon(onPressed: () => context.go('/admin/mock-tests/create'),
          icon: const Icon(Icons.add, size: 18), label: const Text('Create Mock Test')),
      ]),
      const SizedBox(height: 16),
      testsAsync.when(
        data: (tests) {
          if (tests.isEmpty) return const AdminEmptyState(icon: Icons.assignment_outlined, message: 'No mock tests yet.');
          return Wrap(spacing: 16, runSpacing: 16, children: tests.map((t) => _MockTestCard(test: t)).toList());
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    ]);
  }
}

class _MockTestCard extends StatelessWidget {
  final MockTestModel test;
  const _MockTestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final statusColor = test.status == 'Active' ? AdminTheme.success
        : test.status == 'Archived' ? AdminTheme.textSecondary : AdminTheme.warning;
    return Container(
      width: 320, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(test.titleEn.isNotEmpty ? test.titleEn : test.titleTa,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(test.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        _infoRow(Icons.quiz_outlined, '${test.totalQuestions} questions'),
        _infoRow(Icons.timer_outlined, '${test.durationMinutes} minutes'),
        _infoRow(Icons.category_outlined, test.type),
        if (test.subject != null) _infoRow(Icons.subject_outlined, test.subject!),
        const SizedBox(height: 12),
        Row(children: [
          _actionBtn(Icons.edit_outlined, 'Edit', () => context.go('/admin/mock-tests/edit?id=${test.id}')),
          const SizedBox(width: 8),
          _actionBtn(Icons.delete_outline, 'Delete', () async {
            await _fs.collection(AdminConstants.mockTestsCollection).doc(test.id).delete();
          }, color: AdminTheme.error),
          const Spacer(),
          if (test.status == 'Draft')
            _actionBtn(Icons.check_circle_outline, 'Activate', () async {
              await _fs.collection(AdminConstants.mockTestsCollection).doc(test.id).update({'status': 'Active'});
            }, color: AdminTheme.success),
        ]),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, size: 14, color: AdminTheme.textSecondary),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary)),
    ]),
  );

  Widget _actionBtn(IconData icon, String tip, VoidCallback onTap, {Color? color}) =>
    Tooltip(message: tip, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6),
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18, color: color ?? AdminTheme.textSecondary))));
}
