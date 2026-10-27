import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcare_app/sesson_helper.dart';

class ApiHelper {
  static String get baseUrl => dotenv.env['API_URL']!;

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