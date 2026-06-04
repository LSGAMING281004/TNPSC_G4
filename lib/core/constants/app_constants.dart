/// Application-wide constants for TNPSC Group 4 Master 2026
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'TNPSC Group 4 Master 2026';
  static const String appNameTamil = 'TNPSC குரூப் 4 மாஸ்டர் 2026';
  static const String appVersion = '1.0.0';

  // Exam Info
  static final DateTime examDate = DateTime(2026, 9, 20); // Expected exam date
  static const String examName = 'TNPSC Group IV & VAO';
  static const String examNameTamil = 'TNPSC குரூப் IV & VAO';

  // Test Configuration
  static const int fullMockQuestions = 100;
  static const int fullMockDurationMinutes = 90;
  static const int subjectTestQuestions = 50;
  static const int subjectTestDurationMinutes = 45;
  static const int chapterTestQuestions = 25;
  static const int chapterTestDurationMinutes = 20;
  static const int dailyChallengeQuestions = 10;
  static const int dailyChallengeDurationMinutes = 10;

  // Marking Scheme
  static const double correctMark = 1.0;
  static const double wrongMark = -0.33;

  // API Keys (Replace with actual keys)
  static const String claudeApiKey = 'YOUR_CLAUDE_API_KEY';
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  static const String claudeModel = 'claude-sonnet-4-20250514';

  // Supabase Config (For Storage)
  static const String supabaseUrl = 'https://qgslvlywsjjjnuwrubzo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnc2x2bHl3c2pqam51d3J1YnpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA1NDkzMTgsImV4cCI6MjA5NjEyNTMxOH0.EPc_aw7YQivze_qUNEdVqQGlqr-vweOUbQR4QGN4530';
  static const String supabaseMediaBucket = 'tnpsc-media';

  // Claude System Prompt
  static const String claudeSystemPrompt = '''
You are TamilBot, an expert TNPSC Group 4 exam coach. Answer in simple Tamil and English. 
Focus on TNPSC syllabus topics. Keep answers exam-focused and concise. 
When asked for practice questions, format them as numbered MCQs with options A/B/C/D.
Subjects: Tamil Language, General Studies (History, Geography, Polity, Economy, Science), 
Aptitude & Mental Ability.
''';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String downloadedMaterialsBox = 'downloaded_materials_box';
  static const String readingProgressBox = 'reading_progress_box';
  static const String quotesBox = 'quotes_box';
  static const String cacheBox = 'cache_box';
  static const String testResultsBox = 'test_results_box';
  static const String notificationsBox = 'notifications_box';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String mockTestsCollection = 'mock_tests';
  static const String studyMaterialsCollection = 'study_materials';
  static const String currentAffairsCollection = 'current_affairs';
  static const String notificationsCollection = 'notifications';
  static const String leaderboardCollection = 'leaderboard';
  static const String achievementsCollection = 'achievements';
  static const String testAttemptsCollection = 'test_attempts';
  static const String conversationsCollection = 'conversations';
  static const String quotesCollection = 'quotes';

  // Subjects
  static const List<String> subjects = ['Tamil', 'General Studies', 'Aptitude & Mental Ability'];
  static const List<String> subjectsTamil = ['தமிழ்', 'பொது அறிவு', 'எண்கணிதம் & மனக்கணக்கு'];

  // Districts of Tamil Nadu
  static const List<String> districts = [
    'Ariyalur', 'Chengalpattu', 'Chennai', 'Coimbatore', 'Cuddalore',
    'Dharmapuri', 'Dindigul', 'Erode', 'Kallakurichi', 'Kancheepuram',
    'Karur', 'Krishnagiri', 'Madurai', 'Mayiladuthurai', 'Nagapattinam',
    'Namakkal', 'Nilgiris', 'Perambalur', 'Pudukkottai', 'Ramanathapuram',
    'Ranipet', 'Salem', 'Sivagangai', 'Tenkasi', 'Thanjavur',
    'Theni', 'Thoothukudi', 'Tiruchirappalli', 'Tirunelveli', 'Tirupattur',
    'Tiruvallur', 'Tiruvannamalai', 'Tiruvarur', 'Vellore', 'Viluppuram',
    'Virudhunagar',
  ];

  // Pagination
  static const int leaderboardPageSize = 20;
  static const int questionsPageSize = 20;
  static const int currentAffairsPageSize = 10;

  // Achievement IDs
  static const String achievementFirstStep = 'first_step';
  static const String achievementStreakMaster = 'streak_master';
  static const String achievementCentury = 'century';
  static const String achievementTamilScholar = 'tamil_scholar';
  static const String achievementSpeedDemon = 'speed_demon';
  static const String achievementPerfectScore = 'perfect_score';
  static const String achievementNightOwl = 'night_owl';
  static const String achievementEarlyBird = 'early_bird';
}
