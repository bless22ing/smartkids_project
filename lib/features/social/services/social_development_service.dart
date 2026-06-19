import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_development_model.dart';

final socialDevServiceProvider =
Provider<SocialDevelopmentService>((ref) => SocialDevelopmentService());

// Stream all records for a specific student — most recent first
final studentSocialRecordsProvider =
StreamProvider.family<List<SocialDevelopmentRecord>, String>(
        (ref, studentId) {
      return ref
          .read(socialDevServiceProvider)
          .streamStudentRecords(studentId);
    });

class SocialDevelopmentService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _records =>
      _db.collection('social_development');

  // Stream all records for one student, newest first
  Stream<List<SocialDevelopmentRecord>> streamStudentRecords(
      String studentId) {
    return _records
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map(SocialDevelopmentRecord.fromFirestore)
        .toList());
  }

  // Add a new record
  Future<void> addRecord(SocialDevelopmentRecord record) async {
    await _records.add(record.toMap());
  }

  // Get the most recent record for a student — used to show
  // current skill levels at a glance
  Future<SocialDevelopmentRecord?> getLatestRecord(
      String studentId) async {
    final snap = await _records
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return SocialDevelopmentRecord.fromFirestore(snap.docs.first);
  }
}