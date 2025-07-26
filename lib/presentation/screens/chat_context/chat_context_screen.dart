import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/presentation/providers/chat/chat_with_context.dart';

import 'package:gemini_app/presentation/providers/users/user_provider.dart';
import 'package:gemini_app/presentation/widgets/chat/custom_button_input.dart';

class ChatContextScreen extends ConsumerWidget {
  const ChatContextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final chatMessages = ref.watch(chatWithContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversational Chat'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatWithContextProvider.notifier).newChat();
            },
            icon: Icon(Icons.clear_outlined),
          ),
        ],
      ),
      body: Chat(
        messages: chatMessages,

        // On Send Message
        onSendPressed: (_) {},
        user: user,
        theme: DarkChatTheme(),
        showUserNames: true,

        //* Custom Input Area
        customBottomWidget: CustomBottomInput(
          onSend: (partialText, {images = const []}) {
            final chatNotifier = ref.read(chatWithContextProvider.notifier);
            chatNotifier.addMessage(
              partialText: partialText,
              user: user,
              images: images,
            );
          },
        ),
      ),
    );
  }
}
