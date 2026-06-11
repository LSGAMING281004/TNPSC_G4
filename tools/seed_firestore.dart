import 'dart:convert';
import 'dart:io';

const String projectId = 'thiral-app';
const String emulatorHost = 'http://127.0.0.1:8080';
const bool useEmulator = true; // Set to false and provide authToken for production
const String? authToken = null; // Provide OAuth2 token if useEmulator is false

String get baseUrl => useEmulator
    ? '$emulatorHost/v1/projects/$projectId/databases/(default)/documents'
    : 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

Future<void> main() async {
  print('🔥 Starting Firestore Seeding (TNPSC Group 4)...');
  
  await seedQuestions();
  await seedMockTests();
  await seedCurrentAffairs();
  await seedStudyMaterials();
  await seedLeaderboard();
  
  print('✅ Seeding completed successfully!');
}

Future<void> _postDocument(String collection, String id, Map<String, dynamic> data) async {
  final url = '$baseUrl/$collection?documentId=$id';
  final uri = Uri.parse(url);
  final client = HttpClient();
  
  try {
    final request = await client.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    if (!useEmulator && authToken != null) {
      request.headers.set('Authorization', 'Bearer $authToken');
    }

    final firestoreJson = jsonEncode({'fields': _toFirestoreMap(data)});
    request.add(utf8.encode(firestoreJson));
    
    final response = await request.close();
    final resBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Seeded $collection/$id');
    } else if (response.statusCode == 409) {
      print('⚠️ $collection/$id already exists (skipped).');
    } else {
      print('❌ Error seeding $collection/$id: ${response.statusCode} - $resBody');
    }
  } catch (e) {
    print('❌ Connection error for $collection/$id: $e');
  } finally {
    client.close();
  }
}

Map<String, dynamic> _toFirestoreMap(Map<String, dynamic> data) {
  return data.map((key, value) => MapEntry(key, _toFirestoreValue(value)));
}

