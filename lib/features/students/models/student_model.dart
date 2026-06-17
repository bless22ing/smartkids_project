import 'package:cloud_firestore/cloud_firestore.dart';

// Guardian model — used for both parents and next of kin
// Separate class because it's a reusable concept
class GuardianModel {
  final String name;
  final String contact;
  final String email;
  final String relationship; // "Mother", "Father", "Uncle" etc.

  const GuardianModel({
    required this.name,
    required this.contact,
    required this.email,
    required this.relationship,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'relationship': relationship,
    };
  }

  // Build from Firestore map
  factory GuardianModel.fromMap(Map<String, dynamic> map) {
    return GuardianModel(
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      email: map['email'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  // Empty guardian — used as default when no data exists
  factory GuardianModel.empty() {
    return const GuardianModel(
      name: '',
      contact: '',
      email: '',
      relationship: '',
    );
  }
}

class StudentModel {
  final String id;

  // Personal details
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String? photoUrl; // nullable — not every student has a photo

  // School details
  final String classId; // "ecda" or "ecdb"
  final DateTime enrollmentDate;

  // Guardians — two separate guardian objects
  final GuardianModel guardian1;
  final GuardianModel guardian2;

  // Next of kin — separate from guardians
  final GuardianModel nextOfKin;

  // Medical
  final String allergies;
  final String medicalNotes;

  // Active status
  final bool active;

  const StudentModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    required this.classId,
    required this.enrollmentDate,
    required this.guardian1,
    required this.guardian2,
    required this.nextOfKin,
    required this.allergies,
    required this.medicalNotes,
    this.active = true,
  });

  // Age is calculated automatically from dateOfBirth
  // We never store age in Firestore because it changes every year
  // This getter computes it fresh every time it's called
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    // Adjust if birthday hasn't happened yet this year
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Human readable class name
  String get className =>
      classId == 'ecda' ? 'ECD A' : 'ECD B';

  // Build StudentModel from a Firestore document
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      id: doc.id,
      name: data['name'] ?? '',
      // Firestore stores dates as Timestamp — convert to DateTime
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      photoUrl: data['photoUrl'],
      classId: data['classId'] ?? 'ecda',
      enrollmentDate: (data['enrollmentDate'] as Timestamp).toDate(),
      // Guardian maps are nested objects in Firestore
      guardian1: data['guardian1'] != null
          ? GuardianModel.fromMap(
          Map<String, dynamic>.from(data['guardian1']))
          : GuardianModel.empty(),
      guardian2: data['guardian2'] != null
          ? GuardianModel.fromMap(
          Map<String, dynamic>.from(data['guardian2']))
          : GuardianModel.empty(),
      nextOfKin: data['nextOfKin'] != null
          ? GuardianModel.fromMap(
          Map<String, dynamic>.from(data['nextOfKin']))
          : GuardianModel.empty(),
      allergies: data['allergies'] ?? '',
      medicalNotes: data['medicalNotes'] ?? '',
      active: data['active'] ?? true,
    );
  }

  // Convert StudentModel to a map to SAVE to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'photoUrl': photoUrl,
      'classId': classId,
      'enrollmentDate': Timestamp.fromDate(enrollmentDate),
      'guardian1': guardian1.toMap(),
      'guardian2': guardian2.toMap(),
      'nextOfKin': nextOfKin.toMap(),
      'allergies': allergies,
      'medicalNotes': medicalNotes,
      'active': active,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}