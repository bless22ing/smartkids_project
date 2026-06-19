import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianModel {
  final String name;
  final String contact;
  final String email;
  final String relationship;

  const GuardianModel({
    required this.name,
    required this.contact,
    required this.email,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'relationship': relationship,
    };
  }

  factory GuardianModel.fromMap(Map<String, dynamic> map) {
    return GuardianModel(
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      email: map['email'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  factory GuardianModel.empty() {
    return const GuardianModel(
      name: '', contact: '', email: '', relationship: '',
    );
  }
}

// Boarder or Day scholar — official register terminology
enum ScholarType {
  day,
  boarder;

  String get displayName => this == ScholarType.day ? 'Day' : 'Boarder';
  String get code => this == ScholarType.day ? 'D' : 'B';

  static ScholarType fromString(String value) {
    return value.toUpperCase() == 'B' || value.toLowerCase() == 'boarder'
        ? ScholarType.boarder
        : ScholarType.day;
  }
}

class StudentModel {
  final String id;

  // Personal details
  final String surname;       // NEW — split from name per register
  final String firstName;     // NEW — split from name per register
  final DateTime dateOfBirth;
  final String gender;
  final String? photoUrl;

  // Official register fields — NEW
  final String birthCertNo;
  final String religion;
  final ScholarType scholarType;
  final String gamesHouse;

  // School details
  final String classId;
  final DateTime enrollmentDate;
  final int? rollNumber; // NEW — the "No." column on the register

  // Guardians
  final GuardianModel guardian1;
  final GuardianModel guardian2;
  final GuardianModel nextOfKin;

  // Medical
  final String allergies;
  final String medicalNotes;

  final bool active;

  const StudentModel({
    required this.id,
    required this.surname,
    required this.firstName,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    this.birthCertNo = '',
    this.religion = '',
    this.scholarType = ScholarType.day,
    this.gamesHouse = '',
    required this.classId,
    required this.enrollmentDate,
    this.rollNumber,
    required this.guardian1,
    required this.guardian2,
    required this.nextOfKin,
    required this.allergies,
    required this.medicalNotes,
    this.active = true,
  });

  // Full name — combines surname + first name for display
  // This is what most of the app will use instead of a single 'name' field
  String get name => '$firstName $surname';

  // Register-style display — SURNAME, Firstname (how official documents show it)
  String get registerName => '${surname.toUpperCase()}, $firstName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get className => classId == 'ecda' ? 'ECD A' : 'ECD B';

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      id: doc.id,
      surname: data['surname'] ?? '',
      firstName: data['firstName'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      photoUrl: data['photoUrl'],
      birthCertNo: data['birthCertNo'] ?? '',
      religion: data['religion'] ?? '',
      scholarType: ScholarType.fromString(data['scholarType'] ?? 'day'),
      gamesHouse: data['gamesHouse'] ?? '',
      classId: data['classId'] ?? 'ecda',
      enrollmentDate: (data['enrollmentDate'] as Timestamp).toDate(),
      rollNumber: data['rollNumber'],
      guardian1: data['guardian1'] != null
          ? GuardianModel.fromMap(Map<String, dynamic>.from(data['guardian1']))
          : GuardianModel.empty(),
      guardian2: data['guardian2'] != null
          ? GuardianModel.fromMap(Map<String, dynamic>.from(data['guardian2']))
          : GuardianModel.empty(),
      nextOfKin: data['nextOfKin'] != null
          ? GuardianModel.fromMap(Map<String, dynamic>.from(data['nextOfKin']))
          : GuardianModel.empty(),
      allergies: data['allergies'] ?? '',
      medicalNotes: data['medicalNotes'] ?? '',
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surname': surname,
      'firstName': firstName,
      'name': name, // also store combined name for easy querying/sorting
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'photoUrl': photoUrl,
      'birthCertNo': birthCertNo,
      'religion': religion,
      'scholarType': scholarType.name,
      'gamesHouse': gamesHouse,
      'classId': classId,
      'enrollmentDate': Timestamp.fromDate(enrollmentDate),
      'rollNumber': rollNumber,
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