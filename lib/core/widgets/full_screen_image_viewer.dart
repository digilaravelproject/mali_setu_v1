import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenImageViewer extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;
  final List<String>? imageUrls;
  final int initialIndex;
  final List<String>? titles;
  final String? tag;

  const FullScreenImageViewer({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.imageUrls,
    this.initialIndex = 0,
    this.titles,
    this.tag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  late List<String> _items;
  final Map<int, TransformationController> _transformationControllers = {};
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      _items = List<String>.from(widget.imageUrls!);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      _items = [widget.imageUrl!];
    } else {
      _items = [];
    }

    _currentIndex = (widget.initialIndex >= 0 && widget.initialIndex < _items.length)
        ? widget.initialIndex
        : 0;

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _transformationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TransformationController _getController(int index) {
    return _transformationControllers.putIfAbsent(
      index,
      () => TransformationController(),
    );
  }

  void _handleDoubleTap(int index, TapDownDetails details) {
    final controller = _getController(index);
    if (controller.value != Matrix4.identity()) {
      // Reset zoom
      setState(() {
        controller.value = Matrix4.identity();
        _isZoomed = false;
      });
    } else {
      // Zoom into tapped point
      final position = details.localPosition;
      final zoomed = Matrix4.diagonal3Values(2.5, 2.5, 1.0)
        ..setTranslationRaw(-position.dx * 1.5, -position.dy * 1.5, 0.0);
      setState(() {
        controller.value = zoomed;
        _isZoomed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSingleLocalFile = widget.imageFile != null;
    final int totalCount = isSingleLocalFile ? 1 : _items.length;

    String? currentTitle;
    if (widget.titles != null &&
        _currentIndex >= 0 &&
        _currentIndex < widget.titles!.length) {
      currentTitle = widget.titles![_currentIndex];
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image / PageView Area
          Positioned.fill(
            child: isSingleLocalFile
                ? _buildSingleFileView()
                : _items.isEmpty
                    ? const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        physics: _isZoomed
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        itemCount: _items.length,
                        onPageChanged: (index) {
                          // Reset zoom on previous page
                          final prevCtrl = _transformationControllers[_currentIndex];
                          if (prevCtrl != null && prevCtrl.value != Matrix4.identity()) {
                            prevCtrl.value = Matrix4.identity();
                          }
                          setState(() {
                            _currentIndex = index;
                            _isZoomed = false;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildPageItem(index);
                        },
                      ),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 16,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentTitle != null && currentTitle.isNotEmpty)
                          Text(
                            currentTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (totalCount > 1)
                          Text(
                            "${_currentIndex + 1} / $totalCount",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Indicator Dots (only shown if multi-image and not zoomed)
          if (totalCount > 1 && totalCount <= 10 && !_isZoomed)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalCount, (idx) {
                  final bool isSelected = idx == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    width: isSelected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleFileView() {
    final controller = _getController(0);
    return GestureDetector(
      onDoubleTapDown: (details) => _handleDoubleTap(0, details),
      onDoubleTap: () {},
      child: Center(
        child: InteractiveViewer(
          transformationController: controller,
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 1.0,
          maxScale: 4.5,
          onInteractionEnd: (_) {
            final scale = controller.value.getMaxScaleOnAxis();
            setState(() {
              _isZoomed = scale > 1.05;
            });
          },
          child: Image.file(
            widget.imageFile!,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildPageItem(int index) {
    final url = _items[index];
    final controller = _getController(index);
    TapDownDetails? doubleTapDetails;

    return GestureDetector(
      onDoubleTapDown: (details) {
        doubleTapDetails = details;
      },
      onDoubleTap: () {
        if (doubleTapDetails != null) {
          _handleDoubleTap(index, doubleTapDetails!);
        }
      },
      child: Center(
        child: InteractiveViewer(
          transformationController: controller,
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 1.0,
          maxScale: 4.5,
          onInteractionEnd: (_) {
            final scale = controller.value.getMaxScaleOnAxis();
            setState(() {
              _isZoomed = scale > 1.05;
            });
          },
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white70,
                strokeWidth: 2.5,
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}
