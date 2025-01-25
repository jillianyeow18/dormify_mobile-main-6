import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/components/card.dart';
import 'package:dormify_mobile/data/property_repository.dart';
import 'package:dormify_mobile/data/wishlist_repository.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RentalIndexPage extends StatefulWidget {
  final bool isLandlord;

  const RentalIndexPage({super.key, this.isLandlord = false});

  @override
  State<RentalIndexPage> createState() => _RentalIndexPageState();
}

class _RentalIndexPageState extends State<RentalIndexPage> {
  final PropertyRepository propertyRepository = PropertyRepository();
  final WishlistRepository wishlistRepository = WishlistRepository();
  final tenant = FirebaseAuth.instance.currentUser!;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? tenantName;
  String? _sortOption = 'Price';

  @override
  void initState() {
    super.initState();
    _getUser();
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
      return 'Error';
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Property>> propertiesStream =
        propertyRepository.fetchProperties(
      tenantID: tenant.uid,
      landlordID: null,
      propertyIDs: null,
    );

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      labelText: 'Search properties...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () async {
                    await _showSortOptions(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: propertiesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No properties available'));
                }

                final properties = snapshot.data!;
                final filteredProperties = properties.where((property) {
                  return property.propertyName!
                      .toLowerCase()
                      .contains(_searchQuery);
                }).toList();

                // Sort the properties based on the selected option
                if (_sortOption == 'Price') {
                  filteredProperties.sort((a, b) {
                    return a.rentalPrice!.compareTo(b.rentalPrice!);
                  });
                } else if (_sortOption == 'Distance') {
                  filteredProperties.sort((a, b) {
                    return a.distance!.compareTo(b.distance!);
                  });
                }

                return ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    property.selectedFacilities.add('Contact Us');

                    return FutureBuilder<bool>(
                      future: wishlistRepository.isPropertyInWishlist(
                          property.propertyID!, tenant.uid),
                      builder: (context, wishlistSnapshot) {
                        if (wishlistSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (wishlistSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${wishlistSnapshot.error}'));
                        }

                        final isInWishlist = wishlistSnapshot.data ?? false;

                        return PropertyCard(
                          property: property,
                          isInWishlist: isInWishlist,
                          onToggleWishlist: () async {
                            await wishlistRepository.toggleWishlist(
                                property.propertyID!, tenant.uid);
                          },
                          onEdit: () {
                            // Add edit functionality if needed
                          },
                          onDelete: () {
                            // Add delete functionality if needed
                          },
                          isLandlord: widget.isLandlord,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to show sort options
  Future<void> _showSortOptions(BuildContext context) async {
    final selectedOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Price'),
              onTap: () {
                Navigator.pop(context, 'Price');
              },
            ),
            ListTile(
              title: Text('Distance'),
              onTap: () {
                Navigator.pop(context, 'Distance');
              },
            ),
          ],
        ),
      ),
    );

    if (selectedOption != null) {
      setState(() {
        _sortOption = selectedOption;
      });
    }
  }
}
