import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String name;
  final String grade;
  final String gender;
  final String parent;
  final bool active;

  StudentModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.gender,
    required this.parent,
    required this.active,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      id: doc.id,
      name: data['name'],
      grade: data['grade'],
      gender: data['gender'],
      parent: data['parent'],
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grade': grade,
      'gender': gender,
      'parent': parent,
      'active': active,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
