import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:healthcare_app/api_helper.dart';
import 'package:healthcare_app/exercise.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/workout_log.dart';

class WorkoutRepository {
  static String get _base => ApiHelper.baseUrl;

  static Future<PagedResult<Exercise>> getExercises({
    String keyword = '',
    bool includeInactive = false,
    int page = 1,
    int pageSize = 50,
  }) async {
    Uri uri = Uri.parse('$_base/api/exercise').replace(
      queryParameters: {
        'keyword': keyword,
        'includeInactive': '$includeInactive',
        'page': '$page',
        'pageSize': '$pageSize',
      },
    );
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách bài tập (${response.statusCode})',
      );
    }
    return PagedResult<Exercise>.fromMap(
      jsonDecode(response.body),
      Exercise.fromMap,
    );
  }

  static Future<int> saveExercise(Exercise exercise) async {
    Uri uri = Uri.parse('$_base/api/exercise');
    var response = await http.post(
      uri,
      headers: await ApiHelper.headers(),
      body: jsonEncode(exercise.toMap()),
    );
    if (response.statusCode != 200) {
      throw Exception('Không lưu được bài tập (${response.statusCode})');
    }
    return int.parse(response.body);
  }

  static Future<int> editExercise(Exercise exercise) async {
    Uri uri = Uri.parse('$_base/api/exercise');
    var response = await http.put(
      uri,
      headers: await ApiHelper.headers(),
      body: jsonEncode(exercise.toMap()),
    );
    if (response.statusCode != 200) {
      throw Exception('Không cập nhật được bài tập (${response.statusCode})');
    }
    return int.parse(response.body);
  }

  static Future<int> updateExercise(Exercise exercise) =>
      exercise.id == 0 ? saveExercise(exercise) : editExercise(exercise);

  static Future<int> deleteExercise(int id) async {
    var response = await http.delete(
      Uri.parse('$_base/api/exercise/$id'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Không xóa được bài tập (${response.statusCode})');
    }
    return int.parse(response.body);
  }

  static Future<PagedResult<WorkoutLog>> getLogs({
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    Map<String, String> query = {'page': '$page', 'pageSize': '$pageSize'};
    if (fromDate != null) query['fromDate'] = _date(fromDate);
    if (toDate != null) query['toDate'] = _date(toDate);
    var response = await http.get(
      Uri.parse('$_base/api/workoutlog').replace(queryParameters: query),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Không tải được nhật ký (${response.statusCode})');
    }
    return PagedResult<WorkoutLog>.fromMap(
      jsonDecode(response.body),
      WorkoutLog.fromMap,
    );
  }

  static Future<int> saveLog(WorkoutLogFormData form) async {
    Uri uri = Uri.parse('$_base/api/workoutlog');
    var response = form.id == null
        ? await http.post(
            uri,
            headers: await ApiHelper.headers(),
            body: jsonEncode(form.toMap()),
          )
        : await http.put(
            uri,
            headers: await ApiHelper.headers(),
            body: jsonEncode(form.toMap()),
          );
    if (response.statusCode != 200) {
      throw Exception('Không lưu được nhật ký (${response.statusCode})');
    }
    return int.parse(response.body);
  }

  static Future<int> deleteLog(int id) async {
    var response = await http.delete(
      Uri.parse('$_base/api/workoutlog/$id'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Không xóa được nhật ký (${response.statusCode})');
    }
    return int.parse(response.body);
  }

  static Future<WorkoutWeeklyStats> weeklyStats(DateTime anyDateInWeek) async {
    var uri = Uri.parse('$_base/api/workoutlog/stats/weekly')
        .replace(queryParameters: {'weekStart': _date(anyDateInWeek)});
    var response = await http.get(uri, headers: await ApiHelper.headers());
    if (response.statusCode != 200) {
      throw Exception('Không tải được thống kê (${response.statusCode})');
    }
    return WorkoutWeeklyStats.fromMap(jsonDecode(response.body));
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
