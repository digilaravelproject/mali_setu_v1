import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/models/webinar_model.dart';
import '../../data/models/agora_token_model.dart';
import '../controllers/webinars_controller.dart';

class WebinarLiveScreen extends StatefulWidget {
  final Webinar webinar;

  const WebinarLiveScreen({
    super.key,
    required this.webinar,
  });

  @override
  State<WebinarLiveScreen> createState() => _WebinarLiveScreenState();
}

class _WebinarLiveScreenState extends State<WebinarLiveScreen> {
  final controller = Get.find<WebinarsController>();
  final ScrollController _commentsScrollController = ScrollController();

  // Agora Engine & State
  RtcEngine? _engine;
  bool _isJoiningAgora = false;
  bool _isJoined = false;
  int? _remoteUid; // Host / Speaker UID
  bool _isMicOn = false;
  bool _isCameraOn = false;
  bool _isFrontCamera = true;
  String _streamStatusText = "Connecting to live session...";
  bool _joinTokenFailed = false;
  AgoraJoinTokenData? _tokenData;

  @override
  void initState() {
    super.initState();
    controller.liveViewerCount.value = widget.webinar.registeredCount;
    controller.fetchWebinarComments(widget.webinar.id, isRefresh: true);
    controller.isMicOn.value = false;
    controller.isCameraOn.value = false;
    _initAgoraAndJoin();
  }

