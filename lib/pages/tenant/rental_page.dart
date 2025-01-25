import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/chat/chat_page.dart';
import 'package:dormify_mobile/pages/tenant/rental_wishlist_page.dart';
import 'package:dormify_mobile/pages/tenant/rental_index_page.dart';
import 'package:dormify_mobile/pages/navbar.dart';
import 'package:dormify_mobile/pages/login_page.dart';
import 'package:dormify_mobile/pages/profile_edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// RentalHomePage displays the main content of the app and the navigation bar.
/// When navbar item is tapped, the selected widget is updated.
class RentalPage extends StatefulWidget {
  const RentalPage({super.key});

  @override
  State<RentalPage> createState() => _RentalPageState();
}

class _RentalPageState extends State<RentalPage> {
  final tenant = FirebaseAuth.instance.currentUser!;
  Widget selectedWidget = const RentalIndexPage();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _onNavbarItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          selectedWidget = const RentalIndexPage();
        });
        break;

      case 1:
        setState(() {
          selectedWidget = const RentalWishlistPage();
        });
        break;

      case 2:
        setState(() {
          selectedWidget = const ChatPage();
        });
        break;

      case 3:
        setState(() {
          selectedWidget = const ProfileEditPage();
        });
        break;
    }
  }

  Future<String> _getUser() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tenant')
          .doc(tenant.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['first name'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return "";
    }
  }

  Future<void> _onLogoutTap() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  onTap: () {},
                )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error during logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF4F925A),
        title: Padding(
          padding: const EdgeInsets.all(5), // Padding for the content
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _onLogoutTap,
                      child: Icon(Icons.exit_to_app,
                          color: const Color.fromARGB(171, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text(
                              'Error fetching name',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            );
                          }

                          return Text(
                            'Welcome back, ${snapshot.data}',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 5, 0, 0),
                                fontSize: 19),
                          );
                        },
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Discover properties with Dormify!",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 14, 0, 0),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/images/appLogo.png',
                        width: 110,
                        height: 110,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        toolbarHeight: 130.0,
      ),
      body: selectedWidget,
      bottomNavigationBar:
          NavBar(onItemTapped: _onNavbarItemTapped, userId: tenant.uid),
    );
  }
}
