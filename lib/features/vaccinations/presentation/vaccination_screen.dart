import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/vaccinations/providers/vaccination_provider.dart'
    hide logger;
import 'package:littlesteps/features/vaccinations/data/vaccination_service.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/shared/widgets/vaccination_card.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

class VaccinationScreen extends ConsumerStatefulWidget {
  final ChildProfile child;
  final String childId;
  final DateTime birthDate;

  const VaccinationScreen({
    super.key,
    required this.child,
    required this.childId,
    required this.birthDate,
  });

  @override
  ConsumerState<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends ConsumerState<VaccinationScreen>
    with SingleTickerProviderStateMixin {
  late final VaccinationService _vaccinationService;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _vaccinationService = VaccinationService();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleVaccinationNotifications();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _scheduleVaccinationNotifications() {
    try {
      logger
          .i("📢 Calling notification scheduler for child: ${widget.child.id}");
      _vaccinationService.scheduleVaccinationNotifications(
          widget.child.id, widget.child.birthDate);
    } catch (e) {
      logger.e("❌ Error scheduling notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vaccinations = ref.watch(vaccinationProvider(widget.child.id));

    return Scaffold(
      appBar: CustomAppBar(
        title: "Vaccination Schedule",
      ),
      body: GradientBackground(
        showPattern: false,
        child: vaccinations.when(
          data: (vaccines) {
            if (vaccines.isEmpty) {
              return Center(
                child: Text(
                  "No vaccinations found for this child.",
                  style: AppTypography.bodyStyle.copyWith(
                    color:
                        isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: VaccinationCard(
                      vaccine: vaccines[index],
                      onMarkCompleted: () {
                        _vaccinationService.updateVaccineStatus(
                            widget.child.id, vaccines[index].name, 'completed');
                      },
                      child: widget.child,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
          error: (e, _) => Center(
            child: Text(
              "Error: $e",
              style: AppTypography.bodyStyle.copyWith(
                color: isDark ? Colors.redAccent : colorScheme.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
