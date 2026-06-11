import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class TestInstructionsScreen extends StatelessWidget {
  final String testId;
  const TestInstructionsScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Instructions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSaffron.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentSaffron.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accentSaffron),
                  SizedBox(width: 12),
                  Expanded(child: Text('Full Mock Test - TNPSC Group IV Pattern', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Exam Rules / தேர்வு விதிகள்', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...[
              '100 Multiple Choice Questions / 100 பன்மை தேர்வு கேள்விகள்',
              'Duration: 90 minutes / நேரம்: 90 நிமிடங்கள்',
              'Each correct answer: +1 mark / சரியான பதில்: +1 மதிப்பெண்',
              'Each wrong answer: -0.33 mark / தவறான பதில்: -0.33 மதிப்பெண்',
              'Unattempted: 0 marks / முயற்சிக்கப்படாதவை: 0 மதிப்பெண்',
              'You can mark questions for review / மறுஆய்வுக்கு குறிக்கலாம்',
              'Auto-submit when time expires / நேரம் முடிந்ததும் தானாக சமர்ப்பிக்கப்படும்',
              'Do not minimize the app / பயன்பாட்டை குறைக்க வேண்டாம்',
            ].map((rule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(rule, style: const TextStyle(fontSize: 14, height: 1.4))),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text('Select Language / மொழியைத் தேர்ந்தெடுக்கவும்', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _LangOption(label: 'English', isSelected: true)),
                const SizedBox(width: 12),
                Expanded(child: _LangOption(label: 'தமிழ்', isSelected: false)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () => context.push('${AppRoutes.testTaking}?testId=$testId'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentSaffron,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text('Start Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _LangOption({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentSaffron.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.accentSaffron : (isDark ? Colors.grey.shade800 : Colors.grey.shade300), width: isSelected ? 2 : 1),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.accentSaffron : (isDark ? Colors.grey.shade400 : Colors.grey))),
      ),
    );
  }
}
