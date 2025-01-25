class Property {
  String? landlordID;
  String? propertyID;
  String? propertyName;
  String? propertyAddress;
  String? propertyState;
  String? propertyCity;
  String? propertyType;
  double? squareFeet;
  double? rentalPrice;
  double? latitude;
  double? longitude;
  double? distance;
  List<String> images; // List of Property_Image objects
  List<String> selectedFacilities; // List of facilities as strings

  // Constructor with optional named parameters and default values
  Property({
    this.landlordID,
    this.propertyID,
    this.propertyName,
    this.propertyAddress,
    this.propertyState,
    this.propertyCity,
    this.propertyType,
    this.squareFeet,
    this.rentalPrice,
    this.latitude,
    this.longitude,
    this.distance,
    List<String>? images,
    List<String>? selectedFacilities,
  })  : images = images ?? [], // Default to empty list if null
        selectedFacilities = selectedFacilities ?? [];

  static fromFirestore(
      Map<String, dynamic> data) {} // Default to empty list if null
}

class Property_Image {
  final String imageID;
  final String imagePath;
  final String uploadDate;
  final String propertyID;

  Property_Image({
    required this.imageID,
    required this.imagePath,
    required this.uploadDate,
    required this.propertyID,
  });
}

class Wishlist {
  final String wishlistID;
  final String propertyID;
  final String tenantID;

  Wishlist({
    required this.wishlistID,
    required this.propertyID,
    required this.tenantID,
  });
}

class Tenant {
  final String tenantID;
  final String tenantUni;

  Tenant({
    required this.tenantID,
    required this.tenantUni,
  });
}
