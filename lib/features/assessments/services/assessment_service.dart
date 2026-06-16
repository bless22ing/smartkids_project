import '../models/assessment_model.dart';
import '../models/student_assessment_model.dart';

class AssessmentService {
  // Temporary in-memory storage (replace with Firebase later)
  final List<AssessmentModel> _assessments = [];
  final List<StudentAssessmentModel> _studentResults = [];

  // =========================
  // CREATE ASSESSMENT
  // =========================
  void createAssessment(AssessmentModel assessment) {
    _assessments.add(assessment);
  }

  // =========================
  // GET ALL ASSESSMENTS
  // =========================
  List<AssessmentModel> getAssessments() {
    return _assessments;
  }

  // =========================
  // GET BY CLASS
  // =========================
  List<AssessmentModel> getByClass(String classLevel) {
    return _assessments
        .where((a) => a.classLevel == classLevel)
        .toList();
  }

  // =========================
  // SAVE STUDENT RESULT
  // =========================
  void addStudentAssessment(StudentAssessmentModel result) {
    _studentResults.add(result);
  }

  // =========================
  // GET RESULTS FOR ASSESSMENT
  // =========================
  List<StudentAssessmentModel> getResults(String assessmentId) {
    return _studentResults
        .where((r) => r.assessmentId == assessmentId)
        .toList();
  }

  // =========================
  // GET STUDENT RESULTS
  // =========================
  List<StudentAssessmentModel> getStudentResults(String studentId) {
    return _studentResults
        .where((r) => r.studentId == studentId)
        .toList();
  }
}