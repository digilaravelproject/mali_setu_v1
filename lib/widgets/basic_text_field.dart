import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
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



  /// 🔽 Dropdown related
  final bool isDropdown;
  final List<String>? dropdownItems;
  final ValueChanged<String>? onDropdownChanged;
  final int? maxLines;
  final bool? readOnly;
  final Color? textColor;
  final VoidCallback? onOtherSelected;
  final bool isRequired;

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
    this.readOnly,
    this.textColor,
    this.onOtherSelected,
    this.isRequired = false,
    /// Dropdown
    this.isDropdown = false,
    this.dropdownItems,
    this.onDropdownChanged,
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
          const SizedBox(height: 8),
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
          validator: validator,
          inputFormatters: isDropdown ? null : inputFormatters,
          onChanged: isDropdown ? null : onChanged,
          style: textColor != null ? TextStyle(color: textColor) : null,

          /// 🔽 Handle tap for dropdown
          //onTap: isDropdown ? () => _showDropdown(context) : null,
          onTap: onTap ?? (isDropdown ? () => _showDropdown(context) : null),


          decoration: InputDecoration(
            hintText: hintText ?? " Enter Your ${label[0].toUpperCase()}${label.substring(1).toLowerCase()}",
            hintStyle: context.textTheme.bodyMedium,

            prefixIcon: iconData == null ? null : Icon(iconData, size: 20),

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

            // suffixIcon: isDropdown
            //     ? Icon(
            //         Icons.keyboard_arrow_down_rounded,
            //         color: theme.primaryColor,
            //       )
            //     : endIcon == null
            //     ? null
            //     : IconButton(
            //         onPressed: onEndIconTap,
            //         style: IconButton.styleFrom(side: BorderSide.none),
            //         icon: Icon(endIcon, color: theme.primaryColor),
            //       ),
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

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: context.theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "Search...",
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            fillColor: (Colors.grey[50] ?? Colors.white).withValues(alpha: 0.5),
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

                      Expanded(
                        child: filteredItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
                                    const SizedBox(height: 12),
                                    Text("No results found", style: TextStyle(color: Colors.grey[500])),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                itemCount: filteredItems.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  final isSelected = controller?.text == item;
                                  
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    title: Text(
                                      item,
                                      style: context.textTheme.bodyLarge?.copyWith(
                                        color: isSelected ? context.theme.primaryColor : null,
                                        fontWeight: isSelected ? FontWeight.w600 : null,
                                      ),
                                    ),
                                    trailing: isSelected 
                                      ? Icon(Icons.check_circle, color: context.theme.primaryColor, size: 20)
                                      : null,
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (item == 'other'.tr && onOtherSelected != null) {
                                        onOtherSelected!.call();
                                      } else {
                                        controller?.text = item;
                                        onDropdownChanged?.call(item);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              }
            );
          },
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
