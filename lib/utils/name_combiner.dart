import '../models/name_components.dart';

/// Utility class for combining name components into a single string
class NameCombiner {
  /// Combines title, firstName, and lastName into a single string
  /// Format: "Title FirstName LastName"
  /// 
  /// Handles:
  /// - Empty fields are skipped
  /// - Whitespace is trimmed from each component
  /// - Multiple spaces are normalized to single space
  /// - Returns empty string if all fields are empty
  static String combine(NameComponents components) {
    final parts = <String>[];

    // Add non-empty, trimmed components
    if (components.title.trim().isNotEmpty) {
      parts.add(components.title.trim());
    }
    if (components.firstName.trim().isNotEmpty) {
      parts.add(components.firstName.trim());
    }
    if (components.middleName.trim().isNotEmpty) {
      parts.add(components.middleName.trim());
    }
    if (components.lastName.trim().isNotEmpty) {
      parts.add(components.lastName.trim());
    }

    // Join with single space and normalize any multiple spaces
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
