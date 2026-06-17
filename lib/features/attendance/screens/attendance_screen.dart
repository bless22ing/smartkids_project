import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_constants.dart';
import 'attendance_day_sheet.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Replace with ref.watch(currentUserProvider).value?.classId
    // For now defaulting to ECD A for testing
    const classId = AppConstants.classEcdA;

    return Scaffold(
      appBar: AppBar(
        // Combined title and class name in one line
        // since subtitle isn't supported in your Flutter version
        title: Text(
          "Attendance — ${AppConstants.classDisplayName(classId)}",
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (_) => AttendanceDaySheet(
              date: selectedDate,
              classId: classId,
            ),
          );
        },
        icon: const Icon(Icons.edit_calendar),
        label: const Text("Take Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month navigator
            _MonthSelector(
              date: selectedDate,
              onChanged: (d) => setState(() => selectedDate = d),
            ),
            const SizedBox(height: 16),

            // Summary row — Present / Absent / Sick counts
            const _MonthlySummary(),
            const SizedBox(height: 16),

            // List of days
            const Expanded(child: _AttendanceList()),
          ],
        ),
      ),
    );
  }
}

// ================= MONTH SELECTOR =================

class _MonthSelector extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _MonthSelector({
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                onChanged(DateTime(date.year, date.month - 1));
              },
            ),
            Text(
              "${_monthName(date.month)} ${date.year}",
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                onChanged(DateTime(date.year, date.month + 1));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}

// ================= MONTHLY SUMMARY =================

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _SummaryItem(
              label: "Present",
              value: "18",
              color: Colors.green,
            ),
            _SummaryItem(
              label: "Absent",
              value: "2",
              color: Colors.red,
            ),
            _SummaryItem(
              label: "Sick",
              value: "1",
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SUMMARY ITEM =================

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

// ================= ATTENDANCE LIST =================

class _AttendanceList extends StatelessWidget {
  const _AttendanceList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: 20,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            title: Text("Day ${index + 1}"),
            subtitle: const Text("Present"),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.disabledColor,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}