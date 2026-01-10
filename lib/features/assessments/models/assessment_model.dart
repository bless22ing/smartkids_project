enum AssessmentType {
  observation,
  oral,
  practical,
  worksheet,
}

enum RatingScale {
  excellent,
  good,
  developing,
  needsSupport,
}

class AssessmentModel {
  final String id;
  final String title;
  final String description;

  /// e.g. Literacy, Numeracy, Motor Skills
  final String subject;

  /// ECD A / ECD B
  final String classLevel;

  final String term;
  final AssessmentType type;

  /// Optional: used if marks are needed
  final int? totalMarks;

  /// Used for preschool-friendly grading
  final bool usesRatingScale;

  final DateTime createdAt;
  final String createdBy; // teacherId or adminId

  AssessmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.classLevel,
    required this.term,
    required this.type,
    this.totalMarks,
    required this.usesRatingScale,
    required this.createdAt,
    required this.createdBy,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> map) {
    return AssessmentModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      subject: map['subject'],
      classLevel: map['classLevel'],
      term: map['term'],
      type: AssessmentType.values.byName(map['type']),
      totalMarks: map['totalMarks'],
      usesRatingScale: map['usesRatingScale'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'classLevel': classLevel,
      'term': term,
      'type': type.name,
      'totalMarks': totalMarks,
      'usesRatingScale': usesRatingScale,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
