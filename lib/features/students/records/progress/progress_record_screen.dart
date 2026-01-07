import 'package:flutter/material.dart';
import 'add_progress_record_screen.dart';

class ProgressRecordScreen extends StatefulWidget {
  const ProgressRecordScreen({super.key});

  @override
  State<ProgressRecordScreen> createState() => _ProgressRecordScreenState();
}

class _ProgressRecordScreenState extends State<ProgressRecordScreen> {
  String selectedTerm = "Term 1";

  final terms = ["Term 1", "Term 2", "Term 3"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Records"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProgressRecordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TermSelector(
              terms: terms,
              selected: selectedTerm,
              onChanged: (v) => setState(() => selectedTerm = v),
            ),
            const SizedBox(height: 16),
            Expanded(child: _SubjectsList()),
          ],
        ),
      ),
    );
  }
}

class _TermSelector extends StatelessWidget {
  final List<String> terms;
  final String selected;
  final ValueChanged<String> onChanged;

  const _TermSelector({
    required this.terms,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          value: selected,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          items: terms
              .map(
                (t) => DropdownMenuItem(
              value: t,
              child: Text(t),
            ),
          )
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

class _SubjectsList extends StatelessWidget {
  final subjects = const [
    "Mathematics",
    "English",
    "Science",
    "Social Studies",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Card(
          child: ExpansionTile(
            leading: Icon(
              Icons.book_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(subjects[index]),
            subtitle: const Text("Average: 75%"),
            childrenPadding: const EdgeInsets.all(16),
            children: const [
              _ScoreRow(label: "Test 1", value: "78%"),
              _ScoreRow(label: "Test 2", value: "72%"),
              SizedBox(height: 8),
              Text(
                "Teacher Comment: Shows steady improvement.",
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
