import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CurrentAffairsScreen extends StatelessWidget {
  const CurrentAffairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Current Affairs'), backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            indicatorColor: AppColors.accentSaffron, labelColor: Colors.white, unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: 'Daily'), Tab(text: 'Monthly'), Tab(text: 'Quiz'), Tab(text: 'Search')],
          ),
        ),
        body: TabBarView(
          children: [_DailyTab(), _MonthlyTab(), _QuizTab(), _SearchTab()],
        ),
      ),
    );
  }
}

class _DailyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, i) {
        final categories = ['TN Politics', 'India', 'Economy', 'Science', 'Sports', 'Education', 'TN Politics', 'India'];
        final colors = [AppColors.tamilSubject, AppColors.gsSubject, AppColors.warning, AppColors.info, AppColors.success, AppColors.aptitudeSubject, AppColors.tamilSubject, AppColors.gsSubject];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: colors[i].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(categories[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors[i])),
                    ),
                    const Spacer(),
                    Text('${i + 1}h ago', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Current affairs headline ${i + 1}: Important government announcement for Tamil Nadu',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 6),
                Text('Brief summary of the news article that provides key information for exam preparation.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.grey),
                    Text(' ${2 + i} min read', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('Read More', style: TextStyle(color: AppColors.accentSaffron, fontSize: 13))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) {
        final months = ['May 2026', 'April 2026', 'March 2026', 'February 2026', 'January 2026', 'December 2025'];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.accentSaffron.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.picture_as_pdf, color: AppColors.accentSaffron),
            ),
            title: Text('Monthly Digest - ${months[i]}'),
            subtitle: Text('${40 + i * 5} pages', style: const TextStyle(fontSize: 12)),
            trailing: IconButton(icon: const Icon(Icons.download_rounded, color: AppColors.accentSaffron), onPressed: () {}),
          ),
        );
      },
    );
  }
}

class _QuizTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_rounded, size: 64, color: AppColors.accentSaffron),
          const SizedBox(height: 16),
          const Text('Weekly Current Affairs Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('10 Questions • 8 Minutes', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
            child: const Text('Start Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search current affairs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.search, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Search for news topics', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
