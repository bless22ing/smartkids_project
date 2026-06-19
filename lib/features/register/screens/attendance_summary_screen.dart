import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_summary_service.dart';

class AttendanceSummaryScreen extends ConsumerStatefulWidget {
  // If classId is provided, scope is locked (used by teacher dashboard)
  // If null, shows the full dropdown (used by admin dashboard)
  final String? lockedClassId;

  const AttendanceSummaryScreen({super.key, this.lockedClassId});

  @override
  ConsumerState<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState
    extends ConsumerState<AttendanceSummaryScreen> {
  late String _scope;
  int _selectedYear = DateTime.now().year;

  // Term date ranges — adjust to match your actual school calendar
  late List<_TermRange> _terms;

  AttendanceSummary? _firstTermSummary;
  AttendanceSummary? _secondTermSummary;
  AttendanceSummary? _thirdTermSummary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scope = widget.lockedClassId ?? 'all';
    _buildTermRanges();
    _loadSummaries();
  }

  // Standard Zimbabwean school terms — adjust dates as needed
  void _buildTermRanges() {
    _terms = [
      _TermRange(
        name: 'First Term',
        start: DateTime(_selectedYear, 1, 1),
        end: DateTime(_selectedYear, 4, 15),
      ),
      _TermRange(
        name: 'Second Term',
        start: DateTime(_selectedYear, 5, 1),
        end: DateTime(_selectedYear, 8, 15),
      ),
      _TermRange(
        name: 'Third Term',
        start: DateTime(_selectedYear, 9, 1),
        end: DateTime(_selectedYear, 12, 15),
      ),
    ];
  }

  Future<void> _loadSummaries() async {
    setState(() => _loading = true);

    final service = ref.read(attendanceSummaryServiceProvider);

    final results = await Future.wait([
      service.calculateSummary(
        scope: _scope,
        termStart: _terms[0].start,
        termEnd: _terms[0].end,
      ),
      service.calculateSummary(
        scope: _scope,
        termStart: _terms[1].start,
        termEnd: _terms[1].end,
      ),
      service.calculateSummary(
        scope: _scope,
        termStart: _terms[2].start,
        termEnd: _terms[2].end,
      ),
    ]);

    if (mounted) {
      setState(() {
        _firstTermSummary = results[0];
        _secondTermSummary = results[1];
        _thirdTermSummary = results[2];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final yearTotal = (_firstTermSummary ?? AttendanceSummary.empty) +
        (_secondTermSummary ?? AttendanceSummary.empty) +
        (_thirdTermSummary ?? AttendanceSummary.empty);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
      body: Column(
        children: [
          // Scope selector — only shown if not locked to a specific class
          if (widget.lockedClassId == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'ecda', label: Text('ECD A')),
                  ButtonSegment(value: 'ecdb', label: Text('ECD B')),
                  ButtonSegment(value: 'all', label: Text('Whole School')),
                ],
                selected: {_scope},
                onSelectionChanged: (selection) {
                  setState(() => _scope = selection.first);
                  _loadSummaries();
                },
              ),
            ),

          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryTable(
                    title: _terms[0].name,
                    summary: _firstTermSummary!,
                  ),
                  const SizedBox(height: 16),
                  _SummaryTable(
                    title: _terms[1].name,
                    summary: _secondTermSummary!,
                  ),
                  const SizedBox(height: 16),
                  _SummaryTable(
                    title: _terms[2].name,
                    summary: _thirdTermSummary!,
                  ),
                  const SizedBox(height: 16),
                  _SummaryTable(
                    title: 'Total for Year',
                    summary: yearTotal,
                    highlighted: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TermRange {
  final String name;
  final DateTime start;
  final DateTime end;
  const _TermRange({
    required this.name,
    required this.start,
    required this.end,
  });
}

// ================= SUMMARY TABLE =================

class _SummaryTable extends StatelessWidget {
  final String title;
  final AttendanceSummary summary;
  final bool highlighted;

  const _SummaryTable({
    required this.title,
    required this.summary,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: highlighted ? 2 : 0,
      color: highlighted
          ? theme.colorScheme.primary.withValues(alpha: 0.06)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: highlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: highlighted ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 12),

            // Table matching the physical register layout
            Table(
              border: TableBorder.all(color: theme.dividerColor),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  children: const [
                    _Cell(''),
                    _Cell('Day', bold: true),
                    _Cell(''),
                    _Cell('Boarder', bold: true),
                    _Cell(''),
                  ],
                ),
                TableRow(
                  children: const [
                    _Cell(''),
                    _Cell('Boy', bold: true),
                    _Cell('Girl', bold: true),
                    _Cell('Boy', bold: true),
                    _Cell('Girl', bold: true),
                  ],
                ),
                TableRow(
                  children: [
                    const _Cell('Total'),
                    _Cell('${summary.dayBoys}'),
                    _Cell('${summary.dayGirls}'),
                    _Cell('${summary.boarderBoys}'),
                    _Cell('${summary.boarderGirls}'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            _StatLine(
              label: 'Total Attendance',
              value: '${summary.totalAttendance}',
            ),
            _StatLine(
              label: 'Number of School Days',
              value: '${summary.numberOfSchoolDays}',
            ),
            _StatLine(
              label: 'Average Daily Attendance',
              value: summary.averageDailyAttendance.toStringAsFixed(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  const _Cell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;
  const _StatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}