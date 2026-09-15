import 'dart:async';

import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_image_view.dart';

class ImageSlider extends StatefulWidget {
  final List<String> images;
  final double viewPort;
  final MainAxisAlignment indicatorAlignment;
  final EdgeInsets itemPadding;
  final bool autoScroll;
  final bool isIndicatorVisible;
  final double borderRadius;
  final bool enableNavigation;
  final IndicatorType indicatorType;
  final BoxFit fit;
  final Function(int index)? onImageTap; // Callback when image is tapped
  final Duration autoScrollInterval;
  final Duration scrollAnimationDuration;
  final Curve animationCurve;
  final bool pauseOnTouch;

  const ImageSlider({
    super.key,
    required this.images,
    this.indicatorAlignment = MainAxisAlignment.center,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.viewPort = 0.9,
    this.isIndicatorVisible = true,
    this.enableNavigation = false,
    this.borderRadius = 16,
    this.autoScroll = true,
    this.indicatorType = IndicatorType.dot,
    this.fit = BoxFit.cover,
    this.onImageTap, // Optional tap callback
    this.autoScrollInterval = const Duration(seconds: 5),
    this.scrollAnimationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeInOutCubic,
    this.pauseOnTouch = true,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;
  int _currentPage = 1;
  Timer? _timer;
  bool _isHolding = false;

  List<String> get _loopImages {
    if (widget.images.isEmpty) return [];
    if (widget.images.length == 1) return widget.images;
    return [
      widget.images.last,
      ...widget.images,
      widget.images.first,
    ];
  }

  int get _activeIndicatorIndex {
    if (widget.images.isEmpty) return 0;
    if (widget.images.length == 1) return 0;
    if (_currentPage == 0) return widget.images.length - 1;
    if (_currentPage >= _loopImages.length - 1) return 0;
    return (_currentPage - 1).clamp(0, widget.images.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.images.length > 1 ? 1 : 0;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewPort,
    );

    if (widget.autoScroll && widget.images.length > 1) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant ImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.length != oldWidget.images.length ||
        widget.autoScroll != oldWidget.autoScroll ||
        widget.autoScrollInterval != oldWidget.autoScrollInterval) {
      _timer?.cancel();
      _currentPage = widget.images.length > 1 ? 1 : 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
      if (widget.autoScroll && widget.images.length > 1 && !_isHolding) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!widget.autoScroll || widget.images.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoScrollInterval, (timer) async {
      if (!mounted || !_pageController.hasClients || _isHolding) return;

      if (_currentPage < _loopImages.length - 1) {
        _currentPage++;
        try {
          await _pageController.animateToPage(
            _currentPage,
            duration: widget.scrollAnimationDuration,
            curve: widget.animationCurve,
          );
          if (!mounted || !_pageController.hasClients) return;
          if (_currentPage >= _loopImages.length - 1) {
            _currentPage = 1;
            _pageController.jumpToPage(1);
          }
        } catch (_) {}
      } else {
        _currentPage = 1;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(1);
        }
      }
    });
  }

  void _pauseTimer() {
    _isHolding = true;
    _timer?.cancel();
    _timer = null;
  }

  void _resumeTimer() {
    _isHolding = false;
    if (widget.autoScroll && widget.images.length > 1) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget slider = Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _loopImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: widget.itemPadding,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    if (widget.enableNavigation) {
                      final width = MediaQuery.of(context).size.width;
                      final tapPosition = details.localPosition.dx;

                      if (tapPosition > width / 2) {
                        if (_currentPage < _loopImages.length - 1) {
                          _pageController.nextPage(
                            duration: widget.scrollAnimationDuration,
                            curve: widget.animationCurve,
                          );
                        }
                      } else {
                        if (_currentPage > 0) {
                          _pageController.previousPage(
                            duration: widget.scrollAnimationDuration,
                            curve: widget.animationCurve,
                          );
                        }
                      }
                    }
                  },
                  onLongPress: () {
                    // Intentionally absorb long press so releasing after holding
                    // does not accidentally trigger onTap
                  },
                  onTap: () {
                    // Call the onImageTap callback with the actual image index (not loop index)
                    if (widget.onImageTap != null) {
                      int actualIndex = widget.images.length > 1 ? index - 1 : index;
                      if (actualIndex < 0) actualIndex = widget.images.length - 1;
                      if (actualIndex >= widget.images.length) actualIndex = 0;
                      widget.onImageTap!(actualIndex);
                    }
                  },
                  child: CustomImageView(
                    url: _loopImages[index],
                    fit: widget.fit,
                    errorBuilder: (ctx, p, q) =>
                        Center(child: Image.asset(AppAssets.getAppLogo())),
                  ),
                ),
              ),
            );
          },
          onPageChanged: (index) {
            setState(() => _currentPage = index);

            if (widget.images.length > 1) {
              if (index == _loopImages.length - 1) {
                Future.delayed(widget.scrollAnimationDuration, () {
                  if (mounted &&
                      _pageController.hasClients &&
                      _currentPage == _loopImages.length - 1) {
                    _pageController.jumpToPage(1);
                  }
                });
              } else if (index == 0) {
                Future.delayed(widget.scrollAnimationDuration, () {
                  if (mounted &&
                      _pageController.hasClients &&
                      _currentPage == 0) {
                    _pageController.jumpToPage(widget.images.length);
                  }
                });
              }
            }
          },
        ),
        if (widget.isIndicatorVisible && widget.images.length > 1)
          _buildIndicator(context),
      ],
    );

    if (widget.pauseOnTouch) {
      slider = Listener(
        onPointerDown: (_) => _pauseTimer(),
        onPointerUp: (_) => _resumeTimer(),
        onPointerCancel: (_) => _resumeTimer(),
        child: slider,
      );
    }

    return slider;
  }

  /// ------------------------------------------------------------
  /// INDICATOR BUILDER (Handles dot, rectangle, story indicators)
  /// ------------------------------------------------------------
  Widget _buildIndicator(BuildContext context) {
    switch (widget.indicatorType) {
      /// Small circular dots
      case IndicatorType.dot:
        return Row(
          mainAxisAlignment: widget.indicatorAlignment,
          children: List.generate(widget.images.length, (i) {
            bool active = (_activeIndicatorIndex == i);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? context.theme.primaryColor
                    : context.theme.dividerColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        );

      /// Rectangle pill indicators
      case IndicatorType.rectangle:
        return Positioned(
          bottom: 12,
          right: 0,
          left: 0,
          child: Row(
            mainAxisAlignment: widget.indicatorAlignment,
            children: List.generate(widget.images.length, (i) {
              bool active = (_activeIndicatorIndex == i);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 10,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? context.theme.primaryColor
                      : context.theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );

      /// Instagram-style story bar indicators
      case IndicatorType.story:
        return Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
            bool active = (_activeIndicatorIndex == i);
            return Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? context.theme.primaryColor
                      : context.theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
            );
          }),
        ).marginSymmetric(horizontal: 12);
    }
  }
}

enum IndicatorType { story, rectangle, dot }
