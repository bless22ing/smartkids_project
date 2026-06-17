import 'package:flutter/material.dart';
import 'package:smartkids_project/features/students/records/progress/progress_record_screen.dart';
import 'package:smartkids_project/features/students/records/reading/reading_record_screen.dart';
import '../../attendance/screens/attendance_record_screen.dart';
import 'anecdotal/anecdotal_record_screen.dart';
import 'development/development_checklist_screen.dart';
import 'intervention/intervention_record_screen.dart';

class RecordsHubScreen extends StatelessWidget {
  final String title;
  final String studentId;

  const RecordsHubScreen({
    super.key,
    required this.title,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final records = [
      _RecordItem(
        title: "Anecdotal Records",
        icon: Icons.note_alt_outlined,
        routeKey: "anecdotal",
      ),
      _RecordItem(
        title: "Attendance Records",
        icon: Icons.check_circle_outline,
        routeKey: "attendance",
      ),
      _RecordItem(
        title: "Progress Records",
        icon: Icons.trending_up,
        routeKey: "progress",
      ),
      _RecordItem(
        title: "Reading Records",
        icon: Icons.menu_book_outlined,
        routeKey: "reading",
      ),
      _RecordItem(
        title: "Development Checklist",
        icon: Icons.fact_check_outlined,
        routeKey: "development",
      ),
      _RecordItem(
        title: "Remedial Work",
        icon: Icons.build_outlined,
        routeKey: "remedial",
      ),
      _RecordItem(
        title: "Extension Work",
        icon: Icons.star_outline,
        routeKey: "extension",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: records.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final item = records[index];

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                _navigateToRecord(
                  context,
                  item.routeKey,
                  studentId,
                  item.title,
                );
              },
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= NAVIGATION LOGIC =================

  void _navigateToRecord(
      BuildContext context,
      String type,
      String studentId,
      String title,
      ) {
    if (type == 'anecdotal') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AnecdotalRecordScreen(studentId: studentId),
        ),
      );
      return;
    }

    if (type == 'attendance') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceRecordScreen(studentId: studentId),
        ),
      );
      return;
    }

    if (type == 'progress') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProgressRecordScreen(studentId: studentId),
        ),
      );
      return;
    }

    if (type == 'reading') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingRecordScreen(studentId: studentId),
        ),
      );
      return;
    }

    if (type == 'development') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DevelopmentChecklistScreen(studentId: studentId),
        ),
      );
      return;
    }

    if (type == 'remedial' || type == 'extension') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InterventionRecordScreen(
            studentId: studentId,
            type: type,
          ),
        ),
      );
      return;
    }


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaceholderRecordScreen(
          title: title,
          studentId: studentId,
          type: type,
        ),
      ),
    );
  }
}

// ================= PLACEHOLDER SCREEN =================

class _PlaceholderRecordScreen extends StatelessWidget {
  final String title;
  final String studentId;
  final String type;

  const _PlaceholderRecordScreen({
    required this.title,
    required this.studentId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "Record type: $type\nStudent ID: $studentId",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ================= MODEL =================

class _RecordItem {
  final String title;
  final IconData icon;
  final String routeKey;

  _RecordItem({
    required this.title,
    required this.icon,
    required this.routeKey,
  });
}
