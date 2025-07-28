import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Gemini')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.pink,
              child: Icon(Icons.person_outline),
            ),
            title: const Text('Gemini Prompt'),
            subtitle: const Text('Using a Flash Model'),
            onTap: () => context.push('/basic-prompt'),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.history_outlined),
            ),
            title: const Text('Conversational Chat'),
            subtitle: const Text('Keep context message'),
            onTap: () => context.push('/history-chat'),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.image_outlined),
            ),
            title: const Text('Image generation'),
            subtitle: const Text('Create and edit images'),
            onTap: () => context.push('/image-playground'),
          ),
        ],
      ),
    );
  }
}
