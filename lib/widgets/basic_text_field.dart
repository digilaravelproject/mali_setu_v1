import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';



class AppInputTextField extends StatelessWidget {
  final String label;
  final TextInputType textInputType;
  final IconData? iconData;
  final IconData? endIcon;
  final bool showLabel;
  final bool isObscure;
  final Widget? suffixWidget;
  final GestureTapCallback? onEndIconTap;
  final TextEditingController? controller;
  final List<String>? hint;
  final String? hintText;
  final bool enable;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final GestureTapCallback? onTap;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? prefixIcon;



  /// 🔽 Dropdown related
  final bool isDropdown;
  final List<String>? dropdownItems;
  final ValueChanged<String>? onDropdownChanged;
  final int? maxLines;
  final bool? readOnly;
  final Color? textColor;
  final VoidCallback? onOtherSelected;
  final bool isRequired;
  final double topPadding;
  final String? errorText;

  const AppInputTextField({
    super.key,
    this.label = "Input Label",
    this.iconData,
    this.controller,
    this.endIcon,
    this.hint,
    this.onEndIconTap,
    this.validator,
    this.onChanged,
    this.hintText,
    this.inputFormatters,
    this.showLabel = true,
    this.isObscure = false,
    this.enable = true,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.onTap,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.suffixWidget,
    this.prefix,
    this.prefixIcon,
    this.readOnly,
    this.textColor,
    this.onOtherSelected,
    this.isRequired = false,
    this.topPadding = 2,
    /// Dropdown
    this.isDropdown = false,
    this.dropdownItems,
    this.onDropdownChanged,
    this.errorText,
  }) : assert(
         isDropdown == false || dropdownItems != null,
         'dropdownItems must be provided when isDropdown is true',
       );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (showLabel) ...[
          SizedBox(height: topPadding),
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
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
        ],

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enable,
          readOnly: readOnly ?? isDropdown || onTap != null,
         // readOnly: isDropdown || onTap != null, // dropdown ya custom onTap
          canRequestFocus: !isDropdown && enable,
          obscureText: isObscure,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines ?? 1,
          autofillHints: hint,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator ??
              (isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter ${label.toLowerCase()}";
                      }
                      return null;
                    }
                  : null),
          inputFormatters: isDropdown ? null : inputFormatters,
          onChanged: isDropdown ? null : onChanged,
          style: textColor != null ? TextStyle(color: textColor) : null,

          /// 🔽 Handle tap for dropdown
          //onTap: isDropdown ? () => _showDropdown(context) : null,
          onTap: onTap ?? (isDropdown ? () => _showDropdown(context) : null),


          decoration: InputDecoration(
            hintText: hintText ?? " Enter Your ${label[0].toUpperCase()}${label.substring(1).toLowerCase()}",
            hintStyle: context.textTheme.bodyMedium,
            errorText: errorText,
            
            // Show red border when errorText is present
            enabledBorder: errorText != null && errorText!.isNotEmpty
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                  )
                : theme.inputDecorationTheme.enabledBorder,
            focusedBorder: errorText != null && errorText!.isNotEmpty
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                  )
                : theme.inputDecorationTheme.focusedBorder,

            prefixIcon: prefixIcon ?? (iconData == null ? null : Icon(iconData, size: 20)),
            prefix: prefix,

            suffixIcon: suffixWidget ??
                (isDropdown
                    ? Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.primaryColor,
                )
                    : endIcon == null
                    ? null
                    : IconButton(
                  onPressed: onEndIconTap,
                  style: IconButton.styleFrom(side: BorderSide.none),
                  icon: Icon(endIcon, color: theme.primaryColor),
                )),
          ),
        ),
      ],
    );
  }

  /// 🔽 Dropdown bottom sheet
  void _showDropdown(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (dropdownItems == null || dropdownItems!.isEmpty) {
      CustomSnackBar.showInfo(message: "No options available");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final List<String> items = dropdownItems!;
        List<String> filteredItems = List.from(items);
        final bool showSearch = items.length > 5;

        return StatefulBuilder(
          builder: (context, setState) {
            // Include keyboard padding to push content up when search is active
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    
                    // Premium Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (label != null)
                            Expanded(
                              child: Text(
                                "Select $label",
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: const Icon(Icons.close, color: Colors.grey, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                    
                    // Search Bar
                    if (showSearch)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextField(
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "Search items...",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(CupertinoIcons.search, size: 20, color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: context.theme.primaryColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredItems = items
                                  .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ),

                    if (!showSearch) const SizedBox(height: 8),

                    Flexible(
                      child: filteredItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.search, size: 54, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text("No results found", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                              itemCount: filteredItems.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = controller?.text == item;
                                
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (item == 'other'.tr && onOtherSelected != null) {
                                        onOtherSelected!.call();
                                      } else {
                                        controller?.text = item;
                                        onDropdownChanged?.call(item);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: context.textTheme.titleMedium?.copyWith(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (isSelected) 
                                            Icon(Icons.radio_button_checked, color: context.theme.primaryColor, size: 24)
                                          else
                                            Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}


class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        color: context.theme.primaryColor,
      ),
    ).marginOnly(bottom: 4);
  }
}

class SingleDropdown extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final IconData? icon;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hint;
  final List<String> items;
  final bool isRequired;
  final String? errorText;

  const SingleDropdown({
    super.key,
    required this.controller,
    required this.items,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.icon,
    this.hint,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputTextField(
      controller: controller,
      label: label ?? "No Label",
      isRequired: isRequired,
      isDropdown: true,
      dropdownItems: items,
      iconData: prefixIcon != null ? prefixIcon : null, // prefix icon
      endIcon: suffixIcon != null ? suffixIcon : null,
      errorText: errorText,
    );
  }
}

class BirthdayDateField extends StatefulWidget {
  const BirthdayDateField({super.key});

  @override
  State<BirthdayDateField> createState() => _BirthdayDateFieldState();
}

class _BirthdayDateFieldState extends State<BirthdayDateField> {
  final TextEditingController dayCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController();

  final FocusNode dayFocus = FocusNode();
  final FocusNode monthFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();

  @override
  void dispose() {
    dayCtrl.dispose();
    monthCtrl.dispose();
    yearCtrl.dispose();
    dayFocus.dispose();
    monthFocus.dispose();
    yearFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: dayCtrl,
            focusNode: dayFocus,
            textAlign: TextAlign.start,
            style: context.textTheme.headlineSmall,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: InputDecoration(
              filled: false,
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'DD',
              hintStyle: context.textTheme.headlineSmall?.copyWith(
                color: context.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            onChanged: (value) {
              if (value.length == 2) monthFocus.requestFocus();
            },
          ),
        ),

        Container(height: 35, width: 1, color: context.theme.dividerColor),

        // --------------------- MM ---------------------
        Expanded(
          child: TextField(
            controller: monthCtrl,
            focusNode: monthFocus,
            textAlign: TextAlign.start,
            style: context.textTheme.headlineSmall,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: InputDecoration(
              filled: false,
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'MM',
              hintStyle: context.textTheme.headlineSmall?.copyWith(
                color: context.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            onChanged: (value) {
              if (value.length == 2) {
                yearFocus.requestFocus();
              } else if (value.isEmpty) {
                dayFocus.requestFocus();
              }
            },
          ),
        ),

        Container(height: 35, width: 1, color: context.theme.dividerColor),

        // --------------------- YYYY ---------------------
        Expanded(
          child: TextField(
            controller: yearCtrl,
            focusNode: yearFocus,
            textAlign: TextAlign.start,
            style: context.textTheme.headlineSmall,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              filled: false,
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'YYYY',
              hintStyle: context.textTheme.headlineSmall?.copyWith(
                color: context.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                monthFocus.requestFocus();
              }
            },
          ),
        ),
      ],
    );
  }
}
