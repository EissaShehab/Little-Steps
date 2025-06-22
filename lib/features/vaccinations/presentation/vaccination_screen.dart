import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/vaccinations/providers/vaccination_provider.dart'
    hide logger;
import 'package:littlesteps/features/vaccinations/data/vaccination_service.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/shared/widgets/generic_card.dart';
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

  int _parseAgeToMonths(String age) {
    if (age.toLowerCase() == 'at birth') return 0;
    if (age.toLowerCase() == 'عند الولادة') return 0; 
    if (age.contains('months') || age.contains('شهور')) {
      return int.tryParse(age.split(' ')[0]) ?? 0;
    }
    if (age.contains('years'))
      return (int.tryParse(age.split(' ')[0]) ?? 0) * 12;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vaccinations = ref.watch(vaccinationProvider(widget.child.id));
    final currentLocale =
        Localizations.localeOf(context).languageCode; 
    return Scaffold(
      appBar: CustomAppBar(
        title: tr.vaccinationSchedule,
      ),
      body: GradientBackground(
        showPattern: false,
        child: vaccinations.when(
          data: (vaccines) {
            if (vaccines.isEmpty) {
              return Center(
                child: Text(
                  tr.noVaccinationsFound,
                  style: AppTypography.bodyStyle.copyWith(
                    color:
                        isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            final sortedVaccines = vaccines.toList()
              ..sort((a, b) {
                final ageA =
                    _parseAgeToMonths(currentLocale == 'ar' ? a.ageAr : a.age);
                final ageB =
                    _parseAgeToMonths(currentLocale == 'ar' ? b.ageAr : b.age);
                return ageA.compareTo(ageB);
              });

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: sortedVaccines.length,
              itemBuilder: (context, index) {
                final vaccine = sortedVaccines[index];
                // اختيار النصوص بناءً على اللغة الحالية
                final displayName =
                    currentLocale == 'ar' ? vaccine.nameAr : vaccine.name;
                final displayAge =
                    currentLocale == 'ar' ? vaccine.ageAr : vaccine.age;
                final displayDescription = currentLocale == 'ar'
                    ? vaccine.descriptionAr
                    : vaccine.description;
                final displayConditions = currentLocale == 'ar'
                    ? vaccine.conditionsAr
                    : vaccine.conditions;

                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: GenericCard(
                      title: displayName,
                      subtitle: "${tr.age}: $displayAge",
                      description: displayDescription,
                      icon: vaccine.adminType == "injection"
                          ? Icons.vaccines
                          : Icons.medication_liquid,
                      status: vaccine.status,
                      statusColor: vaccine.status == "completed"
                          ? Colors.greenAccent
                          : vaccine.status == "missed"
                              ? colorScheme.error
                              : colorScheme.secondary,
                      isExpandable: true,
                      hasAction: vaccine.status != "completed",
                      actionLabel: tr.markAsTaken,
                      actionValue: vaccine.status == "completed",
                      onActionTap: () {
                        _vaccinationService.updateVaccineStatus(
                          widget.child.id,
                          vaccine.name,
                          'completed',
                        );
                      },
                      conditions: displayConditions,
                      mandatory: vaccine.mandatory,
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
              "${tr.error}: $e",
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
