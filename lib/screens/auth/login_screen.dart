import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../services/biometric_auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      showSnackBar(
        context,
        authProvider.error ?? 'Login failed. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      showSnackBar(
        context,
        authProvider.error ?? 'Google login failed. Please try again.',
        isError: true,
      );
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  Future<void> _loginWithBiometrics() async {
    final biometricService = BiometricAuthService();

    // Check if biometric authentication is enabled
    if (!(await biometricService.isBiometricEnabled())) {
      if (mounted) {
        showSnackBar(
          context,
          'Biometric login is not enabled. Please enable it in your profile settings.',
          isError: true,
        );
      }
      return;
    }

    // Authenticate using biometrics
    final userId = await biometricService.authenticateAndGetUserId();

    if (userId != null) {
      // Check if still mounted before accessing context
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Set loading state to true
      authProvider.setLoadingState(true);

      try {
        // Attempt to sign in with the userId
        final success = await authProvider.signInWithBiometricUserId(userId);

        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (mounted) {
          showSnackBar(
            context,
            authProvider.error ?? 'Biometric login failed. Please try again.',
            isError: true,
          );
        }
      } finally {
        // Set loading state to false
        authProvider.setLoadingState(false);
      }
    } else if (mounted) {
      showSnackBar(
        context,
        'Biometric authentication failed. Please try again or use email/password.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or app name
                  const Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 24),

                  // Welcome text
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 8),

                  // Remember me & Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: Colors.deepPurple,
                          ),
                          const Text('Remember me'),
                        ],
                      ),

                      // Forgot password
                      TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  CustomButton(
                    text: 'Login',
                    onPressed: _login,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Or divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google login button
                  CustomButton(
                    text: 'Continue with Google',
                    onPressed: _loginWithGoogle,
                    isOutlined: true,
                    icon: Icons.g_mobiledata,
                  ),
                  const SizedBox(height: 16),

                  // Biometric login button - only show if available
                  FutureBuilder<bool>(
                    future: BiometricAuthService().isBiometricsAvailable(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }

                      final isBiometricsAvailable = snapshot.data ?? false;

                      if (!isBiometricsAvailable) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          CustomButton(
                            text: 'Login with Biometrics',
                            onPressed: _loginWithBiometrics,
                            isOutlined: true,
                            icon: Icons.fingerprint,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text('Register'),
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
