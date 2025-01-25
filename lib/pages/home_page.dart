import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/Tenant/rental_page.dart';
import 'package:dormify_mobile/pages/profile_edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'select_role_page.dart';
import 'package:dormify_mobile/pages/Landlord/landlord_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  Future<void> navigateBasedOnRole(BuildContext context) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await userDoc.get();
    if (context.mounted) {
      if (snapshot.exists) {
        final role = snapshot.data()?['role'];
        if (role == 'Tenant') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => RentalPage()));
        } else if (role == 'Landlord') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LandlordPage()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SelectRolePage()));
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SelectRolePage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    navigateBasedOnRole(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileEditPage()),
            ),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
