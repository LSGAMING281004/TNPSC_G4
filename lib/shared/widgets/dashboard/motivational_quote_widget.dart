import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

// Stream provider to fetch quotes dynamically from Firestore
final clientQuotesStreamProvider = StreamProvider<List<Map<String, String>>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.quotesCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) {
            final data = d.data();
            return {
              'ta': (data['ta'] as String? ?? ''),
              'en': (data['en'] as String? ?? ''),
            };
          }).toList());
});

class MotivationalQuoteWidget extends ConsumerStatefulWidget {
  const MotivationalQuoteWidget({super.key});

  @override
  ConsumerState<MotivationalQuoteWidget> createState() => _MotivationalQuoteWidgetState();
}

class _MotivationalQuoteWidgetState extends ConsumerState<MotivationalQuoteWidget> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  static const List<Map<String, String>> defaultQuotes = [
    {'ta': 'கற்றது கைமண் அளவு, கல்லாதது உலகளவு', 'en': 'What you have learned is a mere handful; what you haven\'t learned is the size of the world.'},
    {'ta': 'அறிவே ஆற்றல்', 'en': 'Knowledge is power.'},
    {'ta': 'முயற்சி திருவினை ஆக்கும்', 'en': 'Effort leads to prosperity.'},
    {'ta': 'ஊக்கமது கைவிடேல்', 'en': 'Never give up your enthusiasm.'},
    {'ta': 'கல்வியே அழியாத செல்வம்', 'en': 'Education is imperishable wealth.'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesAsync = ref.watch(clientQuotesStreamProvider);

    return quotesAsync.when(
      data: (firestoreQuotes) {
        final quotes = firestoreQuotes.isNotEmpty ? firestoreQuotes : defaultQuotes;
        // Ensure index is within range of loaded quotes
        if (_currentIndex >= quotes.length) {
          _currentIndex = 0;
        }

        return _buildQuoteCard(quotes);
      },
      loading: () => _buildQuoteCard(defaultQuotes),
      error: (_, __) => _buildQuoteCard(defaultQuotes),
    );
  }

  Widget _buildQuoteCard(List<Map<String, String>> quotes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.saffronGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text('Daily Inspiration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${_currentIndex + 1}/${quotes.length}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: quotes.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(quotes[i]['ta']!, textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'NotoSansTamil', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(quotes[i]['en']!, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(quotes.length, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == i ? 16 : 6, height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == i ? Colors.white : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
