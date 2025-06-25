import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
User geminiUser(Ref ref) {
  final geminiUser = User(
    id: 'gemini-id',
    firstName: 'Gemini',
    imageUrl: 'https://example.com/gemini-avatar.png',
  );

  return geminiUser;
}

@riverpod
User user(Ref ref) {
  final user = User(
    id: 'user-id-abc',
    firstName: 'Benito',
    lastName: 'Martinez',
    imageUrl: 'https://example.com/user-avatar.png',
  );

  return user;
}
