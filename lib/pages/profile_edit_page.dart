import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/landlord/landlord_page.dart';
import 'package:dormify_mobile/pages/tenant/rental_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final raceController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final profileDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final tenantDoc = await FirebaseFirestore.instance
          .collection('tenant')
          .doc(user.uid)
          .get();
      final landlordDoc = await FirebaseFirestore.instance
          .collection('landlord')
          .doc(user.uid)
          .get();

      if (tenantDoc.exists) {
        updateControllers(tenantDoc.data());
      } else if (landlordDoc.exists) {
        updateControllers(landlordDoc.data());
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void updateControllers(Map<String, dynamic>? data) {
    if (data != null) {
      setState(() {
        firstNameController.text = data['first name'] ?? '';
        lastNameController.text = data['last name'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        raceController.text = data['race'] ?? '';
        phoneNumberController.text = data['phone number'] ?? '';
        profileDescriptionController.text = data['profile description'] ?? '';
      });
    }
  }

  Future<void> saveUserData() async {
    try {
      final tenantDoc =
          FirebaseFirestore.instance.collection('tenant').doc(user.uid);
      final landlordDoc =
          FirebaseFirestore.instance.collection('landlord').doc(user.uid);

      Map<String, dynamic> userData = {
        'first name': firstNameController.text.trim(),
        'last name': lastNameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()) ?? 0,
        'race': raceController.text.trim(),
        'phone number': phoneNumberController.text.trim(),
        'profile description': profileDescriptionController.text.trim(),
      };
      print(userData);

      final tenantSnapshot = await tenantDoc.get();
      if (tenantSnapshot.exists) {
        await tenantDoc.set(userData, SetOptions(merge: true));
      } else {
        await landlordDoc.set(userData, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      if (tenantSnapshot.exists) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => RentalPage(), maintainState: true),
            (Route<dynamic> route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => LandlordPage(), maintainState: true),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    raceController.dispose();
    phoneNumberController.dispose();
    profileDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: raceController,
              decoration: const InputDecoration(labelText: 'Race'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: profileDescriptionController,
              decoration:
                  const InputDecoration(labelText: 'Profile Description'),
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2A629A),
                foregroundColor: Colors.white70,
              ),
              onPressed: saveUserData,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
