import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceRecordScreen extends StatelessWidget {
  final String studentId;

  const AttendanceRecordScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final attendanceRef = FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('attendance')
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAttendanceDialog(context, studentId);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: attendanceRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No attendance records yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return _AttendanceTile(
                date: data['date'] ?? '',
                status: data['status'] ?? 'Unknown',
                note: data['note'] ?? '',
              );
            },
          );
        },
      ),
    );
  }

  // ================= ADD ATTENDANCE DIALOG =================

  void _showAddAttendanceDialog(BuildContext context, String studentId) {
    final dateCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String status = 'Present';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Attendance"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: "Date (YYYY-MM-DD)",
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(
                    value: 'Present',
                    child: Text('Present'),
                  ),
                  DropdownMenuItem(
                    value: 'Absent',
                    child: Text('Absent'),
                  ),
                  DropdownMenuItem(
                    value: 'Late',
                    child: Text('Late'),
                  ),
                ],
                onChanged: (value) {
                  status = value!;
                },
                decoration: const InputDecoration(
                  labelText: "Status",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: "Note (optional)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dateCtrl.text.isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(studentId)
                    .collection('attendance')
                    .add({
                  'date': dateCtrl.text.trim(),
                  'status': status,
                  'note': noteCtrl.text.trim(),
                  'createdAt': Timestamp.now(),
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

// ================= ATTENDANCE TILE =================

class _AttendanceTile extends StatelessWidget {
  final String date;
  final String status;
  final String note;

  const _AttendanceTile({
    required this.date,
    required this.status,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor() {
      switch (status) {
        case 'Present':
          return Colors.green;
        case 'Absent':
          return Colors.red;
        case 'Late':
          return Colors.orange;
        default:
          return theme.disabledColor;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor().withValues(alpha: 0.15),
          child: Icon(
            Icons.check_circle_outline,
            color: statusColor(),
          ),
        ),
        title: Text(date),
        subtitle: note.isNotEmpty ? Text(note) : null,
        trailing: Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor(),
          ),
        ),
      ),
    );
  }
}
