import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart' show Brightness, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/network_info.dart';
import '../../core/network/dio_client.dart';
import '../../core/providers/app_providers.dart';
import '../models/user_model.dart';

// ─── Firebase Providers ───
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

// ─── Network Providers ───
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo(ref.watch(connectivityProvider)));
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// ─── Auth State Provider ───
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ─── Auth UID Provider ───
final authUidProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});

// ─── Current User Provider ───
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// ─── Settings Providers ───
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  if (themeMode == ThemeMode.system) {
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }
  return themeMode == ThemeMode.dark;
});

final notifDailyReminderProvider = StateProvider<bool>((ref) {
  final box = Hive.box(AppConstants.settingsBox);
  return box.get('notif_daily_reminder', defaultValue: true) as bool;
});

final notifTestAlertsProvider = StateProvider<bool>((ref) {
  final box = Hive.box(AppConstants.settingsBox);
  return box.get('notif_test_alerts', defaultValue: true) as bool;
});

final notifCurrentAffairsProvider = StateProvider<bool>((ref) {
  final box = Hive.box(AppConstants.settingsBox);
  return box.get('notif_current_affairs', defaultValue: true) as bool;
});

final pdfQualityProvider = StateProvider<String>((ref) {
  final box = Hive.box(AppConstants.settingsBox);
  return box.get('pdf_quality', defaultValue: 'high') as String;
});


// ─── Hive Box Providers ───
final userBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.userBox));
final settingsBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.settingsBox));
final bookmarksBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.bookmarksBox));
final cacheBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.cacheBox));
final testResultsBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.testResultsBox));

final cacheSizeProvider = FutureProvider<int>((ref) async {
  int totalBytes = 0;
  
  // 1. Temp directory
  try {
    final tempDir = await getTemporaryDirectory();
    totalBytes += await _getDirectorySize(tempDir);
  } catch (_) {}

  // 2. Cache directory
  try {
    final cacheDir = await getApplicationCacheDirectory();
    totalBytes += await _getDirectorySize(cacheDir);
  } catch (_) {}

  return totalBytes;
});

Future<int> _getDirectorySize(Directory dir) async {
  int total = 0;
  try {
    if (await dir.exists()) {
      await for (final file in dir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          total += await file.length();
        }
      }
    }
  } catch (_) {}
  return total;
}
