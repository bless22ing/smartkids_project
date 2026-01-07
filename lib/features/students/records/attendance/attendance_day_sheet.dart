import 'package:flutter/material.dart';

class AttendanceDaySheet extends StatefulWidget {
  final DateTime date;

  const AttendanceDaySheet({super.key, required this.date});

  @override
  State<AttendanceDaySheet> createState() => _AttendanceDaySheetState();
}

class _AttendanceDaySheetState extends State<AttendanceDaySheet> {
  String status = "Present";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Attendance for ${widget.date.day}/${widget.date.month}/${widget.date.year}",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            _radio("Present"),
            _radio("Absent"),
            _radio("Sick"),

            const SizedBox(height: 16),
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

  Widget _radio(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: status,
      onChanged: (v) => setState(() => status = v!),
    );
  }
}
