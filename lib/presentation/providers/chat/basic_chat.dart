//? Riverpod
import 'package:gemini_app/presentation/providers/users/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

//?Providers
import 'package:gemini_app/presentation/providers/chat/is_gemini_writing.dart';

//? Gemini Implementation
import 'package:gemini_app/config/gemini/gemini_implementation.dart';

//?Packages
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:uuid/uuid.dart';

part 'basic_chat.g.dart';

final uuid = Uuid();

@riverpod
class BasicChat extends _$BasicChat {
  final gemini = GeminiImplementation();
  late User geminiUser;

  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    return [];
  }

  void addMessage({required PartialText partialText, required User user}) {
    //TODO: add conditional when receiving images
    //if ... else switch

    _addTextMessage(partialText, user);
  }

  void _addTextMessage(PartialText partialText, User author) {
    _createTextMessage(partialText.text, author);

    _geminiTextResponse(partialText.text);
  }

  void _geminiTextResponse(String prompt) async {
    _setGeminiWritingStatus(true);

    final textResponse = await gemini.getResponse(prompt);

    _setGeminiWritingStatus(false);

    _createTextMessage(textResponse, geminiUser);
  }

  //? Helper methods
  void _createTextMessage(String text, User author) {
    final message = TextMessage(
      id: uuid.v4(),
      author: author,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [message, ...state];
  }

  void _setGeminiWritingStatus(bool isWriting) {
    final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);

    isWriting
        ? isGeminiWriting.setIsWriting()
        : isGeminiWriting.setIsNotWriting();
  }
}
