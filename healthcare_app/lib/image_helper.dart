import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageHelper {
  static Future<String?> pick() async {
    PlatformFile? file = await FilePicker.pickFile(type: FileType.image);
    return file?.path;
  }

  static String url(String folder, String fileName) {
    return '${dotenv.env['API_URL']}/$folder/$fileName';
  }
}