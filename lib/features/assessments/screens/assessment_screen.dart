import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../services/assessment_service.dart';
import 'create_assessment_screen.dart';
import 'record_assessment_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final AssessmentService service;

  const AssessmentScreen({super.key, required this.service});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    final assessments = widget.service.getAssessments();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assessments"),
      ),
      body: assessments.isEmpty
          ? const Center(child: Text("No assessments created yet"))
          : ListView.builder(
        itemCount: assessments.length,
        itemBuilder: (context, index) {
          final a = assessments[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(a.title),
              subtitle: Text("${a.subject} • ${a.classLevel}"),
              trailing: Text(a.term),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordAssessmentScreen(
                      assessment: a,
                      service: widget.service,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateAssessmentScreen(service: widget.service),
            ),
          );

          setState(() {});
        },
      ),
    );
  }
}