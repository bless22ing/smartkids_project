import 'package:flutter/material.dart';

class StaffProfileScreen extends StatelessWidget {
  final StaffModel staff;

  const StaffProfileScreen({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(staff: staff),
            const SizedBox(height: 24),
            _InfoCard(
              title: "Personal Information",
              children: [
                _InfoRow("Full Name", staff.name),
                _InfoRow("Role", staff.role),
                _InfoRow("Status", staff.status),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: "Work Details",
              children: [
                _InfoRow("Assigned Class", staff.assignedClass),
                _InfoRow("Level", staff.level),
                _InfoRow("Employment Type", staff.employmentType),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: "Contact Information",
              children: [
                _InfoRow("Phone", staff.phone),
                _InfoRow("Email", staff.email),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: "Qualifications",
              children: [
                Text(
                  staff.qualifications,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _ActionButtons(),
          ],
        ),
      ),
    );
  }
}

// ================= PROFILE HEADER =================

class _ProfileHeader extends StatelessWidget {
  final StaffModel staff;

  const _ProfileHeader({required this.staff});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor:
            theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              staff.name.isNotEmpty ? staff.name[0] : "?",
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            staff.name,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            staff.role,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.disabledColor),
          ),
        ],
      ),
    );
  }
}

// ================= INFO CARD =================

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ================= INFO ROW =================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

// ================= ACTION BUTTONS =================

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: Edit staff (Admin only)
            },
            child: const Text("Edit"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Deactivate staff (Admin only)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Deactivate"),
          ),
        ),
      ],
    );
  }
}

// ================= MODEL =================

class StaffModel {
  final String id;
  final String name;
  final String role;
  final String status;
  final String assignedClass;
  final String level;
  final String employmentType;
  final String phone;
  final String email;
  final String qualifications;

  const StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.assignedClass,
    required this.level,
    required this.employmentType,
    required this.phone,
    required this.email,
    required this.qualifications,
  });
}
