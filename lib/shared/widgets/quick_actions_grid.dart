import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/features/growth/presentation/growth_entry_screen.dart';
import 'package:littlesteps/features/health_records/presentation/health_records_screen.dart';
import 'package:littlesteps/features/health_tips/presentation/healthTips_screen.dart';
import 'package:littlesteps/features/vaccinations/presentation/vaccination_screen.dart';
import 'package:littlesteps/features/authorities/presentation/authorities_screen.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';

final logger = Logger();

class QuickActionsGrid extends ConsumerWidget {
 final VoidCallback onManageChildren;

 const QuickActionsGrid({super.key, required this.onManageChildren});

 @override
 Widget build(BuildContext context, WidgetRef ref) {
 final selectedChild = ref.watch(selectedChildProvider);
 final colorScheme = Theme.of(context).colorScheme;
 final isDark = Theme.of(context).brightness == Brightness.dark;

 return Padding(
 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
 child: GridView.count(
 shrinkWrap: true,
 physics: const NeverScrollableScrollPhysics(),
 crossAxisCount: 3,
 crossAxisSpacing: 16,
 mainAxisSpacing: 16,
 children: [
 _buildActionButton(
 context,
 'assets/icons/chart.png',
 'Growth',
 colorScheme.tertiary,
 () {
 if (selectedChild != null) {
 logger.i("Navigating to GrowthEntryScreen for child ${selectedChild.id}");
 context.push(
 '/growthEntry/${selectedChild.id}',
 extra: {
 'gender': selectedChild.gender,
 'birthDate': selectedChild.birthDate,
 },
 );
 } else {
 _showNoChildSelectedDialog(context);
 }
 },
 semanticLabel: 'Open growth tracking for child',
 ),
 _buildActionButton(
 context,
 'assets/icons/syringe.png',
 'Vaccines',
 colorScheme.secondary,
 () {
 if (selectedChild != null) {
 logger.i("Navigating to VaccinationScreen for child ${selectedChild.id}");
 context.push(
 '/vaccinations',
 extra: {
 'childId': selectedChild.id,
 'birthDate': selectedChild.birthDate,
 'child': selectedChild, // selectedChild هو ChildProfile
 },
 );
 } else {
 _showNoChildSelectedDialog(context);
 }
 },
 semanticLabel: 'Open vaccination schedule for child',
 ),
 _buildActionButton(
 context,
 'assets/icons/health_tips.png',
 'Health Tips',
 colorScheme.outline,
 () {
 logger.i("Navigating to HealthTipsScreen");
 context.push('/healthTips');
 },
 semanticLabel: 'Open health tips for child',
 ),
 _buildActionButton(
 context,
 'assets/icons/records.png',
 'Health Records',
 colorScheme.error,
 () {
 if (selectedChild != null) {
 logger.i("Navigating to HealthRecordsScreen for child ${selectedChild.id}");
 context.push(
 '/healthRecords',
 extra: {'child': selectedChild}, // selectedChild هو ChildProfile
 );
 } else {
 _showNoChildSelectedDialog(context);
 }
 },
 semanticLabel: 'Open health records for child',
 ),
 _buildActionButton(
 context,
 'assets/icons/manage.png',
 'Manage Children',
 Colors.blueAccent,
 onManageChildren,
 semanticLabel: 'Manage child profiles',
 ),
 _buildActionButton(
 context,
 'assets/icons/contact.png',
 'Contact',
 Colors.orangeAccent,
 () {
 logger.i("Navigating to AuthoritiesScreen");
 context.push('/authorities');
 },
 semanticLabel: 'Contact authorities',
 ),
 ],
 ),
 );
 }

 Widget _buildActionButton(
 BuildContext context,
 String iconPath,
 String label,
 Color buttonColor,
 VoidCallback onPressed, {
 required String semanticLabel,
 }) {
 final colorScheme = Theme.of(context).colorScheme;
 final isDark = Theme.of(context).brightness == Brightness.dark;

 return GestureDetector(
 onTap: onPressed,
 child: Semantics(
 label: semanticLabel,
 child: AnimatedScaleButton(
 onPressed: onPressed,
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Container(
 padding: const EdgeInsets.all(12),
 decoration: BoxDecoration(
 shape: BoxShape.circle,
 color: buttonColor,
 boxShadow: [
 BoxShadow(
 color: buttonColor.withOpacity(0.3),
 blurRadius: 4,
 offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Image.asset(
 iconPath,
 width: 28,
 height: 28,
 color: Colors.white,
 ),
 ),
 const SizedBox(height: 8),
 SizedBox(
 width: 100,
 child: FittedBox(
 fit: BoxFit.scaleDown,
 child: Text(
 label,
 textAlign: TextAlign.center,
 style: AppTypography.captionStyle.copyWith(
 fontWeight: FontWeight.w600,
 color: isDark ? Colors.white : colorScheme.onSurface,
 ),
 softWrap: false,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }

 void _showNoChildSelectedDialog(BuildContext context) {
 final colorScheme = Theme.of(context).colorScheme;
 final isDark = Theme.of(context).brightness == Brightness.dark;

 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: Text(
 'No Child Selected',
 style: AppTypography.subheadingStyle.copyWith(
 color: isDark ? Colors.white : colorScheme.onSurface,
 ),
 ),
 content: Text(
 'Please select a child before accessing this feature.',
 style: AppTypography.bodyStyle.copyWith(
 color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
 ),
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: Text(
 'OK',
 style: AppTypography.buttonStyle.copyWith(
 color: isDark ? Colors.white : colorScheme.primary,
 ),
 ),
 ),
 ],
 backgroundColor: isDark ? Colors.grey[800] : colorScheme.surface,
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(12),
 ),
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