import 'package:flutter/material.dart';
import 'students/models/class_model.dart';

class ClassDetailsScreen extends StatelessWidget {
  final ClassModel classModel;

  const ClassDetailsScreen({
    super.key,
    required this.classModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(classModel.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoTile("Level", classModel.level),
            _InfoTile("Age Range", classModel.ageRange),
            const SizedBox(height: 24),
            Text("Assigned Staff", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _StaffChip("Teacher", "Mrs. Chipo Moyo"),
            _StaffChip("Assistant", "Ms. Rudo Dube"),
            const SizedBox(height: 24),
            Text("Students", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text("18 Students Enrolled"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: View students in class
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HELPERS =================

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _StaffChip extends StatelessWidget {
  final String role;
  final String name;

  const _StaffChip(this.role, this.name);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        avatar: const Icon(Icons.person_outline),
        label: Text("$role: $name"),
      ),
    );
  }
}
