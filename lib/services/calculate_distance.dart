import 'package:google_maps_webservice/distance.dart';

class DistanceCalculator {
  static const String _apiKey = 'AIzaSyAqzMTUiskKBUkqXhgmyvyOW7mAxn2k8es';
  static final googleDistance = GoogleDistanceMatrix(apiKey: _apiKey);

  // Coordinates for all universities
  static const Map<String, Map<String, double>> universities = {
    'Universiti Sains Malaysia': {'lat': 5.3564, 'lng': 100.3000},
    'Universiti Malaya': {'lat': 3.1291, 'lng': 101.6530},
    'University Utara Malaysia': {'lat': 6.0603, 'lng': 100.3481},
    'Universiti Kebangsaan Malaysia': {'lat': 2.9267, 'lng': 101.7919},
    'University Malaysia Sabah': {'lat': 5.9682, 'lng': 116.0735},
  };

  // General method to calculate distance from a university
  Future<double?> _getDistanceFromUniversity(
      double lat, double lng, double uniLat, double uniLng) async {
    try {
      final response = await googleDistance.distanceWithLocation(
        [Location(lat: lat, lng: lng)],
        [Location(lat: uniLat, lng: uniLng)],
      );

      if (response.isOkay && response.results.isNotEmpty) {
        final distanceMeters =
            response.results.first.elements.first.distance.value;
        return distanceMeters / 1000; // Convert to kilometers
      } else {
        print('Error: ${response.errorMessage}');
        return null;
      }
    } catch (e) {
      print('Failed to calculate distance: $e');
      return null;
    }
  }

  // Method to get distance from a selected university based on property state
  Future<double?> getDistanceFromUniversity(
      double lat, double lng, String propertyState) async {
    final universityMapping = {
      "Penang": "Universiti Sains Malaysia",
      "Kuala Lumpur": "Universiti Malaya",
      "Selangor": "Universiti Kebangsaan Malaysia",
      "Kedah": "University Utara Malaysia",
      "Sabah": "University Malaysia Sabah"
    };

    // Get the university name from the mapping
    final universityName = universityMapping[propertyState];

    if (universityName != null && universities.containsKey(universityName)) {
      try {
        // Fetch university coordinates
        final uniLat = universities[universityName]!['lat']!;
        final uniLng = universities[universityName]!['lng']!;
        // Calculate and return the distance
        return await _getDistanceFromUniversity(lat, lng, uniLat, uniLng);
      } catch (e) {
        print('Error calculating distance: $e');
        return null;
      }
    } else {
      print('Error: University not found for the provided state');
      return null;
    }
  }
}
