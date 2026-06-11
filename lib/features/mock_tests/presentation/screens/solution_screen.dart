import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SolutionScreen extends StatelessWidget {
  final String resultId;
  const SolutionScreen({super.key, required this.resultId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Solutions')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final isCorrect = index % 3 != 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Q${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? AppColors.success : AppColors.error)),
                      ),
                      const Spacer(),
                      Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? AppColors.success : AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Sample question ${index + 1}: Which article of the Indian Constitution deals with the right to equality?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  ...['Article 14', 'Article 19', 'Article 21', 'Article 32'].asMap().entries.map((entry) {
                    final i = entry.key;
                    final opt = entry.value;
                    final isCorrectOpt = i == 0;
                    final isUserChoice = isCorrect ? i == 0 : i == 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrectOpt ? AppColors.success.withValues(alpha: 0.08) : isUserChoice && !isCorrect ? AppColors.error.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isCorrectOpt ? AppColors.success : isUserChoice && !isCorrect ? AppColors.error : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          Text('${'ABCD'[i]}. ', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Expanded(child: Text(opt)),
                          if (isCorrectOpt) const Icon(Icons.check, color: AppColors.success, size: 18),
                          if (isUserChoice && !isCorrect) const Icon(Icons.close, color: AppColors.error, size: 18),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: AppColors.info, size: 18),
                            SizedBox(width: 6),
                            Text('Explanation', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.info)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Article 14 guarantees equality before law and equal protection of laws. It is the foundation of the Right to Equality.', style: TextStyle(fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: const Text('Report Error', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
