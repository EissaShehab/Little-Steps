import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading
    if (!mounted) return;

    final initialRoute = await AppRoutes.determineInitialRoute();
    logger.i("✅ Navigating to $initialRoute after splash screen");
    context.go(initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFF2196F3), // Deeper blue for the top
          Colors.white, // White at the bottom
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.child_care,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'LittleSteps',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr.splashTagline,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 30, // Increase the size of the loading indicator
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth:
                      4, // Slightly thicker stroke for better visibility
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
