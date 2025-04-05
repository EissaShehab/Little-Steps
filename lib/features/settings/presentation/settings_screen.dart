import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import
import 'package:littlesteps/providers/theme_provider.dart';
import 'package:littlesteps/features/auth/providers/auth_provider.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:littlesteps/features/settings/presentation/about_screen.dart';
import 'package:littlesteps/features/settings/presentation/change_password_screen.dart';
import 'package:littlesteps/features/settings/presentation/privacy_policy_screen.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = themeMode == AppThemeMode.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        onBackPressed: () => context.pop(), // Use GoRouter to go back
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
                        "Dark Mode",
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
                  "Language",
                  onTap: () {
                    logger.i('Language settings clicked');
                  },
                ),
                _buildSettingsOption(
                  context,
                  Icons.lock,
                  "Change Password",
                  onTap: () {
                    context.push(AppRoutes.changePassword); // Use GoRouter to push
                  },
                ),
                _buildSettingsOption(
                  context,
                  Icons.lock_outline,
                  "Privacy Policy",
                  onTap: () {
                    context.push(AppRoutes.privacyPolicy); // Use GoRouter to push
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
                "About",
                onTap: () {
                  context.push(AppRoutes.about); // Use GoRouter to push
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
                "Logout",
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Log Out',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (shouldLogout == true && context.mounted) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logging out...')),
                      );
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) {
                        logger.i("✅ User logged out successfully, navigating to login");
                        context.go(AppRoutes.login); // Use GoRouter to replace stack
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error logging out: $e')),
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
}