import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/styles/app_colors.dart';

class FirebaseRecaptchaHelper {
  static const String _firebaseApiKey = 'AIzaSyC5OtmhldQJOc6yAFLR5JMpT4yy6kDdvQc';
  static const String _firebaseAuthDomain = 'malisetu-be0df.firebaseapp.com';
  static const String _firebaseProjectId = 'malisetu-be0df';

  /// Obtains a real Firebase reCAPTCHA token using an invisible/dialog WebView
  static Future<String?> getRecaptchaToken(BuildContext context) async {
    final completer = Completer<String?>();

    Get.dialog(
      _RecaptchaDialog(
        apiKey: _firebaseApiKey,
        authDomain: _firebaseAuthDomain,
        projectId: _firebaseProjectId,
        onTokenReceived: (token) {
          if (!completer.isCompleted) {
            completer.complete(token);
          }
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        },
        onError: (err) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        },
      ),
      barrierDismissible: false,
    );

    // Timeout safety of 45 seconds
    return completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        return null;
      },
    );
  }
}

class _RecaptchaDialog extends StatefulWidget {
  final String apiKey;
  final String authDomain;
  final String projectId;
  final ValueChanged<String> onTokenReceived;
  final ValueChanged<String> onError;

  const _RecaptchaDialog({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.onTokenReceived,
    required this.onError,
  });

  @override
  State<_RecaptchaDialog> createState() => _RecaptchaDialogState();
}

class _RecaptchaDialogState extends State<_RecaptchaDialog> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'RecaptchaChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final msg = message.message;
          if (msg.startsWith('ERROR:')) {
            widget.onError(msg);
          } else if (msg.isNotEmpty) {
            widget.onTokenReceived(msg);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            widget.onError(error.description);
          },
        ),
      )
      ..loadHtmlString(
        _buildHtmlContent(),
        baseUrl: 'https://${widget.authDomain}',
      );
  }

  String _buildHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
      background: transparent;
      overflow: hidden;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    #recaptcha-container {
      display: flex;
      justify-content: center;
      align-items: center;
    }
  </style>
</head>
<body>
  <div id="recaptcha-container"></div>
  <script>
    try {
      const firebaseConfig = {
        apiKey: "${widget.apiKey}",
        authDomain: "${widget.authDomain}",
        projectId: "${widget.projectId}"
      };
      firebase.initializeApp(firebaseConfig);

      window.recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', {
        'size': 'invisible',
        'callback': function(response) {
          if (window.RecaptchaChannel) {
            window.RecaptchaChannel.postMessage(response);
          }
        },
        'expired-callback': function() {
          if (window.RecaptchaChannel) {
            window.RecaptchaChannel.postMessage('ERROR:EXPIRED');
          }
        }
      });

      window.recaptchaVerifier.render().then(function(widgetId) {
        window.recaptchaVerifier.verify().then(function(token) {
          if (window.RecaptchaChannel) {
            window.RecaptchaChannel.postMessage(token);
          }
        }).catch(function(err) {
          if (window.RecaptchaChannel) {
            window.RecaptchaChannel.postMessage('ERROR:' + (err && (err.message || err.toString())));
          }
        });
      }).catch(function(err) {
        if (window.RecaptchaChannel) {
          window.RecaptchaChannel.postMessage('ERROR:' + (err && (err.message || err.toString())));
        }
      });
    } catch (e) {
      if (window.RecaptchaChannel) {
        window.RecaptchaChannel.postMessage('ERROR:' + e.toString());
      }
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        height: 380,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Security Verification',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.onError('Verification cancelled by user');
                  },
                  child: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Verifying security with Google reCAPTCHA...',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const Divider(height: 20, thickness: 0.8),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: WebViewWidget(controller: _webViewController),
                  ),
                  if (_isLoading)
                    const Center(
                      child: CupertinoActivityIndicator(radius: 12),
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

