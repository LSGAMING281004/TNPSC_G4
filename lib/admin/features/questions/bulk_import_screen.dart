import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/models/question_model.dart';
import '../../shared/services/admin_activity_log_service.dart';
import '../../shared/widgets/admin_shell.dart';

/// CSV bulk import screen — paste or upload CSV, preview, validate, import.
class BulkImportScreen extends ConsumerStatefulWidget {
  const BulkImportScreen({super.key});
  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  final _csvCtrl = TextEditingController();
  List<List<String>> _parsed = [];
  List<String?> _errors = [];
  bool _importing = false;
  double _progress = 0;
  int _imported = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Bulk Import Questions';
    });
  }

  void _parseCSV() {
    final lines = _csvCtrl.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;
    // Skip header if first line contains 'subject'
    final start = lines.first.toLowerCase().contains('subject') ? 1 : 0;
    _parsed = [];
    _errors = [];
    for (var i = start; i < lines.length; i++) {
      final row = _parseCsvLine(lines[i]);
      _parsed.add(row);
      _errors.add(_validateRow(row, i - start));
    }
    setState(() {});
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(ch);
      }
    }
    result.add(current.toString());
    return result;
  }

  String? _validateRow(List<String> row, int index) {
    if (row.length < 17) return 'Row ${index + 1}: needs 18 cols, got ${row.length}';
    if (row[0].trim().isEmpty) return 'Row ${index + 1}: subject empty';
    if (row[3].trim().isEmpty && row[4].trim().isEmpty) return 'Row ${index + 1}: question text empty';
    final correct = row[13].trim().toUpperCase();
    if (!['A', 'B', 'C', 'D'].contains(correct)) return 'Row ${index + 1}: invalid correct answer "$correct"';
    final diff = row[16].trim();
    if (!AdminConstants.difficulties.contains(diff)) return 'Row ${index + 1}: invalid difficulty "$diff"';
    return null;
  }

  Future<void> _import() async {
    final valid = <QuestionModel>[];
    for (var i = 0; i < _parsed.length; i++) {
      if (_errors[i] == null) {
        try {
          valid.add(QuestionModel.fromCsvRow(_parsed[i]));
        } catch (_) {}
      }
    }
    if (valid.isEmpty) return;

    setState(() { _importing = true; _progress = 0; _imported = 0; });
    final fs = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Batch in groups of 500
    for (var i = 0; i < valid.length; i += 500) {
      final batch = fs.batch();
      final end = (i + 500).clamp(0, valid.length);
      for (var j = i; j < end; j++) {
        final ref = fs.collection(AdminConstants.questionsCollection).doc();
        final data = valid[j].toFirestore();
        data['createdBy'] = uid;
        batch.set(ref, data);
      }
      await batch.commit();
      _imported += (end - i);
      setState(() => _progress = _imported / valid.length);
    }

    await AdminActivityLogService.log(
      action: 'Bulk imported $_imported questions',
      targetCollection: AdminConstants.questionsCollection,
    );
    setState(() => _importing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $_imported questions successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final validCount = _errors.where((e) => e == null).length;
    final errorCount = _errors.where((e) => e != null).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Paste your CSV data below. Format: subject,chapter,topic,questionTa,questionEn,...',
        style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 12),
      TextFormField(
        controller: _csvCtrl,
        maxLines: 8,
        decoration: const InputDecoration(hintText: 'Paste CSV content here...', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      Row(children: [
        ElevatedButton.icon(
          onPressed: _parseCSV,
          icon: const Icon(Icons.preview, size: 18),
          label: const Text('Parse & Preview'),
        ),
        const SizedBox(width: 12),
        if (_parsed.isNotEmpty) Text('$validCount valid, $errorCount errors',
          style: TextStyle(color: errorCount > 0 ? AdminTheme.error : AdminTheme.success, fontWeight: FontWeight.w600)),
      ]),
      if (_importing) ...[
        const SizedBox(height: 16),
        LinearProgressIndicator(value: _progress, color: AdminTheme.saffron),
        const SizedBox(height: 4),
        Text('Importing... $_imported/${_errors.where((e) => e == null).length}'),
      ],
      if (_parsed.isNotEmpty && !_importing) ...[
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(border: Border.all(color: AdminTheme.border), borderRadius: BorderRadius.circular(8)),
          child: ListView.builder(
            itemCount: _parsed.length,
            itemBuilder: (_, i) {
              final hasError = _errors[i] != null;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: hasError ? AdminTheme.error.withValues(alpha: 0.05) : null,
                child: Row(children: [
                  Icon(hasError ? Icons.error_outline : Icons.check_circle_outline,
                    size: 16, color: hasError ? AdminTheme.error : AdminTheme.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    hasError ? _errors[i]! : '${_parsed[i][0]} / ${_parsed[i][1]} — ${_parsed[i][4].length > 50 ? _parsed[i][4].substring(0, 50) : _parsed[i][4]}...',
                    style: TextStyle(fontSize: 12, color: hasError ? AdminTheme.error : AdminTheme.textPrimary),
                  )),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: validCount > 0 ? _import : null,
          icon: const Icon(Icons.cloud_upload, size: 18),
          label: Text('Import $validCount valid rows'),
        ),
      ],
    ]);
  }

  @override
  void dispose() { _csvCtrl.dispose(); super.dispose(); }
}
