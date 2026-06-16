import 'package:flutter/material.dart';

enum AssessmentType {
  observation,
  oral,
  practical,
  worksheet,
}

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() =>
      _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String selectedClass = 'ECD A';
  AssessmentType selectedType = AssessmentType.observation;
  String selectedTerm = 'Term 1';
  String learningArea = '';
  String instructions = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Assessment'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAssessment,
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assessment Details",
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Class
                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration:
                    const InputDecoration(labelText: 'Class'),
                    items: const [
                      DropdownMenuItem(
                          value: 'ECD A', child: Text('ECD A')),
                      DropdownMenuItem(
                          value: 'ECD B', child: Text('ECD B')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedClass = value!);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Assessment Type
                  DropdownButtonFormField<AssessmentType>(
                    value: selectedType,
                    decoration:
                    const InputDecoration(labelText: 'Assessment Type'),
                    items: AssessmentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.name[0].toUpperCase() +
                              type.name.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Term
                  DropdownButtonFormField<String>(
                    value: selectedTerm,
                    decoration:
                    const InputDecoration(labelText: 'Term'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Term 1', child: Text('Term 1')),
                      DropdownMenuItem(
                          value: 'Term 2', child: Text('Term 2')),
                      DropdownMenuItem(
                          value: 'Term 3', child: Text('Term 3')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedTerm = value!);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Learning Area
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Learning Area',
                      hintText: 'e.g. Language, Numeracy',
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => learningArea = value!,
                  ),

                  const SizedBox(height: 16),

                  // Instructions
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Teacher Instructions',
                    ),
                    maxLines: 3,
                    onSaved: (value) => instructions = value ?? '',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveAssessment() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Later: save to database / Firestore / API
    debugPrint('Assessment Created');
    debugPrint('Class: $selectedClass');
    debugPrint('Type: $selectedType');
    debugPrint('Term: $selectedTerm');
    debugPrint('Learning Area: $learningArea');

    Navigator.pop(context);
  }
}
