import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/local_database.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/reminder.dart';

class ReminderRepository {
  static String get _base => '${dotenv.env['API_URL']}/api/reminder';

  static Future<PagedResult<Reminder>> getReminders(
    int? type,
    bool? isDone,
    String keyword,
    int page,
    int pageSize,
  ) async {
    Map<String, String> query = {
      'keyword': keyword,
      'page': '$page',
      'pageSize': '$pageSize',
    };
    if (type != null) query['type'] = type.toString();
    if (isDone != null) query['isDone'] = isDone.toString();
    Uri uri = Uri.parse(_base).replace(queryParameters: query);
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode == 200) {
      return PagedResult<Reminder>.fromMap(
        jsonDecode(response.body),
        Reminder.fromMap,
      );
    }
    throw Exception(
      'Không tải được danh sách nhắc nhở (${response.statusCode})',
    );
  }

  static Future<List<Reminder>> getUpcoming() async {
    http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('$_base/upcoming?limit=20'),
            headers: await ApiHelper.headers(),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return LocalDatabase.getReminders();
    }
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Reminder> list = data.map((p) => Reminder.fromMap(p)).toList();
      try {
        await LocalDatabase.saveReminders(list);
      } catch (ex) {
        debugPrint(ex.toString());
      }
      return list;
    }
    throw Exception('Không tải được nhắc sắp tới (${response.statusCode})');
  }

  static String _body(
    int id,
    String title,
    int type,
    DateTime remindAt,
    String note,
  ) {
    return jsonEncode({
      'reminderId': id,
      'title': title,
      'reminderType': type,
      'remindAt': remindAt.toIso8601String(),
      'note': note.isEmpty ? null : note,
    });
  }

  static Future<int> add(
    String title,
    int type,
    DateTime remindAt,
    String note,
  ) async {
    var response = await http.post(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: _body(0, title, type, remindAt, note),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> edit(
    int id,
    String title,
    int type,
    DateTime remindAt,
    String note,
  ) async {
    var response = await http.put(
      Uri.parse(_base),
      headers: await ApiHelper.headers(),
      body: _body(id, title, type, remindAt, note),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> setDone(int id, bool isDone) async {
    var response = await http.put(
      Uri.parse('$_base/done'),
      headers: await ApiHelper.headers(),
      body: jsonEncode({'reminderId': id, 'isDone': isDone}),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> delete(int id) async {
    var response = await http.delete(
      Uri.parse('$_base/$id'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }

  static Future<int> createFromPrescription(
    int prescriptionId,
    DateTime startDate,
    int days,
    List<String> times,
  ) async {
    String two(int n) => n.toString().padLeft(2, '0');
    var response = await http.post(
      Uri.parse('$_base/from-prescription'),
      headers: await ApiHelper.headers(),
      body: jsonEncode({
        'prescriptionId': prescriptionId,
        'startDate':
            '${startDate.year}-${two(startDate.month)}-${two(startDate.day)}',
        'days': days,
        'times': times,
      }),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return -9;
  }
}
