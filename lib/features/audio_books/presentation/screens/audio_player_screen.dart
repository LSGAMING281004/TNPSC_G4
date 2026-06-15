import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../shared/models/audio_book_model.dart';
import '../../../../shared/widgets/bilingual_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/services/audio_handler.dart';
import '../../data/audio_book_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/providers/app_providers.dart';

/// Full-screen audio player with controls and background playback support.
class AudioPlayerScreen extends ConsumerStatefulWidget {
  final String bookId;
  const AudioPlayerScreen({super.key, required this.bookId});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isInitializing = false;
  String? _loadedBookId;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    // Mark as currently playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentlyPlayingIdProvider.notifier).state = widget.bookId;
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _initAudio(AudioBookModel book) async {
    if (_loadedBookId == book.id) return;
    _loadedBookId = book.id;
    
    final audioHandler = ref.read(audioHandlerProvider);
    final mediaItem = MediaItem(
      id: book.id,
      album: book.subject,
      title: book.titleEn,
      artist: book.narrator.isNotEmpty ? book.narrator : AppConstants.appName,
      artUri: book.coverImageUrl != null ? Uri.parse(book.coverImageUrl!) : null,
      extras: {'bookId': book.id},
    );

    setState(() => _isInitializing = true);
    await audioHandler.loadAudio(book.audioUrl, mediaItem);
    await audioHandler.play();
    setState(() => _isInitializing = false);
  }

  void _togglePlay(bool isPlaying) {
    final handler = ref.read(audioHandlerProvider);
    if (isPlaying) {
      handler.pause();
      _rotationController.stop();
    } else {
      handler.play();
      _rotationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(audioBookProvider(widget.bookId));
    final contentLang = ref.watch(contentLangProvider);

    return Scaffold(
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Audio book not found'));
          }

          // Trigger loading if not yet loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initAudio(book);
          });

