import 'package:flutter/material.dart';
import 'package:smartkids_project/screens/staff/staff_profile_screen.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Management"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add staff (Admin only)
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StaffStats(),
            const SizedBox(height: 16),
            Expanded(child: _StaffList()),
          ],
        ),
      ),
    );
  }
}

// ================= STAFF STATS =================

class _StaffStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            title: "Teachers",
            value: "8",
            icon: Icons.school_outlined,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "Assistants",
            value: "5",
            icon: Icons.support_agent_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.headlineSmall),
                Text(title, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= STAFF LIST =================

class _StaffList extends StatelessWidget {
  final List<_StaffMember> staff = const [
    _StaffMember(
      name: "Mrs. Chipo Moyo",
      role: "Teacher",
      status: "Active",
    ),
    _StaffMember(
      name: "Mr. Tendai Ncube",
      role: "Teacher",
      status: "On Leave",
    ),
    _StaffMember(
      name: "Ms. Rudo Dube",
      role: "Teaching Assistant",
      status: "Active",
    ),
    _StaffMember(
      name: "Ms. Tariro Nyathi",
      role: "Teaching Assistant",
      status: "Active",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: staff.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = staff[index];
        return _StaffTile(member: member);
      },
    );
  }
}

class _StaffTile extends StatelessWidget {
  final _StaffMember member;

  const _StaffTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isActive = member.status == "Active";

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            member.name[0],
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(member.name),
        subtitle: Text(member.role),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            member.status,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffProfileScreen(
                staff: StaffModel(
                  id: "1",
                  name: member.name,
                  role: member.role,
                  status: member.status,
                  assignedClass: "ECD A",
                  level: "ECD A",
                  employmentType: "Full Time",
                  phone: "+263 77 123 4567",
                  email: "staff@smartkids.co.zw",
                  qualifications: "Early Childhood Diploma",
                ),
              ),
            ),
          );
        },

      ),
    );
  }
}

// ================= MODEL =================

class _StaffMember {
  final String name;
  final String role;
  final String status;

  const _StaffMember({
    required this.name,
    required this.role,
    required this.status,
  });
}
