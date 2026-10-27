import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/medicine_category.dart';

class MedicineCategoryRepository {
  static Future<List<MedicineCategory>> getMedicineCategories() async {
    String url = '${dotenv.env['API_URL']}/api/medicinecategory';
    var response = await http.get(
      Uri.parse(url),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => MedicineCategory.fromMap(p)).toList();
    }
    throw Exception('Không tải được nhóm thuốc (${response.statusCode})');
  }

  static Future<int> add(String name, String description, String? filePath) {
    return _send('POST', 0, name, description, filePath);
  }

  static Future<int> edit(int id, String name, String description, String? filePath) {
    return _send('PUT', id, name, description, filePath);
  }

  static Future<int> _send(
    String method,
    int id,
    String name,
    String description,
    String? filePath,
  ) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/medicinecategory');
    var request = http.MultipartRequest(method, uri);
    request.headers.addAll(await ApiHelper.authHeaders());
    request.fields['medicineCategoryId'] = id.toString();
    request.fields['medicineCategoryName'] = name;
    request.fields['description'] = description;
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }
    var response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> delete(int id) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/medicinecategory/$id');
    var response = await http.delete(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}