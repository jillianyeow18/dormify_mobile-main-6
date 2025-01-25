import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/data/property_repository.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';

class WishlistRepository {
  final PropertyRepository propertyRepository = PropertyRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> isPropertyInWishlist(String propertyID, String tenantID) async {
    final querySnapshot = await _firestore
        .collection('Wishlist')
        .where('propertyID', isEqualTo: propertyID)
        .where('tenantID', isEqualTo: tenantID)
        .get();

    print(propertyID);
    print(tenantID);
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> toggleWishlist(String propertyID, String tenantID) async {
    final inWishlist = await isPropertyInWishlist(propertyID, tenantID);
    if (inWishlist) {
      final querySnapshot = await _firestore
          .collection('Wishlist')
          .where('propertyID', isEqualTo: propertyID)
          .where('tenantID', isEqualTo: tenantID)
          .get();
      for (var doc in querySnapshot.docs) {
        await _firestore.collection('Wishlist').doc(doc.id).delete();
      }
    } else {
      await _firestore.collection('Wishlist').add({
        'propertyID': propertyID,
        'tenantID': tenantID,
      });
    }
  }

  Future<DocumentSnapshot?> getWishlistItem(
      String propertyID, String tenantID) async {
    try {
      // Query the collection to find a matching document
      final querySnapshot = await _firestore
          .collection('Wishlist')
          .where('propertyID', isEqualTo: propertyID)
          .where('tenantID', isEqualTo: tenantID)
          .get();

      // Check if a matching document exists
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        print('No matching wishlist item found.');
        return null;
      }
    } catch (e) {
      print('Failed to get wishlist item: $e');
      return null;
    }
  }

  Stream<List<Property>> streamWishlist(String tenantID) async* {
    try {
      final wishlistStream = _firestore
          .collection('Wishlist')
          .where('tenantID', isEqualTo: tenantID)
          .snapshots();

      print('Hello, I\'m here');
      print('TenantID: $tenantID');

      await for (var wishlistSnapshot in wishlistStream) {
        if (wishlistSnapshot.docs.isEmpty) {
          print('No wishlist items found for tenantID: $tenantID');
          yield []; // Emit an empty list if no wishlist items are found
        } else {
          List<String> propertyIDs = wishlistSnapshot.docs
              .map((doc) => doc['propertyID'] as String?)
              .whereType<String>()
              .toList();

          print('Extracted propertyIDs: $propertyIDs');

          if (propertyIDs.isEmpty) {
            print(
                'No valid propertyIDs found in the wishlist for tenantID: $tenantID');
            yield []; // Emit an empty list if no valid property IDs are found
          } else {
            // If fetchPropertiesByWishlist returns a Stream, process it as such
            final propertiesStream = propertyRepository.fetchProperties(
              tenantID: null, // Replace with the actual tenantID if needed
              landlordID: null, // Replace with the actual landlordID if needed
              propertyIDs: propertyIDs, // Pass the propertyIDs list here
            );

            await for (var properties in propertiesStream) {
              print('Fetched properties: $properties'); // Debugging
              yield properties; // Yield each list of properties from the stream
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
      yield []; // Emit an empty list on error
    }
  }

  Future<void> addWishList(String propertyID, String tenantID) async {
    try {
      final existingItem = await getWishlistItem(propertyID, tenantID);
      if (existingItem == null) {
        await _firestore.collection('Wishlist').add({
          'propertyID': propertyID,
          'tenantID': tenantID,
        });
        print('Property added to wishlist.');
      } else {
        print('Property already exists in wishlist.');
      }
    } catch (e) {
      print('Failed to add property to wishlist: $e');
    }
  }

  Future<void> removeWishList(String propertyID, String tenantID) async {
    try {
      final existingItem = await getWishlistItem(propertyID, tenantID);
      if (existingItem != null) {
        await _firestore.collection('Wishlist').doc(existingItem.id).delete();
        print('Property removed from wishlist.');
      } else {
        print('Property not found in wishlist.');
      }
    } catch (e) {
      print('Failed to remove property from wishlist: $e');
    }
  }
}
