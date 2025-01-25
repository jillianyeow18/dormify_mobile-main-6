import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserTypeEnum {
  landlord,
  tenant,
}

extension TypeExtension on User {
  Future<UserTypeEnum> type(User user) async {
    final tenantDoc = await FirebaseFirestore.instance
        .collection('tenant')
        .doc(user.uid)
        .get();

    if (tenantDoc.exists) {
      return UserTypeEnum.tenant;
    }

    final landlordDoc = await FirebaseFirestore.instance
        .collection('landlord')
        .doc(user.uid)
        .get();

    if (landlordDoc.exists) {
      return UserTypeEnum.landlord;
    }

    return UserTypeEnum.tenant;
  }
}
