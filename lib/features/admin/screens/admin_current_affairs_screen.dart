import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

class AdminCurrentAffairsScreen extends StatefulWidget {
  const AdminCurrentAffairsScreen({super.key});

  @override
  State<AdminCurrentAffairsScreen> createState() => _AdminCurrentAffairsScreenState();
}

class _AdminCurrentAffairsScreenState extends State<AdminCurrentAffairsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleTamilController = TextEditingController();
  final _titleEnglishController = TextEditingController();
  final _contentTamilController = TextEditingController();
  final _contentEnglishController = TextEditingController();
  
  String _category = 'TN_State';
  String _importance = 'high';
  bool _isPublished = true;
  String? _imageUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  final List<String> _categories = ['TN_State', 'National', 'International', 'Economy', 'Science', 'Sports', 'Awards'];

  Future<void> _pickAndUploadImage({Function(String url)? onUploaded}) async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null || result.files.single.bytes == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = '${const Uuid().v4()}_${result.files.single.name}';
      final ref = FirebaseStorage.instance.ref().child('current_affairs').child(fileName);
      
      await ref.putData(result.files.single.bytes!);
      final url = await ref.getDownloadURL();
      
      if (onUploaded != null) {
        onUploaded(url);
      } else {
        setState(() => _imageUrl = url);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final docRef = FirebaseFirestore.instance.collection('current_affairs').doc();
      await docRef.set({
        'id': docRef.id,
        'titleTamil': _titleTamilController.text.trim(),
        'titleEnglish': _titleEnglishController.text.trim(),
        'contentTamil': _contentTamilController.text.trim(),
        'contentEnglish': _contentEnglishController.text.trim(),
        'category': _category,
        'importance': _importance,
        'isPublished': _isPublished,
        'imageUrl': _imageUrl,
        'publishedAt': FieldValue.serverTimestamp(),
        'tags': [],
        'hasQuiz': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article published successfully!')));
        _titleTamilController.clear();
        _titleEnglishController.clear();
        _contentTamilController.clear();
        _contentEnglishController.clear();
        setState(() => _imageUrl = null);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteArticle(String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Article?'),
        content: Text('Are you sure you want to delete "$title"? This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('current_affairs').doc(docId).delete();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article deleted.')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  void _editArticle(String docId, Map<String, dynamic> data) {
    final titleTamilCtrl = TextEditingController(text: data['titleTamil']);
    final titleEnglishCtrl = TextEditingController(text: data['titleEnglish']);
    final contentTamilCtrl = TextEditingController(text: data['contentTamil']);
    final contentEnglishCtrl = TextEditingController(text: data['contentEnglish']);
    String editCategory = data['category'] ?? 'TN_State';
    String editImportance = data['importance'] ?? 'high';
    bool editIsPublished = data['isPublished'] ?? true;
    String? editImageUrl = data['imageUrl'];
    bool localUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Article', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 800,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleTamilCtrl,
                          decoration: const InputDecoration(labelText: 'Title (Tamil)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: titleEnglishCtrl,
                          decoration: const InputDecoration(labelText: 'Title (English)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: editCategory,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setDialogState(() => editCategory = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: editImportance,
                          decoration: const InputDecoration(labelText: 'Importance', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                          ],
                          onChanged: (v) => setDialogState(() => editImportance = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Switch(
                        value: editIsPublished,
                        onChanged: (val) => setDialogState(() => editIsPublished = val),
                      ),
                      Text(editIsPublished ? 'Published' : 'Draft'),
                      const SizedBox(width: 32),
                      ElevatedButton.icon(
                        onPressed: localUploading ? null : () async {
                          final result = await FilePicker.pickFiles(type: FileType.image);
                          if (result == null || result.files.single.bytes == null) return;
                          setDialogState(() => localUploading = true);
                          try {
                            final fileName = '${const Uuid().v4()}_${result.files.single.name}';
                            final ref = FirebaseStorage.instance.ref().child('current_affairs').child(fileName);
                            await ref.putData(result.files.single.bytes!);
                            final url = await ref.getDownloadURL();
                            setDialogState(() => editImageUrl = url);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                            }
                          } finally {
                            setDialogState(() => localUploading = false);
                          }
                        },
                        icon: localUploading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.image),
                        label: Text(localUploading ? 'Uploading...' : 'Change Image'),
                      ),
                      const SizedBox(width: 16),
                      if (editImageUrl != null)
                        Image.network(editImageUrl!, height: 40, width: 70, fit: BoxFit.cover),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentTamilCtrl,
                    maxLines: 8,
                    decoration: const InputDecoration(labelText: 'Content (Tamil)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentEnglishCtrl,
                    maxLines: 8,
                    decoration: const InputDecoration(labelText: 'Content (English)', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, foregroundColor: Colors.white),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('current_affairs').doc(docId).update({
                  'titleTamil': titleTamilCtrl.text.trim(),
                  'titleEnglish': titleEnglishCtrl.text.trim(),
                  'contentTamil': contentTamilCtrl.text.trim(),
                  'contentEnglish': contentEnglishCtrl.text.trim(),
                  'category': editCategory,
                  'importance': editImportance,
                  'isPublished': editIsPublished,
                  'imageUrl': editImageUrl,
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1E36) : Colors.grey.shade100,
        appBar: AppBar(
          title: Text('Current Affairs Console', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryNavy, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.accentSaffron,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.grey.shade700,
            indicatorColor: AppColors.accentSaffron,
            tabs: const [
              Tab(icon: Icon(Icons.add_box), text: 'Post Article'),
              Tab(icon: Icon(Icons.article), text: 'Manage Articles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPostArticleTab(isDark),
            _buildManageArticlesTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPostArticleTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleTamilController,
                          decoration: const InputDecoration(labelText: 'Title (Tamil)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleEnglishController,
                          decoration: const InputDecoration(labelText: 'Title (English)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _importance,
                          decoration: const InputDecoration(labelText: 'Importance', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                          ],
                          onChanged: (v) => setState(() => _importance = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Article Image Banner', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _pickAndUploadImage(),
                    icon: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.image),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                  ),
                  const SizedBox(width: 16),
                  if (_imageUrl != null)
                    Container(
                      height: 60,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contentTamilController,
                      maxLines: 12,
                      decoration: const InputDecoration(labelText: 'Content (Tamil - Markdown supported)', border: OutlineInputBorder(), alignLabelWithHint: true),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _contentEnglishController,
                      maxLines: 12,
                      decoration: const InputDecoration(labelText: 'Content (English - Markdown supported)', border: OutlineInputBorder(), alignLabelWithHint: true),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _isPublished,
                        activeThumbColor: AppColors.accentSaffron,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                      Text(_isPublished ? 'Status: Published' : 'Status: Draft', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveArticle,
                    icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                    label: Text(_isSaving ? 'Publish Now' : 'Save Article'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      backgroundColor: AppColors.accentSaffron,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageArticlesTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('current_affairs')
              .orderBy('publishedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('No articles found.'));

            return DataTable2(
              columnSpacing: 12,
              horizontalMargin: 24,
              minWidth: 900,
              headingRowColor: WidgetStateProperty.all(isDark ? Colors.grey.shade900 : Colors.grey.shade50),
              columns: const [
                DataColumn2(label: Text('Title (Tamil)'), size: ColumnSize.L),
                DataColumn2(label: Text('Category'), size: ColumnSize.M),
                DataColumn2(label: Text('Importance'), size: ColumnSize.S),
                DataColumn2(label: Text('Status'), size: ColumnSize.S),
                DataColumn2(label: Text('Published Date'), size: ColumnSize.M),
                DataColumn2(label: Text('Actions'), size: ColumnSize.S, numeric: true),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isPublished = data['isPublished'] ?? true;
                final publishedAt = (data['publishedAt'] as Timestamp?)?.toDate();
                final dateStr = publishedAt != null ? DateFormat('MMM d, yyyy').format(publishedAt) : 'Draft';

                return DataRow(
                  cells: [
                    DataCell(Text(data['titleTamil'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DataCell(Text(data['category'] ?? '')),
                    DataCell(Text(data['importance']?.toString().toUpperCase() ?? '')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPublished ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPublished ? 'Published' : 'Draft',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(Text(dateStr)),
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                            tooltip: 'Edit Article',
                            onPressed: () => _editArticle(doc.id, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            tooltip: 'Delete Article',
                            onPressed: () => _deleteArticle(doc.id, data['titleTamil'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
