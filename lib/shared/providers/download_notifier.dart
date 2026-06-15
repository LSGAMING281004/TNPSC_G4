import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/app_dialogs.dart';

class ActiveDownloadsNotifier extends StateNotifier<Map<String, double>> {
  ActiveDownloadsNotifier() : super({});

  final Dio _dio = Dio();

  Future<void> download({
    required BuildContext context,
    required String materialId,
    required String title,
    required String fileUrl,
  }) async {
    final box = Hive.box(AppConstants.downloadedMaterialsBox);

    // Check if already downloaded
    if (box.containsKey(materialId)) {
      final confirm = await showConfirmDialog(
        context,
        title: 'Re-download material?',
        message: 'This material is already downloaded. Do you want to download it again?',
        confirmLabel: 'Re-download',
        cancelLabel: 'Cancel',
      );
      if (!confirm) return;
    }

    // Mark as downloading (start at 0.0)
    state = {...state, materialId: 0.0};

    try {
      final appDir = await getApplicationDocumentsDirectory();
      String ext = '.pdf';
      if (fileUrl.contains('.')) {
        final parts = fileUrl.split('.');
        final possibleExt = parts.last.split('?').first.toLowerCase();
        if (possibleExt == 'pdf' || possibleExt == 'mp4') {
          ext = '.$possibleExt';
        }
      }

      final localPath = '${appDir.path}/downloads/$materialId$ext';

      // Ensure download directory exists
      final file = File(localPath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      await _dio.download(
        fileUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = {...state, materialId: progress};
          }
        },
      );

      // Get file size
      final fileSize = await file.length();

      // Save to Hive
      await box.put(materialId, {
        'materialId': materialId,
        'title': title,
        'fileSizeBytes': fileSize,
        'downloadedAt': DateTime.now().toIso8601String(),
        'localPath': localPath,
      });

      if (context.mounted) {
        showAppSnackBar(context, message: 'Download completed: $title', isSuccess: true);
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, message: 'Failed to download: $e', isError: true);
      }
    } finally {
      // Remove from active downloads
      final updated = Map<String, double>.from(state);
      updated.remove(materialId);
      state = updated;
    }
  }

  Future<void> deleteDownload(BuildContext context, String materialId) async {
    final box = Hive.box(AppConstants.downloadedMaterialsBox);
    final data = box.get(materialId);
    if (data == null) return;

    final localPath = data['localPath'] as String?;
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await box.delete(materialId);
    if (context.mounted) {
      showAppSnackBar(context, message: 'Deleted download: ${data['title']}', isSuccess: true);
    }
  }

  Future<void> clearAll(BuildContext context) async {
    final box = Hive.box(AppConstants.downloadedMaterialsBox);
    int deletedCount = 0;
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final localPath = data['localPath'] as String?;
        if (localPath != null) {
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
            deletedCount++;
          }
        }
      }
    }
    await box.clear();
    if (context.mounted) {
      showAppSnackBar(context, message: 'Cleared all $deletedCount downloads', isSuccess: true);
    }
  }
}

final activeDownloadsProvider = StateNotifierProvider<ActiveDownloadsNotifier, Map<String, double>>((ref) {
  return ActiveDownloadsNotifier();
});

// A helper provider to watch a specific material's download progress
final materialDownloadProgressProvider = Provider.family<double?, String>((ref, id) {
  return ref.watch(activeDownloadsProvider)[id];
});

// Handles reactive reading of downloaded materials list
class DownloadedMaterialsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DownloadedMaterialsNotifier() : super([]) {
    _load();
    _box.listenable().addListener(_onBoxChanged);
  }

  final Box _box = Hive.box(AppConstants.downloadedMaterialsBox);

  void _load() {
    final list = <Map<String, dynamic>>[];
    for (final key in _box.keys) {
      final val = _box.get(key);
      if (val is Map) {
        list.add(Map<String, dynamic>.from(val));
      }
    }
    state = list;
  }

  void _onBoxChanged() {
    _load();
  }

  @override
  void dispose() {
    _box.listenable().removeListener(_onBoxChanged);
    super.dispose();
  }
}

final downloadedMaterialsProvider = StateNotifierProvider<DownloadedMaterialsNotifier, List<Map<String, dynamic>>>((ref) {
  return DownloadedMaterialsNotifier();
});

// A helper provider to check if a specific material is downloaded
final isMaterialDownloadedProvider = Provider.family<bool, String>((ref, id) {
  final list = ref.watch(downloadedMaterialsProvider);
  return list.any((item) => item['materialId'] == id);
});
