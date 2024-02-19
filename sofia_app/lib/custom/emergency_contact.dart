class EmergencyContact {
  String id;
  String name;
  String phoneNumber;

  EmergencyContact({
    this.id = '',
    required this.name,
    required this.phoneNumber,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }
}
