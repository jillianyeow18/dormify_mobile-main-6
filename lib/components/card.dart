import 'package:dormify_mobile/pages/chat/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dormify_mobile/pages/Tenant/rental_details_page.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final bool isInWishlist;
  final VoidCallback onToggleWishlist;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isLandlord;

  const PropertyCard({
    super.key,
    required this.property,
    required this.isInWishlist,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onDelete,
    required this.isLandlord,
  });

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late PageController _pageController;
  late bool _isInWishlist;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.isInWishlist;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleWishlist() async {
    widget.onToggleWishlist();
    setState(() {
      _isInWishlist = !_isInWishlist; // Toggle the wishlist state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: !widget.isLandlord
            ? () {
                print("Pressed property: ${widget.property.propertyName}");
                // Navigate to rental detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RentalDetailPage(property: widget.property),
                  ),
                );
              }
            : null, // Make it null if the user is a landlord
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
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
                              height: 100, // Ensure a fixed height for PageView
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
                            // Page indicator
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                          ],
                        ),
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.property.propertyName ?? 'Unnamed Property',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .end, // Align icons to the right
                            children: [
                              if (!widget.isLandlord)
                                IconButton(
                                  icon: Icon(
                                    Icons
                                        .message, // Icon for the message button
                                    color: Colors
                                        .blue, // You can customize the color
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/chat/detail',
                                        arguments: ChatDetailArguments(
                                          partnerId:
                                              widget.property.landlordID!,
                                          isLandlord:
                                              false, // Since this is from tenant's view
                                        ));
                                  },
                                ),
                              if (!widget.isLandlord)
                                IconButton(
                                  icon: Icon(
                                    _isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: _toggleWishlist,
                                ),
                            ],
                          ),
                          if (widget.isLandlord) ...[
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color.fromARGB(255, 0, 4, 8)),
                              onPressed: widget.onEdit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Color.fromARGB(255, 145, 14, 4)),
                              onPressed: widget.onDelete,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Adds space between the icon and the address
                      Text(
                        widget.property.propertyAddress ??
                            'Address not available', // Display address
                        style: const TextStyle(
                            color: Color.fromARGB(255, 114, 112, 112)),
                      ), // Adds space between the address and the distance
                      Text(
                        ' (${widget.property.distance?.toStringAsFixed(2) ?? 'N/A'} km)', // Display distance
                        style: const TextStyle(
                            color: Color.fromARGB(255, 114, 112, 112)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "${widget.property.propertyType ?? 'Type Unknown'} · ${widget.property.squareFeet?.toStringAsFixed(0) ?? 'N/A'} sq ft",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const Spacer(),
                      Text(
                        'RM ${widget.property.rentalPrice?.toStringAsFixed(2) ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 3, 8)),
                      ),
                    ],
                  ),
                  // Property Type and Area

                  const SizedBox(height: 6),

                  // Show Facilities only if not a landlord
                  if (!widget.isLandlord &&
                      widget.property.selectedFacilities.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Facilities:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 6.0,
                      alignment: WrapAlignment.start,
                      children:
                          widget.property.selectedFacilities.map((facility) {
                        return Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                facilityIcons[facility] , // Assign icon or fallback
                                color: const Color.fromARGB(255, 0, 1, 1),
                              ),
                              const SizedBox(
                                  width: 6), // Space between icon and text
                              Text(
                                facility,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 4, 4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 253, 255, 254),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final Map<String, IconData> facilityIcons = {
  'Swimming Pool': Icons.pool,
  'Gym': Icons.fitness_center,
  'Parking': Icons.local_parking,
  'Wi-Fi': Icons.wifi,
  'CCTV': Icons.videocam,
  'Playground': Icons.play_arrow,
  'Garden': Icons.park,
  'Security': Icons.security,
  'Others': Icons.more_horiz,
};
