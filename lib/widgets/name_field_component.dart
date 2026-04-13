import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/name_components.dart';
import '../utils/name_combiner.dart';
import '../utils/name_parser.dart';
import 'basic_text_field.dart';

/// Reusable widget component for name input with Title, First Name, and Last Name fields
class NameFieldComponent extends StatefulWidget {
  final String? initialName;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  // Optional external controllers — if provided, widget uses these instead of creating its own
  final TextEditingController? externalTitleCtrl;
  final TextEditingController? externalFirstNameCtrl;
  final TextEditingController? externalLastNameCtrl;
  // Optional custom title list — defaults to full list if not provided
  final List<String>? titleItems;

  const NameFieldComponent({
    super.key,
    this.initialName,
    this.isRequired = false,
    this.onChanged,
    this.externalTitleCtrl,
    this.externalFirstNameCtrl,
    this.externalLastNameCtrl,
    this.titleItems,
  });

  @override
  State<NameFieldComponent> createState() => NameFieldComponentState();
}

class NameFieldComponentState extends State<NameFieldComponent> {
  late TextEditingController titleCtrl;
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  bool _usingExternalControllers = false;
  final GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.externalTitleCtrl != null) {
      // Use external controllers — don't create or dispose them
      _usingExternalControllers = true;
      titleCtrl = widget.externalTitleCtrl!;
      firstNameCtrl = widget.externalFirstNameCtrl!;
      lastNameCtrl = widget.externalLastNameCtrl!;
    } else {
      // Create own controllers from initialName
      final components = widget.initialName != null && widget.initialName!.isNotEmpty
          ? NameParser.parse(widget.initialName!)
          : const NameComponents();
      titleCtrl = TextEditingController(text: components.title);
      firstNameCtrl = TextEditingController(text: components.firstName);
      lastNameCtrl = TextEditingController(text: components.lastName);
    }

    titleCtrl.addListener(_notifyChange);
    firstNameCtrl.addListener(_notifyChange);
    lastNameCtrl.addListener(_notifyChange);
  }

  void _notifyChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(getCombinedName());
    }
  }

  @override
  void dispose() {
    titleCtrl.removeListener(_notifyChange);
    firstNameCtrl.removeListener(_notifyChange);
    lastNameCtrl.removeListener(_notifyChange);
    if (!_usingExternalControllers) {
      titleCtrl.dispose();
      firstNameCtrl.dispose();
      lastNameCtrl.dispose();
    }
    super.dispose();
  }

  /// Returns the combined name string in format "Title FirstName LastName"
  String getCombinedName() {
    return NameCombiner.combine(NameComponents(
      title: titleCtrl.text,
      firstName: firstNameCtrl.text,
      lastName: lastNameCtrl.text,
    ));
  }

  /// Validates that title and first name are not empty (if required)
  /// Also triggers the inner Form to display inline error messages.
  String? validate() {
    if (widget.isRequired) {
      // This triggers the visual error display on each field
      final isFormValid = nameFormKey.currentState?.validate() ?? false;
      if (!isFormValid) {
        // Trigger rebuild to sync error display
        if (mounted) setState(() {});

        if (titleCtrl.text.trim().isEmpty) return 'Please select title';
        if (firstNameCtrl.text.trim().isEmpty) return 'first_name_required'.tr;
        if (lastNameCtrl.text.trim().isEmpty) return 'last_name_required'.tr;
        return "Please fill name details";
      }
    }
    // Clear display state if valid
    if (mounted) setState(() {});
    return null;
  }

  /// Programmatically set name fields from a full name string
  void setName(String fullName) {
    final components = NameParser.parse(fullName);
    titleCtrl.text = components.title ?? '';
    firstNameCtrl.text = components.firstName ?? '';
    lastNameCtrl.text = components.lastName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: nameFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title dropdown

          Row(
            children: [
              Expanded(
                child:  AppInputTextField(
                  label: 'title'.tr,
                  controller: titleCtrl,
                  isRequired: widget.isRequired,
                  isDropdown: true,
                  topPadding: 0,
                  validator: (value) {
                    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                      return 'title_required'.tr;
                    }
                    return null;
                  },
                  dropdownItems: widget.titleItems ?? [
                    'mr'.tr,
                    'mrs'.tr,
                    'ms'.tr,
                    'dr'.tr,
                    'prof'.tr,
                  ],
                  onDropdownChanged: (value) {
                    titleCtrl.text = value;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppInputTextField(
                  label: 'first_name'.tr,
                  controller: firstNameCtrl,
                  isRequired: widget.isRequired,
                  textInputType: TextInputType.name,
                  topPadding: 0,
                  validator: (value) {
                    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                      return 'first_name_required'.tr;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInputTextField(
                  label: 'middle_name'.tr,
                  controller: firstNameCtrl,
                  isRequired: widget.isRequired,
                  textInputType: TextInputType.name,
                  topPadding: 0,
                  validator: (value) {
                    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                      return 'first_name_required'.tr;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppInputTextField(
                  label: 'last_name'.tr,
                  controller: lastNameCtrl,
                  isRequired: widget.isRequired,
                  textInputType: TextInputType.name,
                  topPadding: 0,
                  validator: (value) {
                    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                      return 'last_name_required'.tr;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
