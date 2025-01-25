import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/domains/landlord.domain.dart';
import 'package:logger/logger.dart';

class LandlordRepository {
  LandlordRepository._();

  static final instance = LandlordRepository._();
  static final _firestore = FirebaseFirestore.instance;
  static final _logger = Logger();

  Future<Landlord> getLandlordById(String landlordId) async {
    try {
      final doc = await _firestore.collection('landlord').doc(landlordId).get();

      if (doc.exists) {
        return Landlord.fromMap(doc.id, doc.data()!);
      }

      return Future.error('Landlord not found');
    } catch (e) {
      _logger.e('Error getting landlord: $e');
      return Future.error('Error getting landlord: $e');
    }
  }
}
