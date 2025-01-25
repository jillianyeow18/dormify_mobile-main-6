import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/landlord/landlord_page.dart';
import 'package:dormify_mobile/pages/tenant/rental_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<void> navigateBasedOnRole(BuildContext context, User user) async {
    try {
      final tenantDoc = await FirebaseFirestore.instance
          .collection('tenant')
          .doc(user.uid)
          .get();

      if (tenantDoc.exists) {
        // Navigate to the tenant's Rental Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RentalPage()),
        );
        return;
      }

      final landlordDoc = await FirebaseFirestore.instance
          .collection('landlord')
          .doc(user.uid)
          .get();

      if (landlordDoc.exists) {
        // Navigate to the landlord's Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandlordPage()),
        );
        return;
      }

      // If the user is not in either collection, handle it (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role not found in database.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking user role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            // Check user role and navigate accordingly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigateBasedOnRole(context, user);
            });
            return Center(
                child:
                    CircularProgressIndicator()); // Placeholder while navigating
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
