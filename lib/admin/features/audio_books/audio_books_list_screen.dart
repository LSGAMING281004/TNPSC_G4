import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/audio_book_model.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/admin_stat_card.dart';
import '../../shared/widgets/admin_empty_state.dart';

// ─── Provider: all audio books (admin sees active + inactive) ───
final _adminAudioBooksProvider = StreamProvider<List<AudioBookModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('audio_books')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => AudioBookModel.fromFirestore(d)).toList());
});

/// Admin Audio Books list & management screen
class AdminAudioBooksScreen extends ConsumerStatefulWidget {
  const AdminAudioBooksScreen({super.key});

  @override
  ConsumerState<AdminAudioBooksScreen> createState() =>
      _AdminAudioBooksScreenState();
}

class _AdminAudioBooksScreenState extends ConsumerState<AdminAudioBooksScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Audio Books';
    });
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(_adminAudioBooksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat row
        booksAsync.when(
          data: (books) => _buildStats(books),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),

        // Toolbar
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search audio books...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AdminTheme.border),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/audio-books/add'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Audio Book'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.saffron,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table
        booksAsync.when(
          data: (books) {
            final filtered = books.where((b) =>
                b.titleEn.toLowerCase().contains(_searchQuery) ||
                b.titleTa.contains(_searchQuery) ||
                b.subject.toLowerCase().contains(_searchQuery));

            if (filtered.isEmpty) {
              return const AdminEmptyState(
                icon: Icons.headphones,
                message: 'No audio books found.',
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                      AdminTheme.navy.withValues(alpha: 0.04)),
                  columns: const [
                    DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Plays', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                  rows: filtered.map((book) => _buildRow(book)).toList(),
                ),
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildStats(List<AudioBookModel> books) {
    final active = books.where((b) => b.isActive).length;
    final totalPlays = books.fold<int>(0, (acc, b) => acc + b.playCount);
    final totalMinutes =
        books.fold<int>(0, (acc, b) => acc + b.durationSeconds) ~/ 60;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            AdminStatCard(
              label: 'Total Audio Books',
              value: '${books.length}',
              icon: Icons.headphones_rounded,
              color: AdminTheme.info,
            ),
            AdminStatCard(
              label: 'Active / Published',
              value: '$active',
              icon: Icons.check_circle_outline,
              color: AdminTheme.success,
            ),
            AdminStatCard(
              label: 'Total Plays',
              value: _formatK(totalPlays),
              icon: Icons.play_circle_outline,
              color: AdminTheme.saffron,
            ),
            AdminStatCard(
              label: 'Total Minutes',
              value: _formatK(totalMinutes),
              icon: Icons.timer_outlined,
              color: AdminTheme.warning,
            ),
          ],
        );
      },
    );
  }

  DataRow _buildRow(AudioBookModel book) {
    return DataRow(cells: [
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AdminTheme.saffron.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.headphones, size: 18, color: AdminTheme.saffron),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(book.titleEn,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                if (book.titleTa.isNotEmpty)
                  Text(book.titleTa,
                      style: TextStyle(
                          fontSize: 11, color: AdminTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
      DataCell(Text(book.subject, style: const TextStyle(fontSize: 13))),
      DataCell(Text(book.formattedDuration,
          style: const TextStyle(fontSize: 13))),
      DataCell(Text('${book.playCount}',
          style: const TextStyle(fontSize: 13))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: book.isActive
              ? AdminTheme.success.withValues(alpha: 0.1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          book.isActive ? 'Active' : 'Draft',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: book.isActive ? AdminTheme.success : AdminTheme.textSecondary,
          ),
        ),
      )),
      DataCell(Text(
        DateFormat('dd MMM yyyy').format(book.createdAt),
        style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
      )),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AdminTheme.info,
            tooltip: 'Edit',
            onPressed: () =>
                context.go('/admin/audio-books/edit?id=${book.id}'),
          ),
          IconButton(
            icon: Icon(
              book.isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
            color: AdminTheme.warning,
            tooltip: book.isActive ? 'Deactivate' : 'Activate',
            onPressed: () => _toggleActive(book),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AdminTheme.error,
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(book),
          ),
        ],
      )),
    ]);
  }

  Future<void> _toggleActive(AudioBookModel book) async {
    await FirebaseFirestore.instance
        .collection('audio_books')
        .doc(book.id)
        .update({'isActive': !book.isActive});
  }

  Future<void> _confirmDelete(AudioBookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Audio Book?'),
        content: Text(
            'Are you sure you want to delete "${book.titleEn}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AdminTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final prefix = '${AppConstants.supabaseUrl}/storage/v1/object/public/${AppConstants.supabaseMediaBucket}/';
        final filesToDelete = <String>[];
        
        if (book.audioUrl.startsWith(prefix)) {
          filesToDelete.add(book.audioUrl.replaceFirst(prefix, ''));
        }
        if (book.coverImageUrl != null && book.coverImageUrl!.startsWith(prefix)) {
          filesToDelete.add(book.coverImageUrl!.replaceFirst(prefix, ''));
        }

        if (filesToDelete.isNotEmpty) {
          await Supabase.instance.client.storage
              .from(AppConstants.supabaseMediaBucket)
              .remove(filesToDelete);
        }
      } catch (_) {}

      await FirebaseFirestore.instance
          .collection('audio_books')
          .doc(book.id)
          .delete();
    }
  }

  String _formatK(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
