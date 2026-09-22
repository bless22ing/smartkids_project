import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartkids_project/features/students/records/anecdotal/add_anecdotal_screen.dart';
import '../../reports/screens/create_report_card_screen.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/services/auth_service.dart';
import '../../social/models/social_development_model.dart';
import '../../social/services/social_development_service.dart';
import '../../social/screens/add_social_record_screen.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final StudentModel student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState
    extends ConsumerState<StudentProfileScreen>
    with SingleTickerProviderStateMixin {
  // TabController controls which tab is active
  // SingleTickerProviderStateMixin is required by TabController
  late final TabController _tabController;

  // We keep a local copy of the student so we can update it
  // after edits without waiting for Firestore to refresh
  late StudentModel _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    // 5 tabs — Personal, Medical, Attendance, Assessments, Social, Anecdotal
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Deactivate student — shows confirmation dialog first
  Future<void> _deactivateStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Student'),
        content: Text(
          'Are you sure you want to deactivate ${_student.name}? '
              'Their records will be kept but they will be marked as inactive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(studentServiceProvider)
          .deactivateStudent(_student.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deactivated successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to deactivate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch current user to check permissions
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: NestedScrollView(
        // NestedScrollView lets the header scroll away
        // while the tab content stays and scrolls independently
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverAppBar(
//               expandedHeight: 200,
//               pinned: true, // keeps app bar visible when scrolled
//               actions: [
//                 // Only show edit/deactivate to admins
//                 userAsync.when(
//                   data: (user) {
//                     if (user == null || !user.role.isAdmin) {
//                       return const SizedBox.shrink();
//                     }
//                     return Row(
//                       children: [
//                         // Inside the userAsync.when -> data: (user) builder,
// // add this button before the edit/deactivate ones:
//                         IconButton(
//                           icon: const Icon(Icons.picture_as_pdf_outlined),
//                           tooltip: 'Generate Report Card',
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => CreateReportCardScreen(student: _student),
//                               ),
//                             );
//                           },
//                         ),
//                         // Edit button
//                         IconButton(
//                           icon: const Icon(Icons.edit_outlined),
//                           tooltip: 'Edit Student',
//                           onPressed: () {
//                             // TODO: Navigate to EditStudentScreen
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Edit coming soon'),
//                               ),
//                             );
//                           },
//                         ),
//                         // Deactivate button — only if student is active
//                         if (_student.active)
//                           IconButton(
//                             icon: const Icon(Icons.person_off_outlined),
//                             tooltip: 'Deactivate Student',
//                             onPressed: _deactivateStudent,
//                           ),
//                       ],
//                     );
//                   },
//                   loading: () => const SizedBox.shrink(),
//                   error: (_, __) => const SizedBox.shrink(),
//                 ),
//               ],
//
//               // Flexible space shows the student header
//               flexibleSpace: FlexibleSpaceBar(
//                 background: _StudentHeader(student: _student),
//               ),
//
//               // Tab bar stays pinned at the bottom of the app bar
//               bottom: TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 tabs: const [
//                   Tab(text: 'Personal'),
//                   Tab(text: 'Medical'),
//                   Tab(text: 'Attendance'),
//                   Tab(text: 'Assessments'),
//                   Tab(text: 'Social'),
//                   Tab(text: 'Anecdotal')
//                 ],
//               ),
//             ),
//           ];
//         },
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          final userAsync = ref.watch(currentUserProvider);

          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              // Actions are always visible — not dependent on scroll position
              actions: [
                // PDF button — visible to everyone
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined,
                      color: Colors.white),
                  tooltip: 'Generate Report Card',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateReportCardScreen(student: _student),
                      ),
                    );
                  },
                ),

                // Edit and deactivate — admin only
                userAsync.when(
                  data: (user) {
                    if (user == null || !user.role.isAdmin) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.white),
                          tooltip: 'Edit Student',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit coming soon')),
                            );
                          },
                        ),
                        if (_student.active)
                          IconButton(
                            icon: const Icon(Icons.person_off_outlined,
                                color: Colors.white),
                            tooltip: 'Deactivate Student',
                            onPressed: _deactivateStudent,
                          ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(width: 8),
              ],

              flexibleSpace: FlexibleSpaceBar(
                background: _StudentHeader(student: _student),
              ),

              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Personal'),
                  Tab(text: 'Medical'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Assessments'),
                  Tab(text: 'Social'),
                ],
              ),
            ),
          ];
        },

        // Tab content
        body: TabBarView(
          controller: _tabController,
          children: [
            _PersonalTab(student: _student),
            _MedicalTab(student: _student),
            _AttendanceTab(student: _student),
            _AssessmentsTab(student: _student),
            _SocialTab(student: _student),
            _AnecdotalTab(student: _student),
          ],
        ),
      ),
    );
  }
}

// ================= STUDENT HEADER =================

class _StudentHeader extends StatelessWidget {
  final StudentModel student;
  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundImage: student.photoUrl != null
                    ? NetworkImage(student.photoUrl!)
                    : null,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: student.photoUrl == null
                    ? Text(
                  student.name.isNotEmpty
                      ? student.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 16),

