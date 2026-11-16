import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../constent/app_constants.dart';
import '../storage/shared_prefs.dart';
import '../controllers/support_controller.dart';

export '../controllers/support_controller.dart';

/// Global overlay manager for WhatsApp Floating Support Action Button.
/// Ensures that the FAB:
/// 1. Is placed in the root Overlay, allowing it to receive touches ANYWHERE on screen.
/// 2. Can be dragged repeatedly across the screen without ever getting stuck.
/// 3. Retains its position across screen transitions.
/// 4. Does not block touches to underlying form fields/buttons when not being dragged.
class _WhatsAppFabOverlayManager {
  static OverlayEntry? _entry;
  static final List<State<WhatsAppSupportFab>> _activeFabStates = [];
  static Offset? _currentPosition;
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
    _entry?.markNeedsBuild();
  }

  static void unregister(State<WhatsAppSupportFab> state) {
    _activeFabStates.remove(state);
    if (_activeFabStates.isEmpty) {
      _removeOverlay();
    } else {
      _entry?.markNeedsBuild();
    }
  }

  static void _removeOverlay() {
    try {
      _entry?.remove();
    } catch (_) {}
    _entry = null;
  }

  static void _ensureOverlay(State<WhatsAppSupportFab> state) {
    if (!state.mounted || _activeFabStates.isEmpty) return;

    final context = state.context;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    if (_entry == null) {
      _entry = OverlayEntry(builder: (ctx) => _buildOverlayContent(ctx));
      overlay.insert(_entry!);
    } else {
      try {
        _entry!.remove();
        overlay.insert(_entry!);
      } catch (_) {
        _entry?.markNeedsBuild();
      }
    }
  }

  static Widget _buildOverlayContent(BuildContext context) {
    if (_activeFabStates.isEmpty) return const SizedBox.shrink();

    final topState = _activeFabStates.last;
    if (!topState.mounted) {
      return const SizedBox.shrink();
    }

    // Hide FAB if the route containing the top FAB is covered by another route
    final route = ModalRoute.of(topState.context);
    if (route != null && !route.isCurrent) {
      return const SizedBox.shrink();
    }

    // Hide FAB on pre-login / auth screens (splash, language selection, login, register, reset password, etc.)
    final routeName = route?.settings.name ?? Get.currentRoute;
    if (_isPreLoginOrAuthRoute(routeName)) {
      return const SizedBox.shrink();
    }

    final widget = topState.widget;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    const double fabSize = 56.0;
    final double minX = padding.left + 8.0;
    final double maxX = screenSize.width - padding.right - fabSize - 8.0;
    final double minY = padding.top + 8.0;
    final double maxY = screenSize.height - padding.bottom - viewInsets.bottom - fabSize - 8.0;

    if (_currentPosition == null) {
      final double initialX = maxX;
      final double initialY = (maxY - widget.bottomPadding).clamp(minY, maxY);
      _currentPosition = Offset(initialX, initialY);
    }

    // Clamp coordinates safely within the visible screen area
    final double x = _currentPosition!.dx.clamp(minX, maxX);
    final double y = _currentPosition!.dy.clamp(minY, maxY);

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
                HapticFeedback.selectionClick();
              }
              final newX = (_currentPosition!.dx + details.delta.dx).clamp(minX, maxX);
              final newY = (_currentPosition!.dy + details.delta.dy).clamp(minY, maxY);
              _currentPosition = Offset(newX, newY);
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
    if (routeName == null) return false;
    final r = routeName.toLowerCase().trim();
    if (r == '/' ||
        r.isEmpty ||
        r == '/splash' ||
        r == '/intro' ||
        r == '/languageselection' ||
        r == '/login' ||
        r == '/register' ||
        r == '/emailpasswordreset' ||
        r == '/resetpasswordscreen' ||
        r.contains('splash') ||
        r.contains('intro') ||
        r.contains('login') ||
        r.contains('register') ||
        r.contains('resetpassword') ||
        r.contains('passwordreset')) {
      if (r == '/changepassword' || r == '/languageselection') {
        final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
        return !isLoggedIn;
      }
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
