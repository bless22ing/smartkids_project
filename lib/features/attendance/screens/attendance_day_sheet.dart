import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/app_constants.dart';

// ConsumerStatefulWidget because we need:
// - local state (status, loading, selectedStudentId)
// - ref to access Firestore through a provider later
class AttendanceDaySheet extends ConsumerStatefulWidget {
  final DateTime date;
  final String classId; // which class — ecda or ecdb

  const AttendanceDaySheet({
    super.key,
    required this.date,
    required this.classId,
  });

  @override
  ConsumerState<AttendanceDaySheet> createState() =>
      _AttendanceDaySheetState();
}

class _AttendanceDaySheetState extends ConsumerState<AttendanceDaySheet> {
  // Using the enum now instead of raw strings
  AttendanceStatus status = AttendanceStatus.present;
  bool _saving = false;

  // Saves the attendance record to Firestore
  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      // Build the document ID from class + date
      // e.g. "ecda_2024-06-17" — unique per class per day
      final docId =
          '${widget.classId}_${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

      // Save to Firestore attendance collection
      await FirebaseFirestore.instance
          .collection(AppConstants.attendanceCollection)
          .doc(docId)
          .set({
        'classId': widget.classId,
        'date': Timestamp.fromDate(widget.date),
        // status stored as string using enum name
        // AttendanceStatus.present.name gives us "present"
        'status': status.name,
        'className': AppConstants.classDisplayName(widget.classId),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // merge: true means if the document exists, update it
      // don't overwrite everything — just the fields we're setting

      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format date nicely for display
    final formattedDate =
        '${widget.date.day}/${widget.date.month}/${widget.date.year}';

    // Get class display name — "ECD A" or "ECD B"
    final className = AppConstants.classDisplayName(widget.classId);

    return Padding(
      // viewInsets accounts for keyboard height
      // sheet moves up when keyboard appears
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mark Attendance",
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      "$className — $formattedDate",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status selection using enum values
            // AttendanceStatus.values gives us all three automatically
            ...AttendanceStatus.values.map((s) {
              return RadioListTile<AttendanceStatus>(
                title: Text(s.displayName),
                subtitle: Text(s.description),
                value: s,
                groupValue: status,
                activeColor: s.color,
                onChanged: (v) => setState(() => status = v!),
              );
            }),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Save Attendance",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Enum defined here and imported by attendance_screen.dart
// We moved it here because it belongs with the sheet that uses it most
enum AttendanceStatus {
  present,
  absent,
  sick;

  // Human readable name shown in the UI
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.sick:
        return 'Sick';
    }
  }

  // Short description shown as subtitle in radio buttons
  String get description {
    switch (this) {
      case AttendanceStatus.present:
        return 'Child attended school today';
      case AttendanceStatus.absent:
        return 'Child did not attend — no reason given';
      case AttendanceStatus.sick:
        return 'Child is unwell';
    }
  }

  // Color for each status — used in radio buttons and lists
  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.sick:
        return Colors.orange;
    }
  }
}