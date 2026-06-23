import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_card_model.dart';

final reportCardServiceProvider =
Provider<ReportCardService>((ref) => ReportCardService());

final studentReportCardsProvider =
StreamProvider.family<List<ReportCardModel>, String>((ref, studentId) {
  return ref.read(reportCardServiceProvider).streamStudentReports(studentId);
});

class ReportCardService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _reports => _db.collection('report_cards');

  Stream<List<ReportCardModel>> streamStudentReports(String studentId) {
    return _reports
        .where('studentId', isEqualTo: studentId)
        .orderBy('year', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map(ReportCardModel.fromFirestore).toList());
  }

  Future<String> saveReportCard(ReportCardModel report) async {
    // Use a composite ID so re-generating a term's report updates it
    // instead of creating duplicates
    final docId = '${report.studentId}_${report.term}_${report.year}';
    await _reports.doc(docId).set(report.toMap());
    return docId;
  }

  Future<ReportCardModel?> getReportCard(String id) async {
    final doc = await _reports.doc(id).get();
    if (!doc.exists) return null;
    return ReportCardModel.fromFirestore(doc);
  }
}