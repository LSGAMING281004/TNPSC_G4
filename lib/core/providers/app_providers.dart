import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final box = Hive.box('settings');
  final stored = box.get('themeMode', defaultValue: 'system') as String;
  return switch (stored) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});
