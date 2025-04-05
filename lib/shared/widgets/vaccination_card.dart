import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/vaccinations/models/vaccination_model.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

class VaccinationCard extends StatefulWidget {
  final Vaccination vaccine;
  final ChildProfile child;
  final VoidCallback onMarkCompleted;

  const VaccinationCard({
    super.key,
    required this.vaccine,
    required this.child,
    required this.onMarkCompleted,
  });

  @override
  _VaccinationCardState createState() => _VaccinationCardState();
}

class _VaccinationCardState extends State<VaccinationCard>
    with SingleTickerProviderStateMixin {
  late bool _isTaken;
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isTaken = widget.vaccine.status == "completed";
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
                Expanded(
                  child: Text(
                    widget.vaccine.name,
                    style: AppTypography.subheadingStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                ),
                _getAdminTypeIcon(widget.vaccine.adminType, colorScheme),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Age: ${widget.vaccine.age}",
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(widget.vaccine.status, colorScheme),
              ],
            ),
            const SizedBox(height: 8),
            _buildMandatoryTag(colorScheme),
            _buildExpandableDetails(colorScheme),
            if (widget.vaccine.status != "completed")
              GestureDetector(
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) {
                  _controller.reverse();
                  _updateVaccineStatus(!_isTaken);
                },
                onTapCancel: () => _controller.reverse(),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SwitchListTile(
                    title: Text(
                      "Mark as Taken",
                      style: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                    value: _isTaken,
                    onChanged: (bool value) => _updateVaccineStatus(value),
                    activeColor: colorScheme.secondary, // Vaccination accent color
                    activeTrackColor: colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateVaccineStatus(bool isTaken) async {
    String newStatus = isTaken ? "completed" : "upcoming";
    await FirebaseFirestore.instance
        .collection("vaccinations")
        .doc(widget.vaccine.name)
        .update({"status": newStatus});

    setState(() => _isTaken = isTaken);
    widget.onMarkCompleted();
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color badgeColor = colorScheme.secondary; // Vaccination accent color
    if (status == "completed") badgeColor = Colors.greenAccent;
    if (status == "missed") badgeColor = colorScheme.error;

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
        status.toUpperCase(),
        style: AppTypography.captionStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getAdminTypeIcon(String type, ColorScheme colorScheme) {
    return Icon(
      type == "injection" ? Icons.vaccines : Icons.medication_liquid,
      color: colorScheme.secondary, // Vaccination accent color
      size: 30,
    );
  }

  Widget _buildMandatoryTag(ColorScheme colorScheme) {
    return widget.vaccine.mandatory
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Mandatory",
              style: AppTypography.captionStyle.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildExpandableDetails(ColorScheme colorScheme) {
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
                "More Details",
                style: AppTypography.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : colorScheme.onSurface,
                ),
              ),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: isDark ? Colors.white : colorScheme.onSurface,
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.vaccine.conditions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Conditions:",
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                      ...widget.vaccine.conditions.map((condition) => Text(
                            "• $condition",
                            style: AppTypography.bodyStyle.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : colorScheme.onSurfaceVariant,
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                Text(
                  widget.vaccine.description,
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}