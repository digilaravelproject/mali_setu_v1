import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/styles/app_colors.dart';
import '../../data/models/webinar_model.dart';
import '../controllers/webinars_controller.dart';
import '../widgets/webinar_notice_dialog.dart';
import 'webinar_live_screen.dart';

class WebinarDetailsScreen extends StatefulWidget {
  final Webinar? webinar;

  const WebinarDetailsScreen({super.key, this.webinar});

  @override
  State<WebinarDetailsScreen> createState() => _WebinarDetailsScreenState();
}

class _WebinarDetailsScreenState extends State<WebinarDetailsScreen> {
  late Webinar webinar;
  final controller = Get.find<WebinarsController>();
  int _selectedTabIndex = 0; // 0: About, 1: Speaker, 2: Agenda
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    if (widget.webinar != null) {
      webinar = widget.webinar!;
    } else if (Get.arguments is Webinar) {
      webinar = Get.arguments as Webinar;
    } else if (controller.selectedWebinar.value != null) {
      webinar = controller.selectedWebinar.value!;
    } else {
      webinar = controller.webinars.first;
    }

    _fetchLatestDetails();
  }

  Future<void> _fetchLatestDetails() async {
    setState(() => _isLoadingDetails = true);
    final fresh = await controller.fetchWebinarDetail(webinar.id);
    if (mounted && fresh != null) {
      setState(() {
        webinar = fresh;
        _isLoadingDetails = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Banner App Bar (Matching reference Image 2)
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Share.share(
                    "Join this community webinar: ${webinar.title}\nDate: ${webinar.dateString} at ${webinar.timeString}\nDownload Mali Setu App: https://malisetu.com",
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: webinar.bannerUrl.isNotEmpty ? webinar.bannerUrl : webinar.videoThumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.primaryDark),
                    errorWidget: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Dark overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.25),
                          Colors.black.withOpacity(0.72),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Center Play Button (Matching Image 2)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (webinar.isCompleted) {
                          WebinarNoticeDialog.showCompleted(context: context);
                          return;
                        }
                        if (!webinar.isLiveSession) {
                          WebinarNoticeDialog.showUpcoming(
                            context: context,
                            dateString: webinar.dateString,
                            timeString: webinar.timeString,
                          );
                          return;
                        }
                        final isReg = controller.isWebinarRegistered(webinar.id) || webinar.isRegistered;
                        if (webinar.requireRegistration && !isReg) {
                          WebinarNoticeDialog.showRegistrationClosed(
                            context: context,
                            message: "This webinar has already started, but you are not registered for it. Registrations are now closed.",
                          );
                          return;
                        }
                        Get.to(
                          () => WebinarLiveScreen(webinar: webinar),
                          transition: Transition.fadeIn,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top Mali Setu Live Watermark Tag
                  Positioned(
                    top: 50,
                    left: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: webinar.isLiveSession ? const Color(0xFFEF4444) : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            webinar.isLiveSession ? "Live Now" : "Mali Setu Live",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Strip: Date & Time, Category, Registered count (Matching Image 2)
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 13,
                        color: AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        webinar.dateString,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        CupertinoIcons.time,
                        size: 13,
                        color: AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          webinar.timeString,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              webinar.category == 'Business'
                                  ? Icons.business_center_rounded
                                  : webinar.category == 'Matrimony'
                                      ? Icons.favorite_rounded
                                      : Icons.groups_rounded,
                              size: 11,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              webinar.category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Registered attendees count
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.person_2,
                            size: 13,
                            color: AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${webinar.registeredCount} Registered",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Webinar Title
                  Text(
                    webinar.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextPrimary,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Custom Refined Tabs Header (About, Speaker, Agenda)
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTabHeader(0, "About"),
                        const SizedBox(width: 16),
                        _buildTabHeader(1, "Speaker"),
                        const SizedBox(width: 16),
                        _buildTabHeader(2, "Agenda"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Dynamic Tab Content (No fixed height cutoff!)
                  if (_isLoadingDetails) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                  ] else ...[
                    if (_selectedTabIndex == 0) _buildAboutTab(),
                    if (_selectedTabIndex == 1) _buildSpeakerTab(),
                    if (_selectedTabIndex == 2) _buildAgendaTab(),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Sticky Button (Matching Image 2)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            final isRegistered = controller.isWebinarRegistered(webinar.id) || webinar.isRegistered;
            final isLive = webinar.isLiveSession;
            final isCompleted = webinar.isCompleted;
            final requireRegistration = webinar.requireRegistration;
            final isRegistering = controller.isRegistering.value;

            // Registration is required if requireRegistration is true AND user is not registered yet
            final needsRegistration = requireRegistration && !isRegistered;

            String buttonText;
            Color buttonColor;
            IconData buttonIcon;
            VoidCallback? onTapAction;

            if (isCompleted) {
              buttonText = "Webinar Completed";
              buttonColor = const Color(0xFF64748B);
              buttonIcon = Icons.check_circle_outline_rounded;
              onTapAction = () {
                WebinarNoticeDialog.showCompleted(context: context);
              };
            } else if (needsRegistration) {
              // Registration is required and user has NOT registered yet
              buttonText = isLive ? "Register to Join Live" : "Register for Webinar";
              buttonColor = AppColors.primary;
              buttonIcon = Icons.app_registration_rounded;
              onTapAction = () async {
                final ok = await controller.registerForWebinar(webinar.id);
                if (ok && mounted) {
                  setState(() {
                    webinar = webinar.copyWith(
                      isRegistered: true,
                      registeredCount: webinar.registeredCount + 1,
                    );
                  });
                }
              };
            } else if (isLive) {
              // Webinar is LIVE and user has access (registered or registration not required)
              buttonText = "Join Webinar (Live)";
              buttonColor = const Color(0xFFEF4444);
              buttonIcon = Icons.videocam_rounded;
              onTapAction = () {
                Get.to(
                  () => WebinarLiveScreen(webinar: webinar),
                  transition: Transition.fadeIn,
                );
              };
            } else {
              // Webinar is UPCOMING and user has access (registered or require_registration == false)
              // User cannot join until live, and cannot re-register!
              buttonText = "Registered • Starts Soon";
              buttonColor = const Color(0xFF10B981);
              buttonIcon = Icons.check_circle_rounded;
              onTapAction = () {
                WebinarNoticeDialog.showUpcoming(
                  context: context,
                  dateString: webinar.dateString,
                  timeString: webinar.timeString,
                );
              };
            }

            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isRegistering ? null : onTapAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isRegistering
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CupertinoActivityIndicator(color: Colors.white, radius: 10),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            buttonIcon,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabHeader(int index, String title) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
          ),
          Container(
            height: 3,
            width: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    final hasDesc = webinar.description.trim().isNotEmpty;
    final hasKeyPoints = webinar.keyPoints.isNotEmpty;

    if (!hasDesc && !hasKeyPoints) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.doc_text, size: 36, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 10),
              const Text(
                "No details available",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "No description has been added for this session yet.",
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (hasDesc) ...[
          Text(
            webinar.description,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Key Points Header (only if key points exist)
        if (hasKeyPoints) ...[
          const Text(
            "Key Points:",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Key Points Checklist with green checkmarks
          ...webinar.keyPoints.map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Session Information Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildInfoRow(CupertinoIcons.videocam_fill, "Format", "Live Interactive Web Session"),
              const Divider(height: 16, thickness: 0.8, color: Color(0xFFE2E8F0)),
              _buildInfoRow(CupertinoIcons.clock_fill, "Duration", webinar.duration),
              const Divider(height: 16, thickness: 0.8, color: Color(0xFFE2E8F0)),
              _buildInfoRow(CupertinoIcons.globe, "Access", webinar.isPaid ? "Paid (${webinar.fee})" : "Free for Registered Members"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSpeakerTab() {
    final speaker = webinar.speaker;
    final hasSpeaker = speaker.name.trim().isNotEmpty;

    if (!hasSpeaker) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.person_crop_circle_badge_exclam, size: 36, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 10),
              const Text(
                "No speaker details",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Speaker information will be announced soon.",
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Speaker Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: speaker.photo,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 65,
                    height: 65,
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speaker.name,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    if (speaker.role.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        speaker.role,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    if (speaker.organization.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        speaker.organization,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (speaker.bio.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            "About the Speaker:",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            speaker.bio,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAgendaTab() {
    if (webinar.agenda.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.calendar_badge_minus, size: 36, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 10),
              const Text(
                "No agenda available",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Session schedule has not been published yet.",
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Session Schedule:",
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 14),

        ...List.generate(webinar.agenda.length, (index) {
          final item = webinar.agenda[index];
          final isLast = index == webinar.agenda.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Step Dot & Vertical Line
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
