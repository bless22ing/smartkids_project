import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/services/student_service.dart';
import '../../students/models/student_model.dart';
import '../../auth/services/auth_service.dart';
import '../models/social_development_model.dart';
import '../services/social_development_service.dart';
import 'add_social_record_screen.dart';

class SocialDevelopmentScreen extends ConsumerWidget {
  const SocialDevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Social Development')),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary
                        .withValues(alpha: 0.12),
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  title: Text(student.name),
                  subtitle: Text(student.className),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentSocialDevScreen(student: student),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= STUDENT SOCIAL DEV SCREEN =================
// Shows history + button to add new record for ONE student

class StudentSocialDevScreen extends ConsumerWidget {
  final StudentModel student;
  const StudentSocialDevScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordsAsync =
    ref.watch(studentSocialRecordsProvider(student.id));

    return Scaffold(
      appBar: AppBar(title: Text('${student.name} — Social Development')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSocialRecordScreen(student: student),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Record'),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text('No records yet',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "New Record" to add the first observation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _RecordCard(record: records[index]);
            },
          );
        },
      ),
    );
  }
}

// ================= RECORD CARD =================

class _RecordCard extends StatelessWidget {
  final SocialDevelopmentRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${record.date.day}/${record.date.month}/${record.date.year}',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  'by ${record.recordedByName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Skill ratings as chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SocialSkills.all
                  .where((key) => record.ratings.containsKey(key))
                  .map((key) {
                final rating = record.ratingFor(key)!;
                return Chip(
                  label: Text(
                    '${SocialSkills.displayNames[key]}: ${rating.displayName}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: rating.color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: rating.color),
                  side: BorderSide.none,
                );
              }).toList(),
            ),

            if (record.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.comment,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}