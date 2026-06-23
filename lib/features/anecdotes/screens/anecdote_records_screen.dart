import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/services/student_service.dart';
import '../../students/models/student_model.dart';
import '../models/anecdote_model.dart';
import '../services/anecdote_service.dart';
import 'add_anecdote_screen.dart';

class AnecdoteRecordsScreen extends ConsumerWidget {
  const AnecdoteRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Anecdote Records')),
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
                    backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
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
                            StudentAnecdotesScreen(student: student),
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

// ================= STUDENT ANECDOTES SCREEN =================

class StudentAnecdotesScreen extends ConsumerWidget {
  final StudentModel student;
  const StudentAnecdotesScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final anecdotesAsync =
    ref.watch(studentAnecdotesProvider(student.id));

    return Scaffold(
      appBar: AppBar(title: Text('${student.name} — Anecdotes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAnecdoteScreen(student: student),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Anecdote'),
      ),
      body: anecdotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (anecdotes) {
          if (anecdotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined,
                      size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text('No anecdotes yet',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "New Anecdote" to record an observation',
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
            itemCount: anecdotes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _AnecdoteCard(anecdote: anecdotes[index]);
            },
          );
        },
      ),
    );
  }
}

// ================= ANECDOTE CARD =================

class _AnecdoteCard extends StatelessWidget {
  final AnecdoteModel anecdote;
  const _AnecdoteCard({required this.anecdote});

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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: anecdote.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(anecdote.category.icon,
                          size: 14, color: anecdote.category.color),
                      const SizedBox(width: 4),
                      Text(
                        anecdote.category.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: anecdote.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${anecdote.date.day}/${anecdote.date.month}/${anecdote.date.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(anecdote.observation),

            const SizedBox(height: 8),

            Text(
              '— ${anecdote.recordedByName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}