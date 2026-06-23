import 'package:cloud_firestore/cloud_firestore.dart';

// The 6 fixed subjects from the school's report card
// Single source of truth — same pattern as SocialSkills
class ReportSubjects {
  static const english = 'english';
  static const chishona = 'chishona';
  static const mathematics = 'mathematics';
  static const peAndArts = 'peAndArts';
  static const scienceAndTech = 'scienceAndTech';
  static const socialScience = 'socialScience';

  static const Map<String, String> displayNames = {
    english: 'English',
    chishona: 'Chishona',
    mathematics: 'Mathematics',
    peAndArts: 'Physical Education & Arts',
    scienceAndTech: 'Science and Technology',
    socialScience: 'Social Science',
  };

  static const List<String> all = [
    english,
    chishona,
    mathematics,
    peAndArts,
    scienceAndTech,
    socialScience,
  ];
}

// Marks for a single subject
class SubjectMark {
  final double possibleMark;
  final double obtainedMark;
  final String comment;

  const SubjectMark({
    required this.possibleMark,
    required this.obtainedMark,
    this.comment = '',
  });

  factory SubjectMark.fromMap(Map<String, dynamic> map) {
    return SubjectMark(
      possibleMark: (map['possibleMark'] ?? 0).toDouble(),
      obtainedMark: (map['obtainedMark'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'possibleMark': possibleMark,
      'obtainedMark': obtainedMark,
      'comment': comment,
    };
  }

  factory SubjectMark.empty() {
    return const SubjectMark(possibleMark: 0, obtainedMark: 0);
  }
}

// A complete report card for one student, one term
class ReportCardModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String grade;       // e.g. "Infant" — shown at top
  final String term;        // "Term 1", "Term 2", "Term 3"
  final int year;

  // Position fields — entered manually by teacher
  final int? positionInClass;
  final int? positionOutOf;
  final String? gradePosition;
  final int? gradePositionOutOf;

  // Attendance — can pull from our existing attendance data,
  // but stored here too so the report is a frozen snapshot
  final int attendanceDays;
  final int attendanceOutOfDays;

  // Marks per subject
  final Map<String, SubjectMark> marks;

  // Comments
  final String teacherComments;
  final String headComments;

  // Admin fields
  final double nextTermFees;
  final DateTime? nextTermBegins;

  final String createdBy;
  final DateTime createdAt;

  const ReportCardModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.grade,
    required this.term,
    required this.year,
    this.positionInClass,
    this.positionOutOf,
    this.gradePosition,
    this.gradePositionOutOf,
    required this.attendanceDays,
    required this.attendanceOutOfDays,
    required this.marks,
    this.teacherComments = '',
    this.headComments = '',
    this.nextTermFees = 0,
    this.nextTermBegins,
    required this.createdBy,
    required this.createdAt,
  });

  // Grand total — sums all subjects automatically
  double get grandTotalPossible =>
      marks.values.fold(0, (sum, m) => sum + m.possibleMark);

  double get grandTotalObtained =>
      marks.values.fold(0, (sum, m) => sum + m.obtainedMark);

  factory ReportCardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final marksData = Map<String, dynamic>.from(data['marks'] ?? {});
    final marks = marksData.map(
          (key, value) =>
          MapEntry(key, SubjectMark.fromMap(Map<String, dynamic>.from(value))),
    );

    return ReportCardModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      grade: data['grade'] ?? 'Infant',
      term: data['term'] ?? 'Term 1',
      year: data['year'] ?? DateTime.now().year,
      positionInClass: data['positionInClass'],
      positionOutOf: data['positionOutOf'],
      gradePosition: data['gradePosition'],
      gradePositionOutOf: data['gradePositionOutOf'],
      attendanceDays: data['attendanceDays'] ?? 0,
      attendanceOutOfDays: data['attendanceOutOfDays'] ?? 0,
      marks: marks,
      teacherComments: data['teacherComments'] ?? '',
      headComments: data['headComments'] ?? '',
      nextTermFees: (data['nextTermFees'] ?? 0).toDouble(),
      nextTermBegins: data['nextTermBegins'] != null
          ? (data['nextTermBegins'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'grade': grade,
      'term': term,
      'year': year,
      'positionInClass': positionInClass,
      'positionOutOf': positionOutOf,
      'gradePosition': gradePosition,
      'gradePositionOutOf': gradePositionOutOf,
      'attendanceDays': attendanceDays,
      'attendanceOutOfDays': attendanceOutOfDays,
      'marks': marks.map((key, value) => MapEntry(key, value.toMap())),
      'teacherComments': teacherComments,
      'headComments': headComments,
      'nextTermFees': nextTermFees,
      'nextTermBegins': nextTermBegins != null
          ? Timestamp.fromDate(nextTermBegins!)
          : null,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}