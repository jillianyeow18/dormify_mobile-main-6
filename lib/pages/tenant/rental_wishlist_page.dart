import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dormify_mobile/data/property_repository.dart';
import 'package:dormify_mobile/data/wishlist_repository.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';
import 'package:dormify_mobile/components/card.dart'; // Ensure this points to your PropertyCard

class RentalWishlistPage extends StatefulWidget {
  // User ID passed as a parameter
  final bool isLandlord = false;

  const RentalWishlistPage({super.key}); // Indicates if the user is a landlord

  @override
  State<RentalWishlistPage> createState() => _RentalWishlistPageState();
}

class _RentalWishlistPageState extends State<RentalWishlistPage> {
  final PropertyRepository propertyRepository = PropertyRepository();
  final WishlistRepository wishlistRepository = WishlistRepository();
  final tenant = FirebaseAuth.instance.currentUser!;

  Stream<List<Property>>? _wishlistPropertiesStream;

  @override
  void initState() {
    super.initState();
    _fetchWishlistProperties(); // Call this to fetch the properties when the page loads
  }

  void _fetchWishlistProperties() {
    setState(() {
      // Now properly assign the stream for fetching wishlist properties
      _wishlistPropertiesStream = wishlistRepository.streamWishlist(tenant.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<List<Property>>(
      stream: _wishlistPropertiesStream, // Stream for fetching properties
      builder: (context, snapshot) {
        // Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Handle case where no data is available
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No properties in your wishlist'));
        }

        final properties = snapshot.data!;

        return ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];

            return PropertyCard(
              property: property,
              isInWishlist: true, // These are wishlist properties
              onToggleWishlist: () async {
                await wishlistRepository.toggleWishlist(
                  property.propertyID!,
                  tenant.uid,
                );
                _fetchWishlistProperties(); // Refresh wishlist properties after toggle
              },
              onEdit: () {}, // Implement edit functionality if needed
              onDelete: () {}, // Implement delete functionality if needed
              isLandlord: widget.isLandlord,
            );
          },
        );
      },
    ));
  }
}
