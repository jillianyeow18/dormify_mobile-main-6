class Tenant {
  final String id;
  final int age;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profileDescription;
  final String race;
  final String university;
  final String userId;

  Tenant({
    required this.id,
    required this.age,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profileDescription,
    required this.race,
    required this.university,
    required this.userId,
  });

  factory Tenant.fromMap(String id, Map<String, dynamic> map) {
    return Tenant(
      id: id,
      age: map['age'] ?? 0,
      firstName: map['first name'] ?? '',
      lastName: map['last name'] ?? '',
      phoneNumber: map['phone number'] ?? '',
      profileDescription: map['profile description'] ?? '',
      race: map['race'] ?? '',
      university: map['university'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'first name': firstName,
      'last name': lastName,
      'phone number': phoneNumber,
      'profile description': profileDescription,
      'race': race,
      'university': university,
      'userId': userId,
    };
  }
}
