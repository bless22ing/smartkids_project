import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single payment made towards a fee
class PaymentRecord {
  final double amount;
  final DateTime date;
  final String recordedBy; // uid of admin
  final String note;

  const PaymentRecord({
    required this.amount,
    required this.date,
    required this.recordedBy,
    this.note = '',
  });

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      recordedBy: map['recordedBy'] ?? '',
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'recordedBy': recordedBy,
      'note': note,
    };
  }
}

// Fee status enum — calculated from balance
enum FeeStatus {
  paid,
  partial,
  unpaid;

  String get displayName {
    switch (this) {
      case FeeStatus.paid:
        return 'Paid';
      case FeeStatus.partial:
        return 'Partial';
      case FeeStatus.unpaid:
        return 'Unpaid';
    }
  }

  Color get color {
    switch (this) {
      case FeeStatus.paid:
        return const Color(0xFF66BB6A); // green
      case FeeStatus.partial:
        return const Color(0xFFFFB74D); // orange
      case FeeStatus.unpaid:
        return const Color(0xFFEF5350); // red
    }
  }
}

// Represents a student's fee record for a specific month
class FeeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final int month;
  final int year;
  final double amountDue;
  final double amountPaid;
  final List<PaymentRecord> payments;

  const FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.month,
    required this.year,
    required this.amountDue,
    required this.amountPaid,
    required this.payments,
  });

  // Balance is always calculated — never stored directly
  // This prevents inconsistencies between stored and actual balance
  double get balance => amountDue - amountPaid;

  // Status is derived from balance — never stored
  FeeStatus get status {
    if (balance <= 0) return FeeStatus.paid;
    if (amountPaid > 0) return FeeStatus.partial;
    return FeeStatus.unpaid;
  }

  // Month name for display
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  factory FeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse payments list — it's an array of maps in Firestore
    final paymentsList = (data['payments'] as List<dynamic>? ?? [])
        .map((p) => PaymentRecord.fromMap(Map<String, dynamic>.from(p)))
        .toList();

    return FeeModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      month: data['month'] ?? 1,
      year: data['year'] ?? DateTime.now().year,
      amountDue: (data['amountDue'] ?? 0).toDouble(),
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
      payments: paymentsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'month': month,
      'year': year,
      'amountDue': amountDue,
      'amountPaid': amountPaid,
      'payments': payments.map((p) => p.toMap()).toList(),
      'status': status.name,
      'balance': balance,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}