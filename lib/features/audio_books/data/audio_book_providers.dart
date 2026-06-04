import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/audio_book_model.dart';

// ─── Firestore stream: all active audio books ───
final audioBooksProvider = StreamProvider<List<AudioBookModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('audio_books')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => AudioBookModel.fromFirestore(d)).toList());
});

// ─── Filter by subject ───
final audioBooksSubjectProvider =
    StreamProvider.family<List<AudioBookModel>, String>((ref, subject) {
  var query = FirebaseFirestore.instance
      .collection('audio_books')
      .where('isActive', isEqualTo: true);
  if (subject != 'All') {
    query = query.where('subject', isEqualTo: subject);
  }
  return query
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => AudioBookModel.fromFirestore(d)).toList());
});

// ─── Single audio book ───
final audioBookProvider =
    StreamProvider.family<AudioBookModel?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection('audio_books')
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? AudioBookModel.fromFirestore(doc) : null);
});

// ─── Currently playing audio book ID ───
final currentlyPlayingIdProvider = StateProvider<String?>((ref) => null);

// ─── Subject filter ───
final audioSubjectFilterProvider = StateProvider<String>((ref) => 'All');
