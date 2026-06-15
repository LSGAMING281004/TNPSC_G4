import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/guest_restrictions.dart';
import '../widgets/app_dialogs.dart';
import 'app_providers.dart';
import 'firestore_providers.dart';

/// Toggles bookmark for the given questionId.
/// Checks guest status first, then adds or removes from Firestore.
Future<void> toggleBookmark(BuildContext context, WidgetRef ref, String questionId) async {
  if (!GuestRestrictions.check(context, ref, featureName: 'Bookmarks')) {
    return;
  }

  final uid = ref.read(authUidProvider) ?? '';
  if (uid.isEmpty) return;

  final isBookmarked = ref.read(isBookmarkedProvider(questionId));
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('bookmarks')
      .doc(questionId);

  try {
    if (isBookmarked) {
      await docRef.delete();
      if (context.mounted) {
        showAppSnackBar(context, message: 'Bookmark removed', isSuccess: true);
      }
    } else {
      await docRef.set({
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        showAppSnackBar(context, message: 'Bookmark added', isSuccess: true);
      }
    }
  } catch (e) {
    if (context.mounted) {
      showAppSnackBar(context, message: 'Failed to update bookmark: $e', isError: true);
    }
  }
}

/// Toggles bookmark for the given study materialId.
Future<void> toggleMaterialBookmark(BuildContext context, WidgetRef ref, String materialId) async {
  if (!GuestRestrictions.check(context, ref, featureName: 'Bookmarks')) {
    return;
  }

  final uid = ref.read(authUidProvider) ?? '';
  if (uid.isEmpty) return;

  final isBookmarked = ref.read(isMaterialBookmarkedProvider(materialId));
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('material_bookmarks')
      .doc(materialId);

  try {
    if (isBookmarked) {
      await docRef.delete();
      if (context.mounted) {
        showAppSnackBar(context, message: 'Material bookmark removed', isSuccess: true);
      }
    } else {
      await docRef.set({
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        showAppSnackBar(context, message: 'Material bookmark added', isSuccess: true);
      }
    }
  } catch (e) {
    if (context.mounted) {
      showAppSnackBar(context, message: 'Failed to update material bookmark: $e', isError: true);
    }
  }
}
