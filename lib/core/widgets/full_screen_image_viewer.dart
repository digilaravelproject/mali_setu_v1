import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenImageViewer extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final String? tag;

  const FullScreenImageViewer({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: tag ?? (imageFile?.path ?? imageUrl ?? 'image'),
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: imageFile != null
                ? Image.file(
                    imageFile!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
