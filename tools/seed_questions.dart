import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thiral_app/shared/models/question_model.dart';
// Note: Adjust import path for firebase_options.dart based on your setup.
import 'package:thiral_app/firebase_options.dart';

/// Seed script to populate Firestore with 50 sample questions.
/// Run via: flutter run tools/seed_questions.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('questions');

  print('Starting to seed 50 questions...');

  final questions = _generateSampleQuestions();
  
  int count = 0;
  for (final q in questions) {
    await collection.doc(q.id).set(q.toMap());
    count++;
    if (count % 10 == 0) {
      print('Seeded $count questions...');
    }
  }

  print('Finished seeding $count questions successfully!');
}

List<QuestionModel> _generateSampleQuestions() {
  final List<QuestionModel> list = [];
  int idCounter = 1000;

  final subjects = ['general_tamil', 'general_english', 'general_knowledge', 'aptitude', 'mental_ability'];
  final difficulties = ['easy', 'medium', 'hard'];
  final years = [0, 2019, 2020, 2021, 2022, 2023, 2024];

  // 10 questions per subject
  for (int s = 0; s < 5; s++) {
    final subject = subjects[s];
    
    for (int i = 0; i < 10; i++) {
      final qId = 'seed_${idCounter++}';
      final year = years[(idCounter % years.length)];
      final difficulty = difficulties[(idCounter % 3)];

      String qTa = '';
      String qEn = '';
      List<String> optTa = [];
      List<String> optEn = [];
      String expTa = '';
      String expEn = '';
      String topic = 'General';

      if (subject == 'general_tamil') {
        qTa = 'திருக்குறளில் உள்ள அதிகாரங்களின் எண்ணிக்கை என்ன? (Q$i)';
        qEn = 'What is the total number of chapters in Thirukkural? (Q$i)';
        optTa = ['133', '1330', '100', '10'];
        optEn = ['133', '1330', '100', '10'];
        expTa = 'திருக்குறளில் 133 அதிகாரங்கள் உள்ளன, ஒவ்வொன்றிலும் 10 குறள்கள் வீதம் 1330 குறள்கள் உள்ளன.';
        expEn = 'Thirukkural has 133 chapters, each with 10 couplets, making a total of 1330 couplets.';
        topic = 'Literature';
      } else if (subject == 'general_english') {
        qTa = 'சரியான ஒத்த சொல்லைக் கண்டுபிடி: "ABANDON" (Q$i)';
        qEn = 'Find the correct synonym for the word: "ABANDON" (Q$i)';
        optTa = ['தொடரவும்', 'கைவிடவும்', 'தொடங்கவும்', 'முடிக்கவும்'];
        optEn = ['Continue', 'Leave', 'Start', 'Finish'];
        expTa = 'Abandon என்றால் ஒரு விஷயத்தை முற்றிலுமாக கைவிடுவது அல்லது விட்டுவிடுவது என்று பொருள்.';
        expEn = 'Abandon means to leave completely and finally; forsake utterly.';
        topic = 'Vocabulary';
      } else if (subject == 'general_knowledge') {
        qTa = 'இந்தியாவின் முதல் செயற்கைக்கோள் எது? (Q$i)';
        qEn = 'What is the name of India\'s first artificial satellite? (Q$i)';
        optTa = ['ஆரியபட்டா', 'பாஸ்கரா', 'ரோகிணி', 'சந்திரயான்'];
        optEn = ['Aryabhata', 'Bhaskara', 'Rohini', 'Chandrayaan'];
        expTa = 'ஆரியபட்டா 1975 இல் சோவியத் யூனியனால் விண்ணில் செலுத்தப்பட்ட இந்தியாவின் முதல் செயற்கைக்கோள் ஆகும்.';
        expEn = 'Aryabhata was India\'s first satellite, launched by the Soviet Union in 1975.';
        topic = 'Space & Science';
      } else if (subject == 'aptitude') {
        qTa = 'ஒரு வேலையை A 10 நாட்களிலும், B 15 நாட்களிலும் முடிக்க முடியும். இருவரும் சேர்ந்து அந்த வேலையை எத்தனை நாட்களில் முடிப்பார்கள்? (Q$i)';
        qEn = 'A can finish a work in 10 days and B can do it in 15 days. In how many days can they finish it working together? (Q$i)';
        optTa = ['6 நாட்கள்', '5 நாட்கள்', '8 நாட்கள்', '12 நாட்கள்'];
        optEn = ['6 Days', '5 Days', '8 Days', '12 Days'];
        expTa = 'சூத்திரம்: (a*b)/(a+b) = (10*15)/(10+15) = 150/25 = 6 நாட்கள்.';
        expEn = 'Formula: (a*b)/(a+b) = (10*15)/(10+15) = 150/25 = 6 days.';
        topic = 'Time and Work';
      } else {
        qTa = 'தொடரில் அடுத்த எண்ணைக் கண்டுபிடி: 2, 4, 8, 16, ? (Q$i)';
        qEn = 'Find the next number in the series: 2, 4, 8, 16, ? (Q$i)';
        optTa = ['32', '24', '64', '20'];
        optEn = ['32', '24', '64', '20'];
        expTa = 'ஒவ்வொரு எண்ணும் முந்தைய எண்ணின் 2 மடங்கு ஆகும் (16 * 2 = 32).';
        expEn = 'Each number is multiplied by 2 to get the next number (16 * 2 = 32).';
        topic = 'Number Series';
      }

      list.add(QuestionModel(
        id: qId,
        questionTamil: qTa,
        questionEnglish: qEn,
        optionsTamil: optTa,
        optionsEnglish: optEn,
        correctOptionIndex: subject == 'general_english' ? 1 : 0, // 'Leave' is index 1 for abandon
        explanationTamil: expTa,
        explanationEnglish: expEn,
        subject: subject,
        topic: topic,
        chapter: 'Basic Concepts',
        difficulty: difficulty,
        year: year,
        tags: [topic.toLowerCase(), difficulty],
        isVerified: true,
      ));
    }
  }

  return list;
}
