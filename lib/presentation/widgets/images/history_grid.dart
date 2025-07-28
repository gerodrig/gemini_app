import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemini_app/presentation/providers/image/generated_history_provider.dart';
import 'package:gemini_app/presentation/providers/image/selected_image_provider.dart';

class HistoryGrid extends ConsumerWidget {
  const HistoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedHistory = ref.watch(generatedHistoryProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    return GridView.builder(
      itemCount: generatedHistory.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (content, index) {
        final imageUrl = generatedHistory[index];

        return GestureDetector(
          onTap: () {
            ref.read(selectedImageProvider.notifier).setSelectedImage(imageUrl);
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                width: selectedImage == imageUrl ? 4 : 0,
                color: selectedImage == imageUrl ? Colors.blue : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageUrl),
              ),
            ),
          ),
        );
      },
    );
  }
}
