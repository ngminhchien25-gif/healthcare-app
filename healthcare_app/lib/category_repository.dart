import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trekbikes_app/category.dart';
import 'package:http/http.dart' as http;
class CategoryRepository {
  static Future<List<Category>> getCategories() async {
    String url = '${dotenv.env['API_URL']}/api/category';
    var response = await http.get(
      Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Category.fromJson(p)).toList(); 
    }
    throw Exception('Not found data');
  }
  static Future<int> add(Category obj) async {
    String url = '${dotenv.env['API_URL']}/api/category';
    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(obj.toMap()),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Not found data ${response.statusCode}');
  }
}