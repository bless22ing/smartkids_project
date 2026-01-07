import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../records/records_hub_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  final StudentModel student;

  const StudentProfileScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(student: student),
            const SizedBox(height: 24),
            _InfoSection(student: student),
            const SizedBox(height: 32),
            _RecordsSection(studentId: student.id),
          ],
        ),
      ),
    );
  }
}

// ================= PROFILE HEADER =================

class _ProfileHeader extends StatelessWidget {
  final StudentModel student;

  const _ProfileHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor:
            theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              student.name.isNotEmpty ? student.name[0] : "?",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student.name,
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

// ================= INFO SECTION =================

class _InfoSection extends StatelessWidget {
  final StudentModel student;

  const _InfoSection({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoTile(label: "Grade", value: student.grade),
            const SizedBox(height: 12),
            _InfoTile(label: "Gender", value: student.gender),
            const SizedBox(height: 12),
            _InfoTile(label: "Parent", value: student.parent),
          ],
        ),
      ),
    );
  }
}

// ================= RECORDS HUB =================

class _RecordsSection extends StatelessWidget {
  final String studentId;

  const _RecordsSection({required this.studentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final records = [
      _RecordItem("Anecdotal Records", Icons.note_alt_outlined),
      _RecordItem("Attendance", Icons.check_circle_outline),
      _RecordItem("Progress Record", Icons.trending_up),
      _RecordItem("Reading Record", Icons.menu_book_outlined),
      _RecordItem("Developmental Checklist", Icons.fact_check_outlined),
      _RecordItem("Remedial Work", Icons.build_outlined),
      _RecordItem("Extension Work", Icons.star_outline),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Student Records",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = records[index];

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordsHubScreen(
                      title: item.title,
                      studentId: studentId,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ================= INFO TILE =================

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

// ================= RECORD ITEM MODEL =================

class _RecordItem {
  final String title;
  final IconData icon;

  _RecordItem(this.title, this.icon);
}
