import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/audio_book_model.dart';
import '../../../core/services/audio_handler.dart';
import 'dart:async';

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

// ─── Sleep Timer State & Notifier ───
class SleepTimerState {
  final Duration? remainingTime;
  final bool isActive;

  const SleepTimerState({this.remainingTime, this.isActive = false});
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  Timer? _timer;
  final Ref _ref;

  SleepTimerNotifier(this._ref) : super(const SleepTimerState());

  void setTimer(Duration duration) {
    _timer?.cancel();
    state = SleepTimerState(remainingTime: duration, isActive: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingTime;
      if (remaining == null || remaining.inSeconds <= 1) {
        cancelTimer();
        _ref.read(audioHandlerProvider).pause();
      } else {
        state = SleepTimerState(
          remainingTime: remaining - const Duration(seconds: 1),
          isActive: true,
        );
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    state = const SleepTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  return SleepTimerNotifier(ref);
});
