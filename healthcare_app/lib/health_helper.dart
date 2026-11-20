import 'package:flutter/material.dart';
import 'package:healthcare_app/health_record.dart';

class HealthHelper {
  static String _two(int n) => n.toString().padLeft(2, '0');

  static String date(DateTime dt) {
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year}';
  }

  static String dateTime(DateTime dt) {
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  static String genderText(int gender) {
    switch (gender) {
      case 1:
        return 'Nam';
      case 2:
        return 'Nữ';
      default:
        return 'Chưa xác định';
    }
  }

  static IconData metricIcon(String code) {
    switch (code.toUpperCase()) {
      case 'WEIGHT':
        return Icons.monitor_weight;
      case 'BLOOD_PRESSURE':
        return Icons.favorite;
      case 'HEART_RATE':
        return Icons.monitor_heart;
      case 'BLOOD_SUGAR':
        return Icons.water_drop;
      default:
        return Icons.analytics;
    }
  }

  static String formatNumber(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  static String formatRecordValue(HealthRecord r) {
    String mainVal = formatNumber(r.value);
    if (r.secondaryValue != null) {
      return '$mainVal/${formatNumber(r.secondaryValue!)} ${r.unit}';
    }
    return '$mainVal ${r.unit}';
  }

  static bool isOutOfRange(HealthRecord r) {
    if (r.minNormal != null && r.value < r.minNormal!) return true;
    if (r.maxNormal != null && r.value > r.maxNormal!) return true;
    return false;
  }

  static Color bmiColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }
}