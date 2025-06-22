import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
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
      final user = await authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (user != null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User authentication failed after registration');
        }

        logger.i(
            "✅ User registered and authenticated successfully: ${user.email}");
        Navigator.of(context).pop();
        context.go(AppRoutes.childProfile);
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
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: GradientBackground(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        showPattern: true, // Enable pattern (optional, requires patternImage)
        // patternImage: 'assets/pattern.png', // Uncomment and provide asset path if desired
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 40.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.child_care,
                                size: 70, color: Colors.white),
                            const SizedBox(height: 24),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'LittleSteps',
                                      style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Color(
                                              0xFFFFCA28))), // Amber accent
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tr.createAccount,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tr.startTracking,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 48),
                            InputField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: tr.fullName,
                              icon: Icons.person,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return tr.fullNameRequired;
                                if (value.length < 2)
                                  return tr.fullNameMinLength;
                                return null;
                              },
                              onFieldSubmitted: (_) =>
                                  _emailFocusNode.requestFocus(),
                            ),
                            const SizedBox(height: 16),
                            InputField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: tr.email,
                              icon: Icons.mark_email_read_sharp,
                              keyboardType: TextInputType.emailAddress,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return tr.emailRequired;
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$')
                                    .hasMatch(value)) {
                                  return tr.invalidEmail;
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) =>
                                  _passwordFocusNode.requestFocus(),
                            ),
                            const SizedBox(height: 16),
                            InputField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: tr.password,
                              icon: Icons.password_rounded,
                              obscureText: _obscurePassword,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return tr.passwordRequired;
                                if (value.length < 8)
                                  return tr.passwordMinLength;
                                if (!RegExp(r'(?=.*[A-Z])').hasMatch(value))
                                  return tr.passwordUppercase;
                                if (!RegExp(r'(?=.*[a-z])').hasMatch(value))
                                  return tr.passwordLowercase;
                                if (!RegExp(r'(?=.*\d)').hasMatch(value))
                                  return tr.passwordNumber;
                                if (!RegExp(r'(?=.*[!@#\$%^&*(),.?":{}|<>])')
                                    .hasMatch(value)) return tr.passwordSpecial;
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              onFieldSubmitted: (_) => _register(),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tr.alreadyHaveAccount,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 15),
                                ),
                                TextLink(
                                  text: '',
                                  linkText: tr.loginHere,
                                  onTap: () => context.go(AppRoutes.login),
                                  linkStyle: const TextStyle(
                                      color: Color(0xFFFFCA28), // Amber accent
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            AnimatedOpacity(
                              opacity: _isLoading ? 0.7 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFFFFCA28), // Amber button
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 100, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 8,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.black87,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        tr.register,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
