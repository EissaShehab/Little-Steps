import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/health_tips/providers/health_tips_provider.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/generic_card.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/features/settings/presentation/settings_screen.dart' show localeProvider;

class HealthTipsScreen extends ConsumerStatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  ConsumerState<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends ConsumerState<HealthTipsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _currentDailyTip;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final selectedChild = ref.watch(selectedChildProvider);
    final language = ref.watch(localeProvider).languageCode;

    // إعادة تحميل النصائح عند تغيير اللغة
    ref.listen(localeProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _currentDailyTip = null; // إعادة تعيين النصيحة اليومية لتحديث اللغة
        });
      }
    });

    return Scaffold(
      appBar: CustomAppBar(title: tr.healthTips),
      body: GradientBackground(
        child: selectedChild == null
            ? Center(child: Text(tr.noChildSelectedTips))
            : Column(
                children: [
                  const SizedBox(height: 16),
                  ref.watch(dailyHealthTipProvider(selectedChild.id)).when(
                    data: (tip) {
                      if (tip == null) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(tr.noDailyTip,
                              style: TextStyle(color: Colors.grey)),
                        );
                      }
                      if (_currentDailyTip == null || _currentDailyTip!['date'] != tip['date']) {
                        _currentDailyTip = Map<String, dynamic>.from(tip);
                      }
                      return GenericCard(
                        title: _currentDailyTip!['title'],
                        subtitle: "Daily Tip",
                        description: "${_currentDailyTip!['content']}\n${tr.source}: ${_currentDailyTip!['source']}",
                        icon: Icons.tips_and_updates,
                        isExpandable: true,
                        hasAction: !(_currentDailyTip!['feedbackGiven'] ?? false) && !_isLoading,
                        actionLabel: _isLoading ? tr.loading : tr.helpful,
                        onActionTap: () async {
                          if (_isLoading) return;
                          setState(() => _isLoading = true);
                          await ref.read(healthTipsServiceProvider).addFeedbackForTip(
                                ref.read(userIdProvider)!,
                                selectedChild.id,
                                _currentDailyTip!['date'],
                                true,
                              );
                          setState(() {
                            _currentDailyTip!['feedbackGiven'] = true;
                            _isLoading = false;
                          });
                        },
                        hasSecondaryAction: !(_currentDailyTip!['feedbackGiven'] ?? false) && !_isLoading,
                        secondaryActionLabel: _isLoading ? tr.loading : tr.unhelpful,
                        onSecondaryActionTap: () async {
                          if (_isLoading) return;
                          setState(() => _isLoading = true);
                          await ref.read(healthTipsServiceProvider).addFeedbackForTip(
                                ref.read(userIdProvider)!,
                                selectedChild.id,
                                _currentDailyTip!['date'],
                                false,
                              );
                          setState(() {
                            _currentDailyTip!['feedbackGiven'] = true;
                            _isLoading = false;
                          });
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(tr.errorOccurred,
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: ref.watch(childTipsStreamProvider(selectedChild.id)).when(
                          data: (tips) {
                            final today = DateTime.now().toUtc().toIso8601String().split('T')[0];
                            // استبعاد النصيحة اليومية بناءً على العنوان
                            final filteredTips = tips.where((tip) {
                              return tip['title'] != (_currentDailyTip?['title'] ?? '');
                            }).toList();
                            return filteredTips.isEmpty
                                ? Center(child: Text(tr.noTipsInCategory))
                                : ListView.builder(
                                    itemCount: filteredTips.length,
                                    itemBuilder: (context, index) {
                                      final tip = filteredTips[index];
                                      return GenericCard(
                                        title: tip['title'],
                                        subtitle: tip['category'],
                                        description: "${tip['content']}\n${tr.source}: ${tip['source']}",
                                        icon: Icons.add_circle_outline,
                                        isExpandable: true,
                                      );
                                    },
                                  );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(tr.errorOccurred,
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}