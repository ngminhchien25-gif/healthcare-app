import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/health_metric_type.dart';

class HealthMetricTypeRepository {
  static String get _base => '${dotenv.env['API_URL']}/api/healthmetrictype';

  static Future<List<HealthMetricType>> getMetricTypes() async {
    var response = await http.get(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => HealthMetricType.fromMap(p)).toList();
    }
    throw Exception('Không tải được danh mục loại chỉ số (${response.statusCode})');
  }

  static String _body(
    int id,
    String code,
    String name,
    String unit,
    double? minNormal,
    double? maxNormal,
    String description,
  ) {
    return jsonEncode({
      'metricTypeId': id,
      'metricCode': code,
      'metricName': name,
      'unit': unit,
      'minNormal': minNormal,
      'maxNormal': maxNormal,
      'description': description,
    });
  }

  static Future<int> add(
    String code,
    String name,
    String unit,
    double? minNormal,
    double? maxNormal,
    String description,
  ) async {
    var response = await http.post(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: _body(0, code, name, unit, minNormal, maxNormal, description),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> edit(
    int id,
    String code,
    String name,
    String unit,
    double? minNormal,
    double? maxNormal,
    String description,
  ) async {
    var response = await http.put(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: _body(id, code, name, unit, minNormal, maxNormal, description),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> delete(int id) async {
    var response = await http.delete(
      Uri.parse('$_base/$id'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}