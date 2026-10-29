import 'package:healthcare_app/prescription.dart';
import 'package:healthcare_app/prescription_line.dart';

class PrescriptionInfo {
  final Prescription prescription;
  final List<PrescriptionLine> lines;
  PrescriptionInfo({required this.prescription, required this.lines});
  factory PrescriptionInfo.fromMap(Map<String, dynamic> map) {
    List<dynamic> list = map['lines'];
    return PrescriptionInfo(
      prescription: Prescription.fromMap(map['prescription']),
      lines: list.map((p) => PrescriptionLine.fromMap(p)).toList(),
    );
  }
}