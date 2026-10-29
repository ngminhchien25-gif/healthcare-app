class Prescription {
  final int id;
  final DateTime prescribedDate;
  final String? doctorName;
  final String? note;
  final int status; 
  final String? reviewNote;
  final DateTime createdAt;
  Prescription({
    required this.id,
    required this.prescribedDate,
    required this.doctorName,
    required this.note,
    required this.status,
    required this.reviewNote,
    required this.createdAt,
  });
  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['prescriptionId'],
      prescribedDate: DateTime.parse(map['prescribedDate']),
      doctorName: map['doctorName'],
      note: map['note'],
      status: map['status'],
      reviewNote: map['reviewNote'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}