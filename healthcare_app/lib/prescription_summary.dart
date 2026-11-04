import 'package:healthcare_app/prescription.dart';

class PrescriptionSummary extends Prescription {
  final String memberName;
  final String memberEmail;
  PrescriptionSummary({
    required super.id,
    required super.prescribedDate,
    required super.doctorName,
    required super.note,
    required super.status,
    required super.reviewNote,
    required super.createdAt,
    required this.memberName,
    required this.memberEmail,
  });
  factory PrescriptionSummary.fromMap(Map<String, dynamic> map) {
    return PrescriptionSummary(
      id: map['prescriptionId'],
      prescribedDate: DateTime.parse(map['prescribedDate']),
      doctorName: map['doctorName'],
      note: map['note'],
      status: map['status'],
      reviewNote: map['reviewNote'],
      createdAt: DateTime.parse(map['createdAt']),
      memberName: map['memberName'] ?? '',
      memberEmail: map['memberEmail'] ?? '',
    );
  }
}
