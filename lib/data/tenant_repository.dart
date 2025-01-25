import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormify_mobile/domains/tenant.domain.dart';
import 'package:logger/logger.dart';

class TenantRepository {
  TenantRepository._();

  static final instance = TenantRepository._();
  static final _firestore = FirebaseFirestore.instance;
  static final _logger = Logger();

  Future<Tenant> getTenantById(String tenantId) async {
    try {
      final doc = await _firestore.collection('tenant').doc(tenantId).get();

      if (doc.exists) {
        return Tenant.fromMap(doc.id, doc.data()!);
      }

      return Future.error('Tenant not found');
    } catch (e) {
      _logger.e('Error getting tenant: $e');
      return Future.error('Error getting tenant: $e');
    }
  }

  Future<List<Tenant>> getAllTenants() async {
    try {
      final snapshot = await _firestore.collection('tenant').get();
      return snapshot.docs
          .map((doc) => Tenant.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      _logger.e('Error getting all tenants: $e');
      return [];
    }
  }

  Future<void> updateTenantProfile(
      String tenantId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tenant').doc(tenantId).update(data);
    } catch (e) {
      _logger.e('Error updating tenant profile: $e');
      throw Exception('Failed to update tenant profile');
    }
  }

  Stream<Tenant?> getTenantStream(String tenantId) {
    return _firestore
        .collection('tenant')
        .doc(tenantId)
        .snapshots()
        .map((doc) => doc.exists ? Tenant.fromMap(doc.id, doc.data()!) : null);
  }
}
