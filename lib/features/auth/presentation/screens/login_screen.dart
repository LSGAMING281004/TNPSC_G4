import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation handled by GoRouter auth guard redirect
    } catch (e) {
      _showError('Login failed. Please check your credentials.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // Navigation handled by GoRouter
    } catch (e) {
      _showError('Google Sign-In failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
      // Navigation handled by GoRouter
    } catch (e) {
      _showError('Guest login failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.local_fire_department, size: 80, color: Color(0xFFF07020)),
                  const SizedBox(height: 16),
                  Text('Welcome Back', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('மீண்டும் வருக', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 48),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address / மின்னஞ்சல்', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password / கடவுச்சொல்', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login / உள்நுழைக'),
                    ),
                    
                  const SizedBox(height: 24),
                  const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR')), Expanded(child: Divider())]),
                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 32),
                    label: const Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: Colors.grey.shade300),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextButton(
                    onPressed: _isLoading ? null : _loginAsGuest,
                    child: const Text('Continue as Guest / விருந்தினராக தொடரவும்'),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('Create Account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