              // Name and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.className} • Age ${student.age} • ${student.gender}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Active/inactive badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: student.active
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        student.active ? 'Enrolled' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PERSONAL TAB =================

class _PersonalTab extends StatelessWidget {
  final StudentModel student;
  const _PersonalTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Personal Information',
          children: [
            _InfoRow(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: '${student.dateOfBirth.day}/${student.dateOfBirth.month}/${student.dateOfBirth.year}',
            ),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Gender',
              value: student.gender,
            ),
            // NEW rows
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Birth Cert No.',
              value: student.birthCertNo,
            ),
            _InfoRow(
              icon: Icons.church_outlined,
              label: 'Religion',
              value: student.religion,
            ),
            _InfoRow(
              icon: Icons.home_work_outlined,
              label: 'Scholar Type',
              value: student.scholarType.displayName,
            ),
            if (student.gamesHouse.isNotEmpty)
              _InfoRow(
                icon: Icons.sports_outlined,
                label: 'Games House',
                value: student.gamesHouse,
              ),
            _InfoRow(
              icon: Icons.class_outlined,
              label: 'Class',
              value: student.className,
            ),
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Enrolled',
              value: '${student.enrollmentDate.day}/${student.enrollmentDate.month}/${student.enrollmentDate.year}',
            ),
          ],
        ),

        const SizedBox(height: 16),

        _SectionCard(
          title: 'Guardian 1 — ${student.guardian1.relationship}',
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: student.guardian1.name,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Contact',
              value: student.guardian1.contact,
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: student.guardian1.email,
            ),
          ],
        ),

        // Only show guardian 2 if they have a name
        if (student.guardian2.name.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Guardian 2 — ${student.guardian2.relationship}',
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Name',
                value: student.guardian2.name,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Contact',
                value: student.guardian2.contact,
              ),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: student.guardian2.email,
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        _SectionCard(
          title: 'Next of Kin — ${student.nextOfKin.relationship}',
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: student.nextOfKin.name,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Contact',
              value: student.nextOfKin.contact,
            ),
          ],
        ),
      ],
    );
  }
}

// ================= MEDICAL TAB =================

class _MedicalTab extends StatelessWidget {
  final StudentModel student;
  const _MedicalTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Allergies warning card — highlighted in orange if has allergies
        if (student.allergies.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allergies',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(student.allergies),
                    ],
                  ),
                ),
              ],
            ),
          ),

        if (student.allergies.isNotEmpty) const SizedBox(height: 16),

        _SectionCard(
          title: 'Medical Notes',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                student.medicalNotes.isNotEmpty
                    ? student.medicalNotes
                    : 'No medical notes recorded.',
                style: TextStyle(
                  color: student.medicalNotes.isNotEmpty
                      ? null
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================= ATTENDANCE TAB =================

class _AttendanceTab extends StatelessWidget {
  final StudentModel student;
  const _AttendanceTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Attendance history coming soon'),
    );
  }
}

// ================= ASSESSMENTS TAB =================

class _AssessmentsTab extends StatelessWidget {
  final StudentModel student;
  const _AssessmentsTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Assessment results coming soon'),
    );
  }
}

// ================= SOCIAL TAB =================

class _SocialTab extends ConsumerWidget {
  final StudentModel student;
  const _SocialTab({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordsAsync =
    ref.watch(studentSocialRecordsProvider(student.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSocialRecordScreen(student: student),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 48, color: theme.disabledColor),
                  const SizedBox(height: 12),
                  Text(
                    'No social development records yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${record.date.day}/${record.date.month}/${record.date.year}',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            'by ${record.recordedByName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SocialSkills.all
                            .where((key) =>
                            record.ratings.containsKey(key))
                            .map((key) {
                          final rating = record.ratingFor(key)!;
                          return Chip(
                            label: Text(
                              '${SocialSkills.displayNames[key]}: ${rating.displayName}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor:
                            rating.color.withValues(alpha: 0.15),
                            labelStyle:
                            TextStyle(color: rating.color),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      if (record.comment.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record.comment,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= SOCIAL TAB =================

class _AnecdotalTab extends ConsumerWidget {
  final StudentModel student;
  const _AnecdotalTab({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordsAsync =
    ref.watch(studentSocialRecordsProvider(student.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAnecdotalScreen(student: student),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 48, color: theme.disabledColor),
                  const SizedBox(height: 12),
                  Text(
                    'No anecdotal records yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${record.date.day}/${record.date.month}/${record.date.year}',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            'by ${record.recordedByName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SocialSkills.all
                            .where((key) =>
                            record.ratings.containsKey(key))
                            .map((key) {
                          final rating = record.ratingFor(key)!;
                          return Chip(
                            label: Text(
                              '${SocialSkills.displayNames[key]}: ${rating.displayName}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor:
                            rating.color.withValues(alpha: 0.15),
                            labelStyle:
                            TextStyle(color: rating.color),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      if (record.comment.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record.comment,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// ================= REUSABLE WIDGETS =================

// Section card — a titled card with a list of info rows
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// A single label + value row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.disabledColor),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}