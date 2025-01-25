import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/chat/chat_page.dart';
import 'package:dormify_mobile/pages/landlord/landlord_index_page.dart';
import 'package:dormify_mobile/pages/navbar.dart';
import 'package:dormify_mobile/pages/login_page.dart';
import 'package:dormify_mobile/pages/profile_edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// RentalHomePage displays the main content of the app and the navigation bar.
/// When navbar item is tapped, the selected widget is updated.
class LandlordPage extends StatefulWidget {
  const LandlordPage({super.key});

  @override
  State<LandlordPage> createState() => _LandlordPageState();
}

class _LandlordPageState extends State<LandlordPage> {
  final tenant = FirebaseAuth.instance.currentUser!;
  Widget selectedWidget = const LandlordIndexPage();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _onNavbarItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          selectedWidget = const LandlordIndexPage();
        });
        break;

      case 1:
        setState(() {
          selectedWidget = const ChatPage();
        });
        break;

      case 2:
        setState(() {
          selectedWidget = const ProfileEditPage();
        });
        break;
    }
  }

  Future<String> _getUser() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('landlord')
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
        backgroundColor: Colors.blue[900], // Dark blue background
        title: Padding(
          padding: const EdgeInsets.all(5), // Padding for the content
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, right: 15), // Adjust top padding as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage(
                                      onTap: () {},
                                    )),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error during logout: $e')));
                        }
                      },
                      child: Icon(Icons.exit_to_app,
                          color: const Color.fromARGB(171, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Column for the welcome text and description
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
                      SizedBox(height: 5), // Spacer between the lines of text
                      Text(
                        "Track your properties with Dormify!",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/images/appLogo.png', // Replace with the correct image path
                        width: 110, // Adjust width as needed
                        height: 110, // Adjust height as needed
                      ),
                    ],
                  ),
                ],
              ),

              // Row for the image (positioned below the welcome text)
            ],
          ),
        ),
        toolbarHeight:
            120.0, // Adjust app bar height as needed to fit the content
      ),
      body: selectedWidget,
      bottomNavigationBar:
          NavBar(onItemTapped: _onNavbarItemTapped, userId: tenant.uid),
    );
  }
}
