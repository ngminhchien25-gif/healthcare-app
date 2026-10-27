import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class SessonHelper{
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<void> save(String email, String token) async{
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'email', value: email);
  }
  static Future<String?> get token async{
    return await _storage.read(key: 'token');
  }
  static Future<String?> get email async{
    return await _storage.read(key: 'email');
  }
  static Future<void> delete() async{
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'email');
  }
}