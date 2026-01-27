/*
part of 'register_base_page.dart';

class RegStep2Birthday extends StatefulWidget {
  const RegStep2Birthday({super.key});

  @override
  State<RegStep2Birthday> createState() => _RegStep2BirthdayState();
}

class _RegStep2BirthdayState extends State<RegStep2Birthday> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Text(
                "Let's celebrate your 🎂",
                style: context.textTheme.headlineMedium,
              ),
            ],
          ),
          Text(
            "Please tells your birthday date your profile does not display your birthdate only your age ",
            style: context.textTheme.bodyMedium,
          ).marginOnly(top: 8),

          Center(
            child: CustomImageView(
              imagePath: AppAssets.cake,
              width: 100,
              height: 100,
            ),
          ).marginSymmetric(vertical: 16),

          BirthdayDateField(),
        ],
      ),
    );
  }
}
*/
