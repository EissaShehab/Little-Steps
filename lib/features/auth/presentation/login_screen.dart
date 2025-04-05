import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/input_field.dart';
import 'package:littlesteps/shared/widgets/text_link.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

final logger = Logger();

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(authServiceProvider).loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop(); // Close the loading dialog
        final initialRoute = await AppRoutes.determineInitialRoute();
        logger.i(
            "✅ User logged in successfully: ${_emailController.text}, navigating to $initialRoute");
        context.go(initialRoute);
      }
    } on FirebaseAuthException catch (e) {
      logger.e("❌ Login failed: ${e.code} - ${e.message}");
      if (mounted) {
        Navigator.of(context).pop();
        _showError(e.message ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      logger.e("❌ Unexpected login error: $e");
      if (mounted) {
        Navigator.of(context).pop();
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Please enter a valid email address to reset your password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSuccess('Password reset email sent! Check your inbox.');
      }
    } on FirebaseAuthException catch (e) {
      logger.e("❌ Password reset failed: ${e.code} - ${e.message}");
      if (mounted) {
        _showError(e.message ??
            'Failed to send password reset email. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF2196F3), Colors.white],
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.child_care,
                              size: 60,
                              color: Colors.white,
                              semanticLabel: 'Child Care Icon',
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'L',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ittleSteps',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                              semanticsLabel: 'Welcome Back Title',
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Continue your child\'s health journey',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 40),
                            InputField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value))
                                  return 'Enter a valid email address';
                                return null;
                              },
                              onFieldSubmitted: (value) =>
                                  _passwordFocusNode.requestFocus(),
                            ),
                            const SizedBox(height: 20),
                            InputField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: 'Password',
                              icon: Icons.lock,
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Password is required';
                                if (value.length < 8)
                                  return 'Password must be at least 8 characters';
                                if (!RegExp(r'(?=.*[A-Z])').hasMatch(value))
                                  return 'Password must contain at least one uppercase letter';
                                if (!RegExp(r'(?=.*[a-z])').hasMatch(value))
                                  return 'Password must contain at least one lowercase letter';
                                if (!RegExp(r'(?=.*\d)').hasMatch(value))
                                  return 'Password must contain at least one number';
                                if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])')
                                    .hasMatch(value))
                                  return 'Password must contain at least one special character';
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                  semanticLabel: _obscurePassword
                                      ? 'Show Password'
                                      : 'Hide Password',
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              onFieldSubmitted: (value) => _login(),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) =>
                                          setState(() => _rememberMe = value!),
                                      checkColor: Colors.white,
                                      activeColor: Colors.blueAccent,
                                      side: const BorderSide(
                                          color: Colors
                                              .white70), // Add this to style the unchecked border
                                    ),
                                    const Text(
                                      'Remember Me',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _resetPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'New user? ',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 15),
                                ),
                                TextLink(
                                  text: '',
                                  linkText: 'Create account',
                                  onTap: () => context.go(AppRoutes.register),
                                  linkStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  semanticLabel:
                                      'Navigate to Registration Screen',
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async => await _login(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 80, vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                elevation: 5,
                                shadowColor: Colors.blueAccent.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.blueAccent,
                                          strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      semanticsLabel: 'Login Button',
                                    ),
                            ),
                            const SizedBox(
                                height: 20), // Add padding at the bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
