import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _resetEmailSent = true;
      });
    } else if (mounted) {
      showSnackBar(
        context,
        authProvider.error ?? 'Failed to send reset email. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _resetEmailSent
                ? _buildSuccessMessage()
                : _buildResetPasswordForm(authProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const Text(
            'Forgot Your Password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          const Text(
            'Enter your email address and we will send you instructions to reset your password.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email field
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),

          // Reset button
          CustomButton(
            text: 'Send Reset Link',
            onPressed: _resetPassword,
            isLoading: authProvider.isLoading,
          ),
          const SizedBox(height: 16),

          // Back to login
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 24),

        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          'We have sent a password reset link to: ${_emailController.text}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        const Text(
          'Please check your email and follow the instructions to reset your password.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Back to login
        CustomButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
