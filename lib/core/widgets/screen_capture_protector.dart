import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// A widget that prevents screenshots and screen recordings of its content.
///
/// When this widget is mounted, it enables system-level protection to prevent 
/// screen captures. When unmounted, it disables the protection.
class ScreenCaptureProtector extends StatefulWidget {
  final Widget child;

  const ScreenCaptureProtector({
    super.key,
    required this.child,
  });

  @override
  State<ScreenCaptureProtector> createState() => _ScreenCaptureProtectorState();
}

class _ScreenCaptureProtectorState extends State<ScreenCaptureProtector> {
  @override
  void initState() {
    super.initState();
    _enableProtection();
  }

  @override
  void dispose() {
    _disableProtection();
    super.dispose();
  }

  Future<void> _enableProtection() async {
    // Prevents screenshots and screen recording on Android and iOS
    await ScreenProtector.preventScreenshotOn();
    // Specific for screen recording detection/prevention on iOS
    await ScreenProtector.protectDataLeakageWithBlur();
  }

  Future<void> _disableProtection() async {
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageWithBlurOff();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
