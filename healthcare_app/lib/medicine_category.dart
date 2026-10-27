class MedicineCategory {
  final int id;
  final String name;
  final String description;
  final String? icon;
  MedicineCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
  factory MedicineCategory.fromMap(Map<String, dynamic> map) {
    return MedicineCategory(
      id: map['medicineCategoryId'],
      name: map['medicineCategoryName'],
      description: map['description'] ?? '',
      icon: map['icon'],
    );
  }
}