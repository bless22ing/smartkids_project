import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/app_constants.dart';
import '../../students/services/student_service.dart';
import '../../students/models/student_model.dart';
import '../../attendance/screens/attendance_day_sheet.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Current week — register works week by week like the physical book
  DateTime _weekStart = _getMonday(DateTime.now());

  // classId — later replace with the teacher's assigned class
  // from currentUserProvider once that wiring is in place
  String _classId = AppConstants.classEcdA;

  // Local cache of marks: studentId -> {weekday -> AttendanceStatus}
  // weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri
  Map<String, Map<int, AttendanceStatus>> _marks = {};
  bool _loading = true;
  bool _saving = false;

  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  // Load existing marks for this week from Firestore
  Future<void> _loadWeek() async {
    setState(() => _loading = true);

    final weekId = _weekDocId();
    final doc = await FirebaseFirestore.instance
        .collection('weekly_register')
        .doc(weekId)
        .get();

    final Map<String, Map<int, AttendanceStatus>> loaded = {};

    if (doc.exists) {
      final data = doc.data()!;
      final studentMarks =
      Map<String, dynamic>.from(data['marks'] ?? {});

      studentMarks.forEach((studentId, days) {
        final dayMap = Map<String, dynamic>.from(days);
        loaded[studentId] = dayMap.map(
              (day, code) => MapEntry(
            int.parse(day),
            _statusFromCode(code as String),
          ),
        );
      });
    }

    if (mounted) {
      setState(() {
        _marks = loaded;
        _loading = false;
      });
    }
  }

  AttendanceStatus _statusFromCode(String code) {
    switch (code) {
      case 'N': return AttendanceStatus.newPupil;
      case '/': return AttendanceStatus.present;
      case 'a': return AttendanceStatus.absent;
      case 's': return AttendanceStatus.sick;
      default: return AttendanceStatus.absent;
    }
  }

  // Document ID for this week+class — e.g. "ecda_2026-06-15"
  String _weekDocId() {
    final dateStr =
        '${_weekStart.year}-${_weekStart.month.toString().padLeft(2, '0')}-${_weekStart.day.toString().padLeft(2, '0')}';
    return '${_classId}_$dateStr';
  }

  // Toggle a single student's mark for a specific weekday
  // Cycles through: unmarked -> present -> absent -> sick -> unmarked
  void _cycleMark(String studentId, int weekday) {
    setState(() {
      _marks.putIfAbsent(studentId, () => {});
      final current = _marks[studentId]![weekday];

      if (current == null) {
        _marks[studentId]![weekday] = AttendanceStatus.present;
      } else if (current == AttendanceStatus.present) {
        _marks[studentId]![weekday] = AttendanceStatus.absent;
      } else if (current == AttendanceStatus.absent) {
        _marks[studentId]![weekday] = AttendanceStatus.sick;
      } else {
        _marks[studentId]!.remove(weekday);
      }
    });
  }

  // Save the entire week to Firestore in one write
  Future<void> _saveWeek(List<StudentModel> students) async {
    setState(() => _saving = true);

    try {
      // Build the marks map in the format Firestore expects:
      // { studentId: { "1": "/", "2": "a", ... } }
      final Map<String, dynamic> marksToSave = {};

      _marks.forEach((studentId, days) {
        marksToSave[studentId] = days.map(
              (day, status) => MapEntry(day.toString(), status.code),
        );
      });

      await FirebaseFirestore.instance
          .collection('weekly_register')
          .doc(_weekDocId())
          .set({
        'classId': _classId,
        'weekStart': Timestamp.fromDate(_weekStart),
        'marks': marksToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => _saving = false);
  }

  void _previousWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
    _loadWeek();
  }

  void _nextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
    _loadWeek();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentsAsync =
    ref.watch(classStudentsProvider(_classId));

    final weekEnd = _weekStart.add(const Duration(days: 4)); // Friday

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: [
          if (!_loading)
            IconButton(
              icon: _saving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.save_outlined),
              onPressed: _saving
                  ? null
                  : () {
                studentsAsync.whenData((students) {
                  _saveWeek(students);
                });
              },
              tooltip: 'Save Register',
            ),
        ],
      ),
      body: Column(
        children: [
          // Week selector
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousWeek,
                  ),
                  Column(
                    children: [
                      Text(
                        'Week Ending',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                      Text(
                        '${weekEnd.day}/${weekEnd.month}/${weekEnd.year}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWeek,
                  ),
                ],
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              children: [
                _LegendItem(color: Colors.green, label: 'Present'),
                _LegendItem(color: Colors.red, label: 'Absent'),
                _LegendItem(color: Colors.orange, label: 'Sick'),
                _LegendItem(color: theme.disabledColor, label: 'Tap to mark'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Register grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : studentsAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
              data: (students) {
                if (students.isEmpty) {
                  return const Center(
                    child: Text('No students in this class'),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _RegisterGrid(
                      students: students,
                      marks: _marks,
                      onCellTap: _cycleMark,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= REGISTER GRID =================

class _RegisterGrid extends StatelessWidget {
  final List<StudentModel> students;
  final Map<String, Map<int, AttendanceStatus>> marks;
  final void Function(String studentId, int weekday) onCellTap;

  const _RegisterGrid({
    required this.students,
    required this.marks,
    required this.onCellTap,
  });

  static const _weekdays = ['M', 'Tu', 'W', 'Th', 'Fr'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Table(
      defaultColumnWidth: const FixedColumnWidth(48),
      columnWidths: const {
        0: FixedColumnWidth(40),  // No.
        1: FixedColumnWidth(180), // Name
      },
      border: TableBorder.all(color: theme.dividerColor),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant),
          children: [
            const _HeaderCell('No.'),
            const _HeaderCell('Name'),
            ..._weekdays.map((d) => _HeaderCell(d)),
            const _HeaderCell('Total'),
          ],
        ),

        // One row per student
        ...students.asMap().entries.map((entry) {
          final index = entry.key;
          final student = entry.value;
          final studentMarks = marks[student.id] ?? {};

          // Count present days for the total column
          final presentCount = studentMarks.values
              .where((s) => s == AttendanceStatus.present)
              .length;

          return TableRow(
            children: [
              _DataCell(text: '${index + 1}'),
              _DataCell(text: student.registerName, alignLeft: true),
              // One cell per weekday — Mon to Fri
              for (int day = 1; day <= 5; day++)
                _MarkCell(
                  status: studentMarks[day],
                  onTap: () => onCellTap(student.id, day),
                ),
              _DataCell(text: '$presentCount'),
            ],
          );
        }),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool alignLeft;
  const _DataCell({required this.text, this.alignLeft = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Text(
        text,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Tappable mark cell — shows the code (/ a s N) with color
class _MarkCell extends StatelessWidget {
  final AttendanceStatus? status;
  final VoidCallback onTap;

  const _MarkCell({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: status?.color.withValues(alpha: 0.12),
        child: Text(
          status?.code ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: status?.color ?? theme.disabledColor,
          ),
        ),
      ),
    );
  }
}

// ================= LEGEND =================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}