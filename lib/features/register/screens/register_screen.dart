import 'package:flutter/material.dart';
import '../../attendance/screens/attendance_screen.dart';

// Register IS attendance — taking today's register means marking attendance
// So we just show AttendanceScreen here, pre-set to today's date
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We simply return AttendanceScreen directly
    // Later we can pass a parameter to pre-select today's date
    return const AttendanceScreen();
  }
}