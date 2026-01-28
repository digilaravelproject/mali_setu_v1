import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_confirm_dialog.dart';

import '../../data/model/profile_model.dart';
import '../controller/matrimony_profile_controller.dart';


class MatrimonyProfileScreen extends StatefulWidget {
  final String profileId;

  const MatrimonyProfileScreen({
    super.key,
    required this.profileId,
  });

  @override
  State<MatrimonyProfileScreen> createState() => _MatrimonyProfileScreenState();
}

class _MatrimonyProfileScreenState extends State<MatrimonyProfileScreen> {
  late Future<ProfileModel> _profileFuture;
  bool _isLoadingConnection = false;
  bool _isShortlisted = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.fetchProfileData(widget.profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<ProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildNoDataScreen();
          }

          final profile = snapshot.data!;
          return _buildProfileScreen(profile);
        },
      ),
    );
  }

  Widget _buildProfileScreen(ProfileModel profile) {
    return CustomScrollView(
      slivers: [
        _buildProfileHeader(profile),
        _buildProfileDetails(profile),
        _buildActionButtons(profile),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Loading Profile...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Failed to load profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _profileFuture = ProfileService.fetchProfileData(widget.profileId);
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Profile not found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildProfileHeader(ProfileModel profile) {
    return SliverAppBar(
      expandedHeight: 350,
      floating: false,
      pinned: true,
      actions: [
        IconButton(
          icon: Icon(_isShortlisted ? Icons.favorite : Icons.favorite_border),
          color: _isShortlisted ? Colors.red : Colors.white,
          onPressed: _toggleShortlist,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareProfile(profile),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(value, profile),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Block Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('Report Profile'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Profile Images Carousel
            PageView.builder(
              itemCount: profile.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  profile.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, size: 100, color: Colors.grey),
                    );
                  },
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),

            // Profile Info Overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (profile.isVerified)
                        const Icon(Icons.verified, color: Colors.blue, size: 24),
                      if (profile.isPremium)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.profession,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      shadows: const [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        profile.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
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

  SliverList _buildProfileDetails(ProfileModel profile) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 15),
              _buildInfoRow('Religion', profile.religion),
              _buildInfoRow('Caste', profile.caste),
              _buildInfoRow('Education', profile.education),
              _buildInfoRow('Height', profile.height),
              if (profile.annualIncome != null)
                _buildInfoRow('Annual Income', profile.annualIncome!),

              const SizedBox(height: 30),

              // About Section
              _buildSectionTitle('About Me'),
              const SizedBox(height: 10),
              Text(
                profile.bio,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // Partner Expectations (if available)
              if (profile.partnerExpectations != null) ...[
                _buildSectionTitle('Partner Expectations'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    profile.partnerExpectations!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // Family Details (if available)
              if (profile.familyDetails != null) ...[
                _buildSectionTitle('Family Details'),
                const SizedBox(height: 10),
                Text(
                  profile.familyDetails!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // Interests Section
              if (profile.interests.isNotEmpty) ...[
                _buildSectionTitle('Interests & Hobbies'),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: profile.interests
                      .map((interest) => Chip(
                    label: Text(interest),
                    backgroundColor: Colors.purple[50],
                    avatar: const Icon(Icons.check, size: 16),
                  ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: Colors.purple,
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverPadding _buildActionButtons(ProfileModel profile) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                // Chat Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startChat(profile),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Call Button (Premium feature)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: profile.isPremium ? () => _makeCall(profile) : null,
                    icon: const Icon(Icons.call_outlined),
                    label: Text(profile.isPremium ? 'Call' : 'Premium'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                        color: profile.isPremium ? Colors.green : Colors.grey[300]!,
                      ),
                      foregroundColor: profile.isPremium ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Connect Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingConnection ? null : () => _sendConnection(profile),
                    icon: _isLoadingConnection
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Icon(Icons.send),
                    label: _isLoadingConnection
                        ? const Text('Sending...')
                        : const Text(
                      'Send Connection',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Report Button
            OutlinedButton.icon(
              onPressed: () => _reportProfile(profile),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('Report Profile'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: Colors.grey[300]!),
                foregroundColor: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Actions Handlers
  void _toggleShortlist() async {
    final profile = await _profileFuture;
    final success = await ProfileService.shortlistProfile(profile.id);

    if (success && mounted) {
      setState(() {
        _isShortlisted = !_isShortlisted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isShortlisted
                ? '${profile.name} added to shortlist'
                : '${profile.name} removed from shortlist',
          ),
          backgroundColor: _isShortlisted ? Colors.green : Colors.grey,
        ),
      );
    }
  }

  void _shareProfile(ProfileModel profile) {
    // Implement share functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Profile'),
        content: const Text('Share this profile via:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, ProfileModel profile) {
    switch (value) {
      case 'block':
        _blockProfile(profile);
        break;
      case 'report':
        _reportProfile(profile);
        break;
    }
  }

  void _blockProfile(ProfileModel profile) {
    CustomConfirmDialog.show(
      title: 'Block Profile',
      message: 'Are you sure you want to block ${profile.name}?',
      confirmText: 'Block',
      confirmColor: Colors.red,
      icon: Icons.block,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.name} has been blocked'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _reportProfile(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select reason for reporting:'),
            const SizedBox(height: 10),
            ...['Fake Profile', 'Inappropriate Content', 'Harassment', 'Other']
                .map((reason) => ListTile(
              leading: const Icon(Icons.report_problem, size: 20),
              title: Text(reason),
              onTap: () {
                Navigator.pop(context);
                _submitReport(profile, reason);
              },
            ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _submitReport(ProfileModel profile, String reason) async {
    final success = await ProfileService.reportProfile(profile.id, reason);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report submitted for ${profile.name}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _startChat(ProfileModel profile) {
    // Navigate to chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${profile.name}'),
      ),
    );
  }

  void _makeCall(ProfileModel profile) {
    // Implement calling functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${profile.name}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendConnection(ProfileModel profile) async {
    setState(() {
      _isLoadingConnection = true;
    });

    final success = await ProfileService.sendConnectionRequest(
      profile.id,
      'Hi, I would like to connect with you!',
    );

    setState(() {
      _isLoadingConnection = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request sent to ${profile.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}