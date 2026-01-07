import 'package:flutter/material.dart';

class AddReadingRecordScreen extends StatefulWidget {
  const AddReadingRecordScreen({super.key});

  @override
  State<AddReadingRecordScreen> createState() =>
      _AddReadingRecordScreenState();
}

class _AddReadingRecordScreenState extends State<AddReadingRecordScreen> {
  final bookCtrl = TextEditingController();
  final skillCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reading Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _input(
              label: "Book / Text",
              controller: bookCtrl,
              icon: Icons.menu_book_outlined,
            ),
            const SizedBox(height: 16),
            _input(
              label: "Reading Skill / Level",
              controller: skillCtrl,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 16),
            _input(
              label: "Teacher Comment",
              controller: commentCtrl,
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
