class PrescriptionLine {
  final int medicineId;
  final String name;
  final String? imageUrl;
  final String unit;
  final int quantity;
  final String? dosageNote;
  PrescriptionLine({
    required this.medicineId,
    required this.name,
    required this.imageUrl,
    required this.unit,
    required this.quantity,
    required this.dosageNote,
  });
  factory PrescriptionLine.fromMap(Map<String, dynamic> map) {
    return PrescriptionLine(
      medicineId: map['medicineId'],
      name: map['medicineName'],
      imageUrl: map['imageUrl'],
      unit: map['unit'],
      quantity: map['quantity'],
      dosageNote: map['dosageNote'],
    );
  }
}