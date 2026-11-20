import 'package:file_picker/file_picker.dart';
import 'package:healthcare_app/api_helper.dart';

class ImageHelper {
  static Future<PlatformFile?> pick() async {
    return FilePicker.pickFile(type: FileType.image);
  }

  static String url(String folder, String fileName) {
    return '${ApiHelper.baseUrl}/$folder/$fileName';
  }
}
