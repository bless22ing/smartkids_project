import 'package:cloud_firestore/cloud_firestore.dart';

class RecordService {
  final String studentId;
  final String type;

  RecordService({
    required this.studentId,
    required this.type,
  });

  CollectionReference get _records => FirebaseFirestore.instance
      .collection('schools')
      .doc('defaultSchool')
      .collection('students')
      .doc(studentId)
      .collection(type);

  Stream<QuerySnapshot> streamRecords() {
    return _records.orderBy('date', descending: true).snapshots();
  }

  Future<void> addRecord(Map<String, dynamic> data) {
    return _records.add({
      ...data,
      'date': FieldValue.serverTimestamp(),
    });
  }
}
