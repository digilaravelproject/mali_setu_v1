import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';

export '../controllers/support_controller.dart';

/// A custom RenderObjectWidget that translates its child visually AND correctly
/// translates the hit-test bounds. Unlike standard Transform.translate (whose parent
/// RenderBox rejects touches outside its initial 56x56 layout box), _MovableFabRenderWidget
/// allows the FAB to be clicked, touched, and dragged repeatedly anywhere on screen.
class _MovableFabRenderWidget extends SingleChildRenderObjectWidget {
  final Offset offset;
  const _MovableFabRenderWidget({
    Key? key,
    required this.offset,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  _RenderMovableFab createRenderObject(BuildContext context) {
    return _RenderMovableFab(offset: offset);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMovableFab renderObject) {
    renderObject.offset = offset;
  }
}

class _RenderMovableFab extends RenderProxyBox {
  Offset _offset;

  _RenderMovableFab({required Offset offset, RenderBox? child})
      : _offset = offset,
        super(child);

  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset != value) {
      _offset = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset + _offset);
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    // ignore: deprecated_member_use
    transform.translate(_offset.dx, _offset.dy);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      final Offset childPosition = position - _offset;
      if (child!.size.contains(childPosition)) {
        return child!.hitTest(result, position: childPosition);
      }
    }
    return false;
  }
}

/// Custom gesture recognizer that eagerly claims touch events for the WhatsApp FAB.
/// Prevents scrollable ancestors (ListView, SingleChildScrollView, etc.) from scrolling,
/// and resets cleanly on every touch without any state locks.
class _FabGestureRecognizer extends OneSequenceGestureRecognizer {
  _FabGestureRecognizer();

  GestureDragStartCallback? onStart;
  GestureDragUpdateCallback? onUpdate;
  GestureDragEndCallback? onEnd;
  GestureDragCancelCallback? onCancel;

  bool _isTracking = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (!_isTracking) {
        _isTracking = true;
        onStart?.call(DragStartDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
        ));
      }
      onUpdate?.call(DragUpdateDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
        delta: event.delta,
      ));
    } else if (event is PointerUpEvent) {
      stopTrackingPointer(event.pointer);
      onEnd?.call(DragEndDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
      ));
      _isTracking = false;
    } else if (event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
      onCancel?.call();
      _isTracking = false;
    }
  }

  @override
  String get debugDescription => 'fab_drag';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _isTracking = false;
  }
}

class WhatsAppSupportFab extends StatefulWidget {
  final double bottomPadding;
  final bool showBadge;
  final String? customSupportMessage;
  final String? customTechSupportMessage;

  const WhatsAppSupportFab({
    Key? key,
    this.bottomPadding = 0.0,
    this.showBadge = true,
    this.customSupportMessage,
    this.customTechSupportMessage,
  }) : super(key: key);

  static Future<void> launchWhatsApp({
    String phoneNumber = "8828287535",
    String message = "Hello Mali Setu Support Team, I need assistance.",
  }) async {
    await SupportController.launchWhatsApp(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  @override
  State<WhatsAppSupportFab> createState() => _WhatsAppSupportFabState();
}

class _WhatsAppSupportFabState extends State<WhatsAppSupportFab>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fabKey = GlobalKey();

  // Persistent offset across screens and dashboard tabs
  static Offset _globalOffset = Offset.zero;

  bool _isDragging = false;
  double _dragDistance = 0.0;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    HapticFeedback.lightImpact();

    // Direct WhatsApp redirect to Support (Primary Number)
    SupportController.to.openSupportChat(
      message: widget.customSupportMessage,
    );

    /*
    // --- 2-Option Popup (Support & Technical Support) commented out for now ---
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
    */
  }

