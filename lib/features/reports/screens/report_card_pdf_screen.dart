import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/report_card_model.dart';
import 'package:flutter/services.dart';

class ReportCardPdfScreen extends StatelessWidget {
  final ReportCardModel report;
  const ReportCardPdfScreen({super.key, required this.report});

  // Builds the actual PDF document matching the school's template
  Future<Uint8List> _buildPdf() async {
    final doc = pw.Document();

    // Colors matching the template — dark red border/heading
    final brandRed = PdfColor.fromHex('#8B0000');

    // Load both images from assets
    final logoBytes = await rootBundle.load('assets/images/school_logo.jpg');
    final coatOfArmsBytes =
    await rootBundle.load('assets/images/coat_of_arms.png');

    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final coatOfArmsImage =
    pw.MemoryImage(coatOfArmsBytes.buffer.asUint8List());

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            // Red border around the whole page like the template
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: brandRed, width: 2),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Left — placeholder for school logo
                    // pw.Container(
                    //   width: 50,
                    //   height: 50,
                    //   decoration: pw.BoxDecoration(
                    //     border: pw.Border.all(color: PdfColors.grey400),
                    //   ),
                    //   child: pw.Center(
                    //     child: pw.Text(
                    //       'LOGO',
                    //       style: const pw.TextStyle(fontSize: 8),
                    //     ),
                    //   ),
                    // ),
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),

                    // Center — school name and address
                    // pw.Expanded(
                    //   child: pw.Column(
                    //     children: [
                    //       pw.Text(
                    //         'SMART KIDS PRE-SCHOOL',
                    //         style: pw.TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: pw.FontWeight.bold,
                    //           color: brandRed,
                    //         ),
                    //       ),
                    //       pw.SizedBox(height: 4),
                    //       pw.Text(
                    //         'Stand No 4536 142 Street, Warren Park D, Harare',
                    //         style: const pw.TextStyle(fontSize: 9),
                    //       ),
                    //       pw.Text(
                    //         'Cell: 0786275055   Email: smartkidspresc@gmail.com',
                    //         style: const pw.TextStyle(fontSize: 9),
                    //       ),
                    //     ],
                    //   ),
                    // ),
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Text(
                    'SMART KIDS PRE-SCHOOL',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: brandRed,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Stand No 4536 142 Street, Warren Park D, Harare',
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Cell: 0786275055   Email: smartkidspresc@gmail.com',
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),

                    // Right — placeholder for coat of arms
                    // pw.Container(
                    //   width: 50,
                    //   height: 50,
                    //   decoration: pw.BoxDecoration(
                    //     border: pw.Border.all(color: PdfColors.grey400),
                    //   ),
                    //   child: pw.Center(
                    //     child: pw.Text(
                    //       'CREST',
                    //       style: const pw.TextStyle(fontSize: 8),
                    //     ),
                    //   ),
                    // ),
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(coatOfArmsImage, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // ===== "INFANT" centered, underlined =====
                pw.Center(
                  child: pw.Text(
                    report.grade.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),

                pw.SizedBox(height: 16),

                // ===== GRADE / TERM / YEAR row =====
                pw.Row(
                  children: [
                    _labelValue('GRADE', report.grade),
                    pw.SizedBox(width: 20),
                    _labelValue('TERM', report.term),
                    pw.SizedBox(width: 20),
                    _labelValue('YEAR', '${report.year}'),
                  ],
                ),

                pw.SizedBox(height: 6),

                pw.Row(
                  children: [
                    _labelValue(
                      'POSITION IN CLASS',
                      report.positionInClass?.toString() ?? '',
                    ),
                    pw.Spacer(),
                    _labelValue(
                      'OUT OF',
                      report.positionOutOf?.toString() ?? '',
                    ),
                  ],
                ),

                pw.SizedBox(height: 6),

                pw.Row(
                  children: [
                    _labelValue(
                      'GRADE POSITION',
                      report.gradePosition ?? '',
                    ),
                    pw.Spacer(),
                    _labelValue(
                      'OUT OF',
                      report.gradePositionOutOf?.toString() ?? '',
                    ),
                  ],
                ),

                pw.SizedBox(height: 6),

                pw.Row(
                  children: [
                    _labelValue(
                      'ATTENDANCE',
                      '${report.attendanceDays}',
                    ),
                    pw.Spacer(),
                    _labelValue(
                      'OUT OF',
                      '${report.attendanceOutOfDays} DAYS',
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // ===== SUBJECTS TABLE =====
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(1.5),
                    2: pw.FlexColumnWidth(1.5),
                    3: pw.FlexColumnWidth(2.5),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _tableHeader('SUBJECT'),
                        _tableHeader('POSSIBLE\nMARK'),
                        _tableHeader('OBTAINED\nMARK'),
                        _tableHeader('COMMENTS'),
                      ],
                    ),

                    // One row per subject
                    ...ReportSubjects.all.map((subject) {
                      final mark = report.marks[subject] ??
                          SubjectMark.empty();
                      return pw.TableRow(
                        children: [
                          _tableCell(
                            ReportSubjects.displayNames[subject]!,
                            bold: true,
                            alignLeft: true,
                          ),
                          _tableCell(
                            mark.possibleMark > 0
                                ? mark.possibleMark.toStringAsFixed(0)
                                : '',
                          ),
                          _tableCell(
                            mark.obtainedMark > 0
                                ? mark.obtainedMark.toStringAsFixed(0)
                                : '',
                          ),
                          _tableCell(mark.comment, alignLeft: true),
                        ],
                      );
                    }),

                    // Grand total row
                    pw.TableRow(
                      decoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _tableCell('GRAND TOTAL', bold: true, alignLeft: true),
                        _tableCell(
                          report.grandTotalPossible.toStringAsFixed(0),
                          bold: true,
                        ),
                        _tableCell(
                          report.grandTotalObtained.toStringAsFixed(0),
                          bold: true,
                        ),
                        _tableCell(''),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // ===== TEACHER'S COMMENTS =====
                pw.Text(
                  "TEACHER'S COMMENTS",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black),
                    ),
                  ),
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    report.teacherComments,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  width: 200,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black),
                    ),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text('SIGNATURE', style: const pw.TextStyle(fontSize: 9)),

                pw.SizedBox(height: 16),

                // ===== HEAD'S COMMENTS =====
                pw.Text(
                  "HEAD/D-HEAD'S COMMENTS",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black),
                    ),
                  ),
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    report.headComments,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  width: 200,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black),
                    ),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text('SIGNATURE', style: const pw.TextStyle(fontSize: 9)),

                pw.SizedBox(height: 16),

                // ===== FOOTER: Fees, Next Term, Photo box =====
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _labelValue(
                            'Next Term Fees \$',
                            report.nextTermFees > 0
                                ? report.nextTermFees.toStringAsFixed(0)
                                : '',
                          ),
                          pw.SizedBox(height: 8),
                          _labelValue(
                            'Next Term Begins',
                            report.nextTermBegins != null
                                ? '${report.nextTermBegins!.day}/${report.nextTermBegins!.month}/${report.nextTermBegins!.year}'
                                : '',
                          ),
                          pw.SizedBox(height: 8),
                          _labelValue("Parent/Guardian's", ''),
                        ],
                      ),
                    ),
                    // Photo box placeholder
                    pw.Container(
                      width: 90,
                      height: 90,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  // Helper — label + underline value, used for header fields
  pw.Widget _labelValue(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.Container(
          constraints: const pw.BoxConstraints(minWidth: 60),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black),
            ),
          ),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _tableCell(String text,
      {bool bold = false, bool alignLeft = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Card — ${report.studentName}'),
      ),
      // PdfPreview is a widget from the 'printing' package
      // It shows a live preview AND gives print/share/download buttons
      // automatically — no need to build those ourselves
      body: PdfPreview(
        build: (format) => _buildPdf(),
        // Filename used when downloading/sharing
        pdfFileName:
        '${report.studentName}_${report.term}_${report.year}.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}