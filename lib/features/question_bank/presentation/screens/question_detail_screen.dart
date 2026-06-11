import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  bool _revealed = false;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Who was the first Chief Minister of Tamil Nadu after independence?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5)),
            const SizedBox(height: 8),
            Text('சுதந்திரத்திற்குப் பின் தமிழ்நாட்டின் முதல் முதலமைச்சர் யார்?',
              style: TextStyle(fontFamily: 'NotoSansTamil', fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 24),
            ...['O.P. Ramasamy Reddiar', 'C. Rajagopalachari', 'K. Kamaraj', 'M.G. Ramachandran'].asMap().entries.map((e) {
              final i = e.key;
              final opt = e.value;
              final isSelected = _selected == i;
              final isCorrect = i == 0;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _revealed
                        ? (isCorrect ? AppColors.success.withValues(alpha: 0.1) : isSelected ? AppColors.error.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05))
                        : (isSelected ? AppColors.accentSaffron.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _revealed
                          ? (isCorrect ? AppColors.success : isSelected ? AppColors.error : (isDark ? Colors.grey.shade800 : Colors.grey.shade300))
                          : (isSelected ? AppColors.accentSaffron : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                      width: isSelected || (isCorrect && _revealed) ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: _revealed ? (isCorrect ? AppColors.success : isSelected ? AppColors.error : (isDark ? Colors.grey.shade800 : Colors.grey.shade200))
                              : (isSelected ? AppColors.accentSaffron : (isDark ? Colors.grey.shade800 : Colors.grey.shade200))),
                        child: Center(child: Text('ABCD'[i], style: TextStyle(fontWeight: FontWeight.bold,
                          color: isSelected || (isCorrect && _revealed) ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade600)))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(opt, style: const TextStyle(fontSize: 15))),
                      if (_revealed && isCorrect) const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      if (_revealed && isSelected && !isCorrect) const Icon(Icons.cancel, color: AppColors.error, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            if (!_revealed)
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _selected != null ? () => setState(() => _revealed = true) : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Reveal Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            if (_revealed) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.lightbulb, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info)),
                    ]),
                    SizedBox(height: 8),
                    Text('O.P. Ramasamy Reddiar was the first Chief Minister of Madras Presidency (later Tamil Nadu) from 1947 to 1949.', style: TextStyle(fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Practice Similar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
