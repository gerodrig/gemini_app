import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gemini_app/config/gemini/gemini_implementation.dart';
import 'package:gemini_app/presentation/providers/image/generated_history_provider.dart';
import 'package:gemini_app/presentation/providers/image/is_generating_provider.dart';
import 'package:image_picker/image_picker.dart';

part 'generated_images_provider.g.dart';

@Riverpod(keepAlive: true)
class GeneratedImages extends _$GeneratedImages {
  final GeminiImplementation gemini = GeminiImplementation();

  late final IsGenerating isGeneratingNotifier;
  late final GeneratedHistory generatedHistoryNotifier;

  String previousPrompt = '';
  List<XFile> previousImages = [];

  @override
  List<String> build() {
    isGeneratingNotifier = ref.read(isGeneratingProvider.notifier);
    generatedHistoryNotifier = ref.read(generatedHistoryProvider.notifier);

    return [];
  }

  //? Methods to help with the image handling
  void addImage(String imageUrl) {
    generatedHistoryNotifier.addImage(imageUrl);
    state = [...state, imageUrl];
  }

  void clearImages() {
    state = [];
  }

  Future<void> generateImage(
    String prompt, {
    List<XFile> images = const [],
  }) async {
    isGeneratingNotifier.setIsGenerating();

    final imageUrl = await gemini.generateImage(prompt, files: images);

    if (imageUrl == null) {
      isGeneratingNotifier.setIsNotGenerating();
      return;
    }

    previousPrompt = prompt;
    previousImages = images;

    addImage(imageUrl);
    isGeneratingNotifier.setIsNotGenerating();

    if (state.length == 1) {
      generateImageWithPreviousPrompt();
    }
  }

  Future<void> generateImageWithPreviousPrompt() async {
    if (previousPrompt.isEmpty) return;

    await generateImage(previousPrompt, images: previousImages);
  }
}
