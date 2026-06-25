import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/audio_book_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_shell.dart';

/// Add / Edit screen for Audio Books (admin)
class AddEditAudioBookScreen extends ConsumerStatefulWidget {
  final String? audioBookId;
  const AddEditAudioBookScreen({super.key, this.audioBookId});

  @override
  ConsumerState<AddEditAudioBookScreen> createState() =>
      _AddEditAudioBookScreenState();
}

class _AddEditAudioBookScreenState
    extends ConsumerState<AddEditAudioBookScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploading = false;

  // Form fields
  final _titleEn = TextEditingController();
  final _titleTa = TextEditingController();
  final _descEn = TextEditingController();
  final _descTa = TextEditingController();
  final _narrator = TextEditingController();
  final _durationMin = TextEditingController();
  final _tags = TextEditingController();
  final _chapterCtrl = TextEditingController();
  String _subject = 'General Studies';
  String _chapter = '';
  bool _isPremium = false;
  bool _isActive = true;
  String? _audioUrl;
  String? _coverUrl;
  String? _uploadError;

  bool get isEditing => widget.audioBookId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state =
          isEditing ? 'Edit Audio Book' : 'Add Audio Book';
      if (isEditing) {
        _loadExisting();
      } else {
        _chapterCtrl.text = _chapter;
      }
    });
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    final doc = await FirebaseFirestore.instance
        .collection('audio_books')
        .doc(widget.audioBookId)
        .get();
    if (doc.exists) {
      final book = AudioBookModel.fromFirestore(doc);
      _titleEn.text = book.titleEn;
      _titleTa.text = book.titleTa;
      _descEn.text = book.descriptionEn;
      _descTa.text = book.descriptionTa;
      _narrator.text = book.narrator;
      _durationMin.text = (book.durationSeconds ~/ 60).toString();
      _tags.text = book.tags.join(', ');
      _subject = book.subject;
      _chapterCtrl.text = book.chapter;
      _isPremium = book.isPremium;
      _isActive = book.isActive;
      _audioUrl = book.audioUrl;
      _coverUrl = book.coverImageUrl;
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleTa.dispose();
    _descEn.dispose();
    _descTa.dispose();
    _narrator.dispose();
    _durationMin.dispose();
    _tags.dispose();
    _chapterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              TextButton.icon(
                onPressed: () => context.go('/admin/audio-books'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Audio Books'),
              ),
              const SizedBox(height: 16),

              _buildSection('Basic Information', [
                _buildTextField('Title (English)', _titleEn, required: true),
                const SizedBox(height: 12),
                _buildTextField('Title (Tamil)', _titleTa),
                const SizedBox(height: 12),
                _buildTextField('Description (English)', _descEn, maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField('Description (Tamil)', _descTa, maxLines: 3),
              ]),
              const SizedBox(height: 20),

              _buildSection('Classification', [
                Row(
                  children: [
                    Expanded(child: _buildSubjectDropdown()),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField(
                            'Chapter / Topic',
                            _chapterCtrl)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child:
                            _buildTextField('Narrator', _narrator)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                          'Duration (minutes)', _durationMin,
                          keyboardType: TextInputType.number,
                          required: true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Tags (comma separated)', _tags),
              ]),
              const SizedBox(height: 20),

              _buildSection('Audio File', [
                _buildFileUpload(
                  label: 'Audio File (.mp3, .m4a, .aac)',
                  currentUrl: _audioUrl,
                  storagePath: 'audio_books/audio',
                  allowedExtensions: ['mp3', 'm4a', 'aac', 'wav'],
                  onUploaded: (url) => setState(() => _audioUrl = url),
                ),
              ]),
              const SizedBox(height: 20),

              _buildSection('Cover Image', [
                _buildFileUpload(
                  label: 'Cover Image (.png, .jpg)',
                  currentUrl: _coverUrl,
                  storagePath: 'audio_books/covers',
                  allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
                  onUploaded: (url) => setState(() => _coverUrl = url),
                ),
              ]),
              const SizedBox(height: 20),

              _buildSection('Settings', [
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Premium Content'),
                        subtitle: const Text('Only for PRO users'),
                        value: _isPremium,
                        activeThumbColor: AdminTheme.saffron,
                        onChanged: (v) => setState(() => _isPremium = v),
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Active / Published'),
                        subtitle: const Text('Visible to users'),
                        value: _isActive,
                        activeThumbColor: AdminTheme.success,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _save,
                  icon: Icon(isEditing ? Icons.save : Icons.add, size: 18),
                  label: Text(isEditing ? 'Update Audio Book' : 'Create Audio Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.textPrimary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? '$label is required' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _subject,
      decoration: InputDecoration(
        labelText: 'Subject',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: ['Tamil', 'General Studies', 'Aptitude & Mental Ability']
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => setState(() => _subject = v ?? _subject),
    );
  }

  Widget _buildFileUpload({
    required String label,
    required String? currentUrl,
    required String storagePath,
    required List<String> allowedExtensions,
    required ValueChanged<String> onUploaded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentUrl != null && currentUrl.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminTheme.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AdminTheme.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('File uploaded',
                      style: const TextStyle(
                          fontSize: 12, color: AdminTheme.success)),
                ),
                TextButton(
                  onPressed: () => onUploaded(''),
                  child: const Text('Remove',
                      style: TextStyle(
                          fontSize: 12, color: AdminTheme.error)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_isUploading) ...[
          const LinearProgressIndicator(
            backgroundColor: AdminTheme.border,
            color: AdminTheme.saffron,
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _isUploading
              ? null
              : () => _pickAndUpload(storagePath, allowedExtensions, onUploaded),
          icon: const Icon(Icons.upload_file, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (_uploadError != null) ...[
          const SizedBox(height: 8),
          Text(
            _uploadError!,
            style: const TextStyle(color: AdminTheme.error, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Future<void> _pickAndUpload(
    String storagePath,
    List<String> extensions,
    ValueChanged<String> onDone,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      setState(() => _uploadError = null);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final fullPath = '$storagePath/$fileName';

      final storageRef = FirebaseStorage.instance.ref('${AppConstants.mediaStoragePath}/$fullPath');
      await storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: _getContentType(file.name)),
      );

      final url = await storageRef.getDownloadURL();

      onDone(url);
    } catch (e) {
      if (mounted) {
        setState(() => _uploadError = 'Upload failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audioUrl == null || _audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an audio file')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'titleEn': _titleEn.text.trim(),
      'titleTa': _titleTa.text.trim(),
      'descriptionEn': _descEn.text.trim(),
      'descriptionTa': _descTa.text.trim(),
      'subject': _subject,
      'chapter': _chapterCtrl.text.trim(),
      'audioUrl': _audioUrl,
      'coverImageUrl': _coverUrl ?? '',
      'durationSeconds': (int.tryParse(_durationMin.text) ?? 0) * 60,
      'narrator': _narrator.text.trim(),
      'isPremium': _isPremium,
      'isActive': _isActive,
      'tags': _tags.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('audio_books')
            .doc(widget.audioBookId)
            .update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['playCount'] = 0;
        await FirebaseFirestore.instance.collection('audio_books').add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              isEditing ? 'Audio book updated!' : 'Audio book created!'),
          backgroundColor: AdminTheme.success,
        ));
        context.go('/admin/audio-books');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return switch (ext) {
      'mp3' => 'audio/mpeg',
      'm4a' => 'audio/mp4',
      'aac' => 'audio/aac',
      'wav' => 'audio/wav',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}
