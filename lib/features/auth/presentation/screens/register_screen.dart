import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedDistrict = '';
  int _targetScore = 150;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signUpWithEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      district: _selectedDistrict,
      targetScore: _targetScore,
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                  const SizedBox(height: 24),
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    child: const Column(
                      children: [
                        Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('கணக்கை உருவாக்கவும்', style: TextStyle(fontFamily: 'NotoSansTamil', color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: AuthTextField(
                      controller: _nameController, hintText: 'Full Name', icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Name is required';
                        if (val.length < 2) return 'Name must be at least 2 characters';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: AuthTextField(
                      controller: _emailController, hintText: 'Email Address', icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: AuthTextField(
                      controller: _passwordController, hintText: 'Password', icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password is required';
                        if (val.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // District dropdown
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict.isEmpty ? null : _selectedDistrict,
                      decoration: InputDecoration(
                        hintText: 'Select District',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.white54),
                        filled: true, fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
                      ),
                      dropdownColor: AppColors.primaryNavyLight,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: AppConstants.districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _selectedDistrict = v ?? ''),
                      validator: (v) => v == null || v.isEmpty ? 'Select your district' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Target score
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target Score: $_targetScore/200', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.accentSaffron,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                            thumbColor: AppColors.accentSaffron,
                          ),
                          child: Slider(
                            value: _targetScore.toDouble(), min: 50, max: 200, divisions: 30,
                            label: '$_targetScore',
                            onChanged: (v) => setState(() => _targetScore = v.round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentSaffron,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Text('Login', style: TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.bold)),
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
