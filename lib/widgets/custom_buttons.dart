import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final Widget? leading;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 46, // Slightly more compact
    this.borderRadius = 12, // More squared consistent look
    this.isLoading = false,
    this.width,
    this.icon,
    this.leading,
    this.fontSize = 15, // Standardized size
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isLoading ? 0 : 8,
            horizontal: 16,
          ),
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: Builder(
          builder: (_) {
            if (isLoading) {
              return SizedBox.square(
                dimension: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [

                  // Text(
                  //   title,
                  //   style: TextStyle(
                  //     color: textColor ?? context.theme.colorScheme.onPrimary,
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  //if (icon != null) ...[

                  if (leading != null) ...[
                    leading!,
                  ] else if (icon != null) ...[

                    Icon(
                      icon,
                      size: 18,
                      color: textColor ?? context.theme.colorScheme.onPrimary,
                    ),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor ?? context.theme.colorScheme.onPrimary,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
            );
            }
          },
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final Widget? leading;
  final double borderWidth;
  final double fontSize;

  const CustomOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.height = 46,
    this.borderRadius = 12,
    this.isLoading = false,
    this.width,
    this.icon,
    this.leading,
    this.borderWidth = 1.2,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = textColor ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isLoading ? 0 : 8,
            horizontal: 16,
          ),
          side: BorderSide(
            color: borderColor ?? effectiveColor,
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: effectiveColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (leading != null) ...[
                    leading!,
                  ] else if (icon != null) ...[
                    Icon(icon, color: effectiveColor, size: 18),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: effectiveColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomTextButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor ?? Theme.of(context).primaryColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
