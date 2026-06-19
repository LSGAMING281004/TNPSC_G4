import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_providers.dart' hide currentUserProvider;
import '../../../../core/language/language_provider.dart';
import '../../../../core/language/language_mode.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../core/services/push_notification_service.dart';

class Achievement {
  final String id;
  final String title;
  final String titleTamil;
  final String icon;
  final String desc;
  final int xp;
  
  const Achievement({
    required this.id, required this.title, required this.titleTamil,
    required this.icon, required this.desc, required this.xp,
  });
}

const _achievements = [
  Achievement(id: 'first_test', title: 'First Step', titleTamil: 'முதல் படி', icon: '🎯', desc: 'Complete your first mock test', xp: 50),
  Achievement(id: 'streak_7', title: 'Week Warrior', titleTamil: 'வார வீரன்', icon: '🔥', desc: '7-day study streak', xp: 100),
  Achievement(id: 'streak_30', title: 'Month Master', titleTamil: 'மாத மேதை', icon: '⚡', desc: '30-day study streak', xp: 500),
  Achievement(id: 'score_90', title: 'Top Scorer', titleTamil: 'முதல் மதிப்பெண்', icon: '🏆', desc: 'Score 90%+ in a full mock test', xp: 300),
  Achievement(id: 'questions_1000', title: 'Question Crusher', titleTamil: 'கேள்வி வீரன்', icon: '💪', desc: 'Answer 1000 questions', xp: 200),
  Achievement(id: 'bookmarks_50', title: 'Knowledge Keeper', titleTamil: 'அறிவு காவலன்', icon: '📚', desc: 'Bookmark 50 questions', xp: 150),
  Achievement(id: 'rank_top10', title: 'State Topper', titleTamil: 'மாநில சாம்பியன்', icon: '🥇', desc: 'Reach Top 10 state rank', xp: 1000),
  Achievement(id: 'accuracy_80', title: 'Sharpshooter', titleTamil: 'துல்லியமானவர்', icon: '🎯', desc: 'Maintain 80%+ accuracy overall', xp: 250),
  Achievement(id: 'tamil_master', title: 'Tamil Scholar', titleTamil: 'தமிழ் அறிஞர்', icon: '📖', desc: 'Answer 500 Tamil questions', xp: 300),
  Achievement(id: 'math_wizard', title: 'Math Wizard', titleTamil: 'கணித மேதை', icon: '🧮', desc: 'Answer 300 Aptitude questions', xp: 300),
  Achievement(id: 'gk_guru', title: 'GK Guru', titleTamil: 'பொது அறிவு குரு', icon: '🌍', desc: 'Answer 500 GK questions', xp: 300),
  Achievement(id: 'early_bird', title: 'Early Bird', titleTamil: 'அதிகாலை பறவை', icon: '🌅', desc: 'Complete a test before 6 AM', xp: 100),
  Achievement(id: 'night_owl', title: 'Night Owl', titleTamil: 'இரவு கழுகு', icon: '🦉', desc: 'Complete a test after 11 PM', xp: 100),
  Achievement(id: 'speed_demon', title: 'Speed Demon', titleTamil: 'வேக புயல்', icon: '🚀', desc: 'Complete a mock test in half the time', xp: 400),
  Achievement(id: 'perfect_week', title: 'Perfect Week', titleTamil: 'சிறந்த வாரம்', icon: '🌟', desc: 'Hit daily target 7 days in a row', xp: 500),
  Achievement(id: 'century', title: 'Century', titleTamil: 'சதம்', icon: '💯', desc: 'Take 100 mock tests', xp: 1000),
  Achievement(id: 'half_century', title: 'Half Century', titleTamil: 'அரை சதம்', icon: '🏏', desc: 'Take 50 mock tests', xp: 400),
  Achievement(id: 'social_butterfly', title: 'Social Butterfly', titleTamil: 'சமூக பட்டாம்பூச்சி', icon: '🦋', desc: 'Share your score 5 times', xp: 100),
  Achievement(id: 'error_free', title: 'Error Free', titleTamil: 'பிழையற்றவர்', icon: '✨', desc: 'Get 100% in a chapter test', xp: 200),
  Achievement(id: 'marathon', title: 'Marathon', titleTamil: 'மாரத்தான்', icon: '🏃', desc: 'Study for 4 hours in a single day', xp: 500),
];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final ref = FirebaseStorage.instance.ref().child('user_avatars').child('$uid.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({'photoUrl': url});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _updateName(String uid) async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'name': newName});
    }
    setState(() => _isEditingName = false);
  }

  Future<void> _updateDistrict(String uid, String district) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'district': district});
  }

  bool _isAchievementUnlocked(Achievement a, UserModel user) {
    switch (a.id) {
      case 'first_test': return user.questionsAttempted > 0; // approximation
      case 'streak_7': return user.studyStreak >= 7;
      case 'streak_30': return user.studyStreak >= 30;
      case 'score_90': return user.accuracy >= 90; // approx 
      case 'questions_1000': return user.questionsAttempted >= 1000;
      case 'bookmarks_50': return false; // Bookmarks not in userModel directly
      case 'rank_top10': return false; // Rank needs leaderboard query
      case 'accuracy_80': return user.accuracy >= 80 && user.questionsAttempted > 50;
      case 'century': return false; // Needs total test attempts count
      default: return false; // For demo, others remain locked unless explicitly coded
    }
  }

  double _calculateExamReadiness(UserModel user) {
    // A simple heuristic based on accuracy and questions attempted
    double readiness = (user.accuracy / 100) * 0.7; // Max 70% from accuracy
    double volume = (user.questionsAttempted / 5000).clamp(0.0, 1.0) * 0.3; // Max 30% from volume
    return (readiness + volume) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      body: userModelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron)),
        error: (_, __) => const Center(child: Text('Error loading profile')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in.'));
          }

          final readiness = _calculateExamReadiness(user);
          final bookmarksCount = ref.watch(userBookmarksStreamProvider).valueOrNull?.length ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user, readiness, isDark),
                const SizedBox(height: 16),
                _buildStatsGrid(user, bookmarksCount, isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Subject Mastery', isDark),
                _buildSubjectMasteryBars(user, isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Achievements (${_achievements.where((a) => _isAchievementUnlocked(a, user)).length}/${_achievements.length})', isDark),
                _buildAchievementsGrid(user, isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Settings', isDark),
                _buildSettingsList(context, isDark),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }

  Widget _buildHeader(UserModel user, double readiness, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF152A4A) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Readiness Ring
          Stack(
            alignment: Alignment.center,
            children: [
              CircularPercentIndicator(
                radius: 56.0,
                lineWidth: 6.0,
                percent: (readiness / 100).clamp(0.0, 1.0),
                progressColor: AppColors.success,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              GestureDetector(
                onTap: () => _pickAndUploadImage(user.uid),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.accentSaffron,
                  backgroundImage: user.photoUrl != null ? CachedNetworkImageProvider(user.photoUrl!) : null,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : (user.photoUrl == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isEditingName
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController..text = user.name,
                              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.check, color: AppColors.success), onPressed: () => _updateName(user.uid)),
                        ],
                      )
                    : Row(
                        children: [
                          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(icon: Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)), onPressed: () => setState(() => _isEditingName = true)),
                        ],
                      ),
                Text(user.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1F324E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: AppConstants.districts.contains(user.district) ? user.district : null,
                      hint: const Text('Select District'),
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF152A4A) : Colors.white,
                      icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
                      onChanged: (val) {
                        if (val != null) _updateDistrict(user.uid, val);
                      },
                      items: AppConstants.districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('Exam Readiness: ${readiness.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserModel user, int bookmarksCount, bool isDark) {
    // Calculate approximate values
    final testsTaken = (user.questionsAttempted / 100).floor(); // Dummy
    final daysActive = user.studyStreak; // Dummy
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard('Tests Taken', '$testsTaken', Icons.assignment, Colors.blue, isDark),
          _buildStatCard('Questions', '${user.questionsAttempted}', Icons.quiz, Colors.purple, isDark),
          _buildStatCard('Avg Score', '${user.accuracy.toStringAsFixed(0)}%', Icons.analytics, Colors.orange, isDark),
          _buildStatCard('Streak', '${user.studyStreak}🔥', Icons.local_fire_department, Colors.red, isDark),
          _buildStatCard('Bookmarks', '$bookmarksCount', Icons.bookmark, Colors.teal, isDark),
          _buildStatCard('Days Active', '$daysActive', Icons.calendar_today, Colors.green, isDark),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? const Color(0xFF152A4A) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSubjectMasteryBars(UserModel user, bool isDark) {
    final subjects = ['General Tamil', 'General Studies', 'Aptitude'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF152A4A) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        children: subjects.map((subj) {
          double percent = 0.0;
          final score = user.subjectScores[subj] ??
              user.subjectScores[subj.toLowerCase()] ??
              (subj == 'Aptitude'
                  ? (user.subjectScores['Aptitude & Mental Ability'] ??
                      user.subjectScores['aptitude_mental_ability'])
                  : null);
          if (score != null) {
            percent = (score / 100).clamp(0.0, 1.0);
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subj, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    Text('${(percent * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: percent,
                  padding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  progressColor: AppColors.accentSaffron,
                  barRadius: const Radius.circular(4),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsGrid(UserModel user, bool isDark) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final a = _achievements[index];
          final unlocked = _isAchievementUnlocked(a, user);
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? (isDark ? const Color(0xFF152A4A) : Colors.white) : (isDark ? const Color(0xFF1A3358) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
              border: unlocked ? Border.all(color: AppColors.accentSaffron.withValues(alpha: 0.3), width: 2) : null,
              boxShadow: unlocked ? [BoxShadow(color: AppColors.accentSaffron.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(a.icon, style: TextStyle(fontSize: 32, color: unlocked ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))),
                const SizedBox(height: 8),
                Text(
                  a.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: unlocked ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
                const SizedBox(height: 4),
                if (unlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('UNLOCKED', style: TextStyle(fontSize: 8, color: AppColors.success, fontWeight: FontWeight.bold)),
                  )
                else
                  Text('${a.xp} XP', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF152A4A) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
            value: isDark, // Wire to theme provider if exists
            onChanged: (val) {
              final mode = val ? ThemeMode.dark : ThemeMode.light;
              ref.read(themeModeProvider.notifier).state = mode;
              Hive.box('settings_box').put('themeMode', val ? 'dark' : 'light');
            },
            activeThumbColor: AppColors.accentSaffron,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(ref.watch(languageNotifierProvider).displayName),
            leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Notifications'),
            secondary: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
            value: ref.watch(notifDailyReminderProvider) || ref.watch(notifTestAlertsProvider) || ref.watch(notifCurrentAffairsProvider),
            onChanged: (val) {
              ref.read(notifDailyReminderProvider.notifier).state = val;
              ref.read(notifTestAlertsProvider.notifier).state = val;
              ref.read(notifCurrentAffairsProvider.notifier).state = val;

              final box = Hive.box('settings_box');
              box.put('notif_daily_reminder', val);
              box.put('notif_test_alerts', val);
              box.put('notif_current_affairs', val);

              if (val) {
                PushNotificationService.subscribeToTopic('daily_reminder');
                PushNotificationService.subscribeToTopic('test_alerts');
                PushNotificationService.subscribeToTopic('current_affairs');
              } else {
                PushNotificationService.unsubscribeFromTopic('daily_reminder');
                PushNotificationService.unsubscribeFromTopic('test_alerts');
                PushNotificationService.unsubscribeFromTopic('current_affairs');
              }
            },
            activeThumbColor: AppColors.accentSaffron,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Log Out'),
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onTap: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Log Out?',
                message: 'You will need to sign in again to access your progress.',
                confirmLabel: 'Log Out',
                isDestructive: true,
                icon: Icons.logout,
              );
              if (!confirmed) return;
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Delete Account?',
                message: 'To delete your account securely, we will redirect you to Settings.',
                confirmLabel: 'Go to Settings',
                isDestructive: true,
                icon: Icons.delete_forever,
              );
              if (confirmed && context.mounted) {
                context.push('/settings');
              }
            },
          ),
        ],
      ),
    );
  }
}
