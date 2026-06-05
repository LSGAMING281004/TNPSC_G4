import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoScaleController;
  late Animation<double> _logoScaleAnimation;

  late AnimationController _textFadeController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  late AnimationController _countdownFadeController;
  late Animation<double> _countdownFadeAnimation;

  double _initProgress = 0.0;
  String _initStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();

    // 1. Logo Scale Animation (0.5 to 1.0, ElasticOut, 800ms)
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.elasticOut),
    );

    // 2. Wordmark Text Slide & Fade (duration 600ms, delayed by 400ms)
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOutCubic),
    );

    // 3. Countdown & Progress Fade (delayed by 1000ms)
    _countdownFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _countdownFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _countdownFadeController, curve: Curves.easeIn),
    );

    // Start Animations Sequentially
    _logoScaleController.forward();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textFadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _countdownFadeController.forward();
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initProgress = 0.3;
        _initStatus = 'Connecting to services...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _initProgress = 0.6;
        _initStatus = 'Authenticating session...';
      });
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // User is already signed in — restore their profile from Firestore
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          final userModel = UserModel.fromFirestore(doc);
          ref.read(currentUserProvider.notifier).state = userModel;
        } else {
          // Firestore doc missing — create a basic one from Firebase Auth data
          final userModel = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            photoURL: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          ref.read(currentUserProvider.notifier).state = userModel;
        }
      }

      setState(() {
        _initProgress = 1.0;
        _initStatus = 'Welcome!';
      });
      
      // Ensure we display splash at least 2.5 seconds for branding and smooth animations
      await Future.delayed(const Duration(milliseconds: 1000));

      // Remove the native splash screen before navigating
      FlutterNativeSplash.remove();

      if (!mounted) return;

      if (firebaseUser != null) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Splash auth restore error: $e');
      FlutterNativeSplash.remove();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoScaleController.dispose();
    _textFadeController.dispose();
    _countdownFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = AppConstants.examDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Stack(
        children: [
          // Splash background image matching native splash to prevent any jar
          Positioned.fill(
            child: Image.asset(
              AppAssets.splashBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primaryNavy),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                
                // Centered Vilakku Mark Logo with Scale transition
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: const AppLogo(
                    variant: LogoVariant.mark,
                    size: 130,
                    theme: LogoTheme.dark,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Animated Text Wordmark below logo
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'GROUP 4 · 2026',
                          style: TextStyle(
                            color: AppColors.accentSaffron,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'உங்கள் வெற்றிக்கான பாதை',
                          style: TextStyle(
                            fontFamily: 'NotoSansTamil',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Bottom Section: Countdown & Loading Progress
                FadeTransition(
                  opacity: _countdownFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        // Countdown Container
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accentSaffron.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: AppColors.accentSaffron,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$daysLeft Days to Exam',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Status Text
                        Text(
                          _initStatus,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _initProgress,
                            minHeight: 3,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentSaffron),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Version indicator
                Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
