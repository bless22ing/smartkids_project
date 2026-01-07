import 'package:flutter/material.dart';

class AddProgressRecordScreen extends StatefulWidget {
  const AddProgressRecordScreen({super.key});

  @override
  State<AddProgressRecordScreen> createState() =>
      _AddProgressRecordScreenState();
}

class _AddProgressRecordScreenState extends State<AddProgressRecordScreen> {
  final scoreCtrl = TextEditingController();
  final commentCtrl = TextEditingController();
  String subject = "Mathematics";

  final subjects = [
    "Mathematics",
    "English",
    "Science",
    "Social Studies",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Progress Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: subject,
              items: subjects
                  .map(
                    (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => subject = v!),
              decoration: const InputDecoration(
                labelText: "Subject",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scoreCtrl,
              decoration: const InputDecoration(
                labelText: "Score (%)",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Teacher Comment",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
