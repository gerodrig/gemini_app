import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class GeminiImplementation {
  final Dio _http = Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  Future<String> getResponse(String prompt) async {
    try {
      final body = jsonEncode({'prompt': prompt});
      final response = await _http.post('/basic-prompt', data: body);

      return response.data as String;
    } catch (e) {
      print(e);
      throw Exception('Failed to get response from Gemini API');
    }
  }

  //?Stream
  Stream<String> getResponseStream(
    String prompt, {
    List<XFile> files = const [],
  }) async* {
    //* option to attach images
    //! Multiplart implementation
    yield* _getStreamResponse(
      endpoint: '/basic-prompt-stream',
      prompt: prompt,
      files: files,
    );
  }

  //?Chat Stream
  Stream<String> getChatStream(
    String prompt,
    String chatId, {
    List<XFile> files = const [],
  }) async* {
    //* option to attach images
    //! Multiplart implementation
    yield* _getStreamResponse(
      endpoint: '/chat-stream',
      prompt: prompt,
      files: files,
      formFields: {'chatId': chatId},
    );
  }

  //? Emit the stream information
  Stream<String> _getStreamResponse({
    required String endpoint,
    required String prompt,
    List<XFile> files = const [],
    Map<String, dynamic> formFields = const {},
  }) async* {
    //! Multiplart implementation
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));

    for (final entry in formFields.entries) {
      formData.fields.add(MapEntry(entry.key, entry.value));
    }

    //?Files
    if (files.isNotEmpty) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }

    // final body = jsonEncode({'prompt': prompt});
    final response = await _http.post(
      endpoint,
      data: formData,
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream as Stream<List<int>>;
    String buffer = '';

    await for (final chunk in stream) {
      final chunkString = utf8.decode(chunk, allowMalformed: true);
      buffer += chunkString;
      yield buffer;
    }
  }

  Future<String?> generateImage(
    String prompt, {
    List<XFile> files = const [],
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));

    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: file.name),
        ),
      );
    }

    try {
      final response = await _http.post('/image-generation', data: formData);
      final imageUrl = response.data['imageUrl'] as String?;

      if (imageUrl == '') {
        return null;
      }

      return imageUrl;
    } catch (e) {
      //log error in a logger
      return null;
    }
  }
}
