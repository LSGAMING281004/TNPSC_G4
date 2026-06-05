import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSent = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(_emailController.text.trim());
      setState(() => _isSent = true);
    } catch (e) {
      _showError('Failed to send reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isSent 
            ? _buildSuccessState() 
            : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_reset, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text('Forgot Password?', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Enter your email to receive a password reset link.', 
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 32),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email Address / மின்னஞ்சல்', prefixIcon: Icon(Icons.email_outlined)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Enter a valid email' : null,
          ),
          
          const SizedBox(height: 32),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Send Reset Email'),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.check_circle_outline, size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text('Email Sent!', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('We have sent a password reset link to\n${_emailController.text}', 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
