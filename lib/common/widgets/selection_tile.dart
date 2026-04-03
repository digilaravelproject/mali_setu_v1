import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? icon;
  final String placeholder;
  final String? errorText;
  final bool isRequired;

  const SelectionTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.placeholder = "Select",
    this.errorText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasValue = value != null && value!.isNotEmpty;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final displayPlaceholder = placeholder == "Select" ? "Select $label" : placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium,
            ),
            if (isRequired)
              Text(
                ' *',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError 
                    ? Colors.red.shade400 
                    : hasValue 
                        ? theme.primaryColor 
                        : theme.dividerColor,
                width: hasValue || hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: hasError ? Colors.red.shade400 : (hasValue ? theme.primaryColor : theme.iconTheme.color)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    hasValue ? value! : displayPlaceholder,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasValue ? theme.textTheme.bodyLarge?.color : theme.hintColor,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: hasError ? Colors.red.shade400 : (hasValue ? theme.primaryColor : theme.hintColor),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }
}
