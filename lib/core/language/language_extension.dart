import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_mode.dart';
import 'language_provider.dart';
import 'app_strings.dart';

extension BuildContextLanguage on BuildContext {
  ProviderContainer get _container => ProviderScope.containerOf(this);

  AppStrings get s => _container.read(appStringsProvider);

  LanguageMode get langMode => _container.read(languageNotifierProvider);

  String get contentLang => _container.read(contentLangProvider);

  bool get isTamil => langMode == LanguageMode.tamil;

  bool get isEnglish => langMode == LanguageMode.english;

  bool get isBoth => langMode == LanguageMode.both;
}
