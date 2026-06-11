import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/question_model.dart';
import '../../../shared/models/question_filter_model.dart';

// --- StateNotifiers ---

class QuestionFilterNotifier extends StateNotifier<QuestionFilter> {
  QuestionFilterNotifier() : super(QuestionFilter());

  void updateQuery(String query) => state = state.copyWith(searchQuery: query);
  
  void toggleSubject(String subject) {
    final s = Set<String>.from(state.subjects);
    if (s.contains(subject)) {
      s.remove(subject);
    } else {
      s.add(subject);
    }
    state = state.copyWith(subjects: s);
  }

  void toggleDifficulty(String diff) {
    final d = Set<String>.from(state.difficulties);
    if (d.contains(diff)) {
      d.remove(diff);
    } else {
      d.add(diff);
    }
    state = state.copyWith(difficulties: d);
  }

  void toggleYear(int year) {
    final y = Set<int>.from(state.years);
    if (y.contains(year)) {
      y.remove(year);
    } else {
      y.add(year);
    }
    state = state.copyWith(years: y);
  }

  void setChapter(String? chapter) => state = state.copyWith(chapter: chapter);

  void clearFilters() => state = QuestionFilter(searchQuery: state.searchQuery);
}

final questionFilterProvider = StateNotifierProvider<QuestionFilterNotifier, QuestionFilter>((ref) {
  return QuestionFilterNotifier();
});

// --- Bookmarks Provider ---

class BookmarksNotifier extends StateNotifier<List<String>> {
  late final Box _box;

  BookmarksNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('bookmarks_box')) {
      _box = await Hive.openBox('bookmarks_box');
    } else {
      _box = Hive.box('bookmarks_box');
    }
    state = _box.values.cast<String>().toList();
  }

  void toggleBookmark(String questionId) {
    if (state.contains(questionId)) {
      _box.delete(questionId);
      state = state.where((id) => id != questionId).toList();
    } else {
      _box.put(questionId, questionId);
      state = [...state, questionId];
    }
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<String>>((ref) {
  return BookmarksNotifier();
});

// --- Pagination & Data Fetching ---

// Keeps track of the loaded questions and handles loading more
class QuestionListNotifier extends StateNotifier<AsyncValue<List<QuestionModel>>> {
  final Ref ref;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  static const int _limit = 20;

  QuestionListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _fetchFirstPage();
  }

  Future<void> _fetchFirstPage() async {
    state = const AsyncValue.loading();
    _lastDoc = null;
    _hasMore = true;
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    try {
      final filter = ref.read(questionFilterProvider);
      Query query = FirebaseFirestore.instance.collection('questions');

      // Firestore Limitations: You can only perform range filters or array-contains 
      // on a single field, and 'in' queries are limited to 10 items.
      // For a truly scalable real-time search, Algolia/Typesense is recommended.
      // Here we do basic filtering and handle search text locally if needed,
      // or rely on a simple 'where' clause.

      if (filter.subjects.isNotEmpty) {
        query = query.where('subject', whereIn: filter.subjects.toList());
      }
      if (filter.difficulties.isNotEmpty) {
        query = query.where('difficulty', whereIn: filter.difficulties.toList());
      }
      if (filter.years.isNotEmpty) {
        query = query.where('year', whereIn: filter.years.toList());
      }

      // We add sorting by ID to have a consistent pagination
      query = query.orderBy(FieldPath.documentId).limit(_limit);

      if (_lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.length < _limit) {
        _hasMore = false;
      }
      
      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
      }

      var newQuestions = snapshot.docs.map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

      // Client-side search for simplicity without Algolia
      if (filter.searchQuery.isNotEmpty) {
        final queryStr = filter.searchQuery.toLowerCase();
        newQuestions = newQuestions.where((q) => 
          q.questionTamil.toLowerCase().contains(queryStr) || 
          q.questionEnglish.toLowerCase().contains(queryStr)
        ).toList();
      }

      if (state.hasValue && state.value != null && _lastDoc != null && state.value!.isNotEmpty) {
        // Appending to existing
        final existing = state.value!;
        // Prevent duplicates
        final newIds = newQuestions.map((q) => q.id).toSet();
        final filteredExisting = existing.where((q) => !newIds.contains(q.id)).toList();
        state = AsyncValue.data([...filteredExisting, ...newQuestions]);
      } else {
        state = AsyncValue.data(newQuestions);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void refresh() {
    _fetchFirstPage();
  }
}

// The provider that triggers fetching and filtering
final questionListProvider = StateNotifierProvider<QuestionListNotifier, AsyncValue<List<QuestionModel>>>((ref) {
  // Listen to filter changes to trigger re-fetch
  ref.watch(questionFilterProvider);
  return QuestionListNotifier(ref);
});

// Provides the bookmarked questions by resolving their IDs against Firestore
final bookmarkedQuestionsProvider = FutureProvider<List<QuestionModel>>((ref) async {
  final bookmarkIds = ref.watch(bookmarksProvider);
  if (bookmarkIds.isEmpty) return [];

  // Firestore 'whereIn' limits to 10 items. For large bookmarks, we might need chunking.
  // Here we chunk by 10.
  List<QuestionModel> results = [];
  
  for (var i = 0; i < bookmarkIds.length; i += 10) {
    final chunk = bookmarkIds.sublist(i, i + 10 > bookmarkIds.length ? bookmarkIds.length : i + 10);
    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where(FieldPath.documentId, whereIn: chunk)
        .get();
        
    results.addAll(snapshot.docs.map((d) => QuestionModel.fromMap(d.data(), d.id)));
  }
  
  return results;
});
