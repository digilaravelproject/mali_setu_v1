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

  const NameFieldComponent({
    super.key,
    this.initialName,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  State<NameFieldComponent> createState() => NameFieldComponentState();
}

class NameFieldComponentState extends State<NameFieldComponent> {
  late TextEditingController titleCtrl;
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;

  @override
  void initState() {
    super.initState();
    
    // Parse initial name if provided
    final components = widget.initialName != null && widget.initialName!.isNotEmpty
        ? NameParser.parse(widget.initialName!)
        : const NameComponents();

    titleCtrl = TextEditingController(text: components.title);
    firstNameCtrl = TextEditingController(text: components.firstName);
    lastNameCtrl = TextEditingController(text: components.lastName);

    // Add listeners to notify parent of changes
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
    titleCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
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
  String? validate() {
    if (widget.isRequired) {
      if (titleCtrl.text.trim().isEmpty) {
        return 'Please select title';
      }
      if (firstNameCtrl.text.trim().isEmpty) {
        return 'first_name_required'.tr;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title dropdown
        AppInputTextField(
          label: 'title'.tr,
          controller: titleCtrl,
          isRequired: widget.isRequired,
          isDropdown: true,
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'title_required'.tr;
            }
            return null;
          },
          dropdownItems: [
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
        const SizedBox(height: 12),
        
        // First Name field
        AppInputTextField(
          label: 'first_name'.tr,
          controller: firstNameCtrl,
          isRequired: widget.isRequired,
          textInputType: TextInputType.name,
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'first_name_required'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Last Name field
        AppInputTextField(
          label: 'last_name'.tr,
          controller: lastNameCtrl,
          isRequired: widget.isRequired,
          textInputType: TextInputType.name,
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'last_name_required'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }
}
