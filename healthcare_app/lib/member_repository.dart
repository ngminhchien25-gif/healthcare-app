import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trekbikes_app/member.dart';
import 'package:trekbikes_app/login_response.dart';
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
}