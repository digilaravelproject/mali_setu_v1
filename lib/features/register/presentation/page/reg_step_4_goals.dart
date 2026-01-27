/*
part of 'register_base_page.dart';

class RegStep4Goals extends GetWidget<RegisterController> {
  const RegStep4Goals({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder(
        valueListenable: controller.selectedGoal,
        builder: (context, selected, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                "Let’s make your intentions clear 😌",
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),

              /// Description
              Text(
                "Pick your features goals to help us match you with date on the same wavelength.",
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              /// Build list items
              ...controller.relationShipGoals.map(
                (item) => _goalItem(
                  context: context,
                  title: item.goals,
                  subtitle: item.description,
                  selected: item == selected,
                  onTap: () => controller.selectedGoal.value = item,
                ).marginOnly(bottom: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Goal item widget
  Widget _goalItem({
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
            /// Title text
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            /// Subtitle text
            Text(subtitle, style: context.textTheme.bodySmall?.copyWith()),
          ],
        ),
      ),
    );
  }
}
*/
