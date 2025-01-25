import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RentalDetailPage extends StatefulWidget {
  final Property property;
  const RentalDetailPage({super.key, required this.property});

  @override
  _RentalDetailPageState createState() => _RentalDetailPageState();
}

class _RentalDetailPageState extends State<RentalDetailPage> {
  late GoogleMapController mapController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

Future<String> fetchContact(String landlordId) async {
  try {
    DocumentSnapshot landlordDoc = await FirebaseFirestore.instance
        .collection('landlord')
        .doc(widget.property.landlordID)
        .get();

    if (landlordDoc.exists) {
      String? phoneNumber = landlordDoc['phone number'];
      return phoneNumber ?? 'N/A'; 
    } else {
      return 'N/A'; 
    }
  } catch (e) {
    print('Error fetching phone number: $e');
    return 'N/A'; 
  }
}
  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    property.images.map((image) => image).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          property.propertyName ?? 'Property',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF4F925A),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slideshow with arrows for scrolling
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.property.images.isEmpty
                      ? const Text("No images available")
                      : widget.property.images.length == 1
                          ? Image.network(
                              widget.property.images[0],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Column(
                              children: [
                                // PageView for image scrolling
                                SizedBox(
                                  height:
                                      200, // Ensure a fixed height for PageView
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: widget.property.images.length,
                                    itemBuilder: (context, index) {
                                      final imagePath =
                                          widget.property.images[index];
                                      return Image.network(
                                        imagePath,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                // Centered Page indicator
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    // This centers the indicator
                                    child: SmoothPageIndicator(
                                      controller: _pageController,
                                      count: widget.property.images.length,
                                      effect: ExpandingDotsEffect(
                                        dotWidth: 8.0,
                                        dotHeight: 8.0,
                                        spacing: 4.0,
                                        radius: 4.0,
                                        dotColor: Colors.grey,
                                        activeDotColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_left, color: Colors.white, size: 30),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  child: IconButton(
                    icon:
                        Icon(Icons.arrow_right, color: Colors.white, size: 30),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Wishlist Button beside it
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.propertyName ?? 'Property',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Price and Distance Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price Card
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'RM ${property.rentalPrice?.toStringAsFixed(2) ?? '0.00'}',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Distance Card
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${property.distance} km',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // 3x2 Grid for details
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return DetailCard(
                            icon: Icons.crop_square,
                            title: 'Square Feet',
                            value: '${property.squareFeet} sq.ft.',
                          );
                        case 1:
                          return DetailCard(
                            icon: Icons.build,
                            title: 'Facilities',
                            value: property.selectedFacilities.isNotEmpty
                                ? property.selectedFacilities.join(", ")
                                : 'No facilities available',
                          );

                        case 2:
                          return DetailCard(
                            icon: Icons.hotel,
                            title: 'Room Type',
                            value: '${property.propertyType}',
                          );
                        case 3:
                        return FutureBuilder<String>(
                          future: property.landlordID != null ? fetchContact(property.landlordID!) : Future.value('N/A'), // Check if landlordID is not null
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              // Handle errors
                              return DetailCard(
                                icon: Icons.phone,
                                title: 'Contact',
                                value: 'Error', // Show error message
                              );
                            } else {
                              // Show the fetched phone number
                              return DetailCard(
                                icon: Icons.phone,
                                title: 'Contact',
                                value: snapshot.data ?? 'N/A', // Fallback to 'N/A' if data is null
                              );
                            }
                          },
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Location Map Section with reduced size
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            property.latitude ?? 0.0, // Provide default if null
                            property.longitude ??
                                0.0, // Provide default if null
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(property.propertyName ??
                                'default_marker'), // Handle nullable name
                            position: LatLng(
                              property.latitude ?? 0.0,
                              property.longitude ?? 0.0,
                            ),
                            infoWindow: InfoWindow(
                                title: property.propertyName ??
                                    'Unknown Property'), // Handle null title
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF4F925A), size: 30),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
