// ✅ SymptomsScreen.dart بعد التعديل على الحد الأدنى والأقصى

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/symptom_checker_api/Symptom-api-service.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:littlesteps/features/symptom_checker_api/symptom_categories.dart';

class SymptomsScreen extends ConsumerStatefulWidget {
  final ChildProfile child;
  final bool cameFromResultScreen;

  const SymptomsScreen({
    super.key,
    required this.child,
    this.cameFromResultScreen = false,
  });

  @override
  ConsumerState<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends ConsumerState<SymptomsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customSymptomController = TextEditingController();
  final Map<String, int> _selectedSymptoms = {};
  final Map<String, List<String>> _symptomCategories = {};

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _symptomCategories.addAll(symptomCategories);
  }

  void _onSubmitSymptoms() async {
    final local = AppLocalizations.of(context)!;
    if (_selectedSymptoms.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.minSymptomsWarning)),
      );
      return;
    }

    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.selectChildFirstMessage)),
      );
      return;
    }

    try {
      final response = await SymptomApiService.predictDisease(_selectedSymptoms);
      if (!mounted) return;

      final predicted = response['predicted_disease'] as String;
      final probs = Map<String, double>.from(
        (response['probabilities'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      );

      context.go('/prediction-result', extra: {
        'predictedDisease': predicted,
        'probabilities': probs,
        'child': selectedChild,
        'selectedSymptoms': _selectedSymptoms,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.analysisFailedMessage(e.toString()))),
      );
    }
  }

  void _addCustomSymptom() {
    final local = AppLocalizations.of(context)!;
    final symptom = _customSymptomController.text.trim();
    if (symptom.isNotEmpty) {
      if (_selectedSymptoms.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(local.maxSymptomsWarning)),
        );
        return;
      }
      setState(() {
        _selectedSymptoms[symptom] = 1;
        _customSymptomController.clear();
      });
    }
  }

  Widget _buildSeveritySelector(String symptom) {
    final local = AppLocalizations.of(context)!;
    return PopupMenuButton<int>(
      initialValue: _selectedSymptoms[symptom],
      tooltip: local.selectSeverityTooltip,
      onSelected: (value) => setState(() => _selectedSymptoms[symptom] = value),
      itemBuilder: (context) => [
        PopupMenuItem(value: 1, child: Text(local.severityLow)),
        PopupMenuItem(value: 2, child: Text(local.severityMedium)),
        PopupMenuItem(value: 3, child: Text(local.severityHigh)),
        PopupMenuItem(value: 4, child: Text(local.severityVeryHigh)),
      ],
      child: Chip(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        label: Text(
          switch (_selectedSymptoms[symptom] ?? 1) {
            2 => local.severityMedium,
            3 => local.severityHigh,
            4 => local.severityVeryHigh,
            _ => local.severityLow,
          },
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final filteredCategories = _symptomCategories.map((categoryKey, symptoms) {
      final filtered = symptoms
          .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      return MapEntry(categoryKey, filtered);
    });

    return WillPopScope(
      onWillPop: () async {
        if (widget.cameFromResultScreen) {
          setState(() {
            _selectedSymptoms.clear();
            _searchController.clear();
            _customSymptomController.clear();
            _searchQuery = "";
          });
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.pushReplacement('/home');
          }
          return false;
        }
        return true;
      },
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: local.symptomsScreenTitle,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: local.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView(
                    children: [
                      for (var entry in filteredCategories.entries)
                        if (entry.value.isNotEmpty)
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ExpansionTile(
                              title: Text(local.translateCategory(entry.key),
                                  style: AppTypography.subheadingStyle),
                              children: entry.value.map((symptom) {
                                final isSelected =
                                    _selectedSymptoms.containsKey(symptom);
                                return ListTile(
                                  title: Text(local.translateSymptom(symptom)),
                                  trailing: isSelected
                                      ? _buildSeveritySelector(symptom)
                                      : null,
                                  onTap: () {
                                    if (!isSelected &&
                                        _selectedSymptoms.length >= 10) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text(local.maxSymptomsWarning)),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      if (isSelected) {
                                        _selectedSymptoms.remove(symptom);
                                      } else {
                                        _selectedSymptoms[symptom] = 1;
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                      const SizedBox(height: 16),
                      Text(local.symptomNotFoundPrompt,
                          style: AppTypography.subheadingStyle),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customSymptomController,
                              decoration: InputDecoration(
                                hintText: local.addSymptomHint,
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addCustomSymptom,
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (var custom in _selectedSymptoms.keys.where((s) =>
                          !_symptomCategories.values.expand((e) => e).contains(s)))
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(custom),
                            trailing: _buildSeveritySelector(custom),
                            onLongPress: () =>
                                setState(() => _selectedSymptoms.remove(custom)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: Text(local.analyzeSymptomsButton),
                    onPressed:
                        _selectedSymptoms.isNotEmpty ? _onSubmitSymptoms : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
