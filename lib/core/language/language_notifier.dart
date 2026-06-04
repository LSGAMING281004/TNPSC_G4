import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'language_mode.dart';

class LanguageNotifier extends StateNotifier<LanguageMode> {
  LanguageNotifier() : super(_loadFromHive());

  static LanguageMode _loadFromHive() {
    final box = Hive.box('settings_box');
    final key = box.get('language_mode', defaultValue: 'en') as String;
    return LanguageModeExtension.fromHiveKey(key);
  }

  void setLanguage(LanguageMode mode) {
    state = mode;
    Hive.box('settings_box').put('language_mode', mode.hiveKey);
    _syncToFirestore(mode);
  }

  void _syncToFirestore(LanguageMode mode) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'preferredLanguage': mode.hiveKey})
        .catchError((_) {});
  }
}
