import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/services/admin_activity_log_service.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

class NotificationComposeScreen extends ConsumerStatefulWidget {
  const NotificationComposeScreen({super.key});
  @override
  ConsumerState<NotificationComposeScreen> createState() => _NotificationComposeScreenState();
}

class _NotificationComposeScreenState extends ConsumerState<NotificationComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _topic = 'all_users';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Send Notification';
    });
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await _fs.collection(AdminConstants.notificationsCollection).add({
        'title': _titleCtrl.text, 'body': _bodyCtrl.text,
        'topic': _topic, 'sentAt': FieldValue.serverTimestamp(),
        'status': 'Sent', 'deliveredCount': 0,
      });
      await AdminActivityLogService.log(action: 'Sent notification', targetCollection: AdminConstants.notificationsCollection);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent!')));
        _titleCtrl.clear(); _bodyCtrl.clear();
      }
    } finally { if (mounted) setState(() => _sending = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(constraints: const BoxConstraints(maxWidth: 600), child: Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Title', counterText: '${_titleCtrl.text.length}/65'),
          maxLength: 65, validator: (v) => v!.isEmpty ? 'Required' : null, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        TextFormField(controller: _bodyCtrl, decoration: InputDecoration(labelText: 'Body', counterText: '${_bodyCtrl.text.length}/240'),
          maxLines: 3, maxLength: 240, validator: (v) => v!.isEmpty ? 'Required' : null, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: _topic, decoration: const InputDecoration(labelText: 'Target Audience'),
          items: AdminConstants.notificationTopics.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
          onChanged: (v) => setState(() => _topic = v!)),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: _sending ? null : _send,
          icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send, size: 18),
          label: const Text('Send Now')),
      ])));
  }

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }
}

// ─── History ───
final notifHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _fs.collection(AdminConstants.notificationsCollection)
      .orderBy('sentAt', descending: true).limit(50).snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});
  @override
  ConsumerState<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Notification History';
    });
  }

  @override
  Widget build(BuildContext context) {
    final nAsync = ref.watch(notifHistoryProvider);
    return nAsync.when(
      data: (items) {
        if (items.isEmpty) return const AdminEmptyState(icon: Icons.notifications_none, message: 'No notifications sent yet.');
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
            headingRowColor: WidgetStateProperty.all(AdminTheme.background),
            columns: const [
              DataColumn(label: Text('Title')), DataColumn(label: Text('Body')),
              DataColumn(label: Text('Topic')), DataColumn(label: Text('Sent')), DataColumn(label: Text('Status')),
            ],
            rows: items.map((n) {
              final sentAt = (n['sentAt'] as Timestamp?)?.toDate();
              return DataRow(cells: [
                DataCell(SizedBox(width: 180, child: Text(n['title'] ?? '', overflow: TextOverflow.ellipsis))),
                DataCell(SizedBox(width: 220, child: Text(n['body'] ?? '', overflow: TextOverflow.ellipsis))),
                DataCell(Text(n['topic'] ?? '')),
                DataCell(Text(sentAt != null ? DateFormat('MMM dd, HH:mm').format(sentAt) : '—')),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AdminTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(n['status'] ?? 'Sent', style: const TextStyle(color: AdminTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
                )),
              ]);
            }).toList(),
          )),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
