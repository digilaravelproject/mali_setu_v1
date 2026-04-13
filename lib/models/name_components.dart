/// Model class representing the three components of a person's name
class NameComponents {
  final String title;
  final String firstName;
  final String middleName;
  final String lastName;

  const NameComponents({
    this.title = '',
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
  });

  /// Returns true if all fields are empty
  bool get isEmpty =>
      title.isEmpty && firstName.isEmpty && middleName.isEmpty && lastName.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameComponents &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          firstName == other.firstName &&
          middleName == other.middleName &&
          lastName == other.lastName;

  @override
  int get hashCode =>
      title.hashCode ^ firstName.hashCode ^ middleName.hashCode ^ lastName.hashCode;

  @override
  String toString() =>
      'NameComponents(title: $title, firstName: $firstName, middleName: $middleName, lastName: $lastName)';
}
