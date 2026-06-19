import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartkids_project/features/register/screens/register_screen.dart';
//import '../../features/classes/screens/classes_screen.dart';
import '../../features/attendance/screens/attendance_screen.dart';
import '../../features/fees/screens/fees_screen.dart';
import '../../features/register/screens/attendance_summary_screen.dart';
import '../../features/students/screens/students_list_screen.dart';
import '../../features/staff/screens/staff_screen.dart';
import '../../features/assessments/screens/assessment_screen.dart';
import '../../../features/auth/services/auth_service.dart';

// Changed to ConsumerStatefulWidget because we need BOTH:
// - local state (selectedIndex) → StatefulWidget
// - Riverpod access (ref for logout) → ConsumerWidget
// ConsumerStatefulWidget gives us both
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// ConsumerState instead of State — gives us ref inside the state class
class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int selectedIndex = 0;

  final List<DashboardItem> items = const [
    DashboardItem(Icons.dashboard_outlined, "Dashboard"),
    DashboardItem(Icons.school_outlined, "Students"),
    DashboardItem(Icons.person_outline, "Staff"),
    DashboardItem(Icons.check_circle_outline, "Attendance"),
    DashboardItem(Icons.assignment_outlined, "Assessment"),
    DashboardItem(Icons.payments_outlined, "Fees"),
    DashboardItem(Icons.class_outlined, "Classes"),
    DashboardItem(Icons.class_outlined, "Register"),
    DashboardItem(Icons.summarize_outlined, "Attendance Summary"),
  ];

  // Pages list matches items list exactly — same order, same count
  // Placeholder is temporary for screens not built yet
  late final List<Widget> pages = [
    const _DashboardHome(),                    // 0 — Dashboard
    const StudentsListScreen(),                // 1 — Students
    const StaffScreen(),         // 2 — Staff
    const AttendanceScreen(),                  // 3 — Attendance
     AssessmentScreen(),                  // 4 — Assessment
    const FeesScreen(),                        // 5 — Fees
    const _ComingSoon(label: 'Classes'),
    const RegisterScreen(),
    const AttendanceSummaryScreen(), // no lockedClassId — admin sees toggle
  ];

  // Logout through AuthService — proper way with Riverpod
  Future<void> _handleLogout() async {
    // ref.read() for one-time actions — not ref.watch()
    // We use read here because we don't want to rebuild on logout
    await ref.read(authServiceProvider).signOut();
    // No need to navigate — authStateProvider will update automatically
    // and the router's redirect will send user to /login on its own
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 900;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          if (isTablet) _buildSideBar(context),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
      bottomNavigationBar: isTablet ? null : _buildBottomNav(context),
    );
  }

  Widget _buildSideBar(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            backgroundColor: theme.cardColor,
            labelType: NavigationRailLabelType.selected,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            selectedIconTheme: IconThemeData(color: theme.colorScheme.primary),
            selectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            unselectedIconTheme: IconThemeData(color: theme.disabledColor),

            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.school, size: 36, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text("SmartKids", style: theme.textTheme.titleMedium),
                ],
              ),
            ),

            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton(
                icon: Icon(Icons.logout, color: theme.disabledColor),
                // Now uses our proper logout method
                onPressed: _handleLogout,
                tooltip: 'Logout',
              ),
            ),

            destinations: items.map((e) {
              return NavigationRailDestination(
                icon: Icon(e.icon),
                label: Text(e.label),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => setState(() => selectedIndex = index),
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.disabledColor,
      backgroundColor: theme.cardColor,
      type: BottomNavigationBarType.fixed,
      items: items.map((e) {
        return BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.label,
        );
      }).toList(),
    );
  }
}

// ================= DASHBOARD HOME =================

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 24),
          const Expanded(child: _DashboardGrid()),
        ],
      ),
    );
  }
}

// ================= HEADER =================

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dashboard", style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              "School Management Overview",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: theme.colorScheme.primary),
        ),
      ],
    );
  }
}

// ================= GRID =================

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    final dashboard = context.findAncestorStateOfType<_AdminDashboardScreenState>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        int count = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
            ? 3
            : 2;

        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(dashboard.items.length, (index) {
            final item = dashboard.items[index];
            return _DashboardCard(
              icon: item.icon,
              label: item.label,
              onTap: () {
                dashboard.setState(() {
                  dashboard.selectedIndex = index;
                });
              },
            );
          }),
        );
      },
    );
  }
}

// ================= CARD =================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

// ================= MODEL =================

class DashboardItem {
  final IconData icon;
  final String label;

  const DashboardItem(this.icon, this.label);
}

class _ComingSoon extends StatelessWidget {
  final String label;
  const _ComingSoon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64,
              color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text('$label — Coming Soon',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}