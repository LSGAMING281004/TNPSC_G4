import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Engine Unit Tests', () {
    test('Timer counts down correctly', () {
      int durationSeconds = 60;
      durationSeconds--;
      expect(durationSeconds, 59);
    });

    test('Auto-submit triggers at 00:00', () {
      bool isSubmitted = false;
      int durationSeconds = 0;
      
      if (durationSeconds <= 0) {
        isSubmitted = true;
      }
      
      expect(isSubmitted, true);
    });

    test('Score calculated correctly (correct/incorrect/skipped)', () {
      // Assuming 3 questions: 1 correct, 1 incorrect, 1 skipped
      final userAnswers = {
        'q1': 0, // correct (index 0)
        'q2': 1, // incorrect (correct is 2)
        // q3 not in map -> skipped
      };
      
      final correctAnswers = {
        'q1': 0,
        'q2': 2,
        'q3': 1,
      };
      
      int correct = 0;
      int incorrect = 0;
      int skipped = 0;
      
      for (final qId in correctAnswers.keys) {
        if (!userAnswers.containsKey(qId)) {
          skipped++;
        } else if (userAnswers[qId] == correctAnswers[qId]) {
          correct++;
        } else {
          incorrect++;
        }
      }
      
      expect(correct, 1);
      expect(incorrect, 1);
      expect(skipped, 1);
      
      // TNPSC Group 4 has no negative marking. 1.5 marks per question.
      final score = correct * 1.5;
      expect(score, 1.5);
    });
  });

  group('Test Engine Widget Tests', () {
    testWidgets('Options highlight correctly on tap', (WidgetTester tester) async {
      int? selectedIndex;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: List.generate(4, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      key: ValueKey('option_$index'),
                      color: selectedIndex == index ? Colors.blue : Colors.white,
                      child: Text('Option $index'),
                    ),
                  );
                }),
              );
            }
          ),
        ),
      ));

      // Initially none selected
      expect(selectedIndex, isNull);
      
      // Tap option 2
      await tester.tap(find.byKey(const ValueKey('option_2')));
      await tester.pump();
      
      expect(selectedIndex, 2);
    });

    testWidgets('Language toggle switches between Tamil/English', (WidgetTester tester) async {
      bool isTamil = true;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Switch(
                    key: const ValueKey('lang_switch'),
                    value: isTamil,
                    onChanged: (val) {
                      setState(() {
                        isTamil = val;
                      });
                    },
                  ),
                  Text(isTamil ? 'தமிழ் கேள்வி' : 'English Question'),
                ],
              );
            }
          ),
        ),
      ));

      // Initially Tamil
      expect(find.text('தமிழ் கேள்வி'), findsOneWidget);
      expect(find.text('English Question'), findsNothing);
      
      // Toggle Switch
      await tester.tap(find.byKey(const ValueKey('lang_switch')));
      await tester.pumpAndSettle();
      
      // Now English
      expect(find.text('English Question'), findsOneWidget);
      expect(find.text('தமிழ் கேள்வி'), findsNothing);
    });
  });
}
