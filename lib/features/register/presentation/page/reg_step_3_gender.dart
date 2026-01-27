/*
part of 'register_base_page.dart';

class RegStep3Gender extends GetWidget<RegisterController> {
  const RegStep3Gender({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder(
        valueListenable: controller.selectedGender,
        builder: (context, selected, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  "Let’s get to know you better 💕",
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                /// DESCRIPTION
                Text(
                  "Choose your gender so we can match you with the right date. "
                  "Your selection stays private and helps us personalize your experience.",
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                Obx(() {
                  return Column(
                    spacing: 16,
                    children: controller.genderList.map((item) {
                      return _genderButton(
                        context: context,
                        label: item.gender,
                        selected: selected == item.value,
                        showArrow: item.value == "other",
                        arrowUp:
                            item.value == "other" && controller.showMore.value,
                        onTap: () {
                          controller.selectedGender.value = item.value;
                          if (item.value == "other") {
                            controller.showMore.value = true;
                          } else {
                            controller.showMore.value = false;
                          }
                        },
                      );
                    }).toList(),
                  );
                }),

                if (controller.showMore.value) ...[
                  SizedBox(height: 16),
                  ...controller.moreGenderList.map(
                    (item) => _moreItem(
                      context: context,
                      title: item.gender,
                      subtitle: "",
                      selected: item.value == selected,
                      onTap: () {
                        controller.selectedGender.value = item.value;
                      },
                    ).marginOnly(bottom: 12),
                  ),
                  SizedBox(height: Get.height * 0.1),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// MAIN BUTTON STYLE (MAN / WOMAN / MORE)
  Widget _genderButton({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool showArrow = false,
    bool arrowUp = false,
  }) {
    final primary = Theme.of(context).primaryColor;
    final border = Theme.of(context).dividerColor;

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? Colors.transparent : border,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : context.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Icon(
                arrowUp ? Icons.keyboard_arrow_up : Icons.chevron_right,
                color: selected
                    ? Colors.white
                    : context.textTheme.bodyLarge?.color,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// EXPANDED “MORE LIST” ITEM
  Widget _moreItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? context.theme.primaryColor
                : context.theme.dividerColor,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: context.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
