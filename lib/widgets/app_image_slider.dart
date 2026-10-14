import 'dart:async';

import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
  final bool isIndicatorBelow;
  final double? aspectRatio;
  final double? height;
  final double indicatorSpacing;
  final Widget Function(BuildContext, String)? placeHolder;

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
    this.isIndicatorBelow = false,
    this.aspectRatio,
    this.height,
    this.indicatorSpacing = 8.0,
    this.placeHolder,
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
    Widget pageView = PageView.builder(
      controller: _pageController,
      itemCount: _loopImages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: widget.itemPadding,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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
                  placeHolder: widget.placeHolder ?? (ctx, url) => _buildImagePlaceholder(ctx),
                  errorWidget: (ctx, url, error) => _buildErrorWidget(ctx),
                  errorBuilder: (ctx, p, q) => _buildErrorWidget(ctx),
                ),
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
    );

    Widget content;
    if (widget.isIndicatorBelow) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.aspectRatio != null)
            AspectRatio(
              aspectRatio: widget.aspectRatio!,
              child: pageView,
            )
          else if (widget.height != null)
            SizedBox(
              height: widget.height,
              child: pageView,
            )
          else
            pageView,
          if (widget.isIndicatorVisible && widget.images.length > 1) ...[
            SizedBox(height: widget.indicatorSpacing),
            _buildIndicator(context),
          ],
        ],
      );
    } else {
      content = Stack(
        children: [
          pageView,
          if (widget.isIndicatorVisible && widget.images.length > 1)
            _buildIndicator(context),
        ],
      );
    }

    if (widget.pauseOnTouch) {
      content = Listener(
        onPointerDown: (_) => _pauseTimer(),
        onPointerUp: (_) => _resumeTimer(),
        onPointerCancel: (_) => _resumeTimer(),
        child: content,
      );
    }

    return content;
  }

  /// ------------------------------------------------------------
  /// IMAGE PLACEHOLDER (Smooth Shimmer + User-friendly Loader)
  /// ------------------------------------------------------------
  Widget _buildImagePlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkShimmerBase : AppColors.lightShimmerBase;
    final highlightColor = isDark ? AppColors.darkShimmerHighlight : AppColors.lightShimmerHighlight;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1400),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.65),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------------------------------------------
  /// ERROR FALLBACK
  /// ------------------------------------------------------------
  Widget _buildErrorWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Center(
        child: Image.asset(
          AppAssets.getAppLogo(),
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.broken_image_outlined,
            color: isDark ? Colors.white30 : Colors.grey.shade400,
            size: 32,
          ),
        ),
      ),
    );
  }

  /// ------------------------------------------------------------
  /// INDICATOR BUILDER (Handles dot, rectangle, story indicators)
  /// ------------------------------------------------------------
  Widget _buildIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.25)
        : primaryColor.withOpacity(0.25);

    Widget indicator;
    switch (widget.indicatorType) {
      /// Clean, modern circular / expanding dots
      case IndicatorType.dot:
        indicator = Row(
          mainAxisAlignment: widget.indicatorAlignment,
          children: List.generate(widget.images.length, (i) {
            final bool active = (_activeIndicatorIndex == i);
            return GestureDetector(
              onTap: () {
                final targetPage = widget.images.length > 1 ? i + 1 : i;
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    targetPage,
                    duration: widget.scrollAnimationDuration,
                    curve: widget.animationCurve,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? primaryColor : inactiveColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        );
        break;

      /// Rectangle pill indicators
      case IndicatorType.rectangle:
        indicator = Row(
          mainAxisAlignment: widget.indicatorAlignment,
          children: List.generate(widget.images.length, (i) {
            final bool active = (_activeIndicatorIndex == i);
            return GestureDetector(
              onTap: () {
                final targetPage = widget.images.length > 1 ? i + 1 : i;
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    targetPage,
                    duration: widget.scrollAnimationDuration,
                    curve: widget.animationCurve,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 8,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? primaryColor : inactiveColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
        break;

      /// Instagram-style story bar indicators
      case IndicatorType.story:
        indicator = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final bool active = (_activeIndicatorIndex == i);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: active
                          ? primaryColor
                          : Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
        break;
    }

    if (widget.isIndicatorBelow) {
      return indicator;
    }

    return Positioned(
      bottom: 12,
      right: 0,
      left: 0,
      child: indicator,
    );
  }
}

enum IndicatorType { story, rectangle, dot }
