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

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authService = ref.read(authServiceProvider);
      await authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close the loading dialog
        logger.i("✅ User registered successfully: ${_emailController.text}, navigating to ${AppRoutes.login}");
        context.go(AppRoutes.login);
      }
    } on FirebaseAuthException catch (e) {
      logger.e("❌ Registration failed: ${e.code} - ${e.message}");
      if (mounted) {
        Navigator.of(context).pop();
        _showError(e.message ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      logger.e("❌ Unexpected registration error: $e");
      if (mounted) {
        Navigator.of(context).pop();
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            semanticsLabel: 'Create Account Title',
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Start tracking your child\'s health journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),
                          InputField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            label: 'Full Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Full Name is required';
                              if (value.length < 2) return 'Name must be at least 2 characters';
                              return null;
                            },
                            onFieldSubmitted: (value) => _emailFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 20),
                          InputField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: 'Email',
                            icon: Icons.mark_email_read_sharp,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email is required';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                                return 'Enter a valid email address';
                              return null;
                            },
                            onFieldSubmitted: (value) => _passwordFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 20),
                          InputField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: 'Password',
                            icon: Icons.password_rounded,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password is required';
                              if (value.length < 8) return 'Password must be at least 8 characters';
                              if (!RegExp(r'(?=.*[A-Z])').hasMatch(value))
                                return 'Password must contain at least one uppercase letter';
                              if (!RegExp(r'(?=.*[a-z])').hasMatch(value))
                                return 'Password must contain at least one lowercase letter';
                              if (!RegExp(r'(?=.*\d)').hasMatch(value))
                                return 'Password must contain at least one number';
                              if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value))
                                return 'Password must contain at least one special character';
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white70,
                                semanticLabel: _obscurePassword ? 'Show Password' : 'Hide Password',
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            onFieldSubmitted: (value) => _register(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(color: Colors.white70, fontSize: 15),
                              ),
                              TextLink(
                                text: '',
                                linkText: 'Login here',
                                onTap: () => context.go(AppRoutes.login),
                                linkStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                semanticLabel: 'Navigate to Login Screen',
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isLoading ? null : () async => await _register(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              elevation: 5,
                              shadowColor: Colors.blueAccent.withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    semanticsLabel: 'Register Button',
                                  ),
                          ),
                          const SizedBox(height: 20), // Add padding at the bottom
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