import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_mode.dart';
import 'language_notifier.dart';
import 'app_strings.dart';
import 'english_strings.dart';
import 'tamil_strings.dart';

// ─── Core Language Provider ───────────────────────────────────────────────────
final languageNotifierProvider =
    StateNotifierProvider<LanguageNotifier, LanguageMode>(
  (ref) => LanguageNotifier(),
);

// ─── UI String Table ──────────────────────────────────────────────────────────
final appStringsProvider = Provider<AppStrings>((ref) {
  final mode = ref.watch(languageNotifierProvider);
  return mode.uiLang == 'ta' ? TamilStrings() : EnglishStrings();
});

// ─── Content Language ('ta' | 'en' | 'both') ─────────────────────────────────
final contentLangProvider = Provider<String>((ref) {
  return ref.watch(languageNotifierProvider).contentLang;
});

// ─── App Locale for MaterialApp ───────────────────────────────────────────────
final appLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageNotifierProvider).appLocale;
});

// ─── Test Active Guard ────────────────────────────────────────────────────────
/// Set this to true while a mock test is running to disable the language toggle.
final testActiveProvider = StateProvider<bool>((ref) => false);
