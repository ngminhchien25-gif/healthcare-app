import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcare_app/member.dart';
import 'package:healthcare_app/login_response.dart';
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/member_summary.dart';
class MemberRepository{
  static Future<int> save(Member obj) async{
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/auth/register');
    var response = await http.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(obj.toMap()),
    );
    if (response.statusCode == 200){
      return int.parse(response.body);
    }
    return -2;
  }
  static Future<LoginResponse?> login(String email, String password) async{
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/auth/login');
    var response = await http.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200){
      return LoginResponse.fromMap(jsonDecode(response.body));
    }
    return null;
  } 
  static Future<int> changePassword(String oldPassword, String newPassword) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/auth/password');
    var response = await http.put(
      uri,
      headers: await ApiHelper.headers(),
      body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
  static Future<PagedResult<MemberSummary>> getMembers(
    String keyword,
    int page,
    int pageSize,
  ) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/member').replace(
      queryParameters: {'keyword': keyword, 'page': '$page', 'pageSize': '$pageSize'},
    );
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return PagedResult<MemberSummary>.fromMap(
        jsonDecode(response.body),
        MemberSummary.fromMap,
      );
    }
    throw Exception('Không tải được danh sách thành viên (${response.statusCode})');
  }
  static Future<int> setRole(String memberId, int role) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/member/role');
    var response = await http.put(
      uri,
      headers: await ApiHelper.headers(),
      body: jsonEncode({'memberId': memberId, 'role': role}),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
  static Future<int> deleteMember(String memberId) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/api/member/$memberId');
    var response = await http.delete(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}