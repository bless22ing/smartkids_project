import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_role.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import '../../../shared/models/user_permissions.dart';

class StaffProfileScreen extends ConsumerStatefulWidget {
  final StaffModel staff;
  const StaffProfileScreen({super.key, required this.staff});

  @override
  ConsumerState<StaffProfileScreen> createState() =>
      _StaffProfileScreenState();
}

class _StaffProfileScreenState extends ConsumerState<StaffProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late StaffModel _staff;

  @override
  void initState() {
    super.initState();
    _staff = widget.staff;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Staff Member'),
        content: Text(
            'Are you sure you want to deactivate ${_staff.name}?'),
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

    await ref.read(staffServiceProvider).deactivateStaff(_staff.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              actions: [
                if (_staff.status == StaffStatus.active)
                  IconButton(
                    icon: const Icon(Icons.person_off_outlined),
                    onPressed: _deactivate,
                    tooltip: 'Deactivate',
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _StaffHeader(staff: _staff),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Qualifications'),
                  Tab(text: 'Permissions'),
                  Tab(text: 'Salary'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _DetailsTab(staff: _staff),
            _QualificationsTab(staff: _staff),
            _PermissionsTab(staff: _staff),
            _SalaryTab(staff: _staff),
          ],
        ),
      ),
    );
  }
}

// ================= HEADER =================

class _StaffHeader extends StatelessWidget {
  final StaffModel staff;
  const _StaffHeader({required this.staff});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: staff.photoUrl != null
                    ? NetworkImage(staff.photoUrl!)
                    : null,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: staff.photoUrl == null
                    ? Text(
                  staff.name.isNotEmpty
                      ? staff.name[0].toUpperCase()
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      staff.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${staff.role.displayName} • ${staff.staffType.displayName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: staff.status.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        staff.status.displayName,
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

// ================= DETAILS TAB =================

class _DetailsTab extends StatelessWidget {
  final StaffModel staff;
  const _DetailsTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Contact Information',
          rows: [
            _InfoRow(icon: Icons.email_outlined,
                label: 'Email', value: staff.email),
            _InfoRow(icon: Icons.phone_outlined,
                label: 'Phone', value: staff.phone),
            _InfoRow(icon: Icons.home_outlined,
                label: 'Address', value: staff.address),
            _InfoRow(icon: Icons.people_outline,
                label: 'Gender', value: staff.gender),
          ],
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Employment',
          rows: [
            _InfoRow(icon: Icons.badge_outlined,
                label: 'Role', value: staff.role.displayName),
            _InfoRow(icon: Icons.work_outline,
                label: 'Type', value: staff.staffType.displayName),
            if (staff.classId != null)
              _InfoRow(
                icon: Icons.class_outlined,
                label: 'Class',
                value: staff.classId == 'ecda' ? 'ECD A' : 'ECD B',
              ),
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Joined',
              value:
              '${staff.joinDate.day}/${staff.joinDate.month}/${staff.joinDate.year}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Duties',
          rows: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(staff.duties.isNotEmpty
                  ? staff.duties
                  : 'No duties recorded'),
            ),
          ],
        ),
      ],
    );
  }
}

// ================= QUALIFICATIONS TAB =================

class _QualificationsTab extends StatelessWidget {
  final StaffModel staff;
  const _QualificationsTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    if (staff.qualifications.isEmpty) {
      return const Center(child: Text('No qualifications recorded'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: staff.qualifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final q = staff.qualifications[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(q.title),
            subtitle: Text('${q.institution} • ${q.year}'),
          ),
        );
      },
    );
  }
}

// ================= PERMISSIONS TAB =================

