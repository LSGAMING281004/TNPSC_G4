class QuestionFilter {
  final Set<String> subjects;
  final Set<String> difficulties;
  final Set<int> years;
  final String? chapter;
  final String searchQuery;

  QuestionFilter({
    this.subjects = const {},
    this.difficulties = const {},
    this.years = const {},
    this.chapter,
    this.searchQuery = '',
  });

  QuestionFilter copyWith({
    Set<String>? subjects,
    Set<String>? difficulties,
    Set<int>? years,
    String? chapter,
    String? searchQuery,
  }) {
    return QuestionFilter(
      subjects: subjects ?? this.subjects,
      difficulties: difficulties ?? this.difficulties,
      years: years ?? this.years,
      chapter: chapter ?? this.chapter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
