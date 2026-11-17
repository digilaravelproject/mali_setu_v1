import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';

export '../controllers/support_controller.dart';

/// Global RouteObserver that informs WhatsAppSupportFab of navigation transitions.
class WhatsAppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    WhatsAppSupportFab.refresh();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    WhatsAppSupportFab.refresh();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    WhatsAppSupportFab.refresh();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    WhatsAppSupportFab.refresh();
  }
}

/// Global overlay manager for WhatsApp Floating Support Action Button.
/// Ensures that the FAB:
/// 1. Is placed in the root Overlay, allowing it to receive touches ANYWHERE on screen.
/// 2. Can be dragged repeatedly across the screen without ever getting stuck.
/// 3. Retains its position across screen transitions.
/// 4. Does not block touches to underlying form fields/buttons when not being dragged.
/// 5. Automatically stays above the bottom navigation bar and any bottom action buttons.
class _WhatsAppFabOverlayManager {
  static OverlayEntry? _entry;
  static final List<State<WhatsAppSupportFab>> _activeFabStates = [];
  static bool _hasUserDragged = false;
  static Offset? _userPosition;
  static bool _isDragging = false;
  static double _dragDistance = 0.0;

  static void register(State<WhatsAppSupportFab> state) {
    _activeFabStates.remove(state);
    _activeFabStates.add(state);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureOverlay(state);
    });
  }

  static void update(State<WhatsAppSupportFab> state) {
    scheduleRebuild();
  }

  static void unregister(State<WhatsAppSupportFab> state) {
    _activeFabStates.remove(state);
    // Defer any unmount and rebuild logic safely to post-frame to NEVER trigger
    // "setState() or markNeedsBuild() called when widget tree was locked."
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activeFabStates.removeWhere((s) => !s.mounted);
      if (_activeFabStates.isEmpty) {
        _removeOverlay();
      } else {
        _ensureOverlay();
      }
    });
  }

  static void scheduleRebuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activeFabStates.removeWhere((s) => !s.mounted);
      if (_activeFabStates.isNotEmpty) {
        _ensureOverlay();
      } else {
        _removeOverlay();
      }
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      _activeFabStates.removeWhere((s) => !s.mounted);
      if (_activeFabStates.isNotEmpty) {
        _ensureOverlay();
      }
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      _activeFabStates.removeWhere((s) => !s.mounted);
      if (_activeFabStates.isNotEmpty) {
        _ensureOverlay();
      }
    });
  }

  static void _removeOverlay() {
    try {
      _entry?.remove();
    } catch (_) {}
    _entry = null;
  }

  static void _ensureOverlay([State<WhatsAppSupportFab>? preferredState]) {
    _activeFabStates.removeWhere((s) => !s.mounted);
    if (_activeFabStates.isEmpty) {
      _removeOverlay();
      return;
    }

    State<WhatsAppSupportFab>? targetState = preferredState;
    if (targetState == null || !targetState.mounted) {
      for (int i = _activeFabStates.length - 1; i >= 0; i--) {
        if (_activeFabStates[i].mounted) {
          targetState = _activeFabStates[i];
          break;
        }
      }
    }
    if (targetState == null || !targetState.mounted) return;

    final context = targetState.context;
    final overlay = Overlay.maybeOf(context, rootOverlay: true) ??
        (Get.overlayContext != null ? Overlay.maybeOf(Get.overlayContext!, rootOverlay: true) : null);
    if (overlay == null) return;

    if (_entry == null || !_entry!.mounted) {
      try {
        _entry?.remove();
      } catch (_) {}
      _entry = OverlayEntry(builder: (ctx) => _buildOverlayContent(ctx));
      try {
        overlay.insert(_entry!);
      } catch (_) {}
    } else {
      try {
        _entry?.markNeedsBuild();
      } catch (_) {}
    }
  }

  static Widget _buildOverlayContent(BuildContext context) {
    _activeFabStates.removeWhere((s) => !s.mounted);
    if (_activeFabStates.isEmpty) return const SizedBox.shrink();

    // Hide FAB on pre-login / auth screens (splash, language selection, login, register, reset password, etc.)
    final currentRouteName = Get.currentRoute;
    if (_isPreLoginOrAuthRoute(currentRouteName)) {
      return const SizedBox.shrink();
    }

    // Find the topmost mounted FAB state whose route is currently visible or becoming visible
    State<WhatsAppSupportFab>? activeState;
    for (int i = _activeFabStates.length - 1; i >= 0; i--) {
      final s = _activeFabStates[i];
      if (!s.mounted) continue;
      final route = ModalRoute.of(s.context);
      final isVisibleRoute = route == null ||
          route.isCurrent ||
          route.secondaryAnimation?.status == AnimationStatus.reverse ||
          route.secondaryAnimation?.status == AnimationStatus.dismissed;
      if (isVisibleRoute) {
        activeState = s;
        break;
      }
    }

    // Fallback while popping / transitioning: pick any active mounted state
    if (activeState == null) {
      for (int i = _activeFabStates.length - 1; i >= 0; i--) {
        final s = _activeFabStates[i];
        if (!s.mounted) continue;
        final route = ModalRoute.of(s.context);
        if (route != null && route.isActive) {
          activeState = s;
          break;
        }
      }
    }

    activeState ??= _activeFabStates.isNotEmpty ? _activeFabStates.last : null;
    if (activeState == null || !activeState.mounted) {
      return const SizedBox.shrink();
    }

    final widget = activeState.widget;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    const double fabSize = 56.0;
    final double minX = padding.left + 8.0;
    final double maxX = screenSize.width - padding.right - fabSize - 8.0;
    final double minY = padding.top + 8.0;

    final String currentRoute = (Get.currentRoute).toLowerCase();
    final String? routeSettingName = ModalRoute.of(activeState.context)?.settings.name?.toLowerCase();
    final bool isDashboard = currentRoute.contains('dashboard') ||
        (routeSettingName != null && routeSettingName.contains('dashboard'));

    // Use widget.bottomPadding (e.g. 85.0 on bottom nav pages) so the FAB always stays strictly ABOVE bottom nav bar
    double effectiveBottomPadding = (widget.bottomPadding > 0.0)
        ? widget.bottomPadding
        : 16.0;

    // On Dashboard (all bottom nav bar tabs), bottom padding MUST be at least 85.0
    if (isDashboard && effectiveBottomPadding < 85.0) {
      effectiveBottomPadding = 85.0;
    }

    final double maxY = screenSize.height - padding.bottom - viewInsets.bottom - fabSize - effectiveBottomPadding;
    final double safeMinY = minY;
    final double safeMaxY = maxY > safeMinY ? maxY : safeMinY;
    final double safeMaxX = maxX > minX ? maxX : minX;

    final double x;
    final double y;
    if (_hasUserDragged && _userPosition != null) {
      x = _userPosition!.dx.clamp(minX, safeMaxX);
      y = _userPosition!.dy.clamp(safeMinY, safeMaxY);
    } else {
      x = safeMaxX;
      y = safeMaxY;
    }

    return Positioned(
      left: x,
      top: y,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            _dragDistance = 0.0;
            _isDragging = false;
          },
          onPanUpdate: (details) {
            _dragDistance += details.delta.distance;
            if (_dragDistance > 3.0) {
              if (!_isDragging) {
                _isDragging = true;
                _hasUserDragged = true;
                HapticFeedback.selectionClick();
              }
              final currentX = _userPosition?.dx ?? safeMaxX;
              final currentY = _userPosition?.dy ?? safeMaxY;
              final newX = (currentX + details.delta.dx).clamp(minX, safeMaxX);
              final newY = (currentY + details.delta.dy).clamp(safeMinY, safeMaxY);
              _userPosition = Offset(newX, newY);
              _entry?.markNeedsBuild();
            }
          },
          onPanEnd: (details) {
            if (!_isDragging && _dragDistance < 6.0) {
              HapticFeedback.lightImpact();
              SupportController.to.openSupportChat(
                message: widget.customSupportMessage,
              );
            }
            _isDragging = false;
            _entry?.markNeedsBuild();
          },
          onPanCancel: () {
            _isDragging = false;
            _entry?.markNeedsBuild();
          },
          child: AnimatedScale(
            scale: _isDragging ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: fabSize + 4,
              height: fabSize + 4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(_isDragging ? 0.6 : 0.45),
                          blurRadius: _isDragging ? 18 : 12,
                          spreadRadius: _isDragging ? 3 : 2,
                          offset: _isDragging ? const Offset(0, 8) : const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        key: ValueKey('whatsapp'),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  if (widget.showBadge)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }

  static bool _isPreLoginOrAuthRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return false;
    final r = routeName.toLowerCase().trim();
    if (r == '/' ||
        r == '/splash' ||
        r == '/intro' ||
        r.contains('splash') ||
        r.contains('intro')) {
      return true;
    }
    return false;
  }
}

/// Draggable WhatsApp floating action button widget.
/// Placed as `floatingActionButton: const WhatsAppSupportFab()` in Scaffolds or CustomScaffold.
/// It renders an interactive floating overlay button that can be freely dragged anywhere
/// across the screen repeatedly without ever getting stuck.
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

  static final WhatsAppRouteObserver routeObserver = WhatsAppRouteObserver();

  static void refresh() {
    _WhatsAppFabOverlayManager.scheduleRebuild();
  }

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

class _WhatsAppSupportFabState extends State<WhatsAppSupportFab> {
  @override
  void initState() {
    super.initState();
    _WhatsAppFabOverlayManager.register(this);
  }

  @override
  void didUpdateWidget(WhatsAppSupportFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _WhatsAppFabOverlayManager.update(this);
  }

  @override
  void dispose() {
    _WhatsAppFabOverlayManager.unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty sized box for the Scaffold slot;
    // the interactive FAB is rendered in the root Overlay.
    return const SizedBox(width: 56, height: 56);
  }
}
