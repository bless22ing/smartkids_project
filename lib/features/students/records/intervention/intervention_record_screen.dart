import 'package:flutter/material.dart';
import 'add_intervention_record_screen.dart';

enum InterventionType { remedial, extension }

class InterventionRecordScreen extends StatelessWidget {
  final InterventionType type;

  const InterventionRecordScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title =
    type == InterventionType.remedial ? "Remedial Records" : "Extension Records";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddInterventionRecordScreen(type: type),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // dummy
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _InterventionCard(
            title: type == InterventionType.remedial
                ? "Difficulty with fractions"
                : "Advanced problem-solving task",
            strategy: type == InterventionType.remedial
                ? "Used visual aids and one-on-one support"
                : "Introduced Olympiad-style questions",
            outcome: "Student showed improvement",
            date: "22 Mar 2026",
          );
        },
      ),
    );
  }
}

class _InterventionCard extends StatelessWidget {
  final String title;
  final String strategy;
  final String outcome;
  final String date;

  const _InterventionCard({
    required this.title,
    required this.strategy,
    required this.outcome,
    required this.date,
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

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Strategy
            Text(
              "Strategy:",
              style: theme.textTheme.labelMedium,
            ),
            Text(strategy),

            const SizedBox(height: 8),

            // Outcome
            Text(
              "Outcome:",
              style: theme.textTheme.labelMedium,
            ),
            Text(outcome),
          ],
        ),
      ),
    );
  }
}
