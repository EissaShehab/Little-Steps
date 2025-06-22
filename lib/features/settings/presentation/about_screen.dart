import 'package:flutter/material.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // الوصول للترجمة

    return Scaffold(
      appBar: CustomAppBar(
        title: tr.about, // استخدام النص المترجم
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          GradientBackground(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation(1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.aboutLittleSteps,
                      style: AppTypography.headingStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr.aboutContent,
                      style: AppTypography.bodyStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.contactInformation,
                              style: AppTypography.subheadingStyle.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              leading: Icon(
                                Icons.email,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                'eissashehab846@gmail.com',
                                style: AppTypography.bodyStyle.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              onTap: () =>
                                  _launchUrl('mailto:eissashehab846@gmail.com'),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.link,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                tr.websiteLabel,
                                style: AppTypography.bodyStyle.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              onTap: () =>
                                  _launchUrl('https://github.com/EissaShehab'),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.phone,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                'NCC: 0786046084',
                                style: AppTypography.bodyStyle.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              onTap: () => _launchUrl('tel:+0786046084'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
