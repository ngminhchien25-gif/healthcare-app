import 'package:healthcare_app/prescription_line.dart';
import 'package:healthcare_app/prescription_summary.dart';

class PrescriptionAdminInfo {
  final PrescriptionSummary prescription;
  final List<PrescriptionLine> lines;
  PrescriptionAdminInfo({required this.prescription, required this.lines});
  factory PrescriptionAdminInfo.fromMap(Map<String, dynamic> map) {
    List<dynamic> list = map['lines'];
    return PrescriptionAdminInfo(
      prescription: PrescriptionSummary.fromMap(map['prescription']),
      lines: list.map((p) => PrescriptionLine.fromMap(p)).toList(),
    );
  }
}
