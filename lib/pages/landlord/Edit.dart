import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/data/cloudinary_service.dart';
import 'package:dormify_mobile/pages/Landlord/menu.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'property_models.dart';

class EditPropertyPage extends StatefulWidget {
  final Property property;

  const EditPropertyPage({super.key, required this.property});

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _propertyNameController;
  late TextEditingController _rentalPriceController;
  late TextEditingController _squareFeetController;
  late TextEditingController _propertyAddressController;
  late TextEditingController _propertyCityController;
  late TextEditingController _propertyStateController;
  List<String> _facilities = [];
  String? _propertyType;
  List<String> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _propertyNameController =
        TextEditingController(text: widget.property.propertyName);
    _rentalPriceController =
        TextEditingController(text: widget.property.rentalPrice?.toString());
    _squareFeetController =
        TextEditingController(text: widget.property.squareFeet?.toString());
    _propertyAddressController =
        TextEditingController(text: widget.property.propertyAddress);
    _propertyCityController =
        TextEditingController(text: widget.property.propertyCity);
    _propertyStateController =
        TextEditingController(text: widget.property.propertyState);
    _propertyType = widget.property.propertyType;
    _fetchPropertyData();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _rentalPriceController.dispose();
    _squareFeetController.dispose();
    _propertyAddressController.dispose();
    _propertyCityController.dispose();
    _propertyStateController.dispose();
    super.dispose();
  }

  Future<void> _fetchPropertyData() async {
    try {
      DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
          .collection('Property')
          .doc(widget.property.propertyID)
          .get();

      if (propertyDoc.exists) {
        var propertyData = propertyDoc.data() as Map<String, dynamic>;

        setState(() {
          _propertyNameController.text = propertyData['name'] ?? '';
          _rentalPriceController.text =
              propertyData['rentalPrice']?.toString() ?? '';
          _squareFeetController.text =
              propertyData['squareFeet']?.toString() ?? '';
          _propertyAddressController.text = propertyData['address'] ?? '';
          _propertyCityController.text = propertyData['city'] ?? '';
          _propertyStateController.text = propertyData['state'] ?? '';
          _propertyType = propertyData['type'] ?? ' ';

          if (propertyData['facilities'] != null &&
              propertyData['facilities'] is List<dynamic>) {
            _facilities = List<String>.from(propertyData['facilities']);
          }

          if (propertyData['images'] != null &&
              propertyData['images'] is List<dynamic>) {
            _images = List<String>.from(propertyData['images']);
          }
        });

        debugPrint('Fetched Property Data: $propertyData');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property data not found.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  Future<void> _saveProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection('Property')
            .doc(widget.property.propertyID)
            .update({
          'name': _propertyNameController.text,
          'rentalPrice': double.tryParse(_rentalPriceController.text) ?? 0,
          'squareFeet': double.tryParse(_squareFeetController.text) ?? 0,
          'address': _propertyAddressController.text,
          'city': _propertyCityController.text,
          'state': _propertyStateController.text,
          'type': _propertyType,
          'facilities': _facilities,
          'images': _images, // Saving image URL
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property updated successfully')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving property: $e')),
        );
      }
    }
  }

  DropdownButtonFormField<String> _buildDropdownFacilities(String label,
      List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  void _removeFacility(String facility) {
    setState(() {
      _facilities.remove(facility);
    });
  }

  void _addFacility(String facility) {
    setState(() {
      _facilities.add(facility);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Property',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Property Details Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Property Details",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _propertyNameController,
                        decoration: InputDecoration(
                          labelText: 'Property Name',
                          prefixIcon:
                              const Icon(Icons.home, color: Colors.black),
                          fillColor:
                              Colors.lightBlue[50], // Light blue background
                          filled: true, // Enables the background color
                          labelStyle: const TextStyle(
                              color: Colors
                                  .black), // Sets the label text color to black
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        enabled:
                            false, // Disables editing, making the field read-only
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12), // Sets the text color to black
                      ),

                      const SizedBox(height: 16),
                      // Combined address section
                      TextFormField(
                        controller: _propertyAddressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon:
                              const Icon(Icons.pin_drop, color: Colors.black),
                          fillColor:
                              Colors.lightBlue[50], // Light blue background
                          filled: true, // Enables the background color
                          labelStyle: const TextStyle(
                              color: Colors
                                  .black), // Sets the label text color to black
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        enabled:
                            false, // Disables editing, making the field read-only
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12), // Sets the text color to black
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _propertyCityController,
                                  decoration: InputDecoration(
                                    labelText: 'City',
                                    prefixIcon: const Icon(Icons.location_city,
                                        color: Colors.black),
                                    fillColor: Colors
                                        .lightBlue[50], // Light blue background
                                    filled:
                                        true, // Enables the background color
                                    labelStyle: const TextStyle(
                                        color: Colors.black), // Label color
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                  enabled: false, // Read-only
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12), // Text color
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8.0), // Space between city and state fields
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _propertyStateController,
                                  decoration: InputDecoration(
                                    labelText: 'State',
                                    prefixIcon: const Icon(Icons.map,
                                        color: Colors.black),
                                    fillColor: Colors
                                        .lightBlue[50], // Light blue background
                                    filled:
                                        true, // Enables the background color
                                    labelStyle: const TextStyle(
                                        color: Colors.black), // Label color
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                  enabled: false, // Read-only
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12), // Text color
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _squareFeetController,
                        decoration: InputDecoration(
                          labelText: 'Area (sq. ft.)',
                          prefixIcon:
                              const Icon(Icons.map, color: Colors.black),
                          fillColor:
                              Colors.lightBlue[50], // Light blue background
                          filled: true, // Enables the background color
                          labelStyle: const TextStyle(
                              color: Colors.black), // Label color
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        enabled: false, // Read-only
                        style: const TextStyle(
                            color: Colors.black, fontSize: 12), // Text color
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _rentalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rental Price (RM)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Facilities Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Facilities",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Wrap to display selected facilities as Chips
                      Wrap(
                        spacing: 8.0,
                        children: _facilities
                            .map((facility) => Chip(
                                  label: Text(facility),
                                  onDeleted: () => setState(
                                      () => _facilities.remove(facility)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown to select a facility
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select a Facility',
                        ),
                        value:
                            null, // Set this to the currently selected facility if needed
                        items: facilities
                            .map((facility) => DropdownMenuItem<String>(
                                  value: facility[
                                      'label'], // Use 'label' as the value
                                  child: Row(
                                    children: [
                                      Icon(
                                        facility[
                                            'icon'], // Display the corresponding icon
                                        color:
                                            Colors.blue, // Customize icon color
                                      ),
                                      const SizedBox(
                                          width:
                                              8), // Add spacing between icon and text
                                      Text(facility[
                                          'label']), // Display the label
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _addFacility(
                                value); // Call the facility handling function
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Property Images",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      _images.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Image.network(
                                      _images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _images.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                "No images available",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Add Image'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveProperty,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Save Property"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final cloudinaryService = CloudinaryService();
        final imageUrl =
            await cloudinaryService.uploadImage(imageFile, 'dormify');

        setState(() {
          // Directly add the image URL to the property images list
          _images.add(imageUrl ?? '');
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No images found.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading images.')));
    }
  }
}
