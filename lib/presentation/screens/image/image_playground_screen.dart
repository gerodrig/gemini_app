import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/presentation/providers/image/selected_image_provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gemini_app/config/theme/app_theme.dart';

import 'package:gemini_app/presentation/providers/image/generated_images_provider.dart';
import 'package:gemini_app/presentation/providers/image/is_generating_provider.dart';
import 'package:gemini_app/presentation/providers/image/selected_art_provider.dart';
import 'package:gemini_app/presentation/widgets/chat/custom_button_input.dart';
import 'package:gemini_app/presentation/widgets/images/history_grid.dart';

const imageArtStyles = [
  'Realistic',
  'Watercolor',
  'Pencil Drawing',
  'Digital Art',
  'Oil Painting',
  'Watercolor',
  'Charcoal Drawing',
  'Digital Illustration',
  'Manga Style',
  'Pixeled',
];

class ImagePlaygroundScreen extends ConsumerWidget {
  const ImagePlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Images with Gemini')),
      backgroundColor: seedColor,
      body: Column(
        children: [
          // Space for generated images
          GeneratedImageGallery(),

          // Art style selector
          ArtStyleSelector(),
          // Fill the remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: HistoryGrid(),
            ),
          ),
          // Space for the prompt
          CustomBottomInput(
            onSend: (partialText, {List<XFile> images = const []}) async {
              final generatedImagesNotifier = ref.read(
                generatedImagesProvider.notifier,
              );
              final selectedStyle = ref.read(selectedArtStyleProvider);
              final selectedImage =
                  await ref.read(selectedImageProvider.notifier).getXFile();

              if (selectedImage != null) {
                images.add(selectedImage);
              }

              String promptWithStyle = partialText.text;

              //* clear previous images
              generatedImagesNotifier.clearImages();

              if (selectedStyle.isNotEmpty) {
                promptWithStyle =
                    "${partialText.text} with style $selectedStyle";
              }

              generatedImagesNotifier.generateImage(
                promptWithStyle,
                images: images,
              );
            },
          ),
        ],
      ),
    );
  }
}

class GeneratedImageGallery extends ConsumerWidget {
  const GeneratedImageGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedImages = ref.watch(generatedImagesProvider);
    final isGenerating = ref.watch(isGeneratingProvider);

    return SizedBox(
      height: 250,
      child: PageView(
        onPageChanged: (index) {
          if (index == generatedImages.length - 1) {
            ref
                .read(generatedImagesProvider.notifier)
                .generateImageWithPreviousPrompt();
          }
        },
        controller: PageController(
          viewportFraction: 0.6, // Shows 1.5 images on the screen
          initialPage: 0,
        ),
        padEnds: true, // Changed to true to center the first image
        children: [
          //* Placeholder until at least one image is generated
          if (generatedImages.isEmpty && !isGenerating)
            const EmptyPlaceholderImage(),

          //* Here we will place the generated images
          ...generatedImages.map(
            (imageUrl) => GeneratedImage(imageUrl: imageUrl),
          ),

          // GeneratedImage(
          //   imageUrl:
          //       'https://www.theclickcommunity.com/blog/wp-content/uploads/2018/04/woman-with-red-hair-outside-by-Cassandra-Casley.jpg',
          // ),
          // GeneratedImage(
          //   imageUrl:
          //       'https://www.theclickcommunity.com/blog/wp-content/uploads/2018/04/woman-with-red-hair-outside-by-Cassandra-Casley.jpg',
          // ),
          if (isGenerating) const GeneratingPlaceholderImage(),
        ],
      ),
    );
  }
}

class GeneratedImage extends StatelessWidget {
  final String imageUrl;

  const GeneratedImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class ArtStyleSelector extends ConsumerWidget {
  const ArtStyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArtStyle = ref.watch(selectedArtStyleProvider);

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageArtStyles.length,
        itemBuilder: (context, index) {
          final style = imageArtStyles[index];
          final activeColor =
              selectedArtStyle == style
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null;

          return GestureDetector(
            onTap: () {
              ref.read(selectedArtStyleProvider.notifier).setSelectedArt(style);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(label: Text(style), backgroundColor: activeColor),
            ),
          );
        },
      ),
    );
  }
}

class EmptyPlaceholderImage extends StatelessWidget {
  const EmptyPlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 50, color: Colors.white),
          const Text('Start generating images'),
        ],
      ),
    );
  }
}

class GeneratingPlaceholderImage extends StatelessWidget {
  const GeneratingPlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 15),
          const Text(
            'Generating image...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
