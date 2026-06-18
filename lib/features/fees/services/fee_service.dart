import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fee_model.dart';

final feeServiceProvider = Provider<FeeService>((ref) => FeeService());

// Stream all fees for a specific month and year
final monthlyFeesProvider =
StreamProvider.family<List<FeeModel>, ({int month, int year})>(
        (ref, period) {
      return ref.read(feeServiceProvider).streamMonthlyFees(
        month: period.month,
        year: period.year,
      );
    });

// Stream fees for a specific student
final studentFeesProvider =
StreamProvider.family<List<FeeModel>, String>((ref, studentId) {
  return ref.read(feeServiceProvider).streamStudentFees(studentId);
});

class FeeService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _fees => _db.collection('fees');
  CollectionReference get _feeStructure => _db.collection('fee_structure');

  // Get the monthly fee amount for a class
  Future<double> getClassFeeAmount(String classId) async {
    try {
      final doc = await _feeStructure.doc(classId).get();
      if (!doc.exists) return 0;
      final data = doc.data() as Map<String, dynamic>;
      return (data['amount'] ?? 0).toDouble();
    } catch (e) {
      return 0;
    }
  }

  // Set monthly fee amount for a class — admin only
  Future<void> setClassFeeAmount(String classId, double amount) async {
    await _feeStructure.doc(classId).set({
      'amount': amount,
      'currency': 'USD',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream all fees for a given month
  Stream<List<FeeModel>> streamMonthlyFees({
    required int month,
    required int year,
  }) {
    return _fees
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .orderBy('studentName')
        .snapshots()
        .map((snap) =>
        snap.docs.map(FeeModel.fromFirestore).toList());
  }

  // Stream all fee records for one student
  Stream<List<FeeModel>> streamStudentFees(String studentId) {
    return _fees
        .where('studentId', isEqualTo: studentId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map(FeeModel.fromFirestore).toList());
  }

  // Generate fee records for all students for a given month
  // Admin runs this at the start of each month
  Future<void> generateMonthlyFees({
    required List<Map<String, dynamic>> students,
    required int month,
    required int year,
  }) async {
    // Use a batch write — writes all records atomically
    // Either all succeed or all fail — no partial states
    final batch = _db.batch();

    for (final student in students) {
      final docId = '${student['id']}_${year}_$month';
      final feeAmount =
      await getClassFeeAmount(student['classId']);

      // Only create if doesn't already exist
      final existing = await _fees.doc(docId).get();
      if (!existing.exists) {
        batch.set(_fees.doc(docId), {
          'studentId': student['id'],
          'studentName': student['name'],
          'classId': student['classId'],
          'month': month,
          'year': year,
          'amountDue': feeAmount,
          'amountPaid': 0,
          'balance': feeAmount,
          'payments': [],
          'status': 'unpaid',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // Record a payment — full or partial
  Future<void> recordPayment({
    required String feeId,
    required double amount,
    required String recordedBy,
    String note = '',
  }) async {
    final doc = await _fees.doc(feeId).get();
    if (!doc.exists) throw Exception('Fee record not found');

    final fee = FeeModel.fromFirestore(doc);

    // Add new payment to the list
    final updatedPayments = [
      ...fee.payments,
      PaymentRecord(
        amount: amount,
        date: DateTime.now(),
        recordedBy: recordedBy,
        note: note,
      ),
    ];

    // Calculate new total paid
    final newAmountPaid = updatedPayments
        .fold(0.0, (sum, p) => sum + p.amount);

    // Determine new status
    final newBalance = fee.amountDue - newAmountPaid;
    final newStatus = newBalance <= 0
        ? 'paid'
        : newAmountPaid > 0
        ? 'partial'
        : 'unpaid';

    await _fees.doc(feeId).update({
      'payments': updatedPayments.map((p) => p.toMap()).toList(),
      'amountPaid': newAmountPaid,
      'balance': newBalance,
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}