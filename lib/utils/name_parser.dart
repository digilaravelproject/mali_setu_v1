import '../models/name_components.dart';

/// Utility class for parsing a combined name string into components
class NameParser {
  /// Valid title options (with and without periods)
  static const validTitles = [
    'Mr', 'Mr.',
    'Mrs', 'Mrs.',
    'Ms', 'Ms.',
    'Dr', 'Dr.',
    'Prof', 'Prof.',
  ];

  /// Parses a combined name string into title, firstName, and lastName
  /// 
  /// Logic:
  /// 1. Normalize whitespace (trim and collapse multiple spaces)
  /// 2. Check if first word is a valid title (case-insensitive)
  /// 3. Extract title if present
  /// 4. Last word becomes lastName
  /// 5. All middle words become firstName
  /// 6. Handle single-word names (goes to firstName)
  /// 
  /// Examples:
  /// - "Mr. John Doe" → title: "Mr.", firstName: "John", lastName: "Doe"
  /// - "John Doe" → title: "", firstName: "John", lastName: "Doe"
  /// - "Dr John Smith Jr" → title: "Dr", firstName: "John Smith", lastName: "Jr"
  /// - "John" → title: "", firstName: "John", lastName: ""
  static NameComponents parse(String fullName) {
    // Normalize whitespace
    final normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    if (normalized.isEmpty) {
      return const NameComponents();
    }

    final words = normalized.split(' ');
    
    if (words.isEmpty) {
      return const NameComponents();
    }

    String title = '';
    List<String> nameWords = words;

    // Check if first word is a valid title (case-insensitive)
    final firstWord = words[0];
    final matchingTitle = validTitles.firstWhere(
      (t) => t.toLowerCase() == firstWord.toLowerCase(),
      orElse: () => '',
    );

    if (matchingTitle.isNotEmpty) {
      title = matchingTitle;
      nameWords = words.sublist(1);
    }

    // Handle remaining words
    if (nameWords.isEmpty) {
      return NameComponents(title: title);
    }

    if (nameWords.length == 1) {
      return NameComponents(
        title: title,
        firstName: nameWords[0],
      );
    }

    if (nameWords.length == 2) {
      return NameComponents(
        title: title,
        firstName: nameWords[0],
        lastName: nameWords[1],
      );
    }

    // 3 or more words
    final firstName = nameWords.first;
    final lastName = nameWords.last;
    final middleName = nameWords.sublist(1, nameWords.length - 1).join(' ');

    return NameComponents(
      title: title,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
    );
  }
}
