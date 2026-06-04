import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MotivationalQuoteWidget extends StatefulWidget {
  const MotivationalQuoteWidget({super.key});

  @override
  State<MotivationalQuoteWidget> createState() => _MotivationalQuoteWidgetState();
}

class _MotivationalQuoteWidgetState extends State<MotivationalQuoteWidget> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  static const List<Map<String, String>> quotes = [
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
