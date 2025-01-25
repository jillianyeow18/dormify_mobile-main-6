import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/components/card.dart';
import 'package:dormify_mobile/data/property_repository.dart';
import 'package:dormify_mobile/pages/Landlord/Edit.dart';
import 'package:dormify_mobile/pages/Landlord/add_property.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format the date

class LandlordIndexPage extends StatefulWidget {
  const LandlordIndexPage({super.key});

  @override
  State<LandlordIndexPage> createState() => _LandlordIndexPageState();
}

class _LandlordIndexPageState extends State<LandlordIndexPage> {
  final landlord = FirebaseAuth.instance.currentUser!;
  final PropertyRepository propertyRepository = PropertyRepository();
  late String currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('EEE, dd MMM yyyy').format(DateTime.now());
    _getLandlordName();
  }

  Future<String> _getLandlordName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('landlord')
          .doc(landlord.uid)
          .get();

      // Check if the document exists and contains the 'first name' field
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['first name'] ??
            'Unknown'; // Return name or fallback
      } else {
        return 'Unknown'; // Fallback if document or field does not exist
      }
    } catch (e) {
      print("Error fetching landlord's name: $e");
      return 'Error'; // Return a default value in case of error
    }
  }

  Stream<int> _getTotalProperties() {
    return propertyRepository
        .fetchProperties(
      tenantID: null,
      landlordID: landlord.uid,
      propertyIDs: null,
    )
        .map((properties) {
      return properties.length;
    });
  }

  void _showDeleteDialog(Property property) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Property'),
          content: const Text('Are you sure you want to delete this property?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await propertyRepository.deleteProperty(property.propertyID!);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Property>> propertiesStream =
        propertyRepository.fetchProperties(
      tenantID: null, // Not fetching by tenant ID
      landlordID: landlord.uid, // Fetching properties for this landlord
      propertyIDs: null, // Not fetching by property IDs
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<int>(
          stream: _getTotalProperties(),
          builder: (context, totalSnapshot) {
            if (totalSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 105,
                        child: Card(
                          elevation: 10,
                          color: const Color.fromARGB(255, 252, 253, 253),
                          child: ListTile(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.home_filled,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total Properties:',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${totalSnapshot.data ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                            tileColor: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 105,
                        child: Card(
                          elevation: 10,
                          color: Colors.blue[900],
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () async {
                                          // Navigate to another page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddPropertyDetailsPage(), // Replace with your target page
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1, vertical: 1),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.add, size: 20),
                                            SizedBox(width: 4),
                                            Text(
                                              'Add New Property',
                                              style: TextStyle(fontSize: 15),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            tileColor: Colors.transparent,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(
                      5.0), // Add padding of 5.0 units to all sides
                  child: Text(
                    'My Properties',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Property>>(
                    stream: propertiesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No properties available.',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }

                      final properties = snapshot.data!;

                      return ListView.builder(
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];

                          return PropertyCard(
                            property: property,
                            isInWishlist:
                                false, // Set to false as it's a landlord view
                            onToggleWishlist: () {},
                            onEdit: () {
                              // Navigate to the EditPropertyPage with the selected property
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPropertyPage(
                                      property:
                                          property), // Pass the property to the EditPropertyPage
                                ),
                              );
                            },

                            onDelete: () {
                              _showDeleteDialog(
                                  property); // Show the delete dialog
                            },
                            isLandlord: true, // Set to true for landlord view
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
