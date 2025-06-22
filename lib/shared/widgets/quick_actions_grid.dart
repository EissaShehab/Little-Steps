import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class QuickActionsGrid extends ConsumerWidget {
  final VoidCallback onManageChildren;

  const QuickActionsGrid({super.key, required this.onManageChildren});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionButton(
                context,
                'assets/icons/chart.png',
                tr.growth,
                colorScheme.tertiary,
                () {
                  if (selectedChild != null) {
                    context.push(
                      '/growthEntry/${selectedChild.id}',
                      extra: {
                        'gender': selectedChild.gender,
                        'birthDate': selectedChild.birthDate,
                      },
                    );
                  } else {
                    _showNoChildSelectedDialog(context);
                  }
                },
                semanticLabel: 'Open growth tracking for child',
              ),
              _buildActionButton(
                context,
                'assets/icons/syringe.png',
                tr.vaccines,
                colorScheme.secondary,
                () {
                  if (selectedChild != null) {
                    context.push(
                      '/vaccinations',
                      extra: {
                        'childId': selectedChild.id,
                        'birthDate': selectedChild.birthDate,
                        'child': selectedChild,
                      },
                    );
                  } else {
                    _showNoChildSelectedDialog(context);
                  }
                },
                semanticLabel: 'Open vaccination schedule for child',
              ),
              _buildActionButton(
                context,
                'assets/icons/health_tips.png',
                tr.healthTips,
                colorScheme.outline,
                () {
                  if (selectedChild != null) {
                    // Add check for selectedChild
                    context.push(
                      '/healthTips',
                      extra: {
                        'childId': selectedChild.id,
                        'birthDate': selectedChild.birthDate,
                        'child': selectedChild,
                      },
                    );
                  } else {
                    _showNoChildSelectedDialog(context);
                  }
                },
                semanticLabel: 'Open health tips for child',
              ),
              _buildActionButton(
                context,
                'assets/icons/records.png',
                tr.healthRecords,
                colorScheme.error,
                () {
                  if (selectedChild != null) {
                    context.push(
                      '/healthRecords',
                      extra: {'child': selectedChild},
                    );
                  } else {
                    _showNoChildSelectedDialog(context);
                  }
                },
                semanticLabel: 'Open health records for child',
              ),
              _buildActionButton(
                context,
                'assets/icons/manage.png',
                tr.manageChildren,
                Colors.blueAccent,
                onManageChildren,
                semanticLabel: 'Manage child profiles',
              ),
              _buildActionButton(
                context,
                'assets/icons/weather.png',
                tr.childWeather,
                Colors.lightBlueAccent,
                () {
                  context.push(
                    '/child-weather',
                    extra: selectedChild,
                  );
                },
                semanticLabel: 'Check today\'s child-specific weather',
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            tr.emergencySection,
            style: AppTypography.subheadingStyle.copyWith(
              color: isDark ? Colors.white : colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 🆘 حالات الطوارئ: مستشفى، صيدلية، ممرضة
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionButton(
                context,
                'assets/icons/hospital.png',
                tr.nearestHospital,
                Colors.green,
                () => context.push('/nearest-hospitals'),
                semanticLabel: 'Open nearest hospital map',
              ),
              _buildActionButton(
                context,
                'assets/icons/pharmacy.png',
                tr.nearestPharmacy,
                Colors.teal,
                () => context.push('/nearest-pharmacies'),
                semanticLabel: 'Open nearest pharmacy map',
              ),
              _buildActionButton(
                context,
                'assets/icons/nurse.png',
                tr.contactNurse,
                Colors.pinkAccent,
                () => context.push('/authorities'),
                semanticLabel: 'Contact nurse or pediatrician',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label,
    Color buttonColor,
    VoidCallback onPressed, {
    required String semanticLabel,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: Semantics(
        label: semanticLabel,
        child: AnimatedScaleButton(
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: buttonColor,
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 100,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.captionStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoChildSelectedDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr.noChildSelected,
          style: AppTypography.subheadingStyle.copyWith(
            color: isDark ? Colors.white : colorScheme.onSurface,
          ),
        ),
        content: Text(
          tr.selectChildBeforeFeature,
          style: AppTypography.bodyStyle.copyWith(
            color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr.ok,
              style: AppTypography.buttonStyle.copyWith(
                color: isDark ? Colors.white : colorScheme.primary,
              ),
            ),
          ),
        ],
        backgroundColor: isDark ? Colors.grey[800] : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
