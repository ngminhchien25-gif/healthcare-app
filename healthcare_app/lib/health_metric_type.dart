class HealthMetricType {
  final int id;
  final String code;
  final String name;
  final String unit;
  final double? minNormal;
  final double? maxNormal;
  final String description;

  HealthMetricType({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    this.minNormal,
    this.maxNormal,
    required this.description,
  });

  factory HealthMetricType.fromMap(Map<String, dynamic> map) {
    return HealthMetricType(
      id: (map['metricTypeId'] as num).toInt(),
      code: map['metricCode'] ?? '',
      name: map['metricName'] ?? '',
      unit: map['unit'] ?? '',
      minNormal: (map['minNormal'] as num?)?.toDouble(),
      maxNormal: (map['maxNormal'] as num?)?.toDouble(),
      description: map['description'] ?? '',
    );
  }
}