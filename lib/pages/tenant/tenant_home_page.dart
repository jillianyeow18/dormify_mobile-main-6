import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/profile_edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TenantHomePage extends StatefulWidget {
  const TenantHomePage({super.key});

  @override
  State<TenantHomePage> createState() => _TenantHomePageState();
}

class _TenantHomePageState extends State<TenantHomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  // Fetch the user's name from Firestore
  Future<void> fetchUserName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['firstName'] ?? 'Tenant';
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Home Pagesland'),
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
      body: Center(
        child: Text(
          'Welcome, $userName',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
