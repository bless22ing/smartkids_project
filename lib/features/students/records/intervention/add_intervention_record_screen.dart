import 'package:flutter/material.dart';
import 'intervention_record_screen1.dart';

class AddInterventionRecordScreen extends StatefulWidget {
  final InterventionType type;

  const AddInterventionRecordScreen({
    super.key,
    required this.type,
  });

  @override
  State<AddInterventionRecordScreen> createState() =>
      _AddInterventionRecordScreenState();
}

class _AddInterventionRecordScreenState
    extends State<AddInterventionRecordScreen> {
  final titleCtrl = TextEditingController();
  final strategyCtrl = TextEditingController();
  final outcomeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isRemedial = widget.type == InterventionType.remedial;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRemedial ? "Add Remedial Record" : "Add Extension Record",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _input(
              label: isRemedial
                  ? "Learning Difficulty"
                  : "Advanced Task / Activity",
              controller: titleCtrl,
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            _input(
              label: "Strategy / Approach",
              controller: strategyCtrl,
              icon: Icons.build_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _input(
              label: "Outcome / Comment",
              controller: outcomeCtrl,
              icon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save to Firebase
                  Navigator.pop(context);
                },
                child: const Text("Save Record"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:
        theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
