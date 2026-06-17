import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_constants.dart';
import '../models/student_model.dart';

// Riverpod provider — one instance of StudentService for the whole app
// Any widget can access it via ref.read(studentServiceProvider)
final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService();
});

// StreamProvider — streams ALL students in real time
// When Firestore data changes, any widget watching this rebuilds automatically
final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return ref.read(studentServiceProvider).streamStudents();
});

// StreamProvider for a specific class — ECD A or ECD B
// Takes the classId as a parameter using .family
// Usage: ref.watch(classStudentsProvider('ecda'))
final classStudentsProvider =
StreamProvider.family<List<StudentModel>, String>((ref, classId) {
  return ref.read(studentServiceProvider).streamStudentsByClass(classId);
});

class StudentService {
  final _db = FirebaseFirestore.instance;

  // Using AppConstants for collection name — never hardcode strings
  CollectionReference get _students =>
      _db.collection(AppConstants.studentsCollection);

  // Stream all students ordered by name
  Stream<List<StudentModel>> streamStudents() {
    return _students
        .orderBy('name')
        .snapshots()
        .map((snap) =>
        snap.docs.map(StudentModel.fromFirestore).toList());
  }

  // Stream students filtered by class
  // This is what teachers use — they only see their class
  Stream<List<StudentModel>> streamStudentsByClass(String classId) {
    return _students
        .where('classId', isEqualTo: classId)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
        snap.docs.map(StudentModel.fromFirestore).toList());
  }

  // Add a new student
  Future<void> addStudent(StudentModel student) async {
    await _students.add(student.toMap());
  }

  // Update existing student
  Future<void> updateStudent(StudentModel student) async {
    await _students.doc(student.id).update(student.toMap());
  }

  // Deactivate student — we never delete, just mark inactive
  // This preserves historical records like attendance and assessments
  Future<void> deactivateStudent(String studentId) async {
    await _students.doc(studentId).update({'active': false});
  }

  // Get a single student by ID — used for profile screen
  Future<StudentModel?> getStudent(String studentId) async {
    final doc = await _students.doc(studentId).get();
    if (!doc.exists) return null;
    return StudentModel.fromFirestore(doc);
  }
}