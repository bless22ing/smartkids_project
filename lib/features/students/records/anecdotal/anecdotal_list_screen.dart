import 'package:flutter/material.dart';
import 'add_anecdotal_screen.dart';

class AnecdotalListScreen extends StatelessWidget {
  const AnecdotalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Anecdotal Records"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAnecdotalScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // dummy for now
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _AnecdotalCard(
            date: "12 Mar 2026",
            time: "10:30 AM",
            note:
            "Student showed difficulty focusing during group activity.",
            followUp: "Monitor attention span next week.",
          );
        },
      ),
    );
  }
}

class _AnecdotalCard extends StatelessWidget {
  final String date;
  final String time;
  final String note;
  final String followUp;

  const _AnecdotalCard({
    required this.date,
    required this.time,
    required this.note,
    required this.followUp,
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
            // Date & Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(date),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(time),
              ],
            ),
            const SizedBox(height: 12),

            // Observation
            Text(
              note,
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 12),

            // Follow up
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      followUp,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
