import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student_model.dart';
import '../../auth/services/auth_service.dart';
import '../models/report_card_model.dart';
import '../services/report_card_service.dart';
import 'report_card_pdf_screen.dart';

class CreateReportCardScreen extends ConsumerStatefulWidget {
  final StudentModel student;
  const CreateReportCardScreen({super.key, required this.student});

  @override
  ConsumerState<CreateReportCardScreen> createState() =>
      _CreateReportCardScreenState();
}

class _CreateReportCardScreenState
    extends ConsumerState<CreateReportCardScreen> {
  String _term = 'Term 1';
  int _year = DateTime.now().year;
  final _gradeCtrl = TextEditingController(text: 'Infant');

  final _positionCtrl = TextEditingController();
  final _positionOutOfCtrl = TextEditingController();
  final _gradePositionCtrl = TextEditingController();
  final _gradePositionOutOfCtrl = TextEditingController();

  final _attendanceDaysCtrl = TextEditingController();
  final _attendanceOutOfCtrl = TextEditingController();

  final _teacherCommentsCtrl = TextEditingController();
  final _headCommentsCtrl = TextEditingController();
  final _nextTermFeesCtrl = TextEditingController();

  // One controller pair per subject — possible & obtained
  final Map<String, TextEditingController> _possibleCtrls = {};
  final Map<String, TextEditingController> _obtainedCtrls = {};
  final Map<String, TextEditingController> _subjectCommentCtrls = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final subject in ReportSubjects.all) {
      _possibleCtrls[subject] = TextEditingController();
      _obtainedCtrls[subject] = TextEditingController();
      _subjectCommentCtrls[subject] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _gradeCtrl.dispose();
    _positionCtrl.dispose();
    _positionOutOfCtrl.dispose();
    _gradePositionCtrl.dispose();
    _gradePositionOutOfCtrl.dispose();
    _attendanceDaysCtrl.dispose();
    _attendanceOutOfCtrl.dispose();
    _teacherCommentsCtrl.dispose();
    _headCommentsCtrl.dispose();
    _nextTermFeesCtrl.dispose();
    for (final c in _possibleCtrls.values) c.dispose();
    for (final c in _obtainedCtrls.values) c.dispose();
    for (final c in _subjectCommentCtrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _generateAndSave() async {
    setState(() => _saving = true);

    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;

      // Build marks map from all subject controllers
      final marks = <String, SubjectMark>{};
      for (final subject in ReportSubjects.all) {
        marks[subject] = SubjectMark(
          possibleMark:
          double.tryParse(_possibleCtrls[subject]!.text) ?? 0,
          obtainedMark:
          double.tryParse(_obtainedCtrls[subject]!.text) ?? 0,
          comment: _subjectCommentCtrls[subject]!.text.trim(),
        );
      }

      final report = ReportCardModel(
        id: '',
        studentId: widget.student.id,
        studentName: widget.student.name,
        classId: widget.student.classId,
        grade: _gradeCtrl.text.trim(),
        term: _term,
        year: _year,
        positionInClass: int.tryParse(_positionCtrl.text),
        positionOutOf: int.tryParse(_positionOutOfCtrl.text),
        gradePosition: _gradePositionCtrl.text.trim().isEmpty
            ? null
            : _gradePositionCtrl.text.trim(),
        gradePositionOutOf: int.tryParse(_gradePositionOutOfCtrl.text),
        attendanceDays: int.tryParse(_attendanceDaysCtrl.text) ?? 0,
        attendanceOutOfDays: int.tryParse(_attendanceOutOfCtrl.text) ?? 0,
        marks: marks,
        teacherComments: _teacherCommentsCtrl.text.trim(),
        headComments: _headCommentsCtrl.text.trim(),
        nextTermFees: double.tryParse(_nextTermFeesCtrl.text) ?? 0,
        createdBy: user?.uid ?? '',
        createdAt: DateTime.now(),
      );

      final id = await ref
          .read(reportCardServiceProvider)
          .saveReportCard(report);

      if (mounted) {
        // Navigate straight to the PDF preview
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReportCardPdfScreen(report: report),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Report Card — ${widget.student.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Term & Year
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _term,
                  decoration: const InputDecoration(
                    labelText: 'Term',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Term 1', 'Term 2', 'Term 3'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (v) => setState(() => _term = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _year.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                  _year = int.tryParse(v) ?? DateTime.now().year,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _gradeCtrl,
            decoration: const InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),
          Text('Position & Attendance', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _positionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Position in Class',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _positionOutOfCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Out Of',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _gradePositionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Grade Position',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _gradePositionOutOfCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Out Of',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _attendanceDaysCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Attendance',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _attendanceOutOfCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Out Of Days',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text('Subject Marks', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),

          // One card per subject
          ...ReportSubjects.all.map((subject) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ReportSubjects.displayNames[subject]!,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _possibleCtrls[subject],
                            decoration: const InputDecoration(
                              labelText: 'Possible Mark',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _obtainedCtrls[subject],
                            decoration: const InputDecoration(
                              labelText: 'Obtained Mark',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subjectCommentCtrls[subject],
                      decoration: const InputDecoration(
                        labelText: 'Comments (optional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          Text("Teacher's Comments", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _teacherCommentsCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),
          Text("Head's Comments", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _headCommentsCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),
          TextFormField(
            controller: _nextTermFeesCtrl,
            decoration: const InputDecoration(
              labelText: 'Next Term Fees (USD)',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _generateAndSave,
              icon: _saving
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(_saving ? 'Generating...' : 'Generate Report Card'),
            ),
          ),
        ],
      ),
    );
  }
}