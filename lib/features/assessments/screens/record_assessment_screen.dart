import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../models/student_assessment_model.dart';
import '../services/assessment_service.dart';

class RecordAssessmentScreen extends StatefulWidget {
  final AssessmentModel assessment;
  final AssessmentService service;

  const RecordAssessmentScreen({
    super.key,
    required this.assessment,
    required this.service,
  });

  @override
  State<RecordAssessmentScreen> createState() =>
      _RecordAssessmentScreenState();
}

class _RecordAssessmentScreenState
    extends State<RecordAssessmentScreen> {

  String studentId = "student1";
  int? score;
  RatingScale? rating;
  String comment = "";

  @override
  Widget build(BuildContext context) {
    final usesRating = widget.assessment.usesRatingScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assessment.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            if (!usesRating)
              TextField(
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: "Score"),
                onChanged: (v) => score = int.tryParse(v),
              )
            else
              DropdownButtonFormField(
                value: rating,
                items: RatingScale.values
                    .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.name),
                ))
                    .toList(),
                onChanged: (v) => rating = v!,
                decoration:
                const InputDecoration(labelText: "Rating"),
              ),

            TextField(
              decoration:
              const InputDecoration(labelText: "Comment"),
              onChanged: (v) => comment = v,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Save"),
              onPressed: _save,
            )
          ],
        ),
      ),
    );
  }

  void _save() {
    final result = StudentAssessmentModel(
      id: DateTime.now().toString(),
      studentId: studentId,
      assessmentId: widget.assessment.id,
      score: score,
      rating: rating,
      teacherComment: comment,
      recordedAt: DateTime.now(),
      recordedBy: "teacher1",
    );

    widget.service.addStudentAssessment(result);
    Navigator.pop(context);
  }
}