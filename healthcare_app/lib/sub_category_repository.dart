import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:trekbikes_app/sub_category.dart';
class SubCategoryRepository {
  static Future<List<SubCategory>> getSubCategories() async {
    String url = "${dotenv.env['API_URL']}/api/subcategory";
    var response = await get(
      Uri.parse(url),
      headers: {'content-type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => SubCategory.fromMap(p)).toList();
    }
    throw Exception('Not found data $url');
  }
  static Future<List<SubCategory>> getSubCategoriesByCategory(int id) async {
    String url = "${dotenv.env['API_URL']}/api/subcategory/$id";
    var response = await get(
      Uri.parse(url),
      headers: {'content-type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => SubCategory.fromMap(p)).toList();
    }
    throw Exception('Not found data $url');
  }
}