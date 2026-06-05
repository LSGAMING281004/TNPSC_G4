import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/current_affairs_model.dart';

// Filter state
class CAFilterState {
  final String period; // 'today', 'week', 'month', 'archive'
  final String category; // 'All', 'TN_State', 'National', etc.

  CAFilterState({this.period = 'today', this.category = 'All'});

  CAFilterState copyWith({String? period, String? category}) {
    return CAFilterState(
      period: period ?? this.period,
      category: category ?? this.category,
    );
  }
}

class CAFilterNotifier extends StateNotifier<CAFilterState> {
  CAFilterNotifier() : super(CAFilterState());

  void setPeriod(String period) => state = state.copyWith(period: period);
  void setCategory(String category) => state = state.copyWith(category: category);
}

final caFilterProvider = StateNotifierProvider<CAFilterNotifier, CAFilterState>((ref) {
  return CAFilterNotifier();
});

// Cache logic
Future<void> _cacheArticles(List<CurrentAffairsModel> articles) async {
  Box box;
  if (!Hive.isBoxOpen('ca_cache')) {
    box = await Hive.openBox('ca_cache');
  } else {
    box = Hive.box('ca_cache');
  }
  
  // Cache up to 30 latest
  final toCache = articles.take(30).toList();
  await box.put('latest', jsonEncode(toCache.map((e) => e.toMap()).toList()));
}

Future<List<CurrentAffairsModel>> _getCachedArticles() async {
  Box box;
  if (!Hive.isBoxOpen('ca_cache')) {
    box = await Hive.openBox('ca_cache');
  } else {
    box = Hive.box('ca_cache');
  }
  
  final data = box.get('latest');
  if (data != null) {
    final list = jsonDecode(data) as List;
    return list.map((e) => CurrentAffairsModel.fromMap(e as Map<String, dynamic>, e['id'])).toList();
  }
  return [];
}

// Articles provider
final currentAffairsListProvider = FutureProvider<List<CurrentAffairsModel>>((ref) async {
  final filter = ref.watch(caFilterProvider);
  
  try {
    Query query = FirebaseFirestore.instance.collection('current_affairs');
    
    // Apply Category Filter
    if (filter.category != 'All') {
      query = query.where('category', isEqualTo: filter.category);
    }
    
    // Apply Period Filter
    final now = DateTime.now();
    DateTime startDate;
    switch (filter.period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        query = query.where('publishedAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1)); // start of week
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        query = query.where('publishedAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        query = query.where('publishedAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
        break;
      case 'archive':
        // get older ones
        startDate = DateTime(now.year, now.month, 1);
        query = query.where('publishedAt', isLessThan: startDate.toIso8601String());
        break;
    }
    
    query = query.orderBy('publishedAt', descending: true).limit(50);
    
    final snapshot = await query.get();
    final articles = snapshot.docs.map((doc) => CurrentAffairsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    
    if (filter.period == 'today' && filter.category == 'All') {
      _cacheArticles(articles); // Fire and forget cache update
    }
    
    return articles;
  } catch (e) {
    // If offline or error, return cached data if no strict filters
    if (filter.category == 'All' && filter.period != 'archive') {
      return await _getCachedArticles();
    }
    rethrow;
  }
});

// Single Article provider
final currentAffairDetailProvider = FutureProvider.family<CurrentAffairsModel, String>((ref, id) async {
  final doc = await FirebaseFirestore.instance.collection('current_affairs').doc(id).get();
  if (doc.exists && doc.data() != null) {
    return CurrentAffairsModel.fromMap(doc.data()!, doc.id);
  }
  
  // Try cache fallback
  final cached = await _getCachedArticles();
  return cached.firstWhere((element) => element.id == id, orElse: () => throw Exception('Article not found'));
});
