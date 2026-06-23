import 'package:flutter/material.dart';
import 'package:smartkids_project/features/students/models/student_model.dart';

class AddAnecdotalScreen extends StatefulWidget {
  const AddAnecdotalScreen({super.key, required StudentModel student});

  @override
  State<AddAnecdotalScreen> createState() => _AddAnecdotalScreenState();
}

class _AddAnecdotalScreenState extends State<AddAnecdotalScreen> {
  final observationCtrl = TextEditingController();
  final followUpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Anecdotal Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _input(
              context,
              label: "Observation / Incident",
              controller: observationCtrl,
              icon: Icons.note_alt_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _input(
              context,
              label: "Follow-up / Action",
              controller: followUpCtrl,
              icon: Icons.flag_outlined,
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

  Widget _input(
      BuildContext context, {
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
