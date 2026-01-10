import 'assessment_model.dart';

class StudentAssessmentModel {
  final String id;
  final String studentId;
  final String assessmentId;

  /// One of these will be used
  final int? score;
  final RatingScale? rating;

  final String teacherComment;

  /// Optional uploads
  final List<String> attachments; // image/pdf paths

  final DateTime recordedAt;
  final String recordedBy; // teacherId

  StudentAssessmentModel({
    required this.id,
    required this.studentId,
    required this.assessmentId,
    this.score,
    this.rating,
    required this.teacherComment,
    this.attachments = const [],
    required this.recordedAt,
    required this.recordedBy,
  });

  factory StudentAssessmentModel.fromMap(Map<String, dynamic> map) {
    return StudentAssessmentModel(
      id: map['id'],
      studentId: map['studentId'],
      assessmentId: map['assessmentId'],
      score: map['score'],
      rating:
      map['rating'] != null ? RatingScale.values.byName(map['rating']) : null,
      teacherComment: map['teacherComment'],
      attachments: List<String>.from(map['attachments'] ?? []),
      recordedAt: DateTime.parse(map['recordedAt']),
      recordedBy: map['recordedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'assessmentId': assessmentId,
      'score': score,
      'rating': rating?.name,
      'teacherComment': teacherComment,
      'attachments': attachments,
      'recordedAt': recordedAt.toIso8601String(),
      'recordedBy': recordedBy,
    };
  }
}
