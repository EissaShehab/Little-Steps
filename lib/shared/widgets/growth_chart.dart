import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart';
import 'package:littlesteps/features/growth/models/growth_model.dart';

class GrowthChart extends StatelessWidget {
  final List<GrowthMeasurement> measurements;
  final String gender;
  final String chartType; // 'weight', 'height', 'head'
  final Function(FlSpot)? onPointTap;

  const GrowthChart({
    super.key,
    required this.measurements,
    required this.gender,
    required this.chartType,
    this.onPointTap,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(child: Text('لا توجد بيانات للعرض'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            axisNameWidget: Text(
              chartType == 'weight' ? 'كجم' : 'سم',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            axisNameWidget: const Text('العمر (أشهر)', style: TextStyle(fontSize: 14)),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[400]!)),
        minX: 0,
        maxX: 60, // حد أقصى 60 شهرًا (5 سنوات)
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          // خطوط الدرجات المئوية
          ..._buildPercentileLines(),
          // خط بيانات الطفل
          LineChartBarData(
            spots: measurements
                .map((m) => FlSpot(
                      m.ageInMonths.toDouble(),
                      chartType == 'weight'
                          ? m.weight
                          : chartType == 'height'
                              ? m.height
                              : m.headCircumference,
                    ))
                .toList(),
            isCurved: true,
            color: Colors.blue[700]!,
            barWidth: 2,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor:(touchedSpot) => Colors.blue[700]!.withOpacity(0.8) ,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} ${chartType == 'weight' ? 'كجم' : 'سم'}\n${spot.x.toInt()} أشهر',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.lineBarSpots == null ||
                response.lineBarSpots!.isEmpty) {
              return;
            }
            if (event is FlTapUpEvent) {
              onPointTap?.call(response.lineBarSpots!.first);
            }
          },
        ),
      ),
    );
  }

  // حساب الحد الأدنى للمحور Y بناءً على نوع القياس
  double _getMinY() {
    switch (chartType) {
      case 'weight':
        return 0;
      case 'height':
        return 30; // الحد الأدنى المنطقي للطول عند الولادة
      case 'head':
        return 20; // الحد الأدنى المنطقي لمحيط الرأس
      default:
        return 0;
    }
  }

  // حساب الحد الأقصى للمحور Y بناءً على نوع القياس
  double _getMaxY() {
    final maxMeasurement = measurements.map((m) => chartType == 'weight'
            ? m.weight
            : chartType == 'height'
                ? m.height
                : m.headCircumference)
        .reduce((a, b) => a > b ? a : b);

    switch (chartType) {
      case 'weight':
        return (maxMeasurement + 5).clamp(0, 50); // حد أقصى 50 كجم
      case 'height':
        return (maxMeasurement + 10).clamp(30, 120); // حد أقصى 120 سم
      case 'head':
        return (maxMeasurement + 5).clamp(20, 60); // حد أقصى 60 سم
      default:
        return maxMeasurement + 10;
    }
  }

  // إنشاء خطوط الدرجات المئوية (3rd, 15th, 50th, 85th, 97th)
  List<LineChartBarData> _buildPercentileLines() {
    const percentiles = [3, 15, 50, 85, 97];
    final colors = [
      Colors.red[300]!,
      Colors.orange[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.red[300]!,
    ];

    return List.generate(percentiles.length, (index) {
      final percentile = percentiles[index];
      final spots = List.generate(61, (age) => FlSpot(
            age.toDouble(),
            WHOService.calculateForPercentile(
              chartType: chartType,
              gender: gender,
              ageMonths: age,
              percentile: percentile,
            ),
          ));

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: colors[index].withOpacity(0.5),
        barWidth: 1,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    });
  }
}