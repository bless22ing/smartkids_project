import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_role.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<UserRole> getUserRole() async {
    final uid = _auth.currentUser!.uid;

    final snap = await _db.collection('users').doc(uid).get();
    final role = snap.data()?['role'] ?? 'teacher';

    return roleFromString(role);
  }
}
