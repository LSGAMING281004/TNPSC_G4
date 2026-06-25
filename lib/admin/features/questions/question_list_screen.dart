import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/models/question_model.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

final questionFilterSubjectProvider = StateProvider<String?>((ref) => null);
final questionFilterDifficultyProvider = StateProvider<String?>((ref) => null);
final questionSearchProvider = StateProvider<String>((ref) => '');

final questionsStreamProvider = StreamProvider<List<QuestionModel>>((ref) {
  Query q = _fs.collection(AdminConstants.questionsCollection);
  final sub = ref.watch(questionFilterSubjectProvider);
  if (sub != null) q = q.where('subject', isEqualTo: sub);
  final diff = ref.watch(questionFilterDifficultyProvider);
  if (diff != null) q = q.where('difficulty', isEqualTo: diff);
  final search = ref.watch(questionSearchProvider);
  if (search.isNotEmpty) q = q.where('searchTokens', arrayContains: search.toLowerCase());
  return q.orderBy('createdAt', descending: true).limit(100).snapshots()
      .map((s) => s.docs.map((d) => QuestionModel.fromFirestore(d)).toList());
});

class QuestionListScreen extends ConsumerStatefulWidget {
  const QuestionListScreen({super.key});
  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Question Bank';
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final qAsync = ref.watch(questionsStreamProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Action bar
      Wrap(spacing: 12, runSpacing: 8, children: [
        SizedBox(width: 260, height: 42, child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(hintText: 'Search...', prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          onSubmitted: (v) => ref.read(questionSearchProvider.notifier).state = v,
        )),
        SizedBox(width: 160, height: 48, child: DropdownButtonFormField<String>(
          isDense: true,
          decoration: InputDecoration(hintText: 'Subject', contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          initialValue: ref.watch(questionFilterSubjectProvider),
          items: [const DropdownMenuItem(value: null, child: Text('All')),
            ...AdminConstants.defaultSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s)))],
          onChanged: (v) => ref.read(questionFilterSubjectProvider.notifier).state = v,
        )),
        SizedBox(width: 130, height: 48, child: DropdownButtonFormField<String>(
          isDense: true,
          decoration: InputDecoration(hintText: 'Difficulty', contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          initialValue: ref.watch(questionFilterDifficultyProvider),
          items: [const DropdownMenuItem(value: null, child: Text('All')),
            ...AdminConstants.difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d)))],
          onChanged: (v) => ref.read(questionFilterDifficultyProvider.notifier).state = v,
        )),
        ElevatedButton.icon(onPressed: () => context.go('/admin/questions/add'),
          icon: const Icon(Icons.add, size: 18), label: const Text('Add Question')),
        OutlinedButton.icon(onPressed: () => context.go('/admin/questions/import'),
          icon: const Icon(Icons.upload_file, size: 18), label: const Text('Import CSV')),
      ]),
      const SizedBox(height: 16),
      // Table
      qAsync.when(
        data: (questions) {
          if (questions.isEmpty) return const AdminEmptyState(icon: Icons.quiz_outlined, message: 'No questions found.');
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: IntrinsicWidth(
              child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
                headingRowColor: WidgetStateProperty.all(AdminTheme.background),
                columns: const [
                  DataColumn(label: Text('#')), DataColumn(label: Text('Subject')),
                  DataColumn(label: Text('Chapter')), DataColumn(label: Text('Difficulty')),
                  DataColumn(label: Text('Preview')), DataColumn(label: Text('Actions')),
                ],
                rows: questions.asMap().entries.map((e) {
                  final i = e.key; final q = e.value;
                  return DataRow(cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(_badge(q.subject, _subjectColor(q.subject))),
                    DataCell(Text(q.chapter, overflow: TextOverflow.ellipsis)),
                    DataCell(_badge(q.difficulty, _diffColor(q.difficulty))),
                    DataCell(SizedBox(width: 300, child: Text(q.questionEn.isNotEmpty ? q.questionEn : q.questionTa, overflow: TextOverflow.ellipsis))),
                    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => context.go('/admin/questions/edit?id=${q.id}')),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                        onPressed: () async {
                          final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                            title: const Text('Delete?'), actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.pop(c, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.error), child: const Text('Delete')),
                            ]));
                          if (ok == true) await _fs.collection(AdminConstants.questionsCollection).doc(q.id).delete();
                        }),
                    ])),
                  ]);
                }).toList(),
              )),
            ),
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    ]);
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)));

  Color _subjectColor(String s) => s == 'Tamil' ? const Color(0xFF9B59B6) : s == 'General Studies' ? const Color(0xFF2980B9) : const Color(0xFF27AE60);
  Color _diffColor(String d) => d == 'Easy' ? AdminTheme.success : d == 'Hard' ? AdminTheme.error : AdminTheme.warning;
}
