import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../models/student_model.dart';
import 'add_student_screen.dart';

// Changed to ConsumerWidget — needs ref to watch studentsStreamProvider
class StudentsListScreen extends ConsumerWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch the stream provider — rebuilds automatically when data changes
    // This replaces the old StreamBuilder + StudentService() pattern
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to AddStudentScreen
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar — UI only for now
            TextField(
              decoration: InputDecoration(
                hintText: "Search students...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant
                    .withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Student list — uses Riverpod AsyncValue instead of StreamBuilder
            Expanded(
              child: studentsAsync.when(
                // Loading state
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),

                // Error state
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load students',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Data state
                data: (students) {
                  if (students.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to enroll a new student',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentTile(
                        student: student,
                        onTap: () {
                          // TODO: Navigate to StudentProfileScreen
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= STUDENT TILE =================

class _StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentTile({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          // Show photo if available, otherwise show initials
          backgroundImage: student.photoUrl != null
              ? NetworkImage(student.photoUrl!)
              : null,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: student.photoUrl == null
              ? Text(
            // First letter of name as avatar
            student.name.isNotEmpty
                ? student.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        title: Text(
          student.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${student.className} • Age ${student.age}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active/inactive badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: student.active
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student.active ? 'Enrolled' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: student.active ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}