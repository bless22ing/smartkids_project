import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/user_permissions.dart';

// Staff status — tracks where they are in the onboarding process
enum StaffStatus {
  invited,   // email sent, account not created yet
  active,    // account created and active
  inactive;  // deactivated by admin

  String get displayName {
    switch (this) {
      case StaffStatus.invited:
        return 'Invited';
      case StaffStatus.active:
        return 'Active';
      case StaffStatus.inactive:
        return 'Inactive';
    }
  }

  Color get color {
    switch (this) {
      case StaffStatus.invited:
        return const Color(0xFFFFB74D); // orange
      case StaffStatus.active:
        return const Color(0xFF66BB6A); // green
      case StaffStatus.inactive:
        return const Color(0xFF9E9E9E); // grey
    }
  }
}

// Staff type — teaching or non-teaching
enum StaffType {
  teaching,
  nonTeaching;

  String get displayName {
    switch (this) {
      case StaffType.teaching:
        return 'Teaching';
      case StaffType.nonTeaching:
        return 'Non-Teaching';
    }
  }

  static StaffType fromString(String value) {
    return StaffType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => StaffType.nonTeaching,
    );
  }
}

// A single qualification entry
class Qualification {
  final String title;        // e.g. "Early Childhood Diploma"
  final String institution;  // e.g. "University of Zimbabwe"
  final int year;            // year obtained

  const Qualification({
    required this.title,
    required this.institution,
    required this.year,
  });

  factory Qualification.fromMap(Map<String, dynamic> map) {
    return Qualification(
      title: map['title'] ?? '',
      institution: map['institution'] ?? '',
      year: map['year'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'institution': institution,
      'year': year,
    };
  }
}

// A salary payment record
class SalaryPayment {
  final double amount;
  final DateTime date;
  final String month;
  final int year;
  final String recordedBy;
  final String note;

  const SalaryPayment({
    required this.amount,
    required this.date,
    required this.month,
    required this.year,
    required this.recordedBy,
    this.note = '',
  });

  factory SalaryPayment.fromMap(Map<String, dynamic> map) {
    return SalaryPayment(
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      month: map['month'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      recordedBy: map['recordedBy'] ?? '',
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'month': month,
      'year': year,
      'recordedBy': recordedBy,
      'note': note,
    };
  }
}

class StaffModel {
  final String id;

  // Personal details
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final DateTime? dateOfBirth;
  final String? photoUrl;

  // Employment details
  final UserRole role;
  final StaffType staffType;
  final String? classId;        // ECD A or ECD B — null for non-teaching
  final String duties;          // description of responsibilities
  final DateTime joinDate;

  // Qualifications
  final List<Qualification> qualifications;

  // Permissions — relevant for assistants
  final UserPermissions permissions;

  // Payment
  final double monthlySalary;
  final List<SalaryPayment> salaryPayments;

  // Status
  final StaffStatus status;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    this.dateOfBirth,
    this.photoUrl,
    required this.role,
    required this.staffType,
    this.classId,
    required this.duties,
    required this.joinDate,
    required this.qualifications,
    required this.permissions,
    required this.monthlySalary,
    required this.salaryPayments,
    required this.status,
  });

  factory StaffModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final qualList = (data['qualifications'] as List<dynamic>? ?? [])
        .map((q) => Qualification.fromMap(Map<String, dynamic>.from(q)))
        .toList();

    final paymentList = (data['salaryPayments'] as List<dynamic>? ?? [])
        .map((p) => SalaryPayment.fromMap(Map<String, dynamic>.from(p)))
        .toList();

    final role = UserRole.fromString(data['role'] ?? 'assistant');

    final UserPermissions permissions;
    if (data['permissions'] != null) {
      permissions = UserPermissions.fromMap(
        Map<String, dynamic>.from(data['permissions']),
      );
    } else {
      permissions = role.defaultPermissions;
    }

    return StaffModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      photoUrl: data['photoUrl'],
      role: role,
      staffType: StaffType.fromString(data['staffType'] ?? 'nonTeaching'),
      classId: data['classId'],
      duties: data['duties'] ?? '',
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : DateTime.now(),
      qualifications: qualList,
      permissions: permissions,
      monthlySalary: (data['monthlySalary'] ?? 0).toDouble(),
      salaryPayments: paymentList,
      status: StaffStatus.values.firstWhere(
            (e) => e.name == (data['status'] ?? 'invited'),
        orElse: () => StaffStatus.invited,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'photoUrl': photoUrl,
      'role': role.name,
      'staffType': staffType.name,
      'classId': classId,
      'duties': duties,
      'joinDate': Timestamp.fromDate(joinDate),
      'qualifications': qualifications.map((q) => q.toMap()).toList(),
      'permissions': permissions.toMap(),
      'monthlySalary': monthlySalary,
      'salaryPayments': salaryPayments.map((p) => p.toMap()).toList(),
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}