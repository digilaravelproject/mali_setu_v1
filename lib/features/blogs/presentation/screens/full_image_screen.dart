import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullImageScreen extends StatefulWidget {
  final String imageUrl;

  const FullImageScreen({super.key, required this.imageUrl});

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      // Zoom into the double tap position
      _controller.value = Matrix4.identity()
        ..translateByDouble(-position.dx * 2, -position.dy * 2, 0.0, 1.0)
        ..scaleByDouble(3.0, 3.0, 1.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Zoomable Image Section
          Center(
            child: GestureDetector(
              onDoubleTapDown: (details) => _doubleTapDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 5.0,
                child: Hero(
                  tag: widget.imageUrl,
                  child: Image.network(
                    widget.imageUrl,
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
                      child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Top Bar (Close Button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Helper Text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Pinch to zoom • Double tap to reset',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
