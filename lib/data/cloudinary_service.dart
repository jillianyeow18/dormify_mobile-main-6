import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'dool4mqv9';
  final String apiKey = '817116237576768';
  final String apiSecret = 'XcezYqwPudUYvShJeFPvo118mAo';

  Future<String?> uploadImage(File imageFile, String uploadPreset) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/dool4mqv9/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseBody);
        return decodedResponse['secure_url']; // Return the image URL
      } else {
        print('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadFile(File pdfFile, String uploadPreset) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/ds7geiavt/raw/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseBody);
        return decodedResponse['secure_url']; // Return the file URL
      } else {
        print('Failed to upload file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}
