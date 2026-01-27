import 'dart:ui';

import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/intro_item_model.dart';
import '../controller/intro_controller.dart';

class IntroPage extends GetWidget<IntroController> {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                CircularProgressIndicator(color: context.theme.primaryColor),
                Text("We are loading", style: context.textTheme.bodySmall),
              ],
            ),
          );
        } else if (controller.introItems.isEmpty) {
          return Center(child: Text("We are not found the"));
        } else {
          return Stack(
            children: [
              PageView.builder(
                controller: controller.pageController,
                itemCount: controller.introItems.length,
                itemBuilder: (context, index) {
                  return _buildPage(context, controller.introItems[index]);
                },
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomSection(context),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildPage(BuildContext context, IntroScreenModel model) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          model.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDarkMode
                      ? AppColors.lightGradientPrimary
                      : AppColors.darkGradientPrimary,
                ),
              ),
            );
          },
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => _buildContent(context)),
              SizedBox(height: 32),

              Obx(() => _buildIndicators(context)),
              SizedBox(height: 32),

              Obx(() => _buildNavigationButtons(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final currentIndex = controller.currentPage.value;
    final item = controller.introItems[currentIndex];

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(currentIndex),
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: .9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.introItems.length,
        (index) => _buildIndicator(context, index),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, int index) {
    final isActive = controller.currentPage.value == index;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final isLastPage =
        controller.currentPage.value == controller.introItems.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isLastPage)
          TextButton(
            onPressed: () {
              controller.pageController.animateToPage(
                controller.introItems.length - 1,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          SizedBox(width: 60),

        CustomButton(
          width: 150,
          onPressed: () {
            if (isLastPage) {
              Get.offNamed(AppRoutes.login);
            } else {
              controller.pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          title: isLastPage ? 'Get Started' : 'Next',
          icon: isLastPage ? Icons.keyboard_double_arrow_right_rounded : null,
        ),
      ],
    );
  }
}
