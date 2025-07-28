import 'dart:io';
import 'package:dio/dio.dart';

import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

//? Path provider
class TemporalImages {
  static Future<XFile> xFileFromUrl(String imageUrl) async {
    final uuid = Uuid();
    final tempDir = await getTemporaryDirectory();
    final filePath = "${tempDir.path}/${uuid.v4()}.png";

    final dio = Dio();
    final response = await dio.get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final file = File(filePath);
    await file.writeAsBytes(response.data!);

    return XFile(file.path);
  }
}
