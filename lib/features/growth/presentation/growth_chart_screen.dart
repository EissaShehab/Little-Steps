import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/features/auth/providers/auth_provider.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart';
import 'package:littlesteps/features/growth/models/growth_model.dart';
import 'package:littlesteps/features/growth/providers/growth_provider.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GrowthChartScreen extends ConsumerStatefulWidget {
  final String childId;
  final String gender;
  final DateTime birthDate;

  const GrowthChartScreen({
    super.key,
    required this.childId,
    required this.gender,
    required this.birthDate,
  });

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _weightChartKey = GlobalKey();
  final GlobalKey _heightChartKey = GlobalKey();
  final GlobalKey _headChartKey = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File?> _captureChartAsImage(GlobalKey chartKey) async {
    try {
      final context = chartKey.currentContext;
      if (context == null) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: const Text(
                'يرجى تمرير الصفحة حتى يظهر الرسم البياني قبل التصدير.'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
        return null;
      }

      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/chart_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(buffer);
      return file;
    } catch (e) {
      print("❌ Error capturing chart image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    final tr = AppLocalizations.of(context)!;
    final measurements = ref.watch(growthProvider(widget.childId));
    final userId = ref.watch(authNotifierProvider).user?.uid;

    return WillPopScope(
      onWillPop: () async => false,
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              tr.growthOverview,
              style: AppTypography.subheadingStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900.withOpacity(0.9),
                    Colors.blue.shade700.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: measurements.isEmpty
              ? Center(
                  child: Text(
                    tr.noMeasurements,
                    style: AppTypography.bodyStyle.copyWith(
                      color: Colors.white70,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                )
              : _buildChart(context, measurements, tr, ref, userId),
          bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: _buildGlassButton(
                          context: context,
                          icon: Icons.download,
                          label: tr.exportToHealthRecords,
                          color: Colors.green.shade700,
                          onPressed: () async {
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(tr.pleaseLoginToExport)),
                              );
                              return;
                            }

                            try {
                              final weightChartImage =
                                  await _captureChartAsImage(_weightChartKey);
                              final heightChartImage =
                                  await _captureChartAsImage(_heightChartKey);
                              final headChartImage =
                                  await _captureChartAsImage(_headChartKey);

                              await ref
                                  .read(growthServiceProvider)
                                  .exportToHealthRecords(
                                    userId,
                                    widget.childId,
                                    measurements,
                                    weightChartImage: weightChartImage,
                                    heightChartImage: heightChartImage,
                                    headChartImage: headChartImage,
                                  );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      tr.growthReportExportedToHealthRecords),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              await weightChartImage?.delete();
                              await heightChartImage?.delete();
                              await headChartImage?.delete();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      tr.errorExportingToHealthRecords(
                                          e.toString())),
                                  backgroundColor: Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: _buildGlassButton(
                          context: context,
                          icon: Icons.add,
                          label: tr.addMeasurement,
                          color: Colors.blue.shade700,
                          onPressed: () {
                            context.pushReplacement(
                              '/growthEntry/${widget.childId}',
                              extra: {
                                'gender': widget.gender,
                                'birthDate': widget.birthDate,
                                'cameFromChartScreen': true,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.1),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Text(
                  label,
                  style: AppTypography.buttonStyle.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<GrowthMeasurement> measurements,
    AppLocalizations tr,
    WidgetRef ref,
    String? userId,
  ) {
    measurements.sort((a, b) => a.ageInMonths.compareTo(b.ageInMonths));
    final maxAge = measurements
        .map((m) => m.ageInMonths)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeTransition(
          opacity: _animation,
          child: _buildChartCard(
            context,
            tr.heightVsAge,
            Colors.green.shade700,
            measurements,
            maxAge,
            tr.heightCm,
            'height',
            tr,
            _heightChartKey,
          ),
        ),
        FadeTransition(
          opacity: _animation,
          child: _buildChartCard(
            context,
            tr.weightVsAge,
            Colors.blue.shade700,
            measurements,
            maxAge,
            tr.weightKg,
            'weight',
            tr,
            _weightChartKey,
          ),
        ),
        FadeTransition(
          opacity: _animation,
          child: _buildChartCard(
            context,
            tr.headVsAge,
            Colors.orange.shade700,
            measurements,
            maxAge,
            tr.headCircumferenceCm,
            'head',
            tr,
            _headChartKey,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: measurements.length,
          itemBuilder: (context, index) {
            final m = measurements.reversed.toList()[index];
            return FadeTransition(
              opacity: _animation,
              child: Dismissible(
                key: Key(m.id ?? m.date.toIso8601String()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade700.withOpacity(0.8),
                        Colors.red.shade500.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white.withOpacity(0.95),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        tr.deleteMeasurement,
                        style: AppTypography.subheadingStyle.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        tr.confirmDeleteMeasurement,
                        style: AppTypography.bodyStyle.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            tr.cancel,
                            style: AppTypography.buttonStyle.copyWith(
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            tr.delete,
                            style: AppTypography.buttonStyle.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  try {
                    await ref
                        .read(growthProvider(widget.childId).notifier)
                        .deleteMeasurement(widget.childId, m.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr.measurementDeleted),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        action: SnackBarAction(
                          label: tr.undo,
                          textColor: Colors.white,
                          onPressed: () async {
                            await ref
                                .read(growthProvider(widget.childId).notifier)
                                .addMeasurement(widget.childId, m);
                          },
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(tr.errorDeletingMeasurement(e.toString())),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                child: _buildSummaryCard(context, m, tr),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    String title,
    Color color,
    List<GrowthMeasurement> measurements,
    double maxAge,
    String yLabel,
    String chartType,
    AppLocalizations tr,
    GlobalKey chartKey,
  ) {
    final spots = measurements.map((m) {
      double value;
      switch (chartType) {
        case 'height':
          value = m.height;
          break;
        case 'weight':
          value = m.weight;
          break;
        case 'head':
          value = m.headCircumference;
          break;
        default:
          value = 0;
      }
      return FlSpot(m.ageInMonths.toDouble(), value);
    }).toList();

    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5;

    // Get the most recent measurement for the specific row
    final mostRecentMeasurement = measurements.last;

    // Prepare data for the specific measurement row based on chartType
    String icon;
    String label;
    String value;
    String status;
    String percentile;
    switch (chartType) {
      case 'height':
        icon = '🔹';
        label = tr.height;
        value = '${mostRecentMeasurement.height} ${tr.cm}';
        status = WHOService.interpretZScore(mostRecentMeasurement.heightZ, 'height', context);
        percentile = tr.percentileHeight(WHOService.zScoreToPercentile(mostRecentMeasurement.heightZ).round());
        break;
      case 'weight':
        icon = '⚖️';
        label = tr.weight;
        value = '${mostRecentMeasurement.weight} ${tr.kg}';
        status = WHOService.interpretZScore(mostRecentMeasurement.weightZ, 'weight', context);
        percentile = tr.percentileWeight(WHOService.zScoreToPercentile(mostRecentMeasurement.weightZ).round());
        break;
      case 'head':
        icon = '🧠';
        label = tr.headCircumference;
        value = '${mostRecentMeasurement.headCircumference} ${tr.cm}';
        status = WHOService.interpretZScore(mostRecentMeasurement.headZ, 'head', context);
        percentile = tr.percentileHead(WHOService.zScoreToPercentile(mostRecentMeasurement.headZ).round());
        break;
      default:
        icon = '';
        label = '';
        value = '';
        status = '';
        percentile = '';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.95),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.subheadingStyle.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RepaintBoundary(
                key: chartKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              axisNameWidget: Text(
                                yLabel,
                                style: AppTypography.captionStyle.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              axisNameWidget: Text(
                                tr.ageMonths,
                                style: AppTypography.captionStyle.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          minX: 0,
                          maxX: maxAge + 1,
                          minY: 0,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: color,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: color,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.3),
                                    color.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Display only the relevant measurement row based on chartType
                    _buildMeasurementRow(
                      icon: icon,
                      label: label,
                      value: value,
                      status: status,
                      percentile: percentile,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, GrowthMeasurement m, AppLocalizations tr) {
    final weightStatus =
        WHOService.interpretZScore(m.weightZ, 'weight', context);
    final heightStatus =
        WHOService.interpretZScore(m.heightZ, 'height', context);
    final headStatus = WHOService.interpretZScore(m.headZ, 'head', context);

    final weightPercentile = WHOService.zScoreToPercentile(m.weightZ).round();
    final heightPercentile = WHOService.zScoreToPercentile(m.heightZ).round();
    final headPercentile = WHOService.zScoreToPercentile(m.headZ).round();

    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(m.date);
    final relativeTime = _formatRelativeTime(context, m.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.95),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-2, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tr.age}: ${m.ageInMonths} ${tr.months}',
                    style: AppTypography.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      relativeTime,
                      style: AppTypography.captionStyle.copyWith(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${tr.date}: $formattedDate',
                style: AppTypography.captionStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _buildMeasurementRow(
                icon: '⚖️',
                label: tr.weight,
                value: '${m.weight} ${tr.kg}',
                status: weightStatus,
                percentile: tr.percentileWeight(weightPercentile),
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 8),
              _buildMeasurementRow(
                icon: '🔹',
                label: tr.height,
                value: '${m.height} ${tr.cm}',
                status: heightStatus,
                percentile: tr.percentileHeight(heightPercentile),
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 8),
              _buildMeasurementRow(
                icon: '🧠',
                label: tr.headCircumference,
                value: '${m.headCircumference} ${tr.cm}',
                status: headStatus,
                percentile: tr.percentileHead(headPercentile),
                color: Colors.orange.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementRow({
    required String icon,
    required String label,
    required String value,
    required String status,
    required String percentile,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$label: ',
                    style: AppTypography.captionStyle.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTypography.captionStyle.copyWith(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '– $status',
                      style: AppTypography.captionStyle.copyWith(
                        color: color,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                percentile,
                style: AppTypography.captionStyle.copyWith(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRelativeTime(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final tr = AppLocalizations.of(context)!;

    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? tr.aMonthAgo : tr.monthsAgo(months);
    } else if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? tr.aWeekAgo : tr.weeksAgo(weeks);
    } else if (diff.inDays >= 1) {
      return diff.inDays == 1 ? tr.aDayAgo : tr.daysAgo(diff.inDays);
    } else if (diff.inHours >= 1) {
      return diff.inHours == 1 ? tr.anHourAgo : tr.hoursAgo(diff.inHours);
    } else {
      return tr.justNow;
    }
  }
}