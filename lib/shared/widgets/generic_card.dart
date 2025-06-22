import 'package:flutter/material.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

class GenericCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? description;
  final IconData? icon;
  final String? status;
  final bool isExpandable;
  final bool hasAction;
  final String? actionLabel;
  final bool? actionValue;
  final VoidCallback? onActionTap;
  final bool hasSecondaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionTap;
  final Color? statusColor;
  final List<String>? conditions;
  final bool? mandatory;
  final Widget? leadingWidget;
  final Widget? feedbackWidget; // ✅ تمت إضافتها

  const GenericCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.icon,
    this.status,
    this.isExpandable = false,
    this.hasAction = false,
    this.actionLabel,
    this.actionValue,
    this.onActionTap,
    this.hasSecondaryAction = false,
    this.secondaryActionLabel,
    this.onSecondaryActionTap,
    this.statusColor,
    this.conditions,
    this.mandatory,
    this.leadingWidget,
    this.feedbackWidget, // ✅ تمت إضافتها
  });

  @override
  _GenericCardState createState() => _GenericCardState();
}

class _GenericCardState extends State<GenericCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.transparent,
          width: 1,
        ),
      ),
      color: isDark ? Colors.grey[800] : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.leadingWidget != null) ...[
                  widget.leadingWidget!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.subheadingStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (widget.icon != null)
                  Icon(widget.icon, color: colorScheme.secondary, size: 30),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.subtitle,
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (widget.status != null)
                  _buildStatusBadge(widget.status!,
                      widget.statusColor ?? colorScheme.secondary, tr),
              ],
            ),
            if (widget.isExpandable) ...[
              const SizedBox(height: 8),
              _buildExpandableDetails(colorScheme, tr),
            ],
            if (widget.feedbackWidget != null) ...[
              const SizedBox(height: 12),
              widget
                  .feedbackWidget!, // ✅ سيتم عرض أداة التقييم فقط إذا كانت موجودة
            ],
            if (widget.hasAction || widget.hasSecondaryAction) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.hasAction && widget.actionLabel != null)
                    _buildActionButton(
                      label: widget.actionLabel!,
                      onTap: widget.onActionTap,
                      color: colorScheme.primary,
                      icon: widget.actionLabel == tr.markAsTaken
                          ? Icons.check_circle
                          : null,
                    ),
                  if (widget.hasSecondaryAction &&
                      widget.secondaryActionLabel != null)
                    _buildActionButton(
                      label: widget.secondaryActionLabel!,
                      onTap: widget.onSecondaryActionTap,
                      color: colorScheme.secondary,
                      icon: widget.secondaryActionLabel == "Email Now"
                          ? Icons.email
                          : null,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onTap,
    required Color color,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (onTap != null) onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: AppTypography.buttonStyle.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
      String status, Color badgeColor, AppLocalizations tr) {
    String translatedStatus;
    switch (status.toLowerCase()) {
      case 'upcoming':
        translatedStatus = tr.statusUpcoming;
        break;
      case 'completed':
        translatedStatus = tr.statusCompleted;
        break;
      case 'missed':
        translatedStatus = tr.statusMissed;
        break;
      default:
        translatedStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        translatedStatus.toUpperCase(),
        style: AppTypography.captionStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExpandableDetails(ColorScheme colorScheme, AppLocalizations tr) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isExpanded ? tr.lessDetails : tr.moreDetails,
                style: AppTypography.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : colorScheme.onSurface,
                ),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: isDark ? Colors.white : colorScheme.onSurface,
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          if (widget.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: AppTypography.bodyStyle.copyWith(
                color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (widget.mandatory != null) ...[
            const SizedBox(height: 8),
            Text(
              "${tr.mandatoryLabel}: ${widget.mandatory! ? tr.yes : tr.no}",
              style: AppTypography.bodyStyle.copyWith(
                color: widget.mandatory! ? Colors.redAccent : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (widget.conditions != null && widget.conditions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "${tr.conditions}:",
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            ...widget.conditions!.map((condition) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "• $condition",
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                )),
          ],
        ],
      ],
    );
  }
}
