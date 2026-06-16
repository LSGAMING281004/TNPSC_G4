import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _type = 'general';
  String _target = 'all_users';

  bool _isSending = false;

  final List<String> _types = ['general', 'new_content', 'current_affairs', 'test_reminder', 'achievement'];

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSending = true);

    try {
      // This writes to the 'notifications' collection which triggers the Cloud Function 'onNotificationCreated'
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'type': _type,
        'topic': _target,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification queued for broadcasting!')));
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1E36) : Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Broadcast Notification', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Compose Push Notification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Notification Title', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Notification Body', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(labelText: 'Tap Action (Type)', border: OutlineInputBorder()),
                          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _target,
                          decoration: const InputDecoration(labelText: 'Target Audience', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'all_users', child: Text('All Users')),
                            // Add more specific targets here if configured in Cloud Messaging
                          ],
                          onChanged: (v) => setState(() => _target = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendNotification,
                      icon: _isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                      label: Text(_isSending ? 'Sending...' : 'Broadcast Now'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
