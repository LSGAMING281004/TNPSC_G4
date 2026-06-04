import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../shared/models/audio_book_model.dart';
import '../../data/audio_book_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A card for a single audio book in the list.
class AudioBookCard extends StatelessWidget {
  final AudioBookModel book;
  final bool isPlaying;
  final VoidCallback onTap;

  const AudioBookCard({
    super.key,
    required this.book,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.accentSaffron.withOpacity(0.08)
              : isDark
                  ? Colors.grey.shade800
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying
                ? AppColors.accentSaffron
                : isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
            width: isPlaying ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: AppColors.primaryNavy.withOpacity(0.1),
                child: book.coverImageUrl != null &&
                        book.coverImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _coverPlaceholder(),
                        errorWidget: (_, __, ___) => _coverPlaceholder(),
                      )
                    : _coverPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.titleEn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.titleTa.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.titleTa,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'NotoSansTamil',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _infoBadge(Icons.timer_outlined, book.formattedDuration),
                      const SizedBox(width: 10),
                      _infoBadge(Icons.play_circle_outline,
                          '${book.playCount} plays'),
                      if (book.isPremium) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PRO',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade800)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Play indicator
            if (isPlaying)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentSaffron,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.equalizer, color: Colors.white, size: 18),
              )
            else
              Icon(Icons.play_circle_filled,
                  color: AppColors.primaryNavy, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: AppColors.primaryNavy.withOpacity(0.08),
        child: const Center(
          child: Icon(Icons.headphones, color: AppColors.primaryNavy, size: 28),
        ),
      );

  Widget _infoBadge(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}
