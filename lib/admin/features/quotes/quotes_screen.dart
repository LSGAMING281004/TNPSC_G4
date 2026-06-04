import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/services/admin_activity_log_service.dart';

final _fs = FirebaseFirestore.instance;

// Quote model representing the Daily Inspiration quote
class QuoteModel {
  final String id;
  final String ta;
  final String en;
  final DateTime? createdAt;

  QuoteModel({
    required this.id,
    required this.ta,
    required this.en,
    this.createdAt,
  });

  factory QuoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuoteModel(
      id: doc.id,
      ta: data['ta'] ?? '',
      en: data['en'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ta': ta,
      'en': en,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

// Provider to stream quotes from Firestore
final adminQuotesStreamProvider = StreamProvider<List<QuoteModel>>((ref) {
  return _fs.collection(AdminConstants.quotesCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => QuoteModel.fromFirestore(d)).toList());
});

class QuotesListScreen extends ConsumerStatefulWidget {
  const QuotesListScreen({super.key});

  @override
  ConsumerState<QuotesListScreen> createState() => _QuotesListScreenState();
}

class _QuotesListScreenState extends ConsumerState<QuotesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Daily Inspiration';
    });
  }

  void _showAddEditDialog([QuoteModel? quote]) {
    showDialog(
      context: context,
      builder: (context) => _AddEditQuoteDialog(quote: quote),
    );
  }

  Future<void> _deleteQuote(QuoteModel quote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: const Text('Are you sure you want to delete this quote?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _fs.collection(AdminConstants.quotesCollection).doc(quote.id).delete();
      await AdminActivityLogService.log(
        action: 'Deleted quote',
        targetCollection: AdminConstants.quotesCollection,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quotesAsync = ref.watch(adminQuotesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddEditDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add New Quote'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.saffron,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 20),
        quotesAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const AdminEmptyState(
                icon: Icons.format_quote_rounded,
                message: 'No inspirational quotes found. Add some to display on the dashboard!',
              );
            }
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AdminTheme.background),
                  columns: const [
                    DataColumn(label: Text('Tamil Text')),
                    DataColumn(label: Text('English Text')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: items.map((q) => DataRow(cells: [
                    DataCell(
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          q.ta,
                          style: const TextStyle(fontFamily: 'NotoSansTamil', fontSize: 13),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          q.en,
                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AdminTheme.navy),
                            onPressed: () => _showAddEditDialog(q),
                            tooltip: 'Edit Quote',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                            onPressed: () => _deleteQuote(q),
                            tooltip: 'Delete Quote',
                          ),
                        ],
                      ),
                    ),
                  ])).toList(),
                ),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.saffron)),
            ),
          ),
          error: (e, _) => Center(child: Text('Error loading quotes: $e', style: const TextStyle(color: AdminTheme.error))),
        ),
      ],
    );
  }
}

class _AddEditQuoteDialog extends ConsumerStatefulWidget {
  final QuoteModel? quote;
  const _AddEditQuoteDialog({this.quote});

  @override
  ConsumerState<_AddEditQuoteDialog> createState() => _AddEditQuoteDialogState();
}

class _AddEditQuoteDialogState extends ConsumerState<_AddEditQuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taController = TextEditingController();
  final _enController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.quote != null) {
      _taController.text = widget.quote!.ta;
      _enController.text = widget.quote!.en;
    }
  }

  @override
  void dispose() {
    _taController.dispose();
    _enController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final taVal = _taController.text.trim();
      final enVal = _enController.text.trim();

      if (widget.quote != null) {
        await _fs.collection(AdminConstants.quotesCollection).doc(widget.quote!.id).update({
          'ta': taVal,
          'en': enVal,
        });
        await AdminActivityLogService.log(
          action: 'Updated quote: $taVal',
          targetCollection: AdminConstants.quotesCollection,
        );
      } else {
        await _fs.collection(AdminConstants.quotesCollection).add({
          'ta': taVal,
          'en': enVal,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await AdminActivityLogService.log(
          action: 'Added quote: $taVal',
          targetCollection: AdminConstants.quotesCollection,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quote: $e'), backgroundColor: AdminTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.quote != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Quote' : 'Add New Quote', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _taController,
                decoration: const InputDecoration(
                  labelText: 'Tamil Quote',
                  hintText: 'உதாரணம்: முயற்சி திருவினை ஆக்கும்',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter the Tamil quote' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enController,
                decoration: const InputDecoration(
                  labelText: 'English Translation',
                  hintText: 'Example: Effort leads to prosperity.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter the English translation' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.saffron,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
