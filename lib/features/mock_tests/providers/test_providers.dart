import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/mock_test_model.dart';
import '../../../shared/models/question_model.dart';
import '../../../shared/models/test_attempt_model.dart';

// Fetch lists of mock tests (stubbed to use dummy data for now)
final testListProvider = FutureProvider.family<List<MockTestModel>, String>((ref, type) async {
  // Replace with actual Firestore fetch: 
  // final snapshot = await FirebaseFirestore.instance.collection('mock_tests').where('type', isEqualTo: type).get();
  await Future.delayed(const Duration(seconds: 1));
  return [
    MockTestModel(
      id: 't1',
      nameTamil: 'முழு மாதிரி தேர்வு 1',
      nameEnglish: 'Full Mock Test 1',
      type: 'full',
      questionCount: 100,
      durationMinutes: 90,
      questionIds: List.generate(100, (i) => 'q$i'),
      isActive: true,
    ),
    MockTestModel(
      id: 't2',
      nameTamil: 'பகுதி மாதிரி தேர்வு 1',
      nameEnglish: 'Subject Test 1',
      type: 'subject',
      questionCount: 50,
      durationMinutes: 45,
      subject: 'General Tamil',
      questionIds: List.generate(50, (i) => 'sq$i'),
      isActive: true,
    ),
  ].where((t) => t.type == type).toList();
});

// Provides questions for a specific test
final testQuestionsProvider = FutureProvider.family<List<QuestionModel>, String>((ref, testId) async {
  await Future.delayed(const Duration(seconds: 1));
  // Dummy question
  return List.generate(10, (i) => QuestionModel(
    id: 'q$i',
    questionTamil: 'கேள்வி $i: பாரதியார் பிறந்த ஊர் எது?',
    questionEnglish: 'Question $i: Where was Bharathiyar born?',
    optionsTamil: ['எட்டயபுரம்', 'சென்னை', 'மதுரை', 'திருச்சி'],
    optionsEnglish: ['Ettayapuram', 'Chennai', 'Madurai', 'Trichy'],
    correctOptionIndex: 0,
    explanationTamil: 'பாரதியார் எட்டயபுரத்தில் பிறந்தார்.',
    explanationEnglish: 'Bharathiyar was born in Ettayapuram.',
    subject: 'general_tamil',
    topic: 'Literature',
    chapter: 'Poets',
    difficulty: 'easy',
    year: 2019,
    tags: ['history'],
    isVerified: true,
  ));
});

// StateNotifier to manage active test attempt
class ActiveTestNotifier extends StateNotifier<TestAttemptModel?> {
  ActiveTestNotifier() : super(null);

  void startTest(String userId, String testId, int totalQuestions) {
    state = TestAttemptModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      testId: testId,
      startedAt: DateTime.now(),
      score: 0,
      totalQuestions: totalQuestions,
      correctCount: 0,
      incorrectCount: 0,
      skippedCount: totalQuestions,
      timeTakenSeconds: 0,
      subjectScores: {},
      answers: [],
      isCompleted: false,
    );
  }

  void updateAnswer(String questionId, int selectedOption, bool isCorrect, int timeSpentSeconds, String subject) {
    if (state == null) return;
    
    final currentAnswers = List<Map<String, dynamic>>.from(state!.answers);
    final existingIndex = currentAnswers.indexWhere((a) => a['questionId'] == questionId);
    
    if (existingIndex >= 0) {
      currentAnswers[existingIndex] = {
        'questionId': questionId,
        'selectedOption': selectedOption,
        'isCorrect': isCorrect,
        'timeSpentSeconds': timeSpentSeconds,
        'subject': subject,
      };
    } else {
      currentAnswers.add({
        'questionId': questionId,
        'selectedOption': selectedOption,
        'isCorrect': isCorrect,
        'timeSpentSeconds': timeSpentSeconds,
        'subject': subject,
      });
    }

    state = state!.copyWith(answers: currentAnswers);
  }

  Future<void> submitTest(int timeTakenSeconds) async {
    if (state == null) return;

    int correct = 0;
    int incorrect = 0;
    Map<String, int> subjectScores = {};

    for (var answer in state!.answers) {
      if (answer['isCorrect'] == true) {
        correct++;
        subjectScores[answer['subject']] = (subjectScores[answer['subject']] ?? 0) + 1;
      } else {
        incorrect++;
      }
    }

    final skipped = state!.totalQuestions - (correct + incorrect);

    state = state!.copyWith(
      completedAt: DateTime.now(),
      correctCount: correct,
      incorrectCount: incorrect,
      skippedCount: skipped,
      score: correct, // 1 point per correct answer
      timeTakenSeconds: timeTakenSeconds,
      subjectScores: subjectScores,
      isCompleted: true,
    );

    // Save to Firestore
    // await FirebaseFirestore.instance.collection('attempts').doc(state!.id).set(state!.toMap());
  }
}

final activeTestProvider = StateNotifierProvider<ActiveTestNotifier, TestAttemptModel?>((ref) {
  return ActiveTestNotifier();
});

// View result provider
final testResultProvider = FutureProvider.family<TestAttemptModel, String>((ref, attemptId) async {
  // Fetch from Firestore: return TestAttemptModel.fromMap(doc.data(), doc.id);
  // Using activeTestProvider state if available, otherwise returning a mock
  final activeTest = ref.read(activeTestProvider);
  if (activeTest != null && activeTest.id == attemptId) {
    return activeTest;
  }
  
  throw Exception('Attempt not found');
});
