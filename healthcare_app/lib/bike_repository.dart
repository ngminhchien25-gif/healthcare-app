import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:healthcare_app/bike.dart';

class BikeRepository {
  static Future<Bike> getBike(int id) async {
    String url = "${dotenv.env['API_URL']}/api/bike/details/$id";
    var response = await get(
      Uri.parse(url),
      headers: {"content-type": 'application/json'},
    );
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      return Bike.fromMap(data);
    }
    throw Exception('Not found $url');
  }

  static Future<List<Bike>> getBikesRelation(int id, int subCategoryId) async {
    String url = "${dotenv.env['API_URL']}/api/bike/relation/$id/$subCategoryId";
    var response = await get(
      Uri.parse(url),
      headers: {"content-type": 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Bike.fromMap(p)).toList();
    }
    throw Exception('Not found $url');
  }

  static Future<List<Bike>> getBikes() async {
    String url = "${dotenv.env['API_URL']}/api/bike";
    var response = await get(
      Uri.parse(url),
      headers: {"content-type": 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Bike.fromMap(p)).toList();
    }
    throw Exception('Not found $url');
  }

  static Future<List<Bike>> getBikesBySubCategories(List<int> ids) async {
    String url = "${dotenv.env['API_URL']}/api/bike";
    var response = await post(
      Uri.parse(url),
      headers: {"content-type": 'application/json'},
      body: jsonEncode(ids),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Bike.fromMap(p)).toList();
    }
    throw Exception('Not found $url');
  }

  static Future<List<Bike>> getBikesByCategory(int id) async {
    String url = "${dotenv.env['API_URL']}/api/bike/$id";
    var response = await get(
      Uri.parse(url),
      headers: {"content-type": 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Bike.fromMap(p)).toList();
    }
    throw Exception('Not found $url');
  }
}