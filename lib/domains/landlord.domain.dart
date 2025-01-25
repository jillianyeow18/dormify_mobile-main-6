class Landlord {
  final String id;
  final int age;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profileDescription;
  final String race;

  Landlord(
      {required this.id,
      required this.age,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.profileDescription,
      required this.race});

  factory Landlord.fromMap(String id, Map<String, dynamic> data) {
    return Landlord(
        id: id,
        age: data['age'],
        firstName: data['first name'],
        lastName: data['last name'],
        phoneNumber: data['phone number'],
        profileDescription: data['profile description'],
        race: data['race']);
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'first name': firstName,
      'last name': lastName,
      'phone number': phoneNumber,
      'profile description': profileDescription,
      'race': race
    };
  }
}
