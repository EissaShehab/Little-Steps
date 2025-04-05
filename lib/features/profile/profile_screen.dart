import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/child_profile/providers/child_provider.dart'
    as child_provider;
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/features/settings/presentation/settings_screen.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final logger = Logger();
final _uuid = const Uuid();

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedChild = ref.watch(selectedChildProvider);
    final children = ref.watch(child_provider.childProvider).value ?? [];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        trailingIcon: Icons.settings,
        onTrailingPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        ),
      ),
      body: GradientBackground(
        showPattern: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Opacity(
                opacity: _fadeAnimation.value,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  color: isDark ? Colors.grey[800] : colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: selectedChild != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildProfileHeader(context, selectedChild),
                              const SizedBox(height: 24),
                              _buildProfileDetails(context, selectedChild),
                              const SizedBox(height: 16),
                              _buildActionButtons(context, selectedChild),
                            ],
                          )
                        : Center(
                            child: Text(
                              children.isNotEmpty
                                  ? 'Please select a child to view their profile.'
                                  : 'No children registered. Add a child profile.',
                              style: AppTypography.bodyStyle.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ChildProfile child) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage:
              child.photoUrl != null ? NetworkImage(child.photoUrl!) : null,
          backgroundColor: colorScheme.primary,
          child: child.photoUrl == null
              ? Icon(
                  Icons.child_care,
                  size: 60,
                  color: Colors.white,
                )
              : null,
        ),
        AnimatedScaleButton(
          onPressed: () =>
              logger.i('Camera button clicked - Implement photo upload'),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(BuildContext context, ChildProfile child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(context, 'Name', child.name, Icons.person_rounded),
        const SizedBox(height: 16),
        _buildDetailRow(context, 'National ID', child.nationalID ?? 'N/A',
            Icons.badge_rounded),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          'Birth Date',
          child.birthDate != null
              ? DateFormat('dd/MM/yyyy').format(child.birthDate!)
              : 'N/A',
          Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(context, 'Gender', child.gender ?? 'N/A', Icons.wc),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          'ID',
          '#${child.id ?? _uuid.v4().substring(0, 8)}',
          Icons.fingerprint,
          showCopy: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool showCopy = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showCopy)
                    AnimatedScaleButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID copied to clipboard'),
                            backgroundColor: colorScheme.primary,
                          ),
                        );
                        logger.i('Copied ID: $value');
                      },
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: isDark
                            ? Colors.white70
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ChildProfile child) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScaleButton(
          onPressed: () => _showEditProfileDialog(context, child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Edit',
              style: AppTypography.buttonStyle.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, ChildProfile child) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: child.name);
    final nationalIdController = TextEditingController(text: child.nationalID);
    final genderController = TextEditingController(text: child.gender);
    DateTime? selectedDate = child.birthDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: AppTypography.subheadingStyle.copyWith(
            color: isDark ? Colors.white : colorScheme.primary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: const OutlineInputBorder(),
                    labelStyle: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white70 : colorScheme.onSurface,
                    ),
                  ),
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nationalIdController,
                  decoration: InputDecoration(
                    labelText: 'National ID',
                    border: const OutlineInputBorder(),
                    labelStyle: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white70 : colorScheme.onSurface,
                    ),
                  ),
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: const OutlineInputBorder(),
                    labelStyle: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white70 : colorScheme.onSurface,
                    ),
                  ),
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedScaleButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Select Birth Date: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Not Set'}',
                      style: AppTypography.bodyStyle.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          AnimatedScaleButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.buttonStyle.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
          AnimatedScaleButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Name cannot be empty'),
                    backgroundColor: colorScheme.error,
                  ),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User not logged in'),
                    backgroundColor: colorScheme.error,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('children')
                    .doc(child.id)
                    .update({
                  'name': nameController.text,
                  'nationalID': nationalIdController.text.isNotEmpty
                      ? nationalIdController.text
                      : null,
                  'gender': genderController.text.isNotEmpty
                      ? genderController.text
                      : null,
                  'birthDate': selectedDate != null
                      ? Timestamp.fromDate(selectedDate!)
                      : null,
                  'updatedAt': Timestamp.now(),
                });

                // Update the selected child in the provider
                ref.read(selectedChildProvider.notifier).state = child.copyWith(
                  name: nameController.text,
                  nationalID: nationalIdController.text.isNotEmpty
                      ? nationalIdController.text
                      : null,
                  gender: genderController.text.isNotEmpty
                      ? genderController.text
                      : null,
                  birthDate: selectedDate,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                logger.e('Error updating child profile: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating profile: $e'),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              'Save',
              style: AppTypography.buttonStyle.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
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
