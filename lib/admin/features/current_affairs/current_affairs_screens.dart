import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/models/content_models.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/services/admin_activity_log_service.dart';

final _fs = FirebaseFirestore.instance;

final caStreamProvider = StreamProvider<List<CurrentAffairsModel>>((ref) {
  return _fs.collection(AdminConstants.currentAffairsCollection)
      .orderBy('publishedAt', descending: true).limit(100).snapshots()
      .map((s) => s.docs.map((d) => CurrentAffairsModel.fromFirestore(d)).toList());
});

class CurrentAffairsListScreen extends ConsumerStatefulWidget {
  const CurrentAffairsListScreen({super.key});
  @override
  ConsumerState<CurrentAffairsListScreen> createState() => _CurrentAffairsListScreenState();
}

class _CurrentAffairsListScreenState extends ConsumerState<CurrentAffairsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Current Affairs';
    });
  }

  @override
  Widget build(BuildContext context) {
    final caAsync = ref.watch(caStreamProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ElevatedButton.icon(onPressed: () => context.go('/admin/current-affairs/add'),
        icon: const Icon(Icons.add, size: 18), label: const Text('Add Article')),
      const SizedBox(height: 16),
      caAsync.when(
        data: (items) {
          if (items.isEmpty) return const AdminEmptyState(icon: Icons.newspaper_outlined, message: 'No current affairs articles yet.');
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
              headingRowColor: WidgetStateProperty.all(AdminTheme.background),
              columns: const [
                DataColumn(label: Text('Date')), DataColumn(label: Text('Title')),
                DataColumn(label: Text('Category')), DataColumn(label: Text('Status')),
                DataColumn(label: Text('Quiz?')), DataColumn(label: Text('Actions')),
              ],
              rows: items.map((a) => DataRow(cells: [
                DataCell(Text(a.publishedAt != null ? DateFormat('MMM dd').format(a.publishedAt!) : '—')),
                DataCell(SizedBox(width: 250, child: Text(a.titleEn.isNotEmpty ? a.titleEn : a.titleTa, overflow: TextOverflow.ellipsis))),
                DataCell(Text(a.category)),
                DataCell(_statusBadge(a.status)),
                DataCell(Icon(a.isQuiz ? Icons.check_circle : Icons.remove, size: 16,
                  color: a.isQuiz ? AdminTheme.success : AdminTheme.textSecondary)),
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => context.go('/admin/current-affairs/edit?id=${a.id}')),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                    onPressed: () => _fs.collection(AdminConstants.currentAffairsCollection).doc(a.id).delete()),
                ])),
              ])).toList(),
            )),
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    ]);
  }

  Widget _statusBadge(String s) {
    final c = s == 'Published' ? AdminTheme.success : s == 'Archived' ? AdminTheme.textSecondary : AdminTheme.warning;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(s, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)));
  }
}

// ─── Add/Edit Article ───
class AddEditArticleScreen extends ConsumerStatefulWidget {
  final String? articleId;
  const AddEditArticleScreen({super.key, this.articleId});
  @override
  ConsumerState<AddEditArticleScreen> createState() => _AddEditArticleScreenState();
}

class _AddEditArticleScreenState extends ConsumerState<AddEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false, _isQuiz = false;
  String _category = 'Tamil Nadu', _status = 'Draft';
  final _titleTa = TextEditingController(), _titleEn = TextEditingController();
  final _summaryTa = TextEditingController(), _summaryEn = TextEditingController();
  final _contentTa = TextEditingController(), _contentEn = TextEditingController();
  final _source = TextEditingController(), _sourceUrl = TextEditingController();
  DateTime _pubDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.articleId != null) _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = widget.articleId != null ? 'Edit Article' : 'Add Current Affairs';
    });
  }

  Future<void> _load() async {
    final doc = await _fs.collection(AdminConstants.currentAffairsCollection).doc(widget.articleId).get();
    if (!doc.exists) return;
    final a = CurrentAffairsModel.fromFirestore(doc);
    setState(() {
      _category = a.category; _status = a.status; _isQuiz = a.isQuiz;
      _titleTa.text = a.titleTa; _titleEn.text = a.titleEn;
      _summaryTa.text = a.summaryTa; _summaryEn.text = a.summaryEn;
      _contentTa.text = a.contentTa; _contentEn.text = a.contentEn;
      _source.text = a.sourceName; _sourceUrl.text = a.sourceUrl;
      if (a.publishedAt != null) _pubDate = a.publishedAt!;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = CurrentAffairsModel(
        publishedAt: _pubDate, category: _category,
        titleTa: _titleTa.text, titleEn: _titleEn.text,
        summaryTa: _summaryTa.text, summaryEn: _summaryEn.text,
        contentTa: _contentTa.text, contentEn: _contentEn.text,
        sourceName: _source.text, sourceUrl: _sourceUrl.text,
        isQuiz: _isQuiz, status: _status,
      ).toFirestore();
      if (widget.articleId != null) {
        await _fs.collection(AdminConstants.currentAffairsCollection).doc(widget.articleId).update(data);
      } else {
        await _fs.collection(AdminConstants.currentAffairsCollection).add(data);
      }
      await AdminActivityLogService.log(action: widget.articleId != null ? 'Updated article' : 'Added article', targetCollection: AdminConstants.currentAffairsCollection);
      if (mounted) context.go('/admin/current-affairs');
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(constraints: const BoxConstraints(maxWidth: 700), child: Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(initialValue: _category, decoration: const InputDecoration(labelText: 'Category'),
            items: AdminConstants.caCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!))),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<String>(initialValue: _status, decoration: const InputDecoration(labelText: 'Status'),
            items: ['Draft', 'Published', 'Archived'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _status = v!))),
        ]),
        const SizedBox(height: 12),
        TextFormField(controller: _titleTa, decoration: const InputDecoration(labelText: 'Title (Tamil)'), validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 8),
        TextFormField(controller: _titleEn, decoration: const InputDecoration(labelText: 'Title (English)'), validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _summaryTa, decoration: InputDecoration(labelText: 'Summary Tamil', counterText: '${_summaryTa.text.length}/300'), maxLines: 2, maxLength: 300),
        TextFormField(controller: _summaryEn, decoration: InputDecoration(labelText: 'Summary English', counterText: '${_summaryEn.text.length}/300'), maxLines: 2, maxLength: 300),
        const SizedBox(height: 12),
        TextFormField(controller: _contentTa, decoration: const InputDecoration(labelText: 'Content (Tamil)'), maxLines: 5),
        const SizedBox(height: 8),
        TextFormField(controller: _contentEn, decoration: const InputDecoration(labelText: 'Content (English)'), maxLines: 5),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: _source, decoration: const InputDecoration(labelText: 'Source Name'))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: _sourceUrl, decoration: const InputDecoration(labelText: 'Source URL'))),
        ]),
        const SizedBox(height: 12),
        SwitchListTile(title: const Text('Quiz Question?'), value: _isQuiz, onChanged: (v) => setState(() => _isQuiz = v), activeThumbColor: AdminTheme.saffron),
        const SizedBox(height: 24),
        Row(children: [
          OutlinedButton(onPressed: () => context.go('/admin/current-affairs'), child: const Text('Cancel')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _saving ? null : _save, child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(widget.articleId != null ? 'Update' : 'Publish')),
        ]),
      ])));
  }

  @override
  void dispose() {
    for (final c in [_titleTa, _titleEn, _summaryTa, _summaryEn, _contentTa, _contentEn, _source, _sourceUrl]) {
      c.dispose();
    }
    super.dispose();
  }
}
