import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';

export '../controllers/support_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleMenu,
            borderRadius: BorderRadius.circular(30),
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
                            .withOpacity(0.45),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
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
    );
  }
}
