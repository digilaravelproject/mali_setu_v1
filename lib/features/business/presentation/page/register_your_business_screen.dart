import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import '../../../../core/helper/form_validator.dart';
import '../../../../widgets/basic_text_field.dart';
import '../../../../widgets/custom_buttons.dart';
import '../controller/reg_business_controller.dart';

class RegYourBusinessScreen extends GetWidget<RegBusinessController>{
  const RegYourBusinessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
        ),
        title: Text("Register Business", style: context.textTheme.titleMedium),
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle("Business Information"),
              AppInputTextField(
                label: "Business Name",
                controller: controller.bNameCtrl,
                textInputType: TextInputType.text,
                iconData: Icons.business_outlined,
                validator: FormValidator.name,
              ),

              SingleDropdown(
                controller: controller.bTypeCtrl,
                label: "Business Type",
                prefixIcon: Icons.category_rounded,
                items: controller.businessTypes,
              ),

              SingleDropdown(
                controller: controller.bCategoryCtrl,
                label: "Business Category",
                prefixIcon: Icons.category_rounded,
                items: controller.businessCategories,
              ),

              AppInputTextField(
                label: "Business Description",
                textInputType: TextInputType.text,
                maxLines: 4,
                hintText: "Describe your business, products",
                validator: FormValidator.name,
              ),
              SizedBox(height: 16,),

              const SectionTitle("Contact Information"),
              AppInputTextField(
                label: "Contact Number ",
                iconData: CupertinoIcons.phone,
                textInputType: TextInputType.phone,
                controller: controller.phoneCtrl,
                hint: const [AutofillHints.telephoneNumber],
              ),
              AppInputTextField(
                label: "Email ",
                iconData: CupertinoIcons.mail_solid,
                textInputType: TextInputType.emailAddress,
                controller: controller.emailCtrl,
                hint: const [AutofillHints.email],
                validator: FormValidator.email,
              ),
              AppInputTextField(
                label: "Website ",
                iconData: Icons.language_rounded,
                textInputType: TextInputType.webSearch,
                controller: controller.websiteCtrl,
              ),

              const SizedBox(height: 30),

              CustomButton(title: "Register Business", onPressed: (){

              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
