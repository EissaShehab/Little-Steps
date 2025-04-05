import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';

final logger = Logger();

class WHOService {
  static bool _isInitialized = false;
  static Map<String, dynamic> _whoData = {};

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/who_growth_data.json');
      _whoData = jsonDecode(jsonString) as Map<String, dynamic>;
      _isInitialized = true;
      logger.i("✅ WHO Growth Data Loaded Successfully!");
    } catch (e) {
      logger.e("❌ Error loading WHO data: $e");
      _isInitialized = false;
      throw Exception('Failed to load WHO growth data: $e');
    }
  }

  static double calculateZScore({
    required String measurementType,
    required String gender,
    required int ageMonths,
    required double measurement,
  }) {
    if (!_isInitialized) {
      logger.w("WHO data not initialized, initializing now...");
      throw Exception('WHO growth data not initialized');
    }
    if (ageMonths < 0 || ageMonths > 60) {
      logger.w("Age $ageMonths out of range (0-60 months)");
      return 0.0;
    }

    try {
      final genderData = _whoData[measurementType]?[gender.toLowerCase()];
      if (genderData == null || (genderData as List).isEmpty) {
        logger.w("No WHO data for $measurementType and gender $gender");
        return 0.0;
      }

      final entry = (genderData as List<dynamic>).firstWhere(
        (e) => e['age'] == ageMonths,
        orElse: () => null,
      );
      if (entry == null) {
        logger.w("No WHO data for age $ageMonths months");
        return 0.0;
      }

      final double l = (entry['L'] as num).toDouble();
      final double m = (entry['M'] as num).toDouble();
      final double s = (entry['S'] as num).toDouble();

      if (measurement <= 0) {
        logger.w("Invalid measurement value: $measurement");
        return 0.0;
      }

      if (l == 0) {
        return (math.log(measurement / m)) / s;
      } else {
        final double powerResult = (math.pow(measurement / m, l) as num).toDouble();
        return (powerResult - 1) / (l * s);
      }
    } catch (e) {
      logger.e("❌ Error calculating Z-score for $measurementType, $gender, $ageMonths: $e");
      return 0.0;
    }
  }

  static double zScoreToPercentile(double zScore) {
    if (zScore.isNaN || zScore.isInfinite) return 0.0;
    final double erf = _erf(zScore / math.sqrt2);
    final double percentile = 50 * (1 + erf);
    return percentile.clamp(0, 100);
  }

  static double _erf(double x) {
    final double t = 1 / (1 + 0.3275911 * x.abs());
    final double result = 1 -
        t *
            math.exp(-x * x - 1.26551223 + 1.00002368 * t + 0.37409196 * t * t +
                0.09678418 * t * t * t - 0.18628806 * t * t * t * t +
                0.27886807 * t * t * t * t * t - 1.13520398 * t * t * t * t * t * t);
    return x >= 0 ? result : -result;
  }

  static double calculateForPercentile({
    required String chartType,
    required String gender,
    required int ageMonths,
    required int percentile,
  }) {
    if (!_isInitialized) {
      logger.w("WHO data not initialized for percentile calculation");
      return 0.0; // قيمة افتراضية بدلاً من رمي استثناء
    }
    if (ageMonths < 0 || ageMonths > 60) return 0.0;

    try {
      // تعديل المفتاح بناءً على chartType
      String key;
      if (chartType == "head") {
        key = "head_circumference_for_age"; // استخدام المفتاح الصحيح لمحيط الرأس
      } else {
        key = "${chartType}_for_age"; // للوزن والطول
      }

      final genderData = _whoData[key]?[gender.toLowerCase()];
      if (genderData == null || (genderData as List).isEmpty) {
        logger.w("No WHO data for $key and gender $gender");
        return 0.0;
      }

      final entry = (genderData as List<dynamic>).firstWhere(
        (e) => e['age'] == ageMonths,
        orElse: () => null,
      );
      if (entry == null) {
        logger.w("No WHO data for age $ageMonths months");
        return 0.0;
      }

      final double l = (entry['L'] as num).toDouble();
      final double m = (entry['M'] as num).toDouble();
      final double s = (entry['S'] as num).toDouble();
      final double z = _percentileToZScore(percentile);

      if (l == 0) {
        return m * math.exp(z * s);
      } else {
        final double powerResult = (math.pow(1 + l * s * z, 1 / l) as num).toDouble();
        return m * powerResult;
      }
    } catch (e) {
      logger.e("❌ Error calculating percentile for $chartType, $gender, $ageMonths: $e");
      return 0.0;
    }
  }

  static double _percentileToZScore(int percentile) {
    switch (percentile) {
      case 3:
        return -1.881;
      case 15:
        return -1.036;
      case 50:
        return 0.0;
      case 85:
        return 1.036;
      case 97:
        return 1.881;
      default:
        if (percentile < 50) {
          return -math.pow((50 - percentile) / 50, 1.5) * 2;
        } else {
          return math.pow((percentile - 50) / 50, 1.5) * 2;
        }
    }
  }

  static String interpretZScore(double zScore, String chartType) {
    if (zScore.isNaN || zScore.isInfinite) return "غير معروف";

    switch (chartType) {
      case 'weight':
        if (zScore < -3) return "نقص وزن شديد";
        if (zScore < -2) return "نقص وزن";
        if (zScore <= 2) return "وزن طبيعي";
        if (zScore <= 3) return "زيادة وزن";
        return "سمنة";
      case 'height':
        if (zScore < -3) return "قصر قامة شديد";
        if (zScore < -2) return "قصر قامة";
        if (zScore <= 2) return "طول طبيعي";
        if (zScore <= 3) return "طويل";
        return "طول مفرط";
      case 'head':
        if (zScore < -3) return "صغر رأس شديد";
        if (zScore < -2) return "صغر رأس";
        if (zScore <= 2) return "حجم رأس طبيعي";
        if (zScore <= 3) return "رأس كبير";
        return "كبر رأس مفرط";
      default:
        return "غير معروف";
    }
  }
}