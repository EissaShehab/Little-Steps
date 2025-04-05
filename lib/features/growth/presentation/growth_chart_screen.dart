// كامل الملف من البداية للنهاية
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart';
import 'package:littlesteps/features/growth/models/growth_model.dart';
import 'package:littlesteps/features/growth/providers/growth_provider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class GrowthChartScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(growthProvider(childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('مخطط النمو'),
        backgroundColor: Colors.blue[700],
      ),
      body: measurements.isEmpty
          ? const Center(child: Text('لا توجد قياسات بعد. أضف قياسًا جديدًا.'))
          : _buildChart(context, measurements, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/growthEntry/$childId',
            extra: {
              'gender': gender,
              'birthDate': birthDate,
            },
          );
        },
        label: const Text('إضافة قياس جديد'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<GrowthMeasurement> measurements,
      WidgetRef ref) {
    final maxAge = measurements
        .map((m) => m.ageInMonths)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final maxHeight =
        measurements.map((m) => m.height).reduce((a, b) => a > b ? a : b);
    final maxHead = measurements
        .map((m) => m.headCircumference)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxHeight > maxHead ? maxHeight : maxHead) + 10;

    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مخطط الطول ومحيط الرأس',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: _titlesData('الطول/محيط الرأس (سم)'),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: maxAge + 1,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: measurements
                          .map(
                              (m) => FlSpot(m.ageInMonths.toDouble(), m.height))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: measurements
                          .map((m) => FlSpot(
                              m.ageInMonths.toDouble(), m.headCircumference))
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    ..._buildWHOHeightCurves(maxAge),
                    ..._buildWHOHeadCurves(maxAge),
                  ],
                  lineTouchData: _buildLineTouchData(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'مخطط الوزن',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: _titlesData('الوزن (كجم)'),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: maxAge + 1,
                  minY: 0,
                  maxY: measurements
                          .map((m) => m.weight)
                          .reduce((a, b) => a > b ? a : b) +
                      2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: measurements
                          .map(
                              (m) => FlSpot(m.ageInMonths.toDouble(), m.weight))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    ..._buildWHOWeightCurves(maxAge),
                  ],
                  lineTouchData: _buildLineTouchData(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تفاصيل القياسات:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: measurements.length,
              itemBuilder: (context, index) {
                final m = measurements[index];
                final weightStatus =
                    WHOService.interpretZScore(m.weightZ, 'weight');
                final heightStatus =
                    WHOService.interpretZScore(m.heightZ, 'height');
                final headStatus = WHOService.interpretZScore(m.headZ, 'head');

                return Card(
                  color: Colors.grey[800],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.child_care, color: Colors.white),
                    title: Text('العمر: ${m.ageInMonths} أشهر',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الطول: ${m.height} سم\nالحالة: $heightStatus',
                            style: const TextStyle(color: Colors.white)),
                        Text('الوزن: ${m.weight} كجم\nالحالة: $weightStatus',
                            style: const TextStyle(color: Colors.white)),
                        Text(
                            'محيط الرأس: ${m.headCircumference} سم\nالحالة: $headStatus',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, m, ref);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGuidanceMessage(measurements.last),
          ],
        ),
      ),
    );
  }

  FlTitlesData _titlesData(String yAxisLabel) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        axisNameWidget: Text(
          yAxisLabel,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        axisNameWidget: const Text(
          'العمر (أشهر)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              '${spot.y.toStringAsFixed(1)}\nالعمر: ${spot.x.toInt()} شهر',
              const TextStyle(color: Colors.white),
            );
          }).toList();
        },
      ),
    );
  }

  List<LineChartBarData> _buildWHOHeightCurves(double maxAge) =>
      _buildWHOCurves(maxAge, 'height');
  List<LineChartBarData> _buildWHOHeadCurves(double maxAge) =>
      _buildWHOCurves(maxAge, 'head');
  List<LineChartBarData> _buildWHOWeightCurves(double maxAge) =>
      _buildWHOCurves(maxAge, 'weight');

  List<LineChartBarData> _buildWHOCurves(double maxAge, String chartType) {
    final zScores = [-2.0, -1.0, 0.0, 1.0, 2.0];
    return zScores.map((z) {
      final percentile = WHOService.zScoreToPercentile(z).toInt();
      final spots = <FlSpot>[];
      for (var age = 0; age <= maxAge.toInt(); age++) {
        final value = WHOService.calculateForPercentile(
          chartType: chartType,
          gender: gender,
          ageMonths: age,
          percentile: percentile,
        );
        spots.add(FlSpot(age.toDouble(), value));
      }
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.grey.withOpacity(0.3),
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  Widget _buildGuidanceMessage(GrowthMeasurement measurement) {
    final heightStatus =
        WHOService.interpretZScore(measurement.heightZ, 'height');
    final weightStatus =
        WHOService.interpretZScore(measurement.weightZ, 'weight');
    final headStatus = WHOService.interpretZScore(measurement.headZ, 'head');

    List<String> warnings = [];
    if (heightStatus != 'طول طبيعي') warnings.add('• $heightStatus');
    if (weightStatus != 'وزن طبيعي') warnings.add('• $weightStatus');
    if (headStatus != 'حجم رأس طبيعي') warnings.add('• $headStatus');

    String message;
    if (warnings.isEmpty) {
      message = 'جميع القياسات طبيعية حسب بيانات منظمة الصحة العالمية. 🌿';
    } else {
      message =
          'انتباه! بعض القياسات خارج النطاق الطبيعي:\n\n${warnings.join('\n')}\n\nننصح بمراجعة الطبيب إن استمرت هذه الحالة.';
    }

    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, GrowthMeasurement measurement, WidgetRef ref) {
    if (measurement.id == null) {
      logger.e("Cannot delete measurement: ID is null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('خطأ: لا يمكن حذف القياس بسبب معرف مفقود')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا القياس؟'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(growthProvider(childId).notifier)
                  .deleteMeasurement(childId, measurement.id!);
              context.pop();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