          final audioHandler = ref.watch(audioHandlerProvider);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryNavy,
                  AppColors.primaryNavy.withValues(alpha: 0.85),
                  const Color(0xFF0A1628),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, book),
                  const SizedBox(height: 20),
                  _buildCoverArt(book),
                  const SizedBox(height: 28),
                  _buildTitleSection(book, contentLang),
                  const SizedBox(height: 24),
                  _buildProgressBar(audioHandler),
                  const SizedBox(height: 24),
                  _buildControls(audioHandler),
                  const SizedBox(height: 20),
                  _buildSpeedAndExtras(audioHandler),
                  const Spacer(),
                  _buildBottomInfo(book),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => Container(
          color: AppColors.primaryNavy,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accentSaffron),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AudioBookModel book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Now Playing',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () => _showMoreMenu(context, book),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverArt(AudioBookModel book) {
    return RotationTransition(
      turns: _rotationController,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentSaffron.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: book.coverImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _coverPlaceholder(),
                  errorWidget: (_, __, ___) => _coverPlaceholder(),
                )
              : _coverPlaceholder(),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: AppColors.primaryNavy,
        child: const Center(
          child: Icon(Icons.headphones_rounded,
              color: AppColors.accentSaffron, size: 64),
        ),
      );

  Widget _buildTitleSection(AudioBookModel book, String contentLang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          BilingualText(
            tamilText: book.titleTa,
            englishText: book.titleEn,
            contentLang: contentLang,
            primaryStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            secondaryStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            '${book.subject} • ${book.narrator.isNotEmpty ? book.narrator : AppConstants.appName}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MyAudioHandler handler) {
    return StreamBuilder<Duration>(
      stream: handler.positionStream,
      builder: (context, positionSnap) {
        return StreamBuilder<Duration?>(
          stream: handler.durationStream,
          builder: (context, durationSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final duration = durationSnap.data ?? Duration.zero;

            double posVal = position.inMilliseconds.toDouble();
            double durVal = duration.inMilliseconds.toDouble();
            if (posVal > durVal && durVal > 0) posVal = durVal;
            if (durVal == 0) durVal = 1.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: AppColors.accentSaffron,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                      thumbColor: AppColors.accentSaffron,
                    ),
                    child: Slider(
                      value: posVal,
                      max: durVal,
                      onChanged: (v) {
                        handler.seek(Duration(milliseconds: v.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(position.inSeconds),
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                        Text(_formatTime(duration.inSeconds),
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControls(MyAudioHandler handler) {
    return StreamBuilder<PlaybackState>(
      stream: handler.playbackState,
      builder: (context, snap) {
        final state = snap.data;
        final playing = state?.playing ?? false;
        
        if (playing && !_rotationController.isAnimating) {
           _rotationController.repeat();
        } else if (!playing && _rotationController.isAnimating) {
           _rotationController.stop();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle, color: Colors.white54, size: 22),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
              onPressed: () {
                final pos = snap.data?.updatePosition ?? Duration.zero;
                handler.seek(pos - const Duration(seconds: 10));
              },
            ),
            const SizedBox(width: 16),
            // Play / Pause
            GestureDetector(
              onTap: () => _togglePlay(playing),
              child: Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.accentSaffron, Color(0xFFFF6B35)],
                  ),
                ),
                child: _isInitializing
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon:
                  const Icon(Icons.forward_30, color: Colors.white, size: 32),
              onPressed: () {
                final pos = snap.data?.updatePosition ?? Duration.zero;
                handler.seek(pos + const Duration(seconds: 30));
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.repeat, color: Colors.white54, size: 22),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedAndExtras(MyAudioHandler handler) {
    return StreamBuilder<PlaybackState>(
      stream: handler.playbackState,
      builder: (context, snap) {
        final speed = snap.data?.speed ?? 1.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _speedChip(handler, speed, 0.5),
            _speedChip(handler, speed, 0.75),
            _speedChip(handler, speed, 1.0),
            _speedChip(handler, speed, 1.25),
            _speedChip(handler, speed, 1.5),
            _speedChip(handler, speed, 2.0),
          ],
        );
      }
    );
  }

  Widget _speedChip(MyAudioHandler handler, double currentSpeed, double speed) {
    final isActive = currentSpeed == speed;
    return GestureDetector(
      onTap: () => handler.setSpeed(speed),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentSaffron
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${speed}x',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(AudioBookModel book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomAction(Icons.bookmark_border, 'Bookmark', onTap: () {}),
          _bottomAction(Icons.download_outlined, 'Download', onTap: () {}),
          _bottomAction(Icons.share_outlined, 'Share', onTap: () {}),
          _bottomAction(
            Icons.timer_outlined,
            'Sleep Timer',
            onTap: () => _showSleepTimerBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context, AudioBookModel book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Colors.white70),
                title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSleepTimerBottomSheet(this.context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.white70),
                title: const Text('Report Issue', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showReportIssueBottomSheet(this.context, book.id);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final timerState = ref.watch(sleepTimerProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sleep Timer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (timerState.isActive && timerState.remainingTime != null) ...[
                      Text(
                        'Remaining time: ${_formatTime(timerState.remainingTime!.inSeconds)}',
                        style: const TextStyle(color: AppColors.accentSaffron, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(sleepTimerProvider.notifier).cancelTimer();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Stop Timer'),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Stop playback after a set amount of time.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildTimerOption(context, ref, '5 Min', const Duration(minutes: 5)),
                          _buildTimerOption(context, ref, '10 Min', const Duration(minutes: 10)),
                          _buildTimerOption(context, ref, '15 Min', const Duration(minutes: 15)),
                          _buildTimerOption(context, ref, '30 Min', const Duration(minutes: 30)),
                          _buildTimerOption(context, ref, '45 Min', const Duration(minutes: 45)),
                          _buildTimerOption(context, ref, '60 Min', const Duration(minutes: 60)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimerOption(BuildContext context, WidgetRef ref, String label, Duration duration) {
    return ActionChip(
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: BorderSide.none,
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: () {
        ref.read(sleepTimerProvider.notifier).setTimer(duration);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sleep timer set for ${duration.inMinutes} minutes.'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  void _showReportIssueBottomSheet(BuildContext context, String bookId) {
    final issues = [
      'Incorrect Audio / Content Mismatch',
      'Audio Stuttering / Buffering',
      'Narrator Pronunciation / Translation Error',
      'Missing chapters or incomplete audio',
      'Other',
    ];
    String selectedIssue = issues[0];
    final detailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Report Issue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What issue did you encounter?',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF0A1628),
                        value: selectedIssue,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: issues.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setModalState(() {
                            selectedIssue = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Details (Optional)',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      hintText: 'Describe the issue...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final uid = ref.read(authUidProvider) ?? '';
                      if (uid.isEmpty) return;

                      try {
                        await FirebaseFirestore.instance.collection('content_reports').add({
                          'userId': uid,
                          'contentId': bookId,
                          'contentType': 'audio',
                          'issueType': selectedIssue,
                          'timestamp': FieldValue.serverTimestamp(),
                          'details': detailsController.text,
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Issue reported successfully. Thank you!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to report issue: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentSaffron,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
