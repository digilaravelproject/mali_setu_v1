import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:edu_cluezer/widgets/app_image_slider.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';

class HomePage extends GetWidget<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          centerTitle: false,
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          title: Row(
            spacing: 8,
            children: [
              SizedBox.square(
                dimension: 48,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CustomImageView(
                    url:
                        "https://img.freepik.com/free-photo/front-view-business-woman-suit_23-2148603018.jpg?semt=ais_hybrid&w=740&q=80",
                    fit: BoxFit.contain,
                    radius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Name",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Designation",
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              style: IconButton.styleFrom(side: BorderSide.none),
              onPressed: () {},
              icon: Badge(child: Icon(CupertinoIcons.bell_fill)),
            ).marginOnly(right: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.theme.dividerColor,
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: context.theme.iconTheme.color,
                    ),
                    Text(
                      "Search Here",
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ).marginSymmetric(horizontal: 16, vertical: 12),

              SizedBox(
                height: Get.height * 0.2,
                child: ImageSlider(
                  indicatorType: IndicatorType.rectangle,
                  images: [
                    "https://img.freepik.com/premium-psd/super-sale-tag-label-template-with-glossy-3d-style-editable-text-effect_628935-983.jpg",
                    "https://img.freepik.com/premium-vector/black-friday-sale-banner-waving-design-template_2239-1556.jpg",
                    "https://img.freepik.com/premium-vector/gradient-zero-commission-sale-banner_52683-98500.jpg",
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "View All",
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColor,
                    ),
                  ),
                ],
              ).marginAll(16),

              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12),
                shrinkWrap: true,
                itemCount: 8,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, index) {
                  return Column(
                    spacing: 8,
                    children: [
                      CustomImageView(
                        height: 40,
                        width: 40,
                        url:
                            "https://cdn-icons-png.freepik.com/512/10416/10416308.png",
                      ),
                      Text(
                        "Category Name",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  );
                },
              ),
              BgGradientBorder(
                child: Row(
                  children: [
                    CustomImageView(
                      url:
                          "https://img.freepik.com/premium-vector/admin-panel_203633-463.jpg",
                      height: 120,
                      width: 120,
                    ).marginOnly(left: 4, top: 4, bottom: 4),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Want to register your business ?",
                            style: context.textTheme.titleMedium,
                          ),
                          Text(
                            "showcase your ideas and generate leads ?",
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            decoration: AppDecorations.primaryBgDecoration(
                              context,
                            ).copyWith(borderRadius: BorderRadius.circular(24)),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              "Start Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).marginSymmetric(horizontal: 12),
              const SizedBox(height: 12),
              BgGradientBorder(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Want to register your Matrimony ?",
                              style: context.textTheme.titleMedium,
                            ),
                            Text(
                              "connecting to your souls for a journey of love and forever",
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              decoration:
                                  AppDecorations.primaryBgDecoration(
                                    context,
                                  ).copyWith(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.regMatrimony);
                                },
                                child: Text(
                                  "Start Now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomImageView(
                        url:
                            "https://img.freepik.com/premium-vector/illustration-couple-eating-ice-cream_276340-139.jpg",
                        height: 100,
                        width: 100,
                      ).marginOnly(left: 4, top: 4, bottom: 4),
                    ],
                  ),
                ),
              ).marginSymmetric(horizontal: 12),
            ],
          ),
        ),
      ],
    );
  }
}