class _PermissionsTab extends ConsumerWidget {
  final StaffModel staff;
  const _PermissionsTab({required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = staff.permissions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (staff.role != UserRole.assistant)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${staff.role.displayName}s have full default permissions '
                  'for their role.',
              style: const TextStyle(color: Colors.green),
            ),
          )
        else ...[
          _PermissionTile(
            label: 'Write Records',
            description: 'Anecdotes and social development',
            value: p.canWriteRecords,
            onChanged: (v) async {
              await ref.read(staffServiceProvider).updatePermissions(
                staff.id,
                UserPermissions(
                  canWriteRecords: v,
                  canMarkAttendance: p.canMarkAttendance,
                  canManageFees: p.canManageFees,
                  canViewReports: p.canViewReports,
                ),
              );
            },
          ),
          _PermissionTile(
            label: 'Mark Attendance',
            description: 'Take register and mark attendance',
            value: p.canMarkAttendance,
            onChanged: (v) async {
              await ref.read(staffServiceProvider).updatePermissions(
                staff.id,
                UserPermissions(
                  canWriteRecords: p.canWriteRecords,
                  canMarkAttendance: v,
                  canManageFees: p.canManageFees,
                  canViewReports: p.canViewReports,
                ),
              );
            },
          ),
          _PermissionTile(
            label: 'Manage Fees',
            description: 'Record fee payments',
            value: p.canManageFees,
            onChanged: (v) async {
              await ref.read(staffServiceProvider).updatePermissions(
                staff.id,
                UserPermissions(
                  canWriteRecords: p.canWriteRecords,
                  canMarkAttendance: p.canMarkAttendance,
                  canManageFees: v,
                  canViewReports: p.canViewReports,
                ),
              );
            },
          ),
          _PermissionTile(
            label: 'View Reports',
            description: 'View student progress reports',
            value: p.canViewReports,
            onChanged: (v) async {
              await ref.read(staffServiceProvider).updatePermissions(
                staff.id,
                UserPermissions(
                  canWriteRecords: p.canWriteRecords,
                  canMarkAttendance: p.canMarkAttendance,
                  canManageFees: p.canManageFees,
                  canViewReports: v,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionTile({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      subtitle: Text(description),
      value: value,
      onChanged: onChanged,
    );
  }
}

// ================= SALARY TAB =================

class _SalaryTab extends ConsumerWidget {
  final StaffModel staff;
  const _SalaryTab({required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Monthly salary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Salary',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      )),
                  Text(
                    '\$${staff.monthlySalary.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showRecordPaymentDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Record Payment'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text('Payment History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),

        if (staff.salaryPayments.isEmpty)
          const Center(child: Text('No payments recorded yet'))
        else
          ...staff.salaryPayments.reversed.map((p) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.payments_outlined,
                    color: Colors.green),
                title: Text('\$${p.amount.toStringAsFixed(0)}'),
                subtitle: Text('${p.month} ${p.year}'
                    '${p.note.isNotEmpty ? ' • ${p.note}' : ''}'),
                trailing: Text(
                  '${p.date.day}/${p.date.month}/${p.date.year}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _showRecordPaymentDialog(
      BuildContext context, WidgetRef ref) async {
    final amountCtrl = TextEditingController(
      text: staff.monthlySalary.toStringAsFixed(0),
    );
    final noteCtrl = TextEditingController();
    final monthCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    String selectedMonth = months[DateTime.now().month - 1];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Record Salary — ${staff.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Month dropdown
                DropdownButtonFormField<String>(
                  value: selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(),
                  ),
                  items: months.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => selectedMonth = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Amount (USD)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final payment = SalaryPayment(
                  amount: double.parse(amountCtrl.text),
                  date: DateTime.now(),
                  month: selectedMonth,
                  year: DateTime.now().year,
                  recordedBy: '',
                  note: noteCtrl.text.trim(),
                );

                await ref
                    .read(staffServiceProvider)
                    .recordSalaryPayment(
                  staffId: staff.id,
                  payment: payment,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Salary payment recorded'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= REUSABLE WIDGETS =================

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _InfoCard({required this.title, required this.rows});

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
            ...rows,
          ],
        ),
      ),
    );
  }
}

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