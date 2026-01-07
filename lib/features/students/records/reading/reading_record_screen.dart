import 'package:flutter/material.dart';
import 'add_reading_record_screen.dart';

class ReadingRecordScreen extends StatelessWidget {
  const ReadingRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading Records"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddReadingRecordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6, // dummy data
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _ReadingRecordCard(
            date: "18 Mar 2026",
            book: "Oxford Reading Tree – Level 4",
            skill: "Fluency & comprehension",
            comment:
            "Reads confidently but struggles with inference questions.",
          );
        },
      ),
    );
  }
}

class _ReadingRecordCard extends StatelessWidget {
  final String date;
  final String book;
  final String skill;
  final String comment;

  const _ReadingRecordCard({
    required this.date,
    required this.book,
    required this.skill,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(date),
              ],
            ),
            const SizedBox(height: 12),

            // Book
            Text(
              book,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              skill,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // Comment
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                comment,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

