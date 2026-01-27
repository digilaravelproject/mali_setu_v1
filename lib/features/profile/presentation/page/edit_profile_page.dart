import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(AppAssets.backArrow),
          style: IconButton.styleFrom(side: BorderSide.none),
        ),
        title: Text("Edit Profile", style: context.textTheme.headlineSmall),
      ),
      body: Column(children: []),
    );
  }
}
