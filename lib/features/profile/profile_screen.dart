import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/child_profile/providers/child_provider.dart'
    as child_provider;
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/features/settings/presentation/settings_screen.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

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
    final tr = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedChild = ref.watch(selectedChildProvider);
    final children =
        ref.watch(child_provider.childProfilesProvider).value ?? [];

    return Scaffold(
      appBar: CustomAppBar(
        title: tr.profile,
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
                            ],
                          )
                        : Center(
                            child: Text(
                              children.isNotEmpty
                                  ? tr.pleaseSelectChild
                                  : tr.noChildrenAddProfile,
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

    return CircleAvatar(
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
    );
  }

  Widget _buildProfileDetails(BuildContext context, ChildProfile child) {
    final tr = AppLocalizations.of(context)!;
    final identifierTypeLabel = child.identifierType == 'national_id'
        ? tr.nationalID
        : tr.residenceID;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(context, tr.fullName, child.name, Icons.person_rounded),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          identifierTypeLabel,
          child.identifier,
          Icons.badge_rounded,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          tr.dateOfBirth,
          child.birthDate != null
              ? DateFormat('dd/MM/yyyy').format(child.birthDate)
              : tr.notAvailable,
          Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
            context, tr.gender, child.gender ?? tr.notAvailable, Icons.wc),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          tr.childID,
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
    final tr = AppLocalizations.of(context)!;
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
                            content: Text(tr.idCopiedToClipboard),
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