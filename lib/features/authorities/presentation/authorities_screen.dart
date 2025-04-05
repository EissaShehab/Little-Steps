import 'package:flutter/material.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthoritiesScreen extends StatelessWidget {
  const AuthoritiesScreen({super.key});

  // Static list of authorities (replace with Firestore data in production)
  static const List<Map<String, String>> authorities = [
    {
      'name': 'Dr. Mohammad Habib',
      'specialty': 'Pediatrician',
      'hospital': 'City General Hospital',
      'phone': '+1234567890',
      'email': 'sarah.johnson@cityhospital.com',
    },
    {
      'name': 'Nurse Sojud Carter',
      'specialty': 'Pediatric Nurse',
      'hospital': 'Sunshine Clinic',
      'phone': '+1987654321',
      'email': 'emily.carter@sunshineclinic.com',
    },
    {
      'name': 'Dr. Michael Lee',
      'specialty': 'Child Psychologist',
      'hospital': 'Hope Medical Center',
      'phone': '+1122334455',
      'email': 'michael.lee@hopemedical.com',
    },
  ];

  // Function to launch phone call
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Function to launch email
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Contact Authorities',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: GradientBackground(
        showPattern: false,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: authorities.length,
          itemBuilder: (context, index) {
            final authority = authorities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Specialty
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              authority['name']!,
                              style: AppTypography.subheadingStyle.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authority['specialty']!,
                              style: AppTypography.captionStyle.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Hospital
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authority['hospital']!,
                              style: AppTypography.bodyStyle.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Phone Number (Tappable)
                      GestureDetector(
                        onTap: () => _launchPhone(authority['phone']!),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              authority['phone']!,
                              style: AppTypography.bodyStyle.copyWith(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email Address (Tappable)
                      GestureDetector(
                        onTap: () => _launchEmail(authority['email']!),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              authority['email']!,
                              style: AppTypography.bodyStyle.copyWith(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}