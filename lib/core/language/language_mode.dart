import 'package:flutter/material.dart';

/// Defines the three language modes for the TNPSC Group 4 Master app.
enum LanguageMode { tamil, english, both }

extension LanguageModeExtension on LanguageMode {
  String get displayName {
    switch (this) {
      case LanguageMode.tamil:   return 'தமிழ்';
      case LanguageMode.english: return 'English';
      case LanguageMode.both:    return 'இரண்டும் / Both';
    }
  }

  String get shortName {
    switch (this) {
      case LanguageMode.tamil:   return 'தமிழ்';
      case LanguageMode.english: return 'EN';
      case LanguageMode.both:    return 'இரண்டும்';
    }
  }

  String get hiveKey {
    switch (this) {
      case LanguageMode.tamil:   return 'ta';
      case LanguageMode.english: return 'en';
      case LanguageMode.both:    return 'both';
    }
  }

  Locale get appLocale {
    switch (this) {
      case LanguageMode.tamil:   return const Locale('ta', 'IN');
      case LanguageMode.english: return const Locale('en', 'US');
      case LanguageMode.both:    return const Locale('en', 'US');
    }
  }

  /// Which string table drives the UI
  String get uiLang {
    switch (this) {
      case LanguageMode.tamil:   return 'ta';
      case LanguageMode.english: return 'en';
      case LanguageMode.both:    return 'en';
    }
  }

  /// Which language drives question/content text
  String get contentLang {
    switch (this) {
      case LanguageMode.tamil:   return 'ta';
      case LanguageMode.english: return 'en';
      case LanguageMode.both:    return 'both';
    }
  }

  static LanguageMode fromHiveKey(String key) {
    switch (key) {
      case 'ta':   return LanguageMode.tamil;
      case 'en':   return LanguageMode.english;
      case 'both': return LanguageMode.both;
      default:     return LanguageMode.english;
    }
  }
}
