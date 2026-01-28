extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

extension StringNullableExtension on String? {
  String toTitleCase() {
    if (this == null || this!.isEmpty) return this ?? '';
    return this!.toTitleCase();
  }
}
