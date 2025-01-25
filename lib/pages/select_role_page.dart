import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_edit_page.dart';

class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  _SelectRolePageState createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  String? selectedUniversity;
  String? selectedRoomType;
  bool isTenant = false;

  final List<String> universities = [
    'Universiti Kebangsaan Malaysia',
    'Universiti Malaya',
    'Universiti Malaysia Sabah',
    'Universiti Sains Malaysia',
    'Universiti Utara Malaysia',
  ];

  final List<String> roomTypes = [
    'Shared Room',
    'Single Room',
    'Single Room with Attached Bathroom',
    'Master Bedroom with Attached Bathroom',
  ];

  Future<void> setRole(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    Map<String, dynamic> userData = {
      'userId': user.uid,
      'role': role,
    };

    if (role == 'Tenant' && selectedUniversity != null) {
      final tenantDoc =
          FirebaseFirestore.instance.collection('tenant').doc(user.uid);

      userData['university'] = selectedUniversity;
      userData['room type'] = selectedRoomType;
      tenantDoc.set(userData);
    } else {
      final landlordDoc =
          FirebaseFirestore.instance.collection('landlord').doc(user.uid);
      landlordDoc.set(userData);
    }

    await userDoc.set(userData);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileEditPage(), maintainState: true),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Select Your Role'),
          backgroundColor: const Color(0xffD1E5F4),
          centerTitle: true),
      backgroundColor: const Color(0xffE5F3FD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isTenant = true;
                });
              },
              child: Card(
                color: const Color(0xffBDD5e7),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/images/tenant.png',
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 10),
                      const Text('Tenant'),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setRole(context, 'Landlord'),
              child: Card(
                color: const Color(0xffBDD5e7),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/images/landlord.png',
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 10),
                      const Text('Landlord'),
                    ],
                  ),
                ),
              ),
            ),
            if (isTenant) ...[
              const Text('Select Your University:'),
              DropdownButton<String>(
                value: selectedUniversity,
                hint: const Text('Choose your university'),
                items: universities.map((String university) {
                  return DropdownMenuItem<String>(
                    value: university,
                    child: Text(university),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUniversity = value;
                  });
                },
              ),
              const Text('Select Your Room Type:'),
              DropdownButton<String>(
                value: selectedRoomType,
                hint: const Text('Choose your room type'),
                items: roomTypes.map((String roomType) {
                  return DropdownMenuItem<String>(
                    value: roomType,
                    child: Text(roomType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoomType = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: selectedUniversity != null
                    ? () => setRole(context, 'Tenant')
                    : null,
                child: const Text('Confirm Selection'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