  Future<void> _initAgoraAndJoin() async {
    if (!mounted) return;
    setState(() {
      _isJoiningAgora = true;
      _joinTokenFailed = false;
      _streamStatusText = "Fetching live stream access...";
    });

    try {
      // 1. Fetch Agora Join Token from backend API: GET /api/webinars/{id}/join-token
      final tokenData = await controller.getWebinarJoinToken(widget.webinar.id);

      if (tokenData == null || (tokenData.token.isEmpty && tokenData.appId.isEmpty)) {
        if (mounted) {
          setState(() {
            _isJoiningAgora = false;
            _joinTokenFailed = true;
            _streamStatusText = tokenData?.message.isNotEmpty == true
                ? tokenData!.message
                : "Webinar meeting has not started yet or access is restricted.";
          });
        }
        return;
      }

      _tokenData = tokenData;

      final appId = tokenData.appId;
      if (appId.isEmpty) {
        if (mounted) {
          setState(() {
            _isJoiningAgora = false;
            _joinTokenFailed = true;
            _streamStatusText = "Agora App ID is missing from server response.";
          });
        }
        return;
      }

      final channelName = tokenData.channel.isNotEmpty
          ? tokenData.channel
          : widget.webinar.agoraChannel;

      if (mounted) {
        setState(() {
          _streamStatusText = "Joining channel: $channelName...";
        });
      }

      // 2. Initialize Agora Engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      // 3. Register Event Handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("[Agora] User joined channel successfully: ${connection.channelId}, localUid: ${connection.localUid}");
            if (mounted) {
              setState(() {
                _isJoined = true;
                _isJoiningAgora = false;
                if (_remoteUid == null) {
                  _streamStatusText = "Waiting for speaker video stream...";
                }
              });
            }
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint("[Agora] Connection state: $state, reason: $reason");
            if (state == ConnectionStateType.connectionStateConnected) {
              if (mounted) {
                setState(() {
                  _isJoined = true;
                  _isJoiningAgora = false;
                  if (_remoteUid == null) {
                    _streamStatusText = "Waiting for speaker video stream...";
                  }
                });
              }
            } else if (state == ConnectionStateType.connectionStateFailed) {
              if (mounted) {
                setState(() {
                  _isJoiningAgora = false;
                  _joinTokenFailed = true;
                  _streamStatusText = "Connection failed: ${reason.name}";
                });
              }
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("[Agora] Remote speaker joined: $remoteUid");
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _isJoined = true;
                _isJoiningAgora = false;
                _streamStatusText = "Live";
              });
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("[Agora] Remote speaker went offline: $remoteUid, reason: $reason");
            if (mounted && _remoteUid == remoteUid) {
              setState(() {
                _remoteUid = null;
                _streamStatusText = "Speaker paused or ended the stream.";
              });
            }
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) async {
            debugPrint("[Agora] Token privilege will expire soon, renewing...");
            final refreshed = await controller.getWebinarJoinToken(widget.webinar.id);
            if (refreshed != null && refreshed.token.isNotEmpty) {
              await _engine?.renewToken(refreshed.token);
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("[Agora Error] $err - $msg");
          },
        ),
      );

      // 4. Enable Audio & Video
      await _engine!.enableVideo();
      await _engine!.enableLocalVideo(false); // Keep local camera hardware off until user turns it on
      await _engine!.enableAudio();
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // 5. Per User Request: User mic is NOT unmuted (user is audience for audio, only listens)
      await _engine!.muteLocalAudioStream(true);

      // Default camera is OFF
      await _engine!.muteLocalVideoStream(true);

      // 6. Join Channel (support both String userAccount and numeric uid)
      final channelMediaOptions = const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: false,
        publishMicrophoneTrack: false, // User mic is always muted
        autoSubscribeAudio: true, // Listen to Host audio
        autoSubscribeVideo: true, // Watch Host video
      );

      if (tokenData.userAccount.isNotEmpty && int.tryParse(tokenData.userAccount) == null) {
        debugPrint("[Agora] Joining with userAccount: ${tokenData.userAccount}");
        await _engine!.joinChannelWithUserAccount(
          token: tokenData.token,
          channelId: channelName,
          userAccount: tokenData.userAccount,
          options: channelMediaOptions,
        );
      } else {
        debugPrint("[Agora] Joining with numeric uid: ${tokenData.uid}");
        await _engine!.joinChannel(
          token: tokenData.token,
          channelId: channelName,
          uid: tokenData.uid,
          options: channelMediaOptions,
        );
      }

      // Safety Timeout: Prevent infinite spinner if host is not yet streaming
      Future.delayed(const Duration(seconds: 12), () {
        if (mounted && !_isJoined && _isJoiningAgora) {
          setState(() {
            _isJoiningAgora = false;
            _joinTokenFailed = true;
            _streamStatusText = "Connecting took too long. Host may still be preparing the live stream.";
          });
        }
      });
    } catch (e) {
      debugPrint("[Agora Init Error] $e");
      if (mounted) {
        setState(() {
          _isJoiningAgora = false;
          _joinTokenFailed = true;
          _streamStatusText = "Failed to connect to live stream: $e";
        });
      }
    }
  }

  Future<void> _toggleMic() async {
    if (_engine == null || !_isJoined) {
      CustomSnackBar.showInfo(message: "Connecting to stream, please wait...");
      return;
    }

    if (!_isMicOn) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        CustomSnackBar.showError(message: "Microphone permission is required to speak.");
        return;
      }
      try {
        await _engine!.muteLocalAudioStream(false);
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(publishMicrophoneTrack: true),
        );
        setState(() {
          _isMicOn = true;
        });
        controller.isMicOn.value = true;
        CustomSnackBar.showInfo(message: "Microphone turned on");
      } catch (e) {
        debugPrint("[Mic On Error] $e");
      }
    } else {
      try {
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(publishMicrophoneTrack: false),
        );
        await _engine!.muteLocalAudioStream(true);
        setState(() {
          _isMicOn = false;
        });
        controller.isMicOn.value = false;
        CustomSnackBar.showInfo(message: "Microphone muted");
      } catch (e) {
        debugPrint("[Mic Off Error] $e");
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_engine == null || !_isJoined) {
      CustomSnackBar.showInfo(message: "Connecting to stream, please wait...");
      return;
    }

    if (!_isCameraOn) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        CustomSnackBar.showError(message: "Camera permission is required to turn on video.");
        return;
      }
      try {
        await _engine!.enableLocalVideo(true);
        await _engine!.muteLocalVideoStream(false);
        await _engine!.startPreview();
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(publishCameraTrack: true),
        );
        setState(() {
          _isCameraOn = true;
        });
        controller.isCameraOn.value = true;
        CustomSnackBar.showInfo(message: "Camera turned on");
      } catch (e) {
        debugPrint("[Camera On Error] $e");
      }
    } else {
      try {
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(publishCameraTrack: false),
        );
        await _engine!.muteLocalVideoStream(true);
        await _engine!.stopPreview();
        await _engine!.enableLocalVideo(false);
        setState(() {
          _isCameraOn = false;
        });
        controller.isCameraOn.value = false;
        CustomSnackBar.showInfo(message: "Camera turned off");
      } catch (e) {
        debugPrint("[Camera Off Error] $e");
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_engine != null && _isCameraOn) {
      HapticFeedback.lightImpact();
      await _engine!.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    }
  }

  Future<void> _leaveAgora() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
      }
    } catch (e) {
      debugPrint("[Agora Leave Error] $e");
    }
  }

  @override
  void dispose() {
    _leaveAgora();
    _commentsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channelName = _tokenData?.channel.isNotEmpty == true
        ? _tokenData!.channel
        : widget.webinar.agoraChannel;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Back button + Title
                  GestureDetector(
                    onTap: () {
                      _leaveAgora();
                      Get.back();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Live Webinar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 🔴 LIVE Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 👥 Viewer Count Badge
                  Obx(() {
                    final count = controller.liveViewerCount.value;
                    if (count <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.person_2_fill, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "$count",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Video Player Area
            AspectRatio(
              aspectRatio: 16 / 9.5,
              child: Stack(
                children: [
                  // 1. Video Render (Host Video or Placeholder/Status)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: _engine != null && _remoteUid != null
                          ? AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: _engine!,
                                canvas: VideoCanvas(uid: _remoteUid!),
                                connection: RtcConnection(channelId: channelName),
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                // Thumbnail / Banner
                                CachedNetworkImage(
                                  imageUrl: widget.webinar.videoThumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: const Color(0xFF1E293B),
                                    child: const Center(
                                      child: Icon(Icons.videocam_rounded, size: 54, color: Colors.white30),
                                    ),
                                  ),
                                ),

                                // Dark overlay
                                Container(
                                  color: Colors.black.withOpacity(0.68),
                                ),

                                // Status text / Connecting indicator
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_isJoiningAgora) ...[
                                          const CupertinoActivityIndicator(color: Colors.white, radius: 13),
                                          const SizedBox(height: 12),
                                        ] else if (_joinTokenFailed) ...[
                                          const Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 30),
                                          const SizedBox(height: 10),
                                        ] else ...[
                                          const Icon(Icons.live_tv_rounded, color: Colors.white70, size: 32),
                                          const SizedBox(height: 10),
                                        ],
                                        Text(
                                          _streamStatusText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (_joinTokenFailed) ...[
                                          const SizedBox(height: 12),
                                          GestureDetector(
                                            onTap: _initAgoraAndJoin,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "Retry Join",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // 2. Speaker Badge at bottom-left of video
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _remoteUid != null ? Icons.mic : Icons.mic_off,
                            color: _remoteUid != null ? const Color(0xFF10B981) : Colors.white60,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${widget.webinar.speaker.name} (Speaker)",
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

                  // 3. Floating Local Camera View (PiP) when Camera is ON
                  if (_isCameraOn && _engine != null)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      width: 96,
                      height: 130,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.5),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: _engine!,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              ),
                              // Switch Camera Button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _switchCamera,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cameraswitch_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ),
                              // "You" label + mic status
                              Positioned(
                                left: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "You",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Icon(
                                        _isMicOn ? Icons.mic : Icons.mic_off,
                                        size: 10,
                                        color: _isMicOn ? const Color(0xFF10B981) : Colors.redAccent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Interactive Controls Bar (Mic, Camera, Flip Camera, Chat, Leave)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Mic Toggle (User can turn Mic ON/OFF)
                  _buildControlButton(
                    icon: _isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                    label: _isMicOn ? "Mic On" : "Mic Off",
                    isActive: _isMicOn,
                    activeColor: const Color(0xFF10B981),
                    onTap: _toggleMic,
                  ),

                  // 2. Camera Toggle (User can turn Camera ON/OFF)
                  _buildControlButton(
                    icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    label: _isCameraOn ? "Camera On" : "Camera Off",
                    isActive: _isCameraOn,
                    activeColor: AppColors.primary,
                    onTap: _toggleCamera,
                  ),

                  // 3. Flip Camera (Active only when camera is ON)
                  if (_isCameraOn)
                    _buildControlButton(
                      icon: Icons.cameraswitch_rounded,
                      label: "Flip",
                      isActive: true,
                      activeColor: const Color(0xFF3B82F6),
                      onTap: _switchCamera,
                    ),

                  // 4. Chat Button
                  _buildControlButton(
                    icon: CupertinoIcons.chat_bubble_2_fill,
                    label: "Chat",
                    isActive: true,
                    activeColor: AppColors.primary,
                    onTap: () {
                      if (_commentsScrollController.hasClients) {
                        _commentsScrollController.animateTo(
                          _commentsScrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),

                  // 5. Leave Button
                  _buildControlButton(
                    icon: Icons.call_end_rounded,
                    label: "Leave",
                    isActive: false,
                    isDestructive: true,
                    onTap: () {
                      _leaveAgora();
                      Get.back();
                      CustomSnackBar.showInfo(message: "Left live webinar");
                    },
                  ),
                ],
              ),
            ),

            // Lower Section: Live Chat Messages List (with Pull to Refresh)
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Header: Live Chat title + count + refresh button
                    Obx(() {
                      final chatCount = controller.chatMessages.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.chat_bubble_2_fill,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Live Chat",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (chatCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$chatCount",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            GestureDetector(
                              onTap: () => controller.fetchWebinarComments(widget.webinar.id, isRefresh: true),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (controller.isLoadingComments.value)
                                    const SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: CupertinoActivityIndicator(radius: 6),
                                    )
                                  else
                                    Icon(Icons.refresh_rounded, size: 15, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Refresh",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Messages List with Pull-To-Refresh
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: Colors.white,
                        onRefresh: () async {
                          await controller.fetchWebinarComments(widget.webinar.id, isRefresh: true);
                        },
                        child: Obx(() {
                          if (controller.isLoadingComments.value && controller.chatMessages.isEmpty) {
                            return const Center(child: CupertinoActivityIndicator());
                          }

                          final list = controller.chatMessages;

                          if (list.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF1F5F9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              size: 32,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "No comments yet",
                                            style: TextStyle(
                                              color: Color(0xFF475569),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Be the first to comment in this session.\nPull down to refresh messages.",
                                            style: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          // Display top to bottom
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_commentsScrollController.hasClients) {
                              _commentsScrollController.animateTo(
                                _commentsScrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          });

                          return ListView.separated(
                            controller: _commentsScrollController,
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            reverse: false,
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final msg = list[index];
                              return _buildMessageItem(msg);
                            },
                          );
                        }),
                      ),
                    ),

                    // Bottom Chat Input Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextField(
                                  controller: controller.chatInputController,
                                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                                  decoration: InputDecoration(
                                    hintText: "Say something...",
                                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                                  ),
                                  onSubmitted: (text) {
                                    if (text.trim().isNotEmpty) {
                                      controller.sendLiveMessage(
                                        widget.webinar.id,
                                        text,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Obx(() {
                              final isPosting = controller.isPostingComment.value;
                              return GestureDetector(
                                onTap: isPosting
                                    ? null
                                    : () {
                                        controller.sendLiveMessage(
                                          widget.webinar.id,
                                          controller.chatInputController.text,
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isPosting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CupertinoActivityIndicator(
                                            color: Colors.white,
                                            radius: 7,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? activeColor,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final bgColor = isDestructive
        ? const Color(0xFFEF4444)
        : (isActive ? (activeColor ?? AppColors.primary) : Colors.white.withOpacity(0.12));

    final labelColor = isDestructive ? const Color(0xFFF87171) : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMessageItem(WebinarChatMessage msg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: msg.userAvatar.isNotEmpty ? NetworkImage(msg.userAvatar) : null,
          child: msg.userAvatar.isEmpty
              ? Text(
                  msg.userName.isNotEmpty ? msg.userName[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (msg.isQuestion) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Q",
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    msg.time,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                msg.message,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
