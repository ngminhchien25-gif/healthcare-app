import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcare_app/sesson_helper.dart';

class ApiHelper {
  static String get baseUrl {
    final value = dotenv.env['API_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Thiếu API_URL trong healthcare_app/.env');
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_URL không phải URL hợp lệ: $value');
    }
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  static Future<Map<String, String>> headers() async {
    String? token = await SessonHelper.token;
    return {
      'content-type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  static Future<Map<String, String>> authHeaders() async {
    String? token = await SessonHelper.token;
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }
}
