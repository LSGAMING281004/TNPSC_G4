import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/models/question_model.dart';
import '../../shared/services/admin_activity_log_service.dart';
import '../../shared/widgets/admin_shell.dart';

class AddEditQuestionScreen extends ConsumerStatefulWidget {
  final String? questionId;
  const AddEditQuestionScreen({super.key, this.questionId});
  @override
  ConsumerState<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends ConsumerState<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirebaseFirestore.instance;
  bool _saving = false;
  bool _isEdit = false;

  String _subject = 'Tamil';
  String _chapter = '';
  String _topic = '';
  String _difficulty = 'Medium';
  String _correct = 'A';
  bool _isPreviousYear = false;
  int? _year;

  final _qTa = TextEditingController();
  final _qEn = TextEditingController();
  final _oATa = TextEditingController();
  final _oAEn = TextEditingController();
  final _oBTa = TextEditingController();
  final _oBEn = TextEditingController();
  final _oCTa = TextEditingController();
  final _oCEn = TextEditingController();
  final _oDTa = TextEditingController();
  final _oDEn = TextEditingController();
  final _expTa = TextEditingController();
  final _expEn = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isEdit = widget.questionId != null;
    if (_isEdit) _loadQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = _isEdit ? 'Edit Question' : 'Add Question';
    });
  }

  Future<void> _loadQuestion() async {
    final doc = await _fs.collection(AdminConstants.questionsCollection).doc(widget.questionId).get();
    if (!doc.exists) return;
    final q = QuestionModel.fromFirestore(doc);
    setState(() {
      _subject = q.subject; _chapter = q.chapter; _topic = q.topic;
      _difficulty = q.difficulty; _correct = q.correct;
      _isPreviousYear = q.isPreviousYear; _year = q.year;
      _qTa.text = q.questionTa; _qEn.text = q.questionEn;
      _oATa.text = q.optionATa; _oAEn.text = q.optionAEn;
      _oBTa.text = q.optionBTa; _oBEn.text = q.optionBEn;
      _oCTa.text = q.optionCTa; _oCEn.text = q.optionCEn;
      _oDTa.text = q.optionDTa; _oDEn.text = q.optionDEn;
      _expTa.text = q.explanationTa; _expEn.text = q.explanationEn;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final model = QuestionModel(
        subject: _subject, chapter: _chapter, topic: _topic,
        questionTa: _qTa.text, questionEn: _qEn.text,
        optionATa: _oATa.text, optionAEn: _oAEn.text,
        optionBTa: _oBTa.text, optionBEn: _oBEn.text,
        optionCTa: _oCTa.text, optionCEn: _oCEn.text,
        optionDTa: _oDTa.text, optionDEn: _oDEn.text,
        correct: _correct, explanationTa: _expTa.text, explanationEn: _expEn.text,
        difficulty: _difficulty, isPreviousYear: _isPreviousYear, year: _year,
        createdBy: FirebaseAuth.instance.currentUser?.uid,
      );
      if (_isEdit) {
        await _fs.collection(AdminConstants.questionsCollection).doc(widget.questionId).update(model.toFirestore());
      } else {
        await _fs.collection(AdminConstants.questionsCollection).add(model.toFirestore());
      }
      await AdminActivityLogService.log(
        action: _isEdit ? 'Updated question' : 'Added question',
        targetCollection: AdminConstants.questionsCollection,
        targetId: widget.questionId ?? 'new',
      );
      if (mounted) context.go('/admin/questions');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Meta row
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 200, child: DropdownButtonFormField<String>(
              initialValue: _subject, decoration: const InputDecoration(labelText: 'Subject'),
              items: AdminConstants.defaultSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _subject = v!),
            )),
            SizedBox(width: 200, child: TextFormField(
              initialValue: _chapter,
              decoration: const InputDecoration(labelText: 'Chapter'),
              onChanged: (v) => _chapter = v,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            SizedBox(width: 200, child: TextFormField(
              initialValue: _topic,
              decoration: const InputDecoration(labelText: 'Topic'),
              onChanged: (v) => _topic = v,
            )),
            SizedBox(width: 150, child: DropdownButtonFormField<String>(
              initialValue: _difficulty, decoration: const InputDecoration(labelText: 'Difficulty'),
              items: AdminConstants.difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
            )),
          ]),
          const SizedBox(height: 20),
          // Question text
          _sectionLabel('Question Text'),
          TextFormField(controller: _qTa, decoration: const InputDecoration(labelText: 'Tamil'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 8),
          TextFormField(controller: _qEn, decoration: const InputDecoration(labelText: 'English'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 20),
          // Options
          _sectionLabel('Options'),
          for (final entry in [
            ('A', _oATa, _oAEn), ('B', _oBTa, _oBEn),
            ('C', _oCTa, _oCEn), ('D', _oDTa, _oDEn),
          ]) ...[
            Row(children: [
              Radio<String>(value: entry.$1, groupValue: _correct, onChanged: (v) => setState(() => _correct = v!), activeColor: AdminTheme.saffron),
              Text('Option ${entry.$1}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            Row(children: [
              Expanded(child: TextFormField(controller: entry.$2, decoration: const InputDecoration(hintText: 'Tamil'), validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: entry.$3, decoration: const InputDecoration(hintText: 'English'), validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 20),
          // Explanation
          _sectionLabel('Explanation'),
          TextFormField(controller: _expTa, decoration: const InputDecoration(labelText: 'Tamil'), maxLines: 3),
          const SizedBox(height: 8),
          TextFormField(controller: _expEn, decoration: const InputDecoration(labelText: 'English'), maxLines: 3),
          const SizedBox(height: 20),
          // Previous year toggle
          Row(children: [
            Switch(value: _isPreviousYear, onChanged: (v) => setState(() => _isPreviousYear = v), activeThumbColor: AdminTheme.saffron),
            const Text('Previous Year Question'),
            if (_isPreviousYear) ...[
              const SizedBox(width: 12),
              SizedBox(width: 100, child: TextFormField(
                initialValue: _year?.toString(),
                decoration: const InputDecoration(hintText: 'Year'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _year = int.tryParse(v),
              )),
            ],
          ]),
          const SizedBox(height: 32),
          // Save
          Row(children: [
            OutlinedButton(onPressed: () => context.go('/admin/questions'), child: const Text('Cancel')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Update Question' : 'Add Question'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
  );

  @override
  void dispose() {
    for (final c in [_qTa, _qEn, _oATa, _oAEn, _oBTa, _oBEn, _oCTa, _oCEn, _oDTa, _oDEn, _expTa, _expEn]) {
      c.dispose();
    }
    super.dispose();
  }
}
