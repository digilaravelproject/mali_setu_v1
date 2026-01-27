class UserModal {
  String id;
  String name;
  String phone;

  UserModal({required this.id, required this.name, required this.phone});

  factory UserModal.fromMap(Map<String, dynamic> map) {
    return UserModal(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone};
  }
}
