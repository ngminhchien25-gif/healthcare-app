import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trekbikes_app/sesson_helper.dart';

class ApiHelper {
  static String get baseUrl => dotenv.env['API_URL']!;

  static Future<Map<String, String>> headers() async {
    String? token = await SessonHelper.token;
    return {
      'content-type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}