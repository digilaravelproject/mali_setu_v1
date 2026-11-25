import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../styles/app_colors.dart';
import '../utils/app_assets.dart';
import '../../features/Auth/login/data/model/res_login_model.dart';

class BirthdayCelebrationDialog extends StatefulWidget {
  final User user;

  const BirthdayCelebrationDialog({
    super.key,
    required this.user,
  });

  static Future<void> show(User user) async {
    await Get.dialog(
      BirthdayCelebrationDialog(user: user),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      useSafeArea: false,
    );
  }

  @override
  State<BirthdayCelebrationDialog> createState() => _BirthdayCelebrationDialogState();
}

class _BirthdayCelebrationDialogState extends State<BirthdayCelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _cardAnimController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _confettiController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 1. Card Pop-in Animation
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeIn,
    );

    // 2. Confetti Falling Animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Generate confetti particles
    _initParticles();

    // 3. Gentle Pulse for Birthday Cake / Logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cardAnimController.forward();
    HapticFeedback.heavyImpact();
  }

  void _initParticles() {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF4081), // Pink
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFF76FF03), // Lime
      const Color(0xFFFF9100), // Orange
      const Color(0xFFD500F9), // Purple
      const Color(0xFFFF1744), // Coral Red
      Colors.white,
    ];

    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * -1.0,
          speed: 0.25 + _random.nextDouble() * 0.75,
          size: 6.0 + _random.nextDouble() * 8.0,
          color: colors[_random.nextInt(colors.length)],
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 4,
          swayAmplitude: 0.02 + _random.nextDouble() * 0.04,
          swayFrequency: 2.0 + _random.nextDouble() * 3.0,
          isCircle: _random.nextBool(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getUserFirstName() {
    final fullName = widget.user.name?.trim() ?? '';
    if (fullName.isEmpty) return 'birthday_default_name'.tr;
    final parts = fullName.split(' ');
    // Filter out common titles if present
    final titles = ['mr', 'mr.', 'mrs', 'mrs.', 'ms', 'ms.', 'shri', 'smt', 'dr', 'dr.'];
    for (final p in parts) {
      if (!titles.contains(p.toLowerCase())) {
        return p;
      }
    }
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final firstName = _getUserFirstName();

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Confetti Rain Overlay
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),

          // 2. Birthday Celebration Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: math.min(screenWidth - 40, 380),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4081).withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Card Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Tag: "HAPPY BIRTHDAY"
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("🎉 ", style: TextStyle(fontSize: 12)),
                                    Text(
                                      'birthday_tag'.tr.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const Text(" 🎉", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Animated Cake Illustration / Sparkle Circle
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFFFE2F2),
                                        const Color(0xFFFFD1E8).withValues(alpha: 0.6),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.5, 0.8, 1.0],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 86,
                                      height: 86,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF0F5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFFFC0D9),
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE63D73).withValues(alpha: 0.2),
                                            blurRadius: 14,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: _buildCakeImage(),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Headline Greeting
                              Text(
                                'birthday_greeting_title'.trParams({'name': firstName}),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  letterSpacing: -0.2,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Festive Blessing from Mali Setu
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE9D5FF),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppAssets.getAppLogo(),
                                          width: 20,
                                          height: 20,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.celebration,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'mali_setu_family'.tr,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'birthday_wish_main'.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF6B21A8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Sub Message
                              Text(
                                'birthday_wish_sub'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Celebration Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'birthday_thank_you'.tr,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text("❤️", style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close button at top right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey.shade600,
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
        ],
      ),
    );
  }

  Widget _buildCakeImage() {
    return SvgPicture.asset(
      AppAssets.imgBirthday,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Image.asset(
        AppAssets.cake,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.cake_rounded,
          size: 42,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// A confetti particle model
class _ConfettiParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final Color color;
  double rotation;
  final double rotationSpeed;
  final double swayAmplitude;
  final double swayFrequency;
  final bool isCircle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.isCircle,
  });
}

/// Custom painter for fluttering confetti particles
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Advance position
      final currentY = (p.y + progress * p.speed * 1.5) % 1.2;
      final currentX = p.x + math.sin((progress * p.swayFrequency * math.pi * 2) + p.rotation) * p.swayAmplitude;
      final currentRotation = p.rotation + progress * p.rotationSpeed;

      final renderX = currentX * size.width;
      final renderY = currentY * size.height;

      // Only draw if on screen
      if (renderY < -20 || renderY > size.height + 20) continue;

      canvas.save();
      canvas.translate(renderX, renderY);
      canvas.rotate(currentRotation);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 1.4,
          height: p.size * 0.7,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
