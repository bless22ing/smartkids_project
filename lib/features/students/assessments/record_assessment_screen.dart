import 'package:flutter/material.dart';
import '../models/student_model.dart';

enum AchievementLevel {
  beginning,
  developing,
  achieved,
  exceeding,
}

class RecordAssessmentScreen extends StatefulWidget {
  final StudentModel student;
  final String assessmentTitle;

  const RecordAssessmentScreen({
    super.key,
    required this.student,
    required this.assessmentTitle,
  });

  @override
  State<RecordAssessmentScreen> createState() =>
      _RecordAssessmentScreenState();
}

class _RecordAssessmentScreenState extends State<RecordAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  AchievementLevel selectedLevel = AchievementLevel.developing;
  String teacherComment = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Assessment'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveRecord,
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StudentHeader(student: widget.student),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.assessmentTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Achievement Level
                      DropdownButtonFormField<AchievementLevel>(
                        value: selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Achievement Level',
                        ),
                        items: AchievementLevel.values.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(_formatLevel(level)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedLevel = value!);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Teacher Comment
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Teacher Comment',
                          hintText:
                          'Short observation about the learner',
                        ),
                        maxLines: 3,
                        validator: (value) =>
                        value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => teacherComment = value!,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRecord() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Later: Save to DB / API
    debugPrint('Assessment Recorded');
    debugPrint('Student: ${widget.student.name}');
    debugPrint('Level: $selectedLevel');
    debugPrint('Comment: $teacherComment');

    Navigator.pop(context);
  }

  String _formatLevel(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.beginning:
        return 'Beginning';
      case AchievementLevel.developing:
        return 'Developing';
      case AchievementLevel.achieved:
        return 'Achieved';
      case AchievementLevel.exceeding:
        return 'Exceeding';
    }
  }
}

// ================= STUDENT HEADER =================

class _StudentHeader extends StatelessWidget {
  final StudentModel student;

  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Text(
                student.name.isNotEmpty ? student.name[0] : "?",
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  student.grade,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
