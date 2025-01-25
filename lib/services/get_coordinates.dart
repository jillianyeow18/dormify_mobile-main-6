import 'dart:convert';
import 'package:http/http.dart' as http;

class GetCoordinates {
  final String _apiKey =
      'AIzaSyAqzMTUiskKBUkqXhgmyvyOW7mAxn2k8es'; // Replace with your API Key

  // This function fetches latitude and longitude for a given address
  Future<Map<String, double>> getCoordinatesFromAddress(String address) async {
    try {
      // Format the address for URL encoding
      String formattedAddress = Uri.encodeComponent(address);

      // Build the API request URL
      final String url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$formattedAddress&key=$_apiKey';

      // Send the HTTP request to the Geocoding API
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the API returns results
        if (data['results'].isNotEmpty) {
          final lat = data['results'][0]['geometry']['location']['lat'];
          final lng = data['results'][0]['geometry']['location']['lng'];

          // Return the coordinates as a map
          return {'lat': lat, 'lng': lng};
        } else {
          throw Exception('No results found for the given address');
        }
      } else {
        throw Exception('Failed to get data from Geocoding API');
      }
    } catch (e) {
      throw Exception('Error getting coordinates: $e');
    }
  }
}
