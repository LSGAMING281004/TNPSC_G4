import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/providers/bookmark_actions.dart';
import '../../../../shared/providers/download_notifier.dart';

class MaterialDetailScreen extends ConsumerWidget {
  final String materialId;
  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialAsync = ref.watch(singleStudyMaterialProvider(materialId));
    final isBookmarked = ref.watch(isMaterialBookmarkedProvider(materialId));
    final downloadedList = ref.watch(downloadedMaterialsProvider);
    
    // Find local downloaded path if it exists
    final downloadData = downloadedList.firstWhere(
      (item) => item['materialId'] == materialId,
      orElse: () => <String, dynamic>{},
    );
    final String? localPath = downloadData.isNotEmpty ? downloadData['localPath'] as String? : null;

    return materialAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Study Material')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron)),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Study Material')),
        body: Center(child: Text('Error loading study material: $err')),
      ),
      data: (material) {
        if (material == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Material')),
            body: const Center(child: Text('Study material not found')),
          );
        }

        final title = material['title'] as String? ?? 'Study Material';
        final fileUrl = material['fileUrl'] as String? ?? '';
        final type = material['type'] as String? ?? 'pdf';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.accentSaffron : null,
                ),
                onPressed: () => toggleMaterialBookmark(context, ref, materialId),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  if (fileUrl.isNotEmpty) {
                    Share.share('Check out this study material: $title\n$fileUrl');
                  }
                },
              ),
            ],
          ),
          body: type == 'video'
              ? _buildVideoPlaceholder(context)
              : _PdfViewerBody(fileUrl: fileUrl, downloadedPath: localPath),
        );
      },
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentSaffron.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 64,
                color: AppColors.accentSaffron,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Video Lesson coming soon!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'We are currently preparing high-quality video lectures for this section. Check back soon!',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfViewerBody extends ConsumerStatefulWidget {
  final String fileUrl;
  final String? downloadedPath;

  const _PdfViewerBody({
    required this.fileUrl,
    this.downloadedPath,
  });

  @override
  ConsumerState<_PdfViewerBody> createState() => _PdfViewerBodyState();
}

class _PdfViewerBodyState extends ConsumerState<_PdfViewerBody> {
  String? _localPath;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  @override
  void didUpdateWidget(covariant _PdfViewerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.downloadedPath != oldWidget.downloadedPath) {
      _preparePdf();
    }
  }

  Future<void> _preparePdf() async {
    if (widget.downloadedPath != null) {
      final file = File(widget.downloadedPath!);
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _localPath = widget.downloadedPath;
            _loading = false;
            _error = null;
          });
        }
        return;
      }
    }

    if (widget.fileUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'No PDF URL available';
          _loading = false;
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final filename = widget.fileUrl.split('/').last.split('?').first;
      final path = '${tempDir.path}/$filename';
      final file = File(path);

      if (!await file.exists()) {
        final dio = Dio();
        await dio.download(widget.fileUrl, path);
      }

      if (mounted) {
        setState(() {
          _localPath = path;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accentSaffron),
            SizedBox(height: 16),
            Text('Loading PDF...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load PDF: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _preparePdf,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_localPath == null) {
      return const Center(child: Text('No PDF file path.'));
    }

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
          });
        }
      },
    );
  }
}
