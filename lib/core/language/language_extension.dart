import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thiral_app/l10n/app_localizations.dart';
import 'language_mode.dart';
import 'language_provider.dart';

extension BuildContextLanguage on BuildContext {
  ProviderContainer get _container => ProviderScope.containerOf(this);

  AppLocalizations get l10n => AppLocalizations.of(this);

  LanguageMode get langMode => _container.read(languageNotifierProvider);

  String get contentLang => _container.read(contentLangProvider);

  bool get isTamil => langMode == LanguageMode.tamil;

  bool get isEnglish => langMode == LanguageMode.english;

  bool get isBoth => langMode == LanguageMode.both;
}
