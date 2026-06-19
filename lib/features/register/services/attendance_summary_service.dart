import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student_model.dart';
import '../../students/services/student_service.dart';
import '../../attendance/screens/attendance_day_sheet.dart';

final attendanceSummaryServiceProvider =
Provider<AttendanceSummaryService>((ref) => AttendanceSummaryService());

// Represents the calculated totals for one scope (a class or whole school)
class AttendanceSummary {
  final int dayBoys;
  final int dayGirls;
  final int boarderBoys;
  final int boarderGirls;
  final int numberOfSchoolDays;

  const AttendanceSummary({
    required this.dayBoys,
    required this.dayGirls,
    required this.boarderBoys,
    required this.boarderGirls,
    required this.numberOfSchoolDays,
  });

  int get totalDay => dayBoys + dayGirls;
  int get totalBoarder => boarderBoys + boarderGirls;
  int get totalAttendance => totalDay + totalBoarder;

  // Average daily attendance = total attendance / number of school days
  double get averageDailyAttendance {
    if (numberOfSchoolDays == 0) return 0;
    return totalAttendance / numberOfSchoolDays;
  }

  static const empty = AttendanceSummary(
    dayBoys: 0, dayGirls: 0, boarderBoys: 0, boarderGirls: 0,
    numberOfSchoolDays: 0,
  );

  AttendanceSummary operator +(AttendanceSummary other) {
    return AttendanceSummary(
      dayBoys: dayBoys + other.dayBoys,
      dayGirls: dayGirls + other.dayGirls,
      boarderBoys: boarderBoys + other.boarderBoys,
      boarderGirls: boarderGirls + other.boarderGirls,
      numberOfSchoolDays: numberOfSchoolDays > other.numberOfSchoolDays
          ? numberOfSchoolDays
          : other.numberOfSchoolDays,
    );
  }
}

class AttendanceSummaryService {
  final _db = FirebaseFirestore.instance;

  // Calculate summary for a date range and scope
  // scope: 'ecda', 'ecdb', or 'all' for whole school
  Future<AttendanceSummary> calculateSummary({
    required String scope,
    required DateTime termStart,
    required DateTime termEnd,
  }) async {
    // Determine which classes to include
    final classesToQuery =
    scope == 'all' ? ['ecda', 'ecdb'] : [scope];

    int dayBoys = 0, dayGirls = 0, boarderBoys = 0, boarderGirls = 0;
    final Set<String> schoolDaysSeen = {};

    for (final classId in classesToQuery) {
      // Fetch all students in this class — need gender + scholar type
      final studentsSnap = await _db
          .collection('students')
          .where('classId', isEqualTo: classId)
          .get();

      final students = {
        for (final doc in studentsSnap.docs)
          doc.id: StudentModel.fromFirestore(doc)
      };

      // Fetch all weekly_register docs for this class within the term range
      final weeksSnap = await _db
          .collection('weekly_register')
          .where('classId', isEqualTo: classId)
          .where('weekStart', isGreaterThanOrEqualTo: Timestamp.fromDate(
          termStart.subtract(const Duration(days: 7))))
          .where('weekStart', isLessThanOrEqualTo: Timestamp.fromDate(termEnd))
          .get();

      for (final weekDoc in weeksSnap.docs) {
        final data = weekDoc.data();
        final marks = Map<String, dynamic>.from(data['marks'] ?? {});
        final weekStart = (data['weekStart'] as Timestamp).toDate();

        marks.forEach((studentId, days) {
          final student = students[studentId];
          if (student == null) return;

          final dayMap = Map<String, dynamic>.from(days);

          dayMap.forEach((dayStr, code) {
            // Only count "present" marks toward attendance totals
            if (code != '/') return;

            final dayOffset = int.parse(dayStr) - 1;
            final actualDate =
            weekStart.add(Duration(days: dayOffset));

            // Skip if outside the term range
            if (actualDate.isBefore(termStart) ||
                actualDate.isAfter(termEnd)) {
              return;
            }

            // Track unique school days for the average calculation
            schoolDaysSeen.add(
                '${actualDate.year}-${actualDate.month}-${actualDate.day}');

            final isBoarder =
                student.scholarType == ScholarType.boarder;
            final isMale = student.gender.toLowerCase() == 'male';

            if (isBoarder && isMale) {
              boarderBoys++;
            } else if (isBoarder && !isMale) {
              boarderGirls++;
            } else if (!isBoarder && isMale) {
              dayBoys++;
            } else {
              dayGirls++;
            }
          });
        });
      }
    }

    return AttendanceSummary(
      dayBoys: dayBoys,
      dayGirls: dayGirls,
      boarderBoys: boarderBoys,
      boarderGirls: boarderGirls,
      numberOfSchoolDays: schoolDaysSeen.length,
    );
  }
}