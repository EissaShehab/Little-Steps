import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget? child;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final bool showPattern;
  final String? patternImage;

  const GradientBackground({
    super.key,
    this.child,
    this.colors = const [],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.showPattern = false,
    this.patternImage,
  });

  const GradientBackground.defaultGradient({
    super.key,
    this.child,
    this.showPattern = false,
    this.patternImage,
  })  : colors = const [],
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = colors.isNotEmpty
        ? colors
        : isDark
            ? [
                const Color(0xFF0D47A1),
                const Color(0xFF42A5F5)
              ] // Dark theme gradient
            : [
                const Color(0xFF1976D2),
                const Color(0xFF64B5F6)
              ]; // Light theme gradient

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: gradientColors,
          stops: const [0.0, 1.0], // Smooth gradient transition
        ),
        image: showPattern && patternImage != null
            ? DecorationImage(
                image: AssetImage(patternImage!),
                fit: BoxFit.cover,
                opacity: 0.05, // Subtle pattern opacity
              )
            : null,
      ),
      child: child,
    );
  }
}
