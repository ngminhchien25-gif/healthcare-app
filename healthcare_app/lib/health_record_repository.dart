import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/health_record.dart';
import 'package:healthcare_app/paged_result.dart';

class HealthRecordRepository {
  static String get _base => '${dotenv.env['API_URL']}/api/healthrecord';

  static Future<PagedResult<HealthRecord>> getRecords(
    int? metricTypeId,
    int page,
    int pageSize,
  ) async {
    Map<String, String> query = {
      'page': '$page',
      'pageSize': '$pageSize',
    };
    if (metricTypeId != null) {
      query['metricTypeId'] = metricTypeId.toString();
    }
    Uri uri = Uri.parse(_base).replace(queryParameters: query);
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return PagedResult<HealthRecord>.fromMap(
        jsonDecode(response.body),
        HealthRecord.fromMap,
      );
    }
    throw Exception('Không tải được lịch sử chỉ số (${response.statusCode})');
  }

  static Future<List<HealthRecord>> getLatest() async {
    var response = await http.get(
      Uri.parse('$_base/latest'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => HealthRecord.fromMap(p)).toList();
    }
    throw Exception('Không tải được chỉ số mới nhất (${response.statusCode})');
  }

  static Future<List<HealthRecord>> getChart(int metricTypeId, int days) async {
    Uri uri = Uri.parse('$_base/chart').replace(queryParameters: {
      'metricTypeId': '$metricTypeId',
      'days': '$days',
    });
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => HealthRecord.fromMap(p)).toList();
    }
    throw Exception('Không tải được dữ liệu biểu đồ (${response.statusCode})');
  }

  static Future<BmiSummary> getBmi() async {
    var response = await http.get(
      Uri.parse('$_base/bmi'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return BmiSummary.fromMap(jsonDecode(response.body));
    }
    throw Exception('Không tính được BMI (${response.statusCode})');
  }

  static String _body(
    int id,
    int metricTypeId,
    double value,
    double? secondaryValue,
    DateTime measuredAt,
    String note,
  ) {
    return jsonEncode({
      'recordId': id,
      'metricTypeId': metricTypeId,
      'value': value,
      'secondaryValue': secondaryValue,
      'measuredAt': measuredAt.toIso8601String(),
      'note': note.isEmpty ? null : note,
    });
  }

  static Future<int> add(
    int metricTypeId,
    double value,
    double? secondaryValue,
    DateTime measuredAt,
    String note,
  ) async {
    var response = await http.post(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: _body(0, metricTypeId, value, secondaryValue, measuredAt, note),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> edit(
    int id,
    int metricTypeId,
    double value,
    double? secondaryValue,
    DateTime measuredAt,
    String note,
  ) async {
    var response = await http.put(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: _body(id, metricTypeId, value, secondaryValue, measuredAt, note),
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