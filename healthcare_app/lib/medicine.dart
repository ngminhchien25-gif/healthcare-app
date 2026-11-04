class Medicine {
  final int id;
  final int categoryId;
  final String name;
  final String? imageUrl;
  final String unit;
  final String? description;
  final String? precaution;
  final DateTime createdAt;
  Medicine({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.imageUrl,
    required this.unit,
    required this.description,
    required this.precaution,
    required this.createdAt,
  });
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['medicineId'],
      categoryId: map['medicineCategoryId'],
      name: map['medicineName'],
      imageUrl: map['imageUrl'],
      unit: map['unit'],
      description: map['description'],
      precaution: map['precaution'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  Map<String, Object?> toMap() {
    return {
      'medicineId': id,
      'medicineCategoryId': categoryId,
      'medicineName': name,
      'imageUrl': imageUrl,
      'unit': unit,
      'description': description,
      'precaution': precaution,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
