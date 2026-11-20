import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/health_profile.dart';

class HealthProfileRepository {
  static String get _base => '${dotenv.env['API_URL']}/api/healthprofile';

  static Future<HealthProfile> getProfile() async {
    var response = await http.get(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return HealthProfile.fromMap(jsonDecode(response.body));
    }
    throw Exception('Không tải được hồ sơ sức khỏe (${response.statusCode})');
  }

  static Future<int> save(
    double? heightCm,
    DateTime? dateOfBirth,
    int gender,
    String? bloodType,
    String? medicalHistory,
  ) async {
    String two(int n) => n.toString().padLeft(2, '0');
    var response = await http.put(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: jsonEncode({
        'heightCm': heightCm,
        'dateOfBirth': dateOfBirth == null
            ? null
            : '${dateOfBirth.year}-${two(dateOfBirth.month)}-${two(dateOfBirth.day)}',
        'gender': gender,
        'bloodType': (bloodType == null || bloodType.isEmpty) ? null : bloodType,
        'medicalHistory': (medicalHistory == null || medicalHistory.isEmpty)
            ? null
            : medicalHistory,
      }),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}