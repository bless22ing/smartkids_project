import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_permissions.dart';
import '../models/staff_model.dart';

final staffServiceProvider = Provider<StaffService>((ref) => StaffService());

// Stream all staff
final staffStreamProvider = StreamProvider<List<StaffModel>>((ref) {
  return ref.read(staffServiceProvider).streamStaff();
});

// Stream teaching staff only
final teachingStaffProvider = StreamProvider<List<StaffModel>>((ref) {
  return ref.read(staffServiceProvider).streamByType(StaffType.teaching);
});

class StaffService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _staff => _db.collection('staff');

  // Stream all staff ordered by name
  Stream<List<StaffModel>> streamStaff() {
    return _staff
        .orderBy('name')
        .snapshots()
        .map((snap) =>
        snap.docs.map(StaffModel.fromFirestore).toList());
  }

  // Stream by staff type
  Stream<List<StaffModel>> streamByType(StaffType type) {
    return _staff
        .where('staffType', isEqualTo: type.name)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
        snap.docs.map(StaffModel.fromFirestore).toList());
  }

  // Add new staff member
  Future<String> addStaff(StaffModel staff) async {
    final doc = await _staff.add(staff.toMap());
    return doc.id;
  }

  // Update staff details
  Future<void> updateStaff(StaffModel staff) async {
    await _staff.doc(staff.id).update(staff.toMap());
  }

  // Update permissions for an assistant
  Future<void> updatePermissions(
      String staffId, UserPermissions permissions) async {
    await _staff.doc(staffId).update({
      'permissions': permissions.toMap(),
    });
  }

  // Record a salary payment
  Future<void> recordSalaryPayment({
    required String staffId,
    required SalaryPayment payment,
  }) async {
    final doc = await _staff.doc(staffId).get();
    if (!doc.exists) throw Exception('Staff member not found');

    final staff = StaffModel.fromFirestore(doc);
    final updatedPayments = [...staff.salaryPayments, payment];

    await _staff.doc(staffId).update({
      'salaryPayments': updatedPayments.map((p) => p.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Deactivate staff member
  Future<void> deactivateStaff(String staffId) async {
    await _staff.doc(staffId).update({
      'status': StaffStatus.inactive.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add qualification
  Future<void> addQualification(
      String staffId, Qualification qualification) async {
    final doc = await _staff.doc(staffId).get();
    if (!doc.exists) throw Exception('Staff member not found');

    final staff = StaffModel.fromFirestore(doc);
    final updatedQuals = [...staff.qualifications, qualification];

    await _staff.doc(staffId).update({
      'qualifications': updatedQuals.map((q) => q.toMap()).toList(),
    });
  }
}