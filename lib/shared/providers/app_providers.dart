import 'dart:ui';
import 'package:flutter/material.dart' show Brightness, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

final languageProvider = StateProvider<String>((ref) {
  final box = Hive.box(AppConstants.settingsBox);
  return box.get('language', defaultValue: 'both') as String;
});

final isTamilProvider = Provider<bool>((ref) {
  final language = ref.watch(languageProvider);
  return language == 'ta' || language == 'both';
});

final isEnglishProvider = Provider<bool>((ref) {
  final language = ref.watch(languageProvider);
  return language == 'en' || language == 'both';
});

// ─── Hive Box Providers ───
final userBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.userBox));
final settingsBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.settingsBox));
final bookmarksBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.bookmarksBox));
final cacheBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.cacheBox));
final testResultsBoxProvider = Provider<Box>((ref) => Hive.box(AppConstants.testResultsBox));
