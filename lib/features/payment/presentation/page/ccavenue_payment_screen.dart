import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';

class CCAvenuePaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String encRequest;
  final String accessCode;
  final String type;

  const CCAvenuePaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.encRequest,
    required this.accessCode,
    required this.type,
  }) : super(key: key);

  @override
  State<CCAvenuePaymentScreen> createState() => _CCAvenuePaymentScreenState();
}

class _CCAvenuePaymentScreenState extends State<CCAvenuePaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkUrlForStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint("Could not launch $url");
                }
              } catch (e) {
                debugPrint("Error launching $url: $e");
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadPaymentForm();
  }

  void _loadPaymentForm() {
    // CCAvenue expects a POST request with encRequest and access_code
    // Using loadRequest natively handles POST without HTML/CORS issues
    final String postData = 'encRequest=${Uri.encodeComponent(widget.encRequest)}&access_code=${Uri.encodeComponent(widget.accessCode)}';
    
    _controller.loadRequest(
      Uri.parse(widget.paymentUrl),
      method: LoadRequestMethod.post,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: Uint8List.fromList(utf8.encode(postData)),
    );
  }

  void _checkUrlForStatus(String url) async {
    final lowerUrl = url.toLowerCase();
    // Assuming backend redirects to success/failure URL or the response comes back from ccavenue
    if (lowerUrl.contains('payment-success') || lowerUrl.contains('success')) {
      CustomSnackBar.showSuccess(message: 'Payment Successful');
      if (Get.isRegistered<AuthService>()) {
        Get.find<AuthService>().refreshProfile();
      }
      Get.back(result: true);
    } else if (lowerUrl.contains('payment-failure') || lowerUrl.contains('cancel') || lowerUrl.contains('failed')) {
      CustomSnackBar.showError(message: 'Payment Failed or Cancelled');
      Get.back(result: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
