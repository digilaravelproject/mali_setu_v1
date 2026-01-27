import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/features/filter/presentation/page/filter_page.dart';
import 'package:edu_cluezer/packages/card_swiper/flutter_card_swiper.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../explore/presentation/page/explore_page.dart';
import '../controller/matrimony_controller.dart';

class MatrimonyPage extends GetWidget<MatrimonyController> {
  const MatrimonyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: CustomScaffold(
        appBar: AppBar(
          title: Text(
            "Discover".toUpperCase(),
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(6),
            child: ClipOval(
              child: SizedBox(
                width: 45,
                height: 45,
                child: CustomImageView(
                  url:
                      "https://img.freepik.com/free-photo/front-view-business-woman-suit_23-2148603018.jpg?semt=ais_hybrid&w=740&q=80",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: (){
                Get.to(() => const FilterScreen());
              },
            //  FilterBottomSheet.show,
              style: IconButton.styleFrom(side: BorderSide.none),
              icon: SizedBox.square(
                dimension: 18,
                child: Center(
                  child: CustomImageView(
                    svgPath: AppAssets.icFilter,
                    color: context.theme.iconTheme.color,
                  ),
                ),
              ),
            ).marginSymmetric(horizontal: 12),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: context.theme.colorScheme.surface.withValues(
                    alpha: 0.12,
                  ),
                ),
                child: TabBar(
                  dividerHeight: 0,
                  physics: const NeverScrollableScrollPhysics(),
                  tabAlignment: TabAlignment.fill,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: context.theme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: context.theme.colorScheme.primary,
                  unselectedLabelColor: context.theme.colorScheme.onSurface,
                  tabs: const [
                    Tab(text: "All Matches"),
                    Tab(text: "Newly Joined"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCardList(context, seriousPeoples),
            _buildCardList(
              context,
              seriousPeoples.where((e) => e.isNew).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<UserProfile> list) {
    return Column(
      children: [
        Flexible(
          child: CardSwiper(
            padding: const EdgeInsets.all(16),
            duration: const Duration(milliseconds: 400),
            cardBuilder: (context, index, dx, dy) {
              return _buildUserCard(context, list[index]);
            },
            cardsCount: list.length,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            IconButton(
              onPressed: () {},
              icon: CustomImageView(
                svgPath: AppAssets.icWhatsapp,
                height: 30,
                width: 30,
              ),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.close, size: 40)),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.check_rounded, size: 30),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfile user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // BACKGROUND IMAGE
            CustomImageView(
              url: user.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // GRADIENT OVERLAY
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),

            // TOP + BOTTOM CONTENT
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP BADGES
                  Row(
                    children: [
                      if (user.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (user.isOnline)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // DISTANCE CHIP
                  _buildDistanceBadge(context, user.distance),
                  const SizedBox(height: 6),

                  // NAME + AGE
                  Text(
                    "${user.name}, ${user.age}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // LOCATION
                  Text(
                    "Designation * 5.1 * ${user.location}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge(BuildContext context, double distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Text(
        "${distance.toStringAsFixed(1)} KM away",
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
