import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class QuestionBankHomeScreen extends StatefulWidget {
  const QuestionBankHomeScreen({super.key});

  @override
  State<QuestionBankHomeScreen> createState() => _QuestionBankHomeScreenState();
}

class _QuestionBankHomeScreenState extends State<QuestionBankHomeScreen> {
  String _selectedSubject = 'All';
  String _selectedDifficulty = 'All';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'), backgroundColor: AppColors.primaryNavy,
        actions: [
          IconButton(icon: const Icon(Icons.bookmark), onPressed: () => context.push(AppRoutes.bookmarks)),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(label: 'All', selected: _selectedSubject == 'All', onTap: () => setState(() => _selectedSubject = 'All')),
                _FilterChip(label: 'Tamil', selected: _selectedSubject == 'Tamil', onTap: () => setState(() => _selectedSubject = 'Tamil')),
                _FilterChip(label: 'GS', selected: _selectedSubject == 'GS', onTap: () => setState(() => _selectedSubject = 'GS')),
                _FilterChip(label: 'Aptitude', selected: _selectedSubject == 'Aptitude', onTap: () => setState(() => _selectedSubject = 'Aptitude')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Easy', selected: _selectedDifficulty == 'Easy', onTap: () => setState(() => _selectedDifficulty = 'Easy'), color: AppColors.difficultyEasy),
                _FilterChip(label: 'Medium', selected: _selectedDifficulty == 'Medium', onTap: () => setState(() => _selectedDifficulty = 'Medium'), color: AppColors.difficultyMedium),
                _FilterChip(label: 'Hard', selected: _selectedDifficulty == 'Hard', onTap: () => setState(() => _selectedDifficulty = 'Hard'), color: AppColors.difficultyHard),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Questions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    onTap: () => context.push('${AppRoutes.questionDetail}?questionId=q$index'),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.gsSubject.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                child: const Text('General Studies', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.gsSubject)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.difficultyMedium.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                child: const Text('MEDIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.difficultyMedium)),
                              ),
                              const Spacer(),
                              IconButton(icon: Icon(Icons.bookmark_border, size: 20, color: Colors.grey.shade400), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Q${index + 1}. Who was the first Chief Minister of Tamil Nadu?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Chapter: Indian History > State Leaders', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accentSaffron;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? c : Colors.grey.shade300),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? c : Colors.grey.shade600)),
        ),
      ),
    );
  }
}