Map<String, dynamic> _toFirestoreValue(dynamic value) {
  if (value is String) return {'stringValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  if (value is bool) return {'booleanValue': value};
  if (value is List) return {'arrayValue': {'values': value.map((v) => _toFirestoreValue(v)).toList()}};
  if (value is Map<String, dynamic>) return {'mapValue': {'fields': _toFirestoreMap(value)}};
  if (value == null) return {'nullValue': null};
  return {'stringValue': value.toString()};
}

// ================= SEED DATA =================

Future<void> seedQuestions() async {
  print('--- Seeding 100 Questions ---');
  // 20 General Tamil
  for (int i = 1; i <= 20; i++) {
    await _postDocument('questions', 'gt_$i', {
      'questionTamil': 'தமிழ்நாட்டின் தலைநகரம் எது? ($i)',
      'questionEnglish': 'What is the capital of Tamil Nadu? ($i)',
      'optionsTamil': ['சென்னை', 'கோயம்புத்தூர்', 'மதுரை', 'திருச்சி'],
      'optionsEnglish': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli'],
      'correctOptionIndex': 0,
      'explanationTamil': 'சென்னை தமிழ்நாட்டின் தலைநகரமும் மிகப்பெரிய நகரமும் ஆகும்.',
      'explanationEnglish': 'Chennai is the capital and largest city of Tamil Nadu.',
      'subject': 'general_tamil',
      'chapter': 'Sangam_Age',
      'topic': 'Poets',
      'difficulty': i % 3 == 0 ? 'hard' : (i % 2 == 0 ? 'medium' : 'easy'),
      'year': 2023,
      'tags': ['tamil', 'literature'],
      'isVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // 20 General English
  for (int i = 1; i <= 20; i++) {
    await _postDocument('questions', 'ge_$i', {
      'questionTamil': 'ஆங்கில இலக்கணம்: சரியான வாக்கியத்தை தேர்ந்தெடு ($i)',
      'questionEnglish': 'English Grammar: Choose the correct sentence ($i)',
      'optionsTamil': ['He go to school', 'He goes to school', 'He going to school', 'He gone to school'],
      'optionsEnglish': ['He go to school', 'He goes to school', 'He going to school', 'He gone to school'],
      'correctOptionIndex': 1,
      'explanationTamil': 'He/She/It வரும்போது வினையுடன் s/es சேர்க்கப்பட வேண்டும்.',
      'explanationEnglish': 'For third-person singular (He/She/It), the verb takes an s/es in simple present tense.',
      'subject': 'general_english',
      'chapter': 'Grammar',
      'topic': 'Tenses',
      'difficulty': i % 2 == 0 ? 'medium' : 'easy',
      'year': 2022,
      'tags': ['english', 'grammar'],
      'isVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // 25 General Knowledge
  for (int i = 1; i <= 25; i++) {
    await _postDocument('questions', 'gk_$i', {
      'questionTamil': 'இந்தியாவின் முதல் குடியரசுத் தலைவர் யார்? ($i)',
      'questionEnglish': 'Who was the first President of India? ($i)',
      'optionsTamil': ['ஜவஹர்லால் நேரு', 'டாக்டர் ராஜேந்திர பிரசாத்', 'சர்தார் வல்லபாய் படேல்', 'பி.ஆர். அம்பேத்கர்'],
      'optionsEnglish': ['Jawaharlal Nehru', 'Dr. Rajendra Prasad', 'Sardar Vallabhbhai Patel', 'B.R. Ambedkar'],
      'correctOptionIndex': 1,
      'explanationTamil': 'டாக்டர் ராஜேந்திர பிரசாத் சுதந்திர இந்தியாவின் முதல் குடியரசுத் தலைவராக பணியாற்றினார்.',
      'explanationEnglish': 'Dr. Rajendra Prasad served as the first President of independent India.',
      'subject': 'general_knowledge',
      'chapter': 'Polity',
      'topic': 'Constitution',
      'difficulty': 'easy',
      'year': 2021,
      'tags': ['polity', 'india', 'history'],
      'isVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // 20 Aptitude
  for (int i = 1; i <= 20; i++) {
    await _postDocument('questions', 'ap_$i', {
      'questionTamil': '100 இன் 20% எவ்வளவு? ($i)',
      'questionEnglish': 'What is 20% of 100? ($i)',
      'optionsTamil': ['10', '20', '30', '40'],
      'optionsEnglish': ['10', '20', '30', '40'],
      'correctOptionIndex': 1,
      'explanationTamil': '(20/100) * 100 = 20',
      'explanationEnglish': '(20/100) * 100 = 20',
      'subject': 'aptitude',
      'chapter': 'Percentage',
      'topic': 'Basic Mathematics',
      'difficulty': 'easy',
      'year': 0,
      'tags': ['math', 'percentage'],
      'isVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // 15 Mental Ability
  for (int i = 1; i <= 15; i++) {
    await _postDocument('questions', 'ma_$i', {
      'questionTamil': 'A=1, B=2 என்றால், C=? ($i)',
      'questionEnglish': 'If A=1, B=2, then C=? ($i)',
      'optionsTamil': ['1', '2', '3', '4'],
      'optionsEnglish': ['1', '2', '3', '4'],
      'correctOptionIndex': 2,
      'explanationTamil': 'C என்பது ஆங்கில எழுத்துக்களில் 3வது எழுத்து.',
      'explanationEnglish': 'C is the 3rd letter in the English alphabet.',
      'subject': 'mental_ability',
      'chapter': 'Coding-Decoding',
      'topic': 'Alphabets',
      'difficulty': 'easy',
      'year': 2024,
      'tags': ['mental_ability', 'coding'],
      'isVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

Future<void> seedMockTests() async {
  print('--- Seeding 8 Mock Tests ---');
  final testTypes = [
    {'id': 'full_1', 'title': 'Full Mock Test 1', 'type': 'full', 'qCount': 100, 'duration': 180},
    {'id': 'full_2', 'title': 'Full Mock Test 2', 'type': 'full', 'qCount': 100, 'duration': 180},
    {'id': 'sub_1', 'title': 'General Tamil Mastery', 'type': 'subject', 'qCount': 50, 'duration': 60},
    {'id': 'sub_2', 'title': 'General Knowledge Pro', 'type': 'subject', 'qCount': 50, 'duration': 60},
    {'id': 'chap_1', 'title': 'Aptitude: Percentages', 'type': 'chapter', 'qCount': 25, 'duration': 30},
    {'id': 'chap_2', 'title': 'Polity: Constitution', 'type': 'chapter', 'qCount': 25, 'duration': 30},
    {'id': 'daily_1', 'title': 'Daily Quiz - June 8', 'type': 'daily', 'qCount': 10, 'duration': 10},
    {'id': 'daily_2', 'title': 'Daily Quiz - June 9', 'type': 'daily', 'qCount': 10, 'duration': 10},
  ];

  for (var t in testTypes) {
    await _postDocument('tests', t['id'] as String, {
      'titleTa': '${t['title']} (தமிழ்)',
      'titleEn': t['title'],
      'descriptionTa': 'உங்கள் திறனை சோதிக்கவும்',
      'descriptionEn': 'Test your skills',
      'type': t['type'],
      'questionCount': t['qCount'],
      'durationMinutes': t['duration'],
      'subject': t['type'] == 'subject' ? 'general_tamil' : null,
      'isActive': true,
      'isPremium': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

Future<void> seedCurrentAffairs() async {
  print('--- Seeding 15 Current Affairs ---');
  for (int i = 1; i <= 15; i++) {
    await _postDocument('current_affairs', 'ca_$i', {
      'titleTa': 'ஜூன் 2026 முக்கிய நிகழ்வு $i',
      'titleEn': 'Major Event in June 2026 $i',
      'contentTa': 'இது ஒரு முக்கிய நடப்பு நிகழ்வு. தேர்வில் அடிக்கடி கேட்கப்படும்...',
      'contentEn': 'This is a major current affair event. Frequently asked in exams...',
      'category': i % 3 == 0 ? 'International' : (i % 2 == 0 ? 'National' : 'Tamil Nadu'),
      'importance': i % 5 == 0 ? 'high' : 'medium',
      'date': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      'imageUrl': 'https://placeholder.com/ca_$i.png',
      'sourceUrl': 'https://thehindu.com',
      'tags': ['news', '2026', 'update'],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

Future<void> seedStudyMaterials() async {
  print('--- Seeding 10 Study Materials ---');
  final subjects = ['general_tamil', 'general_english', 'general_knowledge', 'aptitude', 'mental_ability'];
  
  for (int i = 1; i <= 10; i++) {
    await _postDocument('study_materials', 'sm_$i', {
      'titleTa': 'பாடம் $i குறிப்புகள்',
      'titleEn': 'Chapter $i Notes',
      'descriptionTa': 'முழுமையான விளக்கங்கள் அடங்கியது.',
      'descriptionEn': 'Contains complete explanations.',
      'subject': subjects[i % subjects.length],
      'type': 'pdf',
      'url': 'https://firebasestorage.googleapis.com/v0/b/thiral-app.appspot.com/o/sample.pdf?alt=media',
      'fileSize': 1024500, // ~1MB
      'pageCount': 45,
      'isPremium': i % 4 == 0, // 25% premium
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

Future<void> seedLeaderboard() async {
  print('--- Seeding 25 Leaderboard Entries ---');
  final names = [
    'Rajesh', 'Karthik', 'Suresh', 'Priya', 'Anitha', 'Meena', 'Ravi', 'Kamal', 'Vijay', 'Ajith',
    'Surya', 'Vikram', 'Dhanush', 'Siva', 'Sivaji', 'MGR', 'Rajini', 'Nayan', 'Trisha', 'Samantha',
    'Shruti', 'Keerthy', 'Anushka', 'Tamanna', 'Hansika'
  ];
  final districts = ['Chennai', 'Madurai', 'Coimbatore', 'Trichy', 'Salem', 'Tirunelveli', 'Vellore', 'Erode'];

  for (int i = 0; i < 25; i++) {
    await _postDocument('leaderboard', 'user_$i', {
      'userId': 'user_$i',
      'userName': names[i],
      'photoUrl': null,
      'district': districts[i % districts.length],
      'totalScore': 10000 - (i * 250), // Descending score
      'testsAttempted': 50 - i,
      'avgScore': 85.5 - (i * 1.5),
      'rank': i + 1,
      'weeklyScore': 1000 - (i * 30),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
