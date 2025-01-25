import 'package:dormify_mobile/data/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dormify_mobile/pages/Landlord/property_models.dart';
import 'package:dormify_mobile/data/property_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'menu.dart'; // Ensure this file provides the facilities data

class AddPropertyDetailsPage extends StatefulWidget {
  const AddPropertyDetailsPage({super.key});

  @override
  _AddPropertyDetailsPageState createState() => _AddPropertyDetailsPageState();
}

class _AddPropertyDetailsPageState extends State<AddPropertyDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final PropertyRepository propertyRepository = PropertyRepository();

  int _currentStep = 0;
  List<File> images = [];
  List<String> selectedFacilities = [];
  Property property = Property(images: []); // Initialize a Property instance

  bool _showTextField = false;
  final TextEditingController _manualFacilityController =
      TextEditingController();

  void _onStepContinue() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else if (_currentStep == 2) {
        _submitForm();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _addImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final cloudinaryService = CloudinaryService();
        final imageUrl =
            await cloudinaryService.uploadImage(imageFile, 'dormify');

        setState(() {
          // Directly add the image URL to the property images list
          property.images.add(imageUrl ?? '');
        });
      } else {
        _showSnackBar('No image selected');
      }
    } catch (e) {
      _showSnackBar('Error uploading image: $e');
    }
  }

  void _submitForm() async {
    User? landlord = FirebaseAuth.instance.currentUser;

    // Ensure landlord is not null and extract the uid
    if (landlord != null) {
      property.landlordID = landlord.uid; // Assign uid as a string
    } else {
      _showSnackBar('Error: User is not logged in');
      return; // Exit if no user is logged in
    }

    // Assign selected facilities to the property
    property.selectedFacilities = selectedFacilities;

    try {
      await propertyRepository.addNewProperty(property);
      _showSnackBar('Property Submitted Successfully');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error submitting property: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Property',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _buildSteps(),
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900], // Button background color
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              if (_currentStep != 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(
                        255, 250, 251, 251), // Button text color
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('Step 1: Property Details'),
        content: _buildPropertyDetailsForm(),
        isActive: _currentStep >= 0,
        state: _currentStep == 0 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: Text('Step 2: Facilities'),
        content: _buildFacilitiesForm(),
        isActive: _currentStep >= 0,
        state: _currentStep == 1 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: Text('Step 3: Add Images'),
        content: _buildImagePicker(),
        isActive: _currentStep >= 1,
        state: _currentStep == 2 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  Widget _buildPropertyDetailsForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameTextField('Name', 'Please enter a name',
                (value) => property.propertyName = value),
            _buildTextField('Address', 'Please enter an address',
                (value) => property.propertyAddress = value),
            _buildDropdown(
                'State', cityData.keys.toList(), property.propertyState,
                (value) {
              setState(() {
                property.propertyState = value;
                property.propertyCity = null; // Reset city
              });
            }),
            _buildDropdown(
                'City',
                property.propertyState == null
                    ? []
                    : cityData[property.propertyState]!,
                property.propertyCity,
                (value) => property.propertyCity = value),
            _buildDropdown(
                'Type',
                ['Apartment', 'Condo', 'Flat', 'House', 'Studio', 'Terrace'],
                property.propertyType,
                (value) => property.propertyType = value),
            _buildNumericTextField(
                'Square Feet', (value) => property.squareFeet = value),
            _buildNumericTextField(
                'Rental Price', (value) => property.rentalPrice = value),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesForm() {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          children: selectedFacilities
              .map((facility) => Chip(
                    label: Text(facility),
                    onDeleted: () =>
                        setState(() => selectedFacilities.remove(facility)),
                  ))
              .toList(),
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select a Facility'),
          value: null, // Set the default selected value if needed
          items: facilities
              .map((facility) => DropdownMenuItem<String>(
                    value: facility['label'], // Use the label as the value
                    child: Row(
                      children: [
                        Icon(facility['icon'],
                            color: Colors.blue), // Add the icon
                        const SizedBox(width: 8), // Space between icon and text
                        Text(facility['label']), // Display the label
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              if (value == 'Others') {
                setState(() =>
                    _showTextField = true); // Show a text field for "Others"
              } else if (!selectedFacilities.contains(value)) {
                setState(() => selectedFacilities
                    .add(value)); // Add to selected facilities
              }
            }
          },
        ),
        if (_showTextField)
          TextFormField(
            controller: _manualFacilityController,
            decoration: InputDecoration(labelText: 'Add Custom Facility'),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty && !selectedFacilities.contains(value)) {
                setState(() {
                  selectedFacilities.add(value);
                  _manualFacilityController.clear();
                  _showTextField = false;
                });
              }
            },
          ),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _addImage,
          child: Text('Add Image'),
        ),
        if (property.images.isNotEmpty)
          Wrap(
            spacing: 8.0,
            children: property.images
                .map((imageUrl) => Stack(
                      clipBehavior: Clip
                          .none, // Allow the icon to overflow outside the image
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                // Remove the image from the list
                                property.images.remove(imageUrl);
                              });
                            },
                          ),
                        ),
                      ],
                    ))
                .toList(),
          )
        else
          Text('No images added yet.', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 16.0),
      ],
    );
  }

  TextFormField _buildTextField(
      String label, String validationMessage, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? validationMessage : null,
      onChanged: onChanged,
    );
  }

  DropdownButtonFormField<String> _buildDropdown(String label,
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

  _buildNameTextField(
      String label, String hintText, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a name.';
        }
        if (RegExp(r'[0-9]').hasMatch(value)) {
          return 'Name cannot contain numbers.';
        }
        return null; // Input is valid
      },
      onChanged: onChanged,
    );
  }

  TextFormField _buildNumericTextField(
      String label, Function(double?) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        if (!isValidNumericInput(value)) {
          return 'Please enter a valid number (>= 0)';
        }
        return null;
      },
      onChanged: (value) => onChanged(double.tryParse(value)),
    );
  }

  bool isValidNumericInput(String value) {
    final number = num.tryParse(value);
    return number != null && number >= 0;
  }
}
