import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_constants.dart';
import '../../auth/services/auth_service.dart';
import '../../attendance/screens/attendance_screen.dart';
import '../../assessments/screens/assessment_screen.dart';
import '../../register/screens/attendance_summary_screen.dart';
import '../../students/screens/students_list_screen.dart';
import '../../social/screens/social_development_screen.dart';
import '../../anecdotes/screens/anecdote_records_screen.dart';
import '../../register/screens/register_screen.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  int selectedIndex = 0;

  final List<_TeacherNavItem> items = const [
    _TeacherNavItem(Icons.dashboard_outlined, "Overview"),
    _TeacherNavItem(Icons.how_to_reg_outlined, "Register"),
    _TeacherNavItem(Icons.people_outline, "My Class"),
    _TeacherNavItem(Icons.assignment_outlined, "Assessments"),
    _TeacherNavItem(Icons.favorite_outline, "Social"),
    _TeacherNavItem(Icons.book_outlined, "Anecdotes"),
    _TeacherNavItem(Icons.book_outlined, "Attendance"),
  ];

  late final List<Widget> pages = [
    const _TeacherHome(),
    const RegisterScreen(),
    const StudentsListScreen(),
    AssessmentScreen(),
    const SocialDevelopmentScreen(),
    const AnecdoteRecordsScreen(),
    AttendanceSummaryScreen(lockedClassId: AppConstants.classEcdA), // or dynamic later
  ];

  Future<void> _handleLogout() async {
    await ref.read(authServiceProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 900;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isTablet
          ? null
          : AppBar(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.school, size: 22),
            SizedBox(width: 8),
            Text(
              'SmartKids',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
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
    final userAsync = ref.watch(currentUserProvider);

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
            indicatorColor:
            theme.colorScheme.secondary.withValues(alpha: 0.12),
            selectedIconTheme:
            IconThemeData(color: theme.colorScheme.secondary),
            selectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
            unselectedIconTheme: IconThemeData(color: theme.disabledColor),

            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("My Class", style: theme.textTheme.titleSmall),
                  // Show the teacher's role below their avatar
                  userAsync.when(
                    data: (user) => Text(
                      user?.role.displayName ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton(
                icon: Icon(Icons.logout, color: theme.disabledColor),
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
      selectedItemColor: theme.colorScheme.secondary,
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

// ================= TEACHER HOME =================

class _TeacherHome extends StatelessWidget {
  const _TeacherHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Dashboard", style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            "Welcome back",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),

          const SizedBox(height: 24),

          // Quick stats
          Row(
            children: const [
              _StatCard(
                icon: Icons.people,
                label: "My Students",
                value: "24",
                color: Colors.blue,
              ),
              SizedBox(width: 12),
              _StatCard(
                icon: Icons.how_to_reg,
                label: "Present Today",
                value: "20",
                color: Colors.green,
              ),
              SizedBox(width: 12),
              _StatCard(
                icon: Icons.warning_amber,
                label: "Absent",
                value: "4",
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text("Quick Actions", style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _QuickActionCard(
                  icon: Icons.how_to_reg_outlined,
                  label: "Take Register",
                  color: Colors.teal,
                ),
                _QuickActionCard(
                  icon: Icons.assignment_outlined,
                  label: "Add Assessment",
                  color: Colors.purple,
                ),
                _QuickActionCard(
                  icon: Icons.favorite_outline,
                  label: "Social Record",
                  color: Colors.pink,
                ),
                _QuickActionCard(
                  icon: Icons.book_outlined,
                  label: "Write Anecdote",
                  color: Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= STAT CARD =================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= QUICK ACTION CARD =================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // TODO: navigate to relevant screen
      },
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
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

// ================= NAV ITEM MODEL =================

class _TeacherNavItem {
  final IconData icon;
  final String label;

  const _TeacherNavItem(this.icon, this.label);
}