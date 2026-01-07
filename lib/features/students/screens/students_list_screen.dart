import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = StudentService();

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
            // 🔍 SEARCH (UI only for now)
            TextField(
              decoration: InputDecoration(
                hintText: "Search students...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor:
                theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📋 STUDENTS LIST (Firestore)
            Expanded(
              child: StreamBuilder<List<StudentModel>>(
                stream: service.streamStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("No students found"));
                  }

                  final students = snapshot.data!;

                  return ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = students[index];

                      return _StudentTile(
                        name: s.name,
                        grade: s.grade,
                        onTap: () {
                          // NEXT: StudentProfileScreen(student: s)
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

class _StudentTile extends StatelessWidget {
  final String name;
  final String grade;
  final VoidCallback onTap;

  const _StudentTile({
    required this.name,
    required this.grade,
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
          backgroundColor:
          theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            Icons.person,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(grade),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.disabledColor,
        ),
      ),
    );
  }
}
