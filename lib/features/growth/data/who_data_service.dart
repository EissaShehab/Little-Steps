import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class WHOService {
  static bool _isInitialized = false;
  static Map<String, Map<String, Map<int, Map<String, dynamic>>>> _whoData = {};

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/who_growth_data.json');
      final rawData = jsonDecode(jsonString) as Map<String, dynamic>;
      _whoData = rawData.map((key, value) => MapEntry(
            key,
            (value as Map).map((gender, data) => MapEntry(
                  gender,
                  Map<int, Map<String, dynamic>>.fromEntries(
                      (data as List).map((e) => MapEntry(
                            e['age'] as int,
                            Map<String, dynamic>.from(e),
                          ))),
                )),
          ));
      _isInitialized = true;
      logger.i("✅ WHO Growth Data Loaded Successfully!");
    } catch (e) {
      logger.e("❌ Error loading WHO data: $e");
      _isInitialized = false;
      throw Exception('Failed to load WHO growth data: $e');
    }
  }

  static Future<bool> initializeWithRetry({int maxRetries = 3}) async {
    if (_isInitialized) return true;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final String jsonString =
            await rootBundle.loadString('assets/json/who_growth_data.json');
        final rawData = jsonDecode(jsonString) as Map<String, dynamic>;
        _whoData = rawData.map((key, value) => MapEntry(
              key,
              (value as Map).map((gender, data) => MapEntry(
                    gender,
                    Map<int, Map<String, dynamic>>.fromEntries(
                        (data as List).map((e) => MapEntry(
                              e['age'] as int,
                              Map<String, dynamic>.from(e),
                            ))),
                  )),
            ));
        _isInitialized = true;
        logger.i("✅ WHO data loaded successfully on attempt $attempt");
        return true;
      } catch (e) {
        logger.w("❌ WHO data load attempt $attempt failed: $e");
        await Future.delayed(const Duration(seconds: 2)); // wait before retry
      }
    }

    logger.e("❌ WHO data failed to initialize after $maxRetries attempts.");
    return false;
  }

  static double calculateZScore({
    required String measurementType,
    required String gender,
    required int ageMonths,
    required double measurement,
  }) {
    if (!_isInitialized) {
      logger.e("WHO data not initialized");
      throw Exception('WHO growth data not initialized');
    }
    if (ageMonths < 0 || ageMonths > 60) {
      logger.w("Age $ageMonths out of range (0-60 months)");
      return 0.0;
    }

    try {
      final genderData = _whoData[measurementType]?[gender.toLowerCase()];
      if (genderData == null || genderData.isEmpty) {
        logger.w("No WHO data for $measurementType and gender $gender");
        return 0.0;
      }

      final entry = genderData[ageMonths];
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
        final double powerResult = (math.pow(measurement / m, l)).toDouble();
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
            math.exp(-x * x -
                1.26551223 +
                1.00002368 * t +
                0.37409196 * t * t +
                0.09678418 * t * t * t -
                0.18628806 * t * t * t * t +
                0.27886807 * t * t * t * t * t -
                1.13520398 * t * t * t * t * t * t);
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
      return 0.0;
    }
    if (ageMonths < 0 || ageMonths > 60) return 0.0;

    try {
      String key = chartType == "head"
          ? "head_circumference_for_age"
          : "${chartType}_for_age";
      final genderData = _whoData[key]?[gender.toLowerCase()];
      if (genderData == null || genderData.isEmpty) {
        logger.w("No WHO data for $key and gender $gender");
        return 0.0;
      }

      final entry = genderData[ageMonths];
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
        final double powerResult = (math.pow(1 + l * s * z, 1 / l)).toDouble();
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

  static String interpretZScore(
      double zScore, String chartType, BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    switch (chartType) {
      case 'weight':
        if (zScore < -3) return tr.zScoreSeverelyUnderweight;
        if (zScore < -2) return tr.zScoreUnderweight;
        if (zScore <= 2) return tr.zScoreNormalWeight;
        if (zScore <= 3) return tr.zScoreOverweight;
        return tr.zScoreObese;

      case 'height':
        if (zScore < -3) return tr.zScoreSeverelyStunted;
        if (zScore < -2) return tr.zScoreStunted;
        return tr.zScoreNormalHeight;

      case 'head':
        if (zScore < -2) return tr.zScoreMicrocephaly;
        if (zScore <= 2) return tr.zScoreNormalHead;
        return tr.zScoreMacrocephaly;

      default:
        return tr.status;
    }
  }

  static String interpretZScoreForForm(
      double zScore, String chartType, BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    switch (chartType) {
      case 'weight':
        if (zScore < -2) return tr.weightTooLow;
        if (zScore > 2) return tr.weightTooHigh;
        return tr.weightNormalRange;
      case 'height':
        if (zScore < -2) return tr.heightTooLow;
        return tr.heightNormalRange;
      case 'head':
        if (zScore < -2) return tr.headTooSmall;
        if (zScore > 2) return tr.headTooLarge;
        return tr.headNormalRange;
      default:
        return tr.valueNormalRange;
    }
  }
}
