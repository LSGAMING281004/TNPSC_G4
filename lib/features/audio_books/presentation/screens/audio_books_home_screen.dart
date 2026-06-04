import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../core/language/language_extension.dart';
import '../../../../shared/models/audio_book_model.dart';
import '../../data/audio_book_providers.dart';
import '../widgets/audio_book_card.dart';
import '../widgets/mini_player.dart';
import 'audio_player_screen.dart';

class AudioBooksHomeScreen extends ConsumerWidget {
  const AudioBooksHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageNotifierProvider);
    final s = context.s;
    final subjectFilter = ref.watch(audioSubjectFilterProvider);
    final booksAsync = ref.watch(audioBooksSubjectProvider(subjectFilter));
    final currentlyPlaying = ref.watch(currentlyPlayingIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.studyMaterials), // reuse or add a new string
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.headphones_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Audio Books',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Listen & Learn on the go 🎧',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subject filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Tamil', 'General Studies', 'Aptitude & Mental Ability']
                  .map((sub) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(sub, style: const TextStyle(fontSize: 12)),
                          selected: subjectFilter == sub,
                          selectedColor: AppColors.accentSaffron,
                          labelStyle: TextStyle(
                            color: subjectFilter == sub
                                ? Colors.white
                                : null,
                          ),
                          onSelected: (_) => ref
                              .read(audioSubjectFilterProvider.notifier)
                              .state = sub,
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Audio book list
          Expanded(
            child: booksAsync.when(
              data: (books) {
                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.headset_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(s.noData,
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (_, i) => AudioBookCard(
                    book: books[i],
                    isPlaying: currentlyPlaying == books[i].id,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AudioPlayerScreen(bookId: books[i].id),
                      ),
                    ),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
            ),
          ),

          // Mini player at bottom
          if (currentlyPlaying != null) const MiniPlayer(),
        ],
      ),
    );
  }
}
