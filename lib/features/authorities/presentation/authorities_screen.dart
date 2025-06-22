import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/generic_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io' show Platform;

class AuthoritiesScreen extends StatelessWidget {
  const AuthoritiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    final authorities = [
      {
        'name': tr.authorityRenadName,
        'specialty': tr.authorityRenadSpecialty,
        'hospital': tr.authorityRenadHospital,
        'phone': '',
        'email': 'Renadnaser5@gmail.com',
      },
      {
        'name': tr.authorityRahafName,
        'specialty': tr.authorityRahafSpecialty,
        'hospital': tr.authorityRahafHospital,
        'phone': '+962 7 9181 3178',
        'email': 'rahafmoha22@gmail.com',
      },
      {
        'name': tr.authorityReefName,
        'specialty': tr.authorityReefSpecialty,
        'hospital': tr.authorityReefHospital,
        'phone': '+962 7 8226 2163',
        'email': 'Reefmaj2002@gmail.com',
      },
      {
        'name': tr.authorityLeenName,
        'specialty': tr.authorityLeenSpecialty,
        'hospital': tr.authorityLeenHospital,
        'phone': '+962 7 8906 5390',
        'email': 'Leenalhendawy4@gmail.com',
      },
      {
        'name': tr.authoritySajoudName,
        'specialty': tr.authoritySajoudSpecialty,
        'hospital': tr.authoritySajoudHospital,
        'phone': '+962 7 8156 3875',
        'email': 'Sujoudzawana@gmail.com',
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: tr.contactAuthorities,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: GradientBackground(
        showPattern: false,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: authorities.length,
          itemBuilder: (context, index) {
            final authority = authorities[index];
            return GenericCard(
              title: authority['name']!,
              subtitle: "${authority['specialty']} - ${authority['hospital']}",
              description:
                  "${tr.phoneLabel}: ${authority['phone']}\n${tr.emailLabel}: ${authority['email']}",
              icon: Icons.local_hospital,
              isExpandable: true,
              hasAction: true,
              actionLabel: tr.callNow,
              onActionTap: () => _launchPhone(context, authority['phone']!),
              hasSecondaryAction: true,
              secondaryActionLabel: tr.emailNow,
              onSecondaryActionTap: () =>
                  _launchGmail(context, authority['email']!),
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        _showError(context, 'No phone app found to make the call.');
      }
    } catch (e) {
      _showError(context, 'Failed to launch phone call: $e');
    }
  }

  Future<void> _launchGmail(BuildContext context, String email) async {
    final Uri fallbackEmailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry from Littlesteps App',
        'body': 'Hello, I would like to contact you regarding...',
      },
    );

    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.SENDTO',
          data: Uri.encodeFull(
              'mailto:$email?subject=Inquiry from Littlesteps App&body=Hello, I would like to contact you regarding...'),
          package: 'com.google.android.gm',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );

        await intent.launch();
        return;
      } else {
        if (await canLaunchUrl(fallbackEmailUri)) {
          await launchUrl(fallbackEmailUri,
              mode: LaunchMode.externalApplication);
          return;
        }
      }
    } catch (_) {
      // Skip to fallback
    }

    // fallback to mailto for Android if Gmail failed
    try {
      if (await canLaunchUrl(fallbackEmailUri)) {
        await launchUrl(fallbackEmailUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // final fallback: copy email to clipboard
    await Clipboard.setData(ClipboardData(text: email));
    if (context.mounted) {
      _showInfo(context,
          '${AppLocalizations.of(context)!.emailLaunchFailed(email)}\n📋 تم نسخ البريد إلى الحافظة.');
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
