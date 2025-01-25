import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final String userId; // Pass the user ID to identify the user
  final Function(int) onItemTapped;

  const NavBar({super.key, required this.userId, required this.onItemTapped});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      // Check in Firestore whether the user is a tenant or landlord
      DocumentSnapshot tenantDoc = await FirebaseFirestore.instance
          .collection('tenant')
          .doc(widget.userId)
          .get();

      DocumentSnapshot landlordDoc = await FirebaseFirestore.instance
          .collection('landlord')
          .doc(widget.userId)
          .get();

      setState(() {
        if (tenantDoc.exists) {
          _role = 'tenant';
        } else if (landlordDoc.exists) {
          _role = 'landlord';
        }
      });
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _handleNavigation(int index, BuildContext context) async {
    widget.onItemTapped(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine color based on role
    Color? selectedColor = _role == 'tenant' ? Colors.green : Colors.blue[900];
    Color unselectedColor = Colors.grey;

    // Display different navigation items based on the user role
    final items = _role == 'tenant'
        ? const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => _handleNavigation(index, context),
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      items: items,
    );
  }
}
