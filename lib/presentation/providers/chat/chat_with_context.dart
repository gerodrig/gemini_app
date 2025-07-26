//? Riverpod
import 'package:gemini_app/presentation/providers/users/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

//?Providers
// import 'package:gemini_app/presentation/providers/chat/is_gemini_writing.dart';

//? Gemini Implementation
import 'package:gemini_app/config/gemini/gemini_implementation.dart';

//?Packages
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:uuid/uuid.dart';

part 'chat_with_context.g.dart';

final uuid = Uuid();

@Riverpod(keepAlive: true)
class ChatWithContext extends _$ChatWithContext {
  final gemini = GeminiImplementation();

  late User geminiUser;
  // late User chatUser;
  late String chatId;

  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    // chatUser = ref.read(userProvider);
    chatId = uuid.v4();
    return [];
  }

  void addMessage({
    required PartialText partialText,
    required User user,
    List<XFile> images = const [],
  }) {
    //*: add conditional when receiving images
    if (images.isNotEmpty) {
      _addTextMessageWithImages(partialText, user, images);
    }

    _addTextMessage(partialText, user);
  }

  void _addTextMessage(PartialText partialText, User author) {
    _createTextMessage(partialText.text, author);

    // _geminiTextResponse(partialText.text);
    _geminiTextResponseStream(partialText.text);
  }

  void _addTextMessageWithImages(
    PartialText partialText,
    User author,
    List<XFile> images,
  ) async {
    for (XFile image in images) {
      _createImageMessage(image, author);
    }

    //* add delay so images are shown first and then the text
    await Future.delayed(Duration(milliseconds: 10));

    _createTextMessage(partialText.text, author);

    _geminiTextResponseStream(partialText.text, images: images);
  }

  // void _geminiTextResponse(String prompt) async {
  //   _setGeminiWritingStatus(true);

  //   final textResponse = await gemini.getResponse(prompt);

  //   _setGeminiWritingStatus(false);

  //   _createTextMessage(textResponse, geminiUser);
  // }

  void _geminiTextResponseStream(
    String prompt, {
    List<XFile> images = const [],
  }) async {
    _createTextMessage('Thinking...', geminiUser);

    gemini.getChatStream(prompt, chatId, files: images).listen((responseChunk) {
      if (responseChunk.isEmpty) return;

      final updatedMessages = [...state];

      final updatedMessage = (updatedMessages.first as TextMessage).copyWith(
        text: responseChunk,
      );

      updatedMessages[0] = updatedMessage;
      state = updatedMessages;
    });
  }

  //? Helper methods
  //*Clear Chat
  void newChat() {
    chatId = uuid.v4();
    state = [];
  }

  // TODO: implement a way to load previous messages
  // void loadPreviousMessages(String chatId) {}

  void _createTextMessage(String text, User author) {
    final message = TextMessage(
      id: uuid.v4(),
      author: author,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [message, ...state];
  }

  void _createImageMessage(XFile image, User author) async {
    final message = ImageMessage(
      id: uuid.v4(),
      author: author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      uri: image.path,
      name: image.name,
      size: await image.length(),
    );

    state = [message, ...state];
  }

  // void _setGeminiWritingStatus(bool isWriting) {
  //   final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);

  //   isWriting
  //       ? isGeminiWriting.setIsWriting()
  //       : isGeminiWriting.setIsNotWriting();
  // }
}
