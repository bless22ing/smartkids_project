import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../services/assessment_service.dart';

class CreateAssessmentScreen extends StatefulWidget {
  final AssessmentService service;

  const CreateAssessmentScreen({super.key, required this.service});

  @override
  State<CreateAssessmentScreen> createState() =>
      _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState
    extends State<CreateAssessmentScreen> {

  final _formKey = GlobalKey<FormState>();

  String title = "";
  String subject = "Literacy";
  String classLevel = "ECD A";
  String term = "Term 1";
  AssessmentType type = AssessmentType.observation;
  bool usesRatingScale = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Assessment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                decoration: const InputDecoration(labelText: "Title"),
                onChanged: (v) => title = v,
                validator: (v) =>
                v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: subject,
                items: ["Literacy", "Numeracy", "Motor Skills"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (v) => subject = v!,
                decoration:
                const InputDecoration(labelText: "Subject"),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: classLevel,
                items: ["ECD A", "ECD B"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (v) => classLevel = v!,
                decoration:
                const InputDecoration(labelText: "Class"),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text("Use Rating Scale"),
                value: usesRatingScale,
                onChanged: (v) {
                  setState(() => usesRatingScale = v);
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                child: const Text("Create"),
                onPressed: _save,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final assessment = AssessmentModel(
      id: DateTime.now().toString(),
      title: title,
      description: "",
      subject: subject,
      classLevel: classLevel,
      term: term,
      type: type,
      usesRatingScale: usesRatingScale,
      createdAt: DateTime.now(),
      createdBy: "teacher1",
    );

    widget.service.createAssessment(assessment);
    Navigator.pop(context);
  }
}