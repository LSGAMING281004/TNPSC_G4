import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import '../../data/audio_book_providers.dart';
import '../screens/audio_player_screen.dart';

/// Persistent mini player shown at bottom of screens when audio is playing.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingId = ref.watch(currentlyPlayingIdProvider);
    if (playingId == null) return const SizedBox.shrink();

    final bookAsync = ref.watch(audioBookProvider(playingId));

    return bookAsync.when(
      data: (book) {
        if (book == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AudioPlayerScreen(bookId: book.id),
            ),
          ),
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryNavy, Color(0xFF1B2838)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated equalizer
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentSaffron.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.equalizer,
                        color: AppColors.accentSaffron, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.titleEn,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(book.subject,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11)),
                    ],
                  ),
                ),
                // Controls
                Consumer(
                  builder: (context, ref, _) {
                    final handler = ref.watch(audioHandlerProvider);
                    return StreamBuilder<PlaybackState>(
                      stream: handler.playbackState,
                      builder: (context, snap) {
                        final playing = snap.data?.playing ?? false;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                if (playing) {
                                  handler.pause();
                                } else {
                                  handler.play();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors.white.withValues(alpha: 0.5), size: 20),
                              onPressed: () {
                                handler.stop();
                                ref.read(currentlyPlayingIdProvider.notifier).state = null;
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
