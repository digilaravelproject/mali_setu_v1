import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/features/_init/presentation/controller/init_controller.dart';
import 'package:edu_cluezer/packages/background/animated_background.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/text_3d.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends GetWidget<InitController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
     // backgroundColor: context.theme.primaryColor,
      body: Stack(
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOutBack,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                final double scale = value;
                final double opacity = value.clamp(0.0, 1.0);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.cardDecoration(
                  context,
                ).copyWith(borderRadius: BorderRadius.circular(76)),
                child: CustomImageView(
                  height: 120,
                  width: 120,
                  imagePath: AppAssets.getAppLogo(),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ).marginOnly(bottom: 24),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 20),
                          child: child,
                        ),
                      );
                    },
                    child: ThreeDText(
                      text: "Mali Setu",
                      textStyle: context.textTheme.titleSmall!.copyWith(
                        color: context.theme.primaryColor,
                        fontSize: 24,
                      ),
                      depth: 10,
                      style: ThreeDStyle.standard,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// BOUNCING PROGRESS INDICATOR
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.3),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    onEnd: controller.startNavigate,
                    child: SizedBox.square(
                      dimension: 25,
                      child: CircularProgressIndicator(
                        color: context.theme.colorScheme.onPrimary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),

                  SizedBox(height: context.mediaQueryPadding.bottom + 35),
                ],
              ),
            ),
          ),
        ],
      ),
      // AnimatedBackground(
      //   behaviour: RandomParticleBehaviour(
      //     options: ParticleOptions(
      //       maxOpacity: 0.9,
      //       minOpacity: 0.3,
      //       baseColor: context.theme.colorScheme.onPrimary,
      //       opacityChangeRate: 0.75,
      //       // image: Image.asset(
      //       //   AppAssets.icHearts,
      //       //   height: 50,
      //       //   width: 50,
      //       //   color: context.theme.colorScheme.onPrimary,
      //       // ),
      //     ),
      //   ),
      //   vsync: controller,
      //   child: Stack(
      //     children: [
      //       Center(
      //         child: TweenAnimationBuilder<double>(
      //           duration: const Duration(seconds: 2),
      //           curve: Curves.easeInOutBack,
      //           tween: Tween<double>(begin: 0.0, end: 1.0),
      //           builder: (context, value, child) {
      //             final double scale = value;
      //             final double opacity = value.clamp(0.0, 1.0);
      //             return Transform.scale(
      //               scale: scale,
      //               child: Opacity(opacity: opacity, child: child),
      //             );
      //           },
      //           child: Container(
      //             padding: const EdgeInsets.all(16),
      //             decoration: AppDecorations.cardDecoration(
      //               context,
      //             ).copyWith(borderRadius: BorderRadius.circular(76)),
      //             child: CustomImageView(
      //               height: 120,
      //               width: 120,
      //               imagePath: AppAssets.imgAppLogo,
      //               fit: BoxFit.contain,
      //             ),
      //           ),
      //         ),
      //       ).marginOnly(bottom: 24),
      //       Positioned(
      //         bottom: 0,
      //         left: 0,
      //         right: 0,
      //         child: Padding(
      //           padding: const EdgeInsets.all(16.0),
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             children: [
      //               TweenAnimationBuilder<double>(
      //                 tween: Tween(begin: 0, end: 1),
      //                 duration: const Duration(milliseconds: 900),
      //                 curve: Curves.easeOut,
      //                 builder: (context, value, child) {
      //                   return Opacity(
      //                     opacity: value,
      //                     child: Transform.translate(
      //                       offset: Offset(0, (1 - value) * 20),
      //                       child: child,
      //                     ),
      //                   );
      //                 },
      //                 child: ThreeDText(
      //                   text: "Mali Setu",
      //                   textStyle: context.textTheme.titleSmall!.copyWith(
      //                     color: Colors.white,
      //                     fontSize: 24,
      //                   ),
      //                   depth: 10,
      //                   style: ThreeDStyle.standard,
      //                 ),
      //               ),
      //
      //               const SizedBox(height: 24),
      //
      //               /// BOUNCING PROGRESS INDICATOR
      //               TweenAnimationBuilder<double>(
      //                 tween: Tween(begin: 0.8, end: 1.3),
      //                 duration: const Duration(milliseconds: 1000),
      //                 curve: Curves.easeInOut,
      //                 builder: (context, scale, child) {
      //                   return Transform.scale(scale: scale, child: child);
      //                 },
      //                 onEnd: controller.startNavigate,
      //                 child: SizedBox.square(
      //                   dimension: 25,
      //                   child: CircularProgressIndicator(
      //                     color: context.theme.colorScheme.onPrimary,
      //                     strokeWidth: 3,
      //                   ),
      //                 ),
      //               ),
      //
      //               SizedBox(height: context.mediaQueryPadding.bottom + 35),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}


