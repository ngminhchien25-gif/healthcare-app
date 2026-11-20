class HealthRecord {
  final int id;
  final String? memberId;
  final int metricTypeId;
  final double value;
  final double? secondaryValue;
  final DateTime measuredAt;
  final String? note;
  final String metricCode;
  final String metricName;
  final String unit;
  final double? minNormal;
  final double? maxNormal;

  HealthRecord({
    required this.id,
    this.memberId,
    required this.metricTypeId,
    required this.value,
    this.secondaryValue,
    required this.measuredAt,
    this.note,
    this.metricCode = '',
    this.metricName = '',
    this.unit = '',
    this.minNormal,
    this.maxNormal,
  });

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: (map['recordId'] as num).toInt(),
      memberId: map['memberId'],
      metricTypeId: (map['metricTypeId'] as num).toInt(),
      value: (map['value'] as num).toDouble(),
      secondaryValue: (map['secondaryValue'] as num?)?.toDouble(),
      measuredAt: DateTime.parse(map['measuredAt'].toString()),
      note: map['note'],
      metricCode: map['metricCode'] ?? '',
      metricName: map['metricName'] ?? '',
      unit: map['unit'] ?? '',
      minNormal: (map['minNormal'] as num?)?.toDouble(),
      maxNormal: (map['maxNormal'] as num?)?.toDouble(),
    );
  }
}

class BmiSummary {
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String category;
  final DateTime? measuredAt;

  BmiSummary({
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.category = 'Chưa đủ dữ liệu',
    this.measuredAt,
  });

  factory BmiSummary.fromMap(Map<String, dynamic> map) {
    return BmiSummary(
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bmi: (map['bmi'] as num?)?.toDouble(),
      category: map['category'] ?? 'Chưa đủ dữ liệu',
      measuredAt: map['measuredAt'] != null
          ? DateTime.tryParse(map['measuredAt'].toString())
          : null,
    );
  }
}