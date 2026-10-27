import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/paged_result.dart';

class MedicineRepository {
  static Future<PagedResult<Medicine>> getMedicines(
    int? categoryId,
    String keyword,
    int page,
    int pageSize,
  ) async {
    Map<String, String> query = {
      'keyword': keyword,
      'page': '$page',
      'pageSize': '$pageSize',
    };
    if (categoryId != null) query['categoryId'] = categoryId.toString();
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/medicine')
        .replace(queryParameters: query);
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return PagedResult<Medicine>.fromMap(
        jsonDecode(response.body),
        Medicine.fromMap,
      );
    }
    throw Exception('Không tải được danh sách thuốc (${response.statusCode})');
  }

  static Future<int> add(Medicine obj, String? filePath) {
    return _send('POST', obj, filePath);
  }

  static Future<int> edit(Medicine obj, String? filePath) {
    return _send('PUT', obj, filePath);
  }

  static Future<int> _send(String method, Medicine obj, String? filePath) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/medicine');
    var request = http.MultipartRequest(method, uri);
    request.headers.addAll(await ApiHelper.authHeaders());
    request.fields['medicineId'] = obj.id.toString();
    request.fields['medicineCategoryId'] = obj.categoryId.toString();
    request.fields['medicineName'] = obj.name;
    request.fields['unit'] = obj.unit;
    request.fields['description'] = obj.description ?? '';
    request.fields['precaution'] = obj.precaution ?? '';
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
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/medicine/$id');
    var response = await http.delete(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}