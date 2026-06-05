import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).registerWithEmailPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Success triggers auth state change, router redirects
    } catch (e) {
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Join Thiral', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Start your TNPSC journey today / உங்கள் பயணத்தை தொடங்கவும்', 
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name / முழு பெயர்', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => (value == null || value.trim().length < 2) ? 'Enter a valid name' : null,
                ),
                const SizedBox(height: 16),

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
                  validator: (value) => (value == null || value.length < 8) ? 'Password must be at least 8 characters' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm Password / கடவுச்சொல்லை உறுதிப்படுத்துக', prefixIcon: Icon(Icons.lock_reset)),
                  obscureText: true,
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                ),
                
                const SizedBox(height: 32),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Sign Up / பதிவு செய்க'),
                  ),
                  
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