  // ignore: unused_element
  void _openMenu() {
    if (_isOpen) return;
    setState(() => _isOpen = true);
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0.0);
  }

  void _closeMenu() {
    if (!_isOpen) return;
    _animController.reverse().then((_) {
      _removeOverlay();
      if (mounted) {
        setState(() => _isOpen = false);
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final supportCtrl = SupportController.to;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // 1. Full-screen backdrop barrier to dismiss on click outside
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: Colors.black.withOpacity(0.28),
                  ),
                ),
              ),
            ),

            // 2. Options card anchored directly above the WhatsApp FAB
            Positioned(
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.bottomRight,
                offset: const Offset(0, -14),
                child: Material(
                  color: Colors.transparent,
                  child: ScaleTransition(
                    scale: _expandAnimation,
                    alignment: Alignment.bottomRight,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Obx(() {
                        final primaryNum = supportCtrl.primaryNumber.value;
                        final secondaryNum = supportCtrl.secondaryNumber.value;

                        return Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF25D366),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Connect on WhatsApp',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF374151),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1, thickness: 0.8, color: Color(0xFFF3F4F6)),
                              const SizedBox(height: 10),

                              // Option 1: Support (Primary Number)
                              _buildOptionTile(
                                title: 'Support',
                                subtitle: primaryNum,
                                iconData: FontAwesomeIcons.whatsapp,
                                gradientColors: const [
                                  Color(0xFF25D366),
                                  Color(0xFF128C7E),
                                ],
                                borderColor: const Color(0xFF25D366).withOpacity(0.25),
                                onTap: () {
                                  _closeMenu();
                                  supportCtrl.openSupportChat(
                                    message: widget.customSupportMessage,
                                  );
                                },
                              ),
                              const SizedBox(height: 10),

                              // Option 2: Technical Support (Secondary Number)
                              _buildOptionTile(
                                title: 'Technical Support',
                                subtitle: secondaryNum,
                                iconData: Icons.headset_mic_rounded,
                                gradientColors: const [
                                  Color(0xFF0EA5E9),
                                  Color(0xFF0284C7),
                                ],
                                borderColor: const Color(0xFF0284C7).withOpacity(0.25),
                                onTap: () {
                                  _closeMenu();
                                  supportCtrl.openTechnicalSupportChat(
                                    message: widget.customTechSupportMessage,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required dynamic iconData,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: iconData is IconData
                      ? Icon(iconData, color: Colors.white, size: 20)
                      : FaIcon(iconData, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _dragDistance = 0.0;
    _isDragging = false;
    if (_isOpen) {
      _closeMenu();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.distance;
    if (_dragDistance > 4.0 && !_isDragging) {
      setState(() => _isDragging = true);
    }

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final origin = box.localToGlobal(Offset.zero);
      final currentX = origin.dx + _globalOffset.dx;
      final currentY = origin.dy + _globalOffset.dy;

      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;

      final minX = padding.left + 8.0;
      final maxX = size.width - padding.right - 56.0 - 8.0;
      final minY = padding.top + 8.0;
      final maxY = size.height - padding.bottom - 56.0 - 8.0;

      final proposedX = currentX + details.delta.dx;
      final proposedY = currentY + details.delta.dy;

      final clampedX = proposedX.clamp(minX, maxX);
      final clampedY = proposedY.clamp(minY, maxY);

      final deltaX = clampedX - currentX;
      final deltaY = clampedY - currentY;

      setState(() {
        _globalOffset += Offset(deltaX, deltaY);
      });
    } else {
      setState(() {
        _globalOffset += details.delta;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging && _dragDistance < 6.0) {
      _toggleMenu();
    }
    if (_isDragging) {
      setState(() => _isDragging = false);
    }
  }

  void _handlePanCancel() {
    if (_isDragging) {
      setState(() => _isDragging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _MovableFabRenderWidget(
      offset: _globalOffset,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: RawGestureDetector(
            key: _fabKey,
            gestures: <Type, GestureRecognizerFactory>{
              _FabGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<_FabGestureRecognizer>(
                () => _FabGestureRecognizer(),
                (_FabGestureRecognizer instance) {
                  instance
                    ..onStart = _handlePanStart
                    ..onUpdate = _handlePanUpdate
                    ..onEnd = _handlePanEnd
                    ..onCancel = _handlePanCancel;
                },
              ),
            },
            child: Material(
              color: Colors.transparent,
              child: AnimatedScale(
                scale: _isDragging ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isOpen
                              ? const [Color(0xFFEF4444), Color(0xFFDC2626)]
                              : const [Color(0xFF25D366), Color(0xFF128C7E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: (_isOpen
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF25D366))
                                .withOpacity(_isDragging ? 0.6 : 0.45),
                            blurRadius: _isDragging ? 18 : 12,
                            spreadRadius: _isDragging ? 3 : 2,
                            offset: _isDragging
                                ? const Offset(0, 8)
                                : const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isOpen
                              ? const Icon(
                                  Icons.close_rounded,
                                  key: ValueKey('close'),
                                  color: Colors.white,
                                  size: 28,
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  key: ValueKey('whatsapp'),
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    if (widget.showBadge && !_isOpen)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Help',
                            textScaler: TextScaler.linear(1.0),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
