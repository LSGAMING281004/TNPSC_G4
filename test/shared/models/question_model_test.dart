import 'package:flutter_test/flutter_test.dart';
import 'package:thiral_app/shared/models/question_model.dart';

void main() {
  group('QuestionModel Tests', () {
    final Map<String, dynamic> firestoreData = {
      'id': 'test_q_1',
      'questionTamil': 'தமிழ்நாட்டின் தலைநகரம் எது?',
      'questionEnglish': 'What is the capital of Tamil Nadu?',
      'optionsTamil': ['சென்னை', 'கோயம்புத்தூர்', 'மதுரை', 'திருச்சி'],
      'optionsEnglish': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli'],
      'correctOptionIndex': 0,
      'explanationTamil': 'சென்னை தமிழ்நாட்டின் தலைநகரம்.',
      'explanationEnglish': 'Chennai is the capital.',
      'subject': 'general_knowledge',
      'chapter': 'Geography',
      'topic': 'Capitals',
      'difficulty': 'easy',
      'year': 2023,
      'tags': ['tn', 'geography'],
      'isVerified': true,
      'createdAt': '2026-06-08T00:00:00Z',
    };

    test('fromJson serializes from Firestore correctly', () {
      final question = QuestionModel.fromJson(firestoreData);

      expect(question.id, 'test_q_1');
      expect(question.questionTamil, 'தமிழ்நாட்டின் தலைநகரம் எது?');
      expect(question.optionsEnglish.length, 4);
      expect(question.correctOptionIndex, 0);
      expect(question.subject, 'general_knowledge');
      expect(question.year, 2023);
      expect(question.isVerified, true);
    });

    test('toJson produces correct map', () {
      final question = QuestionModel.fromJson(firestoreData);
      final json = question.toJson();

      expect(json['id'], 'test_q_1');
      expect(json['subject'], 'general_knowledge');
      expect(json['optionsTamil'], isA<List>());
      expect((json['optionsTamil'] as List).first, 'சென்னை');
    });
  });
}
