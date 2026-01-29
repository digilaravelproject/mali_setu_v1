import 'dart:ui';

import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Discover",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.search);
            },
            icon: const Icon(CupertinoIcons.search),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filters
            _buildCategoryFilter(),
            const SizedBox(height: 20),

            // Serious Peoples Section
            _buildSectionHeader(context, "Serious peoples", onViewAll: () {}),
            const SizedBox(height: 10),
            _buildHorizontalUserGrid(context, seriousPeoples),
            const SizedBox(height: 24),

            // Nearby Section
            _buildSectionHeader(context, "Nearby", onViewAll: () {}),
            const SizedBox(height: 10),
            _buildHorizontalUserGrid(context, nearbyPeople),
            const SizedBox(height: 24),

            // Featured Profiles
            _buildSectionHeader(context, "Featured", onViewAll: () {}),
            const SizedBox(height: 10),
            _buildFeaturedProfiles(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              "View All",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalUserGrid(
    BuildContext context,
    List<UserProfile> users,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.24,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(context, users[index]);
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfile user) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          // Background Image with Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomImageView(
                  url: user.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 50),
                    );
                  },
                ),
              ),
            ),
          ),

          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: Text(
                          "NEW",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

                // Bottom Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _buildDistanceBadge(context, user.distance)),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        "${user.name}, ${user.age}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        user.location.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge(BuildContext context, double distance) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: Colors.white.withValues(alpha: 0.15),
            child: Text(
              "${distance.toStringAsFixed(1)} KM away",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProfiles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildFeaturedCard(context, seriousPeoples[0]),
          const SizedBox(height: 12),
          _buildFeaturedCard(context, seriousPeoples[1]),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, UserProfile user) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              user.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey.shade300);
              },
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${user.name}, ${user.age}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${user.distance.toStringAsFixed(1)} km away • ${user.location}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: user.interests
                              .take(3)
                              .map(
                                (interest) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    interest,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.chat_bubble,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Data Models
class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String location;
  final String imageUrl;
  final double distance;
  final bool isNew;
  final bool isOnline;
  final List<String> interests;

  UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.imageUrl,
    required this.distance,
    this.isNew = false,
    this.isOnline = false,
    required this.interests,
  });
}

// Dummy Data
final List<UserProfile> seriousPeoples = [
  UserProfile(
    name: "Emma",
    age: 24,
    location: "Downtown",
    imageUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
    distance: 2.3,
    isNew: true,
    isOnline: true,
    interests: ["Travel", "Music", "Coffee"],
  ),
  UserProfile(
    name: "Sophia",
    age: 22,
    location: "Old Town",
    imageUrl: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e",
    distance: 4.8,
    isNew: true,
    interests: ["Art", "Yoga", "Reading"],
  ),
  UserProfile(
    name: "Olivia",
    age: 26,
    location: "City Center",
    imageUrl: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1",
    distance: 3.5,
    interests: ["Photography", "Hiking", "Food"],
  ),
  UserProfile(
    name: "Isabella",
    age: 23,
    location: "Westside",
    imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
    distance: 5.2,
    isOnline: true,
    interests: ["Fashion", "Dance", "Movies"],
  ),
  UserProfile(
    name: "Mia",
    age: 25,
    location: "East Bay",
    imageUrl: "https://images.unsplash.com/photo-1517841905240-472988babdf9",
    distance: 6.1,
    interests: ["Fitness", "Cooking", "Tech"],
  ),
  UserProfile(
    name: "Ava",
    age: 21,
    location: "Marina",
    imageUrl: "https://images.unsplash.com/photo-1488716820095-cbe80883c496",
    distance: 7.3,
    isNew: true,
    interests: ["Music", "Beach", "Pets"],
  ),
  UserProfile(
    name: "Charlotte",
    age: 27,
    location: "Uptown",
    imageUrl: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04",
    distance: 4.2,
    isOnline: true,
    interests: ["Wine", "Writing", "Nature"],
  ),
  UserProfile(
    name: "Amelia",
    age: 24,
    location: "Suburbs",
    imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
    distance: 8.5,
    interests: ["Sports", "Travel", "Gaming"],
  ),
];

final List<UserProfile> nearbyPeople = [
  UserProfile(
    name: "Lucas",
    age: 28,
    location: "Downtown",
    imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    distance: 1.2,
    isOnline: true,
    interests: ["Gym", "Business", "Travel"],
  ),
  UserProfile(
    name: "James",
    age: 26,
    location: "City Center",
    imageUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d",
    distance: 1.8,
    interests: ["Music", "Coffee", "Tech"],
  ),
  UserProfile(
    name: "Noah",
    age: 25,
    location: "Old Town",
    imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
    distance: 2.1,
    isNew: true,
    interests: ["Sports", "Movies", "Food"],
  ),
  UserProfile(
    name: "Oliver",
    age: 29,
    location: "Westside",
    imageUrl: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7",
    distance: 2.9,
    isOnline: true,
    interests: ["Photography", "Art", "Wine"],
  ),
];

final List<String> categories = [
  "All",
  "Nearby",
  "New",
  "Online",
  "Popular",
  "Active",
];
