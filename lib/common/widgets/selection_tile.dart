import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? icon;
  final String placeholder;

  const SelectionTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.placeholder = "Select",
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium,
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
                color: hasValue ? theme.primaryColor : theme.dividerColor,
                width: hasValue ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: hasValue ? theme.primaryColor : theme.iconTheme.color),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    hasValue ? value! : placeholder,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasValue ? theme.textTheme.bodyLarge?.color : theme.hintColor,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: hasValue ? theme.primaryColor : theme.hintColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
