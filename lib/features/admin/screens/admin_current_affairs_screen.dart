import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null || result.files.single.bytes == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = '${const Uuid().v4()}_${result.files.single.name}';
      final ref = FirebaseStorage.instance.ref().child('current_affairs').child(fileName);
      
      // For web, we upload bytes
      await ref.putData(result.files.single.bytes!);
      final url = await ref.getDownloadURL();
      
      setState(() => _imageUrl = url);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Post Current Affairs', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Switch(
            value: _isPublished,
            activeThumbColor: AppColors.accentSaffron,
            onChanged: (val) => setState(() => _isPublished = val),
          ),
          Center(child: Text(_isPublished ? 'Published' : 'Draft', style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.w600))),
          const SizedBox(width: 24),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
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
                            value: _category,
                            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _importance,
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
                      onPressed: _isUploading ? null : _pickAndUploadImage,
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
                        maxLines: 15,
                        decoration: const InputDecoration(labelText: 'Content (Tamil - Markdown supported)', border: OutlineInputBorder(), alignLabelWithHint: true),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: TextFormField(
                        controller: _contentEnglishController,
                        maxLines: 15,
                        decoration: const InputDecoration(labelText: 'Content (English - Markdown supported)', border: OutlineInputBorder(), alignLabelWithHint: true),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveArticle,
                    icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                    label: Text(_isSaving ? 'Saving...' : 'Save Article'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      backgroundColor: AppColors.accentSaffron,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
