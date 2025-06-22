import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/theme_provider.dart';
import 'package:littlesteps/features/auth/providers/auth_provider.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// Provider لإدارة اللغة
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = themeMode == AppThemeMode.dark;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: tr.settings,
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsTile(
              context: context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24),
                      const SizedBox(width: 12),
                      Text(
                        tr.darkMode,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeNotifier.setTheme(
                          value ? AppThemeMode.dark : AppThemeMode.light);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// **Settings Options**
            _buildSettingsTileList(
              context: context,
              items: [
                _buildSettingsOption(
                  context,
                  Icons.language,
                  tr.language,
                  onTap: () {
                    logger.i('Language settings clicked');
                    _showLanguageDialog(context, ref);
                  },
                ),
                _buildSettingsOption(
                  context,
                  Icons.lock,
                  tr.changePassword,
                  onTap: () {
                    context.push(AppRoutes.changePassword);
                  },
                ),
                _buildSettingsOption(
                  context,
                  Icons.lock_outline,
                  tr.privacyPolicy,
                  onTap: () {
                    context.push(AppRoutes.privacyPolicy);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// **About Section**
            _buildSettingsTile(
              context: context,
              child: _buildSettingsOption(
                context,
                Icons.info,
                tr.about,
                onTap: () {
                  context.push(AppRoutes.about);
                },
              ),
            ),

            const Spacer(),

            /// **Logout Button**
            _buildSettingsTile(
              context: context,
              child: _buildSettingsOption(
                context,
                Icons.logout,
                tr.logout,
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(tr.logoutConfirmTitle),
                      content: Text(tr.logoutConfirmMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(tr.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(tr.logout,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (shouldLogout == true && context.mounted) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr.loggingOut)),
                      );
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) {
                        logger.i(
                            "✅ User logged out successfully, navigating to login");
                        context.go(AppRoutes.login);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(tr.errorLoggingOut(e.toString()))),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable Tile for Each Setting Section**
  Widget _buildSettingsTile({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// **Reusable Settings Option**
  Widget _buildSettingsOption(
    BuildContext context,
    IconData icon,
    String title, {
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  /// **List of Setting Options**
  Widget _buildSettingsTileList({
    required BuildContext context,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: item,
                ))
            .toList(),
      ),
    );
  }

  /// **Show Language Selection Dialog**
  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('English'),
              value: const Locale('en'),
              groupValue: ref.watch(localeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<Locale>(
              title: const Text('العربية'),
              value: const Locale('ar'),
              groupValue: ref.watch(localeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
        ],
      ),
    );
  }
}
