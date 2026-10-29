import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/prescription_info.dart';
import 'package:healthcare_app/prescription_line.dart';

class PrescriptionRepository {
  static String get _base => '${dotenv.env['API_URL']}/api/prescription';

  static String _apiDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static Future<List<PrescriptionLine>> getCart() async {
    var response = await http.get(
      Uri.parse('$_base/cart'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => PrescriptionLine.fromMap(p)).toList();
    }
    throw Exception('Không tải được đơn đang soạn (${response.statusCode})');
  }

  static Future<int> countCart() async {
    var response = await http.get(
      Uri.parse('$_base/cart/count'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return 0;
  }

  static String _cartBody(int medicineId, int quantity, String dosageNote) {
    return jsonEncode({
      'medicineId': medicineId,
      'quantity': quantity,
      'dosageNote': dosageNote.isEmpty ? null : dosageNote,
    });
  }

  static Future<int> addCart(int medicineId, int quantity, String dosageNote) async {
    var response = await http.post(
      Uri.parse('$_base/cart'),
      headers: await ApiHelper.headers(),
      body: _cartBody(medicineId, quantity, dosageNote),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> updateCart(int medicineId, int quantity, String dosageNote) async {
    var response = await http.put(
      Uri.parse('$_base/cart'),
      headers: await ApiHelper.headers(),
      body: _cartBody(medicineId, quantity, dosageNote),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> removeCart(int medicineId) async {
    var response = await http.delete(
      Uri.parse('$_base/cart/$medicineId'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> clearCart() async {
    var response = await http.delete(
      Uri.parse('$_base/cart'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> checkout(DateTime date, String doctorName, String note) async {
    var response = await http.post(
      Uri.parse('$_base/checkout'),
      headers: await ApiHelper.headers(),
      body: jsonEncode({
        'prescribedDate': _apiDate(date),
        'doctorName': doctorName.isEmpty ? null : doctorName,
        'note': note.isEmpty ? null : note,
      }),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<PrescriptionInfo> getPrescription(int id) async {
    var response = await http.get(
      Uri.parse('$_base/$id'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return PrescriptionInfo.fromMap(jsonDecode(response.body));
    }
    throw Exception('Không tìm thấy đơn thuốc $id (${response.statusCode})');
  }
}