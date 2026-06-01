import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) {
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go(AppRoutes.dashboard);
      } else if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _googleSignIn() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithGoogle();
    if (mounted) {
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  Future<void> _guestLogin() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInAsGuest();
    if (mounted) {
      final state = ref.read(authNotifierProvider);
      if (state.isAuthenticated) {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryNavy, AppColors.primaryNavyDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  // Header
                  FadeInDown(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.accentSaffron, AppColors.accentSaffronLight],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentSaffron.withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.school_rounded, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        const Text('Welcome Back!',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('வணக்கம்! உள்நுழையுங்கள்',
                          style: TextStyle(
                            fontFamily: 'NotoSansTamil', fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email field
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: AuthTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password is required';
                        if (val.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Remember me & Forgot password
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24, height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? false),
                            activeColor: AppColors.accentSaffron,
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Remember Me',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.forgotPassword),
                          child: const Text('Forgot Password?',
                            style: TextStyle(color: AppColors.accentSaffron, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login button
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentSaffron,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white,
                                ),
                              )
                            : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Divider
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Google Sign In
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading ? null : _googleSignIn,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.white),
                        label: const Text('Sign in with Google',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Guest login
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: TextButton(
                      onPressed: authState.isLoading ? null : _guestLogin,
                      child: Text('Continue as Guest',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Register link
                  FadeInUp(
                    delay: const Duration(milliseconds: 900),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: const Text('Register',
                            style: TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
