import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/styles/app_decoration.dart';
import '../controller/login_controller.dart';

class VerifyOtpBottomSheet extends StatefulWidget {
  final LoginController controller;

  const VerifyOtpBottomSheet({super.key, required this.controller});

  @override
  State<VerifyOtpBottomSheet> createState() => _VerifyOtpBottomSheetState();

  static show(LoginController c) {
    Get.bottomSheet(
      PopScope(canPop: false, child: VerifyOtpBottomSheet(controller: c)),
      //persistent: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,           // swipe se close ho jaye
      backgroundColor: Colors.transparent,
    );
  }
}

class _VerifyOtpBottomSheetState extends State<VerifyOtpBottomSheet> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  /// ✅ Reactive variables
  final RxInt countdown = 30.obs;
  final RxBool isResendEnabled = false.obs;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      final index = i;
      otpFocusNodes[index].onKeyEvent = (focusNode, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (otpControllers[index].text.isEmpty && index > 0) {
            otpControllers[index - 1].clear();
            otpFocusNodes[index - 1].requestFocus();
            if (mounted) setState(() {});
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
    startCountdown();
  }

  void _onOtpDigitChanged(int index, String val) {
    final cleanDigits = val.replaceAll(RegExp(r'\D'), '');

    // 1. Multi-digit paste or autofill (e.g. 6-digit OTP copied/autofilled)
    if (cleanDigits.length >= 6 || cleanDigits.length >= 4) {
      for (int i = 0; i < 6; i++) {
        if (i < cleanDigits.length) {
          otpControllers[i].text = cleanDigits[i];
        }
      }
      if (cleanDigits.length >= 6) {
        otpFocusNodes[5].unfocus();
      } else {
        otpFocusNodes[cleanDigits.length].requestFocus();
      }
      if (mounted) setState(() {});
      return;
    }

    // 2. Typing into an already filled box (replace digit and advance)
    if (cleanDigits.length > 1) {
      final newChar = cleanDigits[cleanDigits.length - 1];
      otpControllers[index].value = TextEditingValue(
        text: newChar,
        selection: const TextSelection.collapsed(offset: 1),
      );
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
      }
      if (mounted) setState(() {});
      return;
    }

    // 3. Normal single digit entry
    if (cleanDigits.isNotEmpty) {
      if (otpControllers[index].text != cleanDigits) {
        otpControllers[index].value = TextEditingValue(
          text: cleanDigits,
          selection: const TextSelection.collapsed(offset: 1),
        );
      }
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }
    }
    if (mounted) setState(() {});
  }

  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (countdown.value > 0) {
        countdown.value--;
        startCountdown();
      } else {
        isResendEnabled.value = true;
      }
    });
  }

  void resetTimer() {
    countdown.value = 30;
    isResendEnabled.value = false;
    startCountdown();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: AppDecorations.bottomSheetDecoration(context),
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: context.mediaQueryPadding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Handle bar
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 32),

                /// Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 52,
                    color: context.theme.primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                /// Title
                Text(
                  "verify_your_number".tr,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// Subtext
                /// Subtext
                Text(
                  "enter_otp_mobile".tr, // Fixed: Removed missing controller fields
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 40),

                /// OTP Boxes (6 boxes)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double totalWidth = constraints.maxWidth;
                    const double spacing = 6.0;
                    const int count = 6;
                    final double boxWidth =
                        ((totalWidth - (spacing * (count - 1))) / count)
                            .clamp(36.0, 48.0);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(count, (index) {
                        return SizedBox(
                          width: boxWidth,
                          height: 48,
                          child: TextFormField(
                            controller: otpControllers[index],
                            focusNode: otpFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            cursorHeight: 20,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: context.theme.primaryColor,
                                  width: 1.8,
                                ),
                              ),
                            ),
                            onChanged: (value) => _onOtpDigitChanged(index, value),
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 32),

                /// ✅ Resend Text using Obx
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "didnt_receive_code".tr,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: isResendEnabled.value ? resetTimer : null,
                        child: Text(
                          isResendEnabled.value
                              ? "resend_otp".tr
                              : "Resend in ${countdown.value}s",
                          style: TextStyle(
                            color: isResendEnabled.value
                                ? context.theme.primaryColor
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 40),

                /// Verify Button
                CustomButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.register);
                  },
                  title: "verify_continue".tr,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
