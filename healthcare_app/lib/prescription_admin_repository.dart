import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/prescription_admin_info.dart';
import 'package:healthcare_app/prescription_summary.dart';

class PrescriptionAdminRepository {
  static String get _base => '${dotenv.env['API_URL']}/api/prescriptionadmin';

  static String _apiDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // Tất cả đơn: tìm theo Member/bác sĩ/ghi chú, lọc trạng thái và khoảng ngày kê, phân trang
  static Future<PagedResult<PrescriptionSummary>> getPrescriptions(
    String keyword,
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
    int page,
    int pageSize,
  ) async {
    Map<String, String> query = {
      'keyword': keyword,
      'page': '$page',
      'pageSize': '$pageSize',
    };
    if (status != null) query['status'] = status.toString();
    if (fromDate != null) query['fromDate'] = _apiDate(fromDate);
    if (toDate != null) query['toDate'] = _apiDate(toDate);
    Uri uri = Uri.parse(_base).replace(queryParameters: query);
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return PagedResult<PrescriptionSummary>.fromMap(
        jsonDecode(response.body),
        PrescriptionSummary.fromMap,
      );
    }
    throw Exception(
      'Không tải được danh sách đơn thuốc (${response.statusCode})',
    );
  }

  static Future<PrescriptionAdminInfo> getPrescription(int id) async {
    var response = await http.get(
      Uri.parse('$_base/$id'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return PrescriptionAdminInfo.fromMap(jsonDecode(response.body));
    }
    throw Exception('Không tìm thấy đơn thuốc $id (${response.statusCode})');
  }

  // 1 thành công, 0 không tìm thấy đơn, -2 dữ liệu không hợp lệ, -3 từ chối thiếu ý kiến, -9 lỗi quyền/kết nối
  static Future<int> review(int id, int status, String reviewNote) async {
    var response = await http.put(
      Uri.parse('$_base/review'),
      headers: await ApiHelper.headers(),
      body: jsonEncode({
        'prescriptionId': id,
        'status': status,
        'reviewNote': reviewNote.isEmpty ? null : reviewNote,
      }),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}
