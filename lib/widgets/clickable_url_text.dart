import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that parses text and renders any web URLs as clickable links,
/// while rendering normal text with standard styling.
class ClickableUrlText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final void Function(String url)? onLinkTap;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ClickableUrlText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.onLinkTap,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  /// Helper to launch URLs using url_launcher
  static Future<void> launchWebUrl(String url) async {
    try {
      String formattedUrl = url.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final Uri? uri = Uri.tryParse(formattedUrl);
      if (uri != null) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          await launchUrl(uri);
        }
      }
    } catch (e) {
      debugPrint('Error launching URL ($url): $e');
    }
  }

  @override
  State<ClickableUrlText> createState() => _ClickableUrlTextState();
}

class _ClickableUrlTextState extends State<ClickableUrlText> {
  final List<TapGestureRecognizer> _recognizers = [];

  static final RegExp _urlRegex = RegExp(
    r'(https?:\/\/[^\s]+|www\.[^\s]+)',
    caseSensitive: false,
  );

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final defaultStyle = widget.style ??
        TextStyle(
          color: Colors.grey[800],
          height: 1.65,
          fontSize: 14,
        );

    final defaultLinkStyle = widget.linkStyle ??
        defaultStyle.copyWith(
          color: const Color(0xFF1976D2),
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        );

    final text = widget.text;
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final matches = _urlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // 1. Text before this URL match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      String rawUrl = match.group(0) ?? '';
      String cleanUrl = rawUrl;
      String trailingPunctuation = '';

      // Clean trailing punctuation like dots, commas, closing brackets if not balanced
      while (cleanUrl.isNotEmpty &&
          (cleanUrl.endsWith('.') ||
              cleanUrl.endsWith(',') ||
              cleanUrl.endsWith(';') ||
              cleanUrl.endsWith('!') ||
              cleanUrl.endsWith('?') ||
              cleanUrl.endsWith('>') ||
              cleanUrl.endsWith('"') ||
              cleanUrl.endsWith("'") ||
              cleanUrl.endsWith(')'))) {
        if (cleanUrl.endsWith(')') &&
            '('.allMatches(cleanUrl).length >=
                ')'.allMatches(cleanUrl).length) {
          break;
        }
        trailingPunctuation =
            cleanUrl[cleanUrl.length - 1] + trailingPunctuation;
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }

      final recognizer = TapGestureRecognizer()
        ..onTap = () {
          if (widget.onLinkTap != null) {
            widget.onLinkTap!(cleanUrl);
          } else {
            ClickableUrlText.launchWebUrl(cleanUrl);
          }
        };
      _recognizers.add(recognizer);

      // 2. Clickable link TextSpan
      spans.add(
        TextSpan(
          text: cleanUrl,
          style: defaultLinkStyle,
          recognizer: recognizer,
        ),
      );

      // 3. Trailing punctuation, if any, rendered as normal text
      if (trailingPunctuation.isNotEmpty) {
        spans.add(
          TextSpan(
            text: trailingPunctuation,
            style: defaultStyle,
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    // 4. Remaining text after the last URL match
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: defaultStyle,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
