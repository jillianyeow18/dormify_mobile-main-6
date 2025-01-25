import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';
import 'package:dormify_mobile/services/calculate_distance.dart';
import 'package:dormify_mobile/services/get_coordinates.dart';

class PropertyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // static const String _apiKey =
  //     'AIzaSyAqzMTUiskKBUkqXhgmyvyOW7mAxn2k8es'; // Google Maps API Key
  Future<void> addNewProperty(Property property) async {
    try {
      // Create an instance of the getCoordinates class
      final coordinatesService = GetCoordinates();

      // Get coordinates from the property address
      final coordinates = await coordinatesService
          .getCoordinatesFromAddress(property.propertyAddress!);
      final latitude = coordinates['lat'];
      final longitude = coordinates['lng'];

      // Add the property details along with coordinates to Firestore
      CollectionReference properties = _firestore.collection('Property');

      DocumentReference propertyRef = await properties.add({
        'name': property.propertyName,
        'address': property.propertyAddress,
        'state': property.propertyState,
        'city': property.propertyCity,
        'type': property.propertyType,
        'squareFeet': property.squareFeet,
        'rentalPrice': property.rentalPrice,
        'landlordId': property.landlordID,
        'latitude': latitude,
        'longitude': longitude,
        'facilities': property.selectedFacilities,
        'images': property.images, // Store image URLs directly under 'images'
      });

      // Create an instance of DistanceCalculator
      final distanceCalculator = DistanceCalculator();

      // Calculate the distance from the university
      final distance = await distanceCalculator.getDistanceFromUniversity(
          latitude!, longitude!, property.propertyState!);

      if (distance != null) {
        // Update the property document with the calculated distance
        await propertyRef.update({'distanceFromUniversity': distance});
        print('Distance from university added to Firebase successfully');
      } else {
        print('Failed to calculate distance from university');
      }

      print('Property added successfully');
    } catch (e) {
      print('Error adding property: $e');
      throw Exception('Failed to add property');
    }
  }

  // Method to add property images

  // Method to add selected facilities to the property
  Future<void> _addSelectedFacilities(
      String propertyId, List<String> facilities) async {
    CollectionReference facilitiesCollection =
        _firestore.collection('PropertyFacility');

    for (var facility in facilities) {
      await facilitiesCollection.add({
        'propertyId': propertyId,
        'facility': facility,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Future<String?> getUniversity(String tenantID) async {
    try {
      // Fetch user details from the Users collection based on tenantID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tenantID)
          .get();

      if (userDoc.exists) {
        final university = userDoc[
            'university']; // Assuming the university is stored as 'university'

        // Return the university name
        return university;
      } else {
        print("User not found");
        return null; // User not found, handle accordingly
      }
    } catch (e) {
      print("Error fetching user's university: $e");
      return null;
    }
  }

  Stream<List<Property>> fetchProperties({
    String? tenantID,
    String? landlordID,
    List<String>? propertyIDs,
  }) async* {
    print("Fetching properties with provided filters.");

    try {
      // Determine query parameters based on provided filters
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('Property');

      if (tenantID != null) {
        print("Fetching properties for tenant UID: $tenantID");
        final university = await getUniversity(tenantID);

        // Debugging output for university
        print("University for tenant $tenantID: $university");

        if (university == null || university == "Unknown") {
          print("Unable to determine state for tenantID: $tenantID");
          yield []; // Return an empty list if state is unknown
          return;
        }

        final universityToState = {
          "Universiti Sains Malaysia": "Penang",
          "Universiti Malaya": "Kuala Lumpur",
          "Universiti Kebangsaan Malaysia": "Subang",
          "University Utara Malaysia": "Kedah",
          "University Malaysia Sabah": "Sabah"
        };

        final state = universityToState[university] ?? "Unknown";

        print("Mapped state for university $university: $state");

        if (state == "Unknown") {
          print("State could not be determined for university: $university");
          yield []; // Return an empty list if state is unknown
          return;
        }

        query = query.where('state', isEqualTo: state);
      }

      if (landlordID != null) {
        print("Fetching properties for landlord UID: $landlordID");
        query = query.where('landlordId', isEqualTo: landlordID);
      }

      if (propertyIDs != null && propertyIDs.isNotEmpty) {
        print("Fetching properties by wishlist.");
        query = query.where(FieldPath.documentId, whereIn: propertyIDs);
      }

      // Fetch properties as a stream from Firestore
      final propertyStream = query.snapshots();

      await for (final snapshot in propertyStream) {
        print("Snapshot received with ${snapshot.docs.length} documents.");

        if (snapshot.docs.isEmpty) {
          print("No properties found with the given filters.");
          yield []; // Emit an empty list if no properties are found
        } else {
          List<Property> properties = [];

          for (var propertyDoc in snapshot.docs) {
            final propertyData = propertyDoc.data();
            final propertyID = propertyDoc.id;

            print("Property Data: ${propertyData.toString()}");

            try {
              properties.add(Property(
                landlordID: propertyData['landlordId'],
                propertyID: propertyID,
                propertyName: propertyData['name'],
                propertyAddress: propertyData['address'],
                propertyState: propertyData['state'],
                propertyCity: propertyData['city'],
                propertyType: propertyData['type'],
                squareFeet: propertyData['squareFeet'].toDouble(),
                rentalPrice: propertyData['rentalPrice'].toDouble(),
                latitude: propertyData['latitude'],
                longitude: propertyData['longitude'],
                distance: propertyData["distanceFromUniversity"],
                images: List<String>.from(propertyData['images'] ?? []),
                selectedFacilities:
                    List<String>.from(propertyData['facilities'] ?? []),
              ));

              print("Added Property: ${propertyData['name']} ($propertyID)");
            } catch (e) {
              print("Error processing property ID $propertyID: $e");
            }
          }

          yield properties;
        }
      }
    } catch (e) {
      print("Error fetching properties: $e");
      yield []; // Emit an empty list if an error occurs
    }
  }

  Future<void> deleteProperty(String propertyID) async {
    try {
      var collection = FirebaseFirestore.instance.collection('Property');

      // Reference to the Property document
      var docRef = collection.doc(propertyID);

      // Reference to the PropertyImage subcollection
      var imageCollection = docRef.collection('PropertyImage');

      // Fetch all images associated with the property
      var imageDocs = await imageCollection.get();

      // Delete all property images in the PropertyImage subcollection
      for (var doc in imageDocs.docs) {
        await doc.reference.delete();
        print('Property image with ID ${doc.id} deleted.');
      }

      // Delete the property document itself
      await docRef.delete();
      print('Property successfully deleted!');
    } catch (e) {
      print('Error deleting property: $e');
    }
  }

  Future<void> updateProperty(Property updatedProperty) async {
    try {
      // Reference to the specific property document in the 'Property' collection
      var propertyRef =
          _firestore.collection('Property').doc(updatedProperty.propertyID);

      // Update the document with new values
      await propertyRef.update({
        'name': updatedProperty.propertyName,
        'rentalPrice': updatedProperty.rentalPrice,
        'squareFeet': updatedProperty.squareFeet,
      });

      print('Property updated successfully!');
    } catch (e) {
      print('Error updating property: $e');
      rethrow; // Optionally rethrow the error for further handling
    }
  }
}
