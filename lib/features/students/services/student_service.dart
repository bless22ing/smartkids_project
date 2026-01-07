import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _students =>
      _db.collection('schools').doc('defaultSchool').collection('students');

  Stream<List<StudentModel>> streamStudents() {
    return _students
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map(StudentModel.fromFirestore).toList());
  }

  Future<void> addStudent(StudentModel student) {
    return _students.add(student.toMap());
  }

  Future<void> updateStudent(StudentModel student) {
    return _students.doc(student.id).update(student.toMap());
  }
}
