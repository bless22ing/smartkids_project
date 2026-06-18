import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import 'add_staff_screen.dart';
import 'staff_profile_screen.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final staffAsync = ref.watch(staffStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStaffScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text('Error: $e')),

        data: (staffList) {
          if (staffList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text('No staff members yet',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a staff member',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: staffList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return _StaffTile(
                staff: staff,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffProfileScreen(staff: staff),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ================= STAFF TILE =================

class _StaffTile extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onTap;

  const _StaffTile({required this.staff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: staff.photoUrl != null
              ? NetworkImage(staff.photoUrl!)
              : null,
          backgroundColor:
          theme.colorScheme.primary.withValues(alpha: 0.12),
          child: staff.photoUrl == null
              ? Text(
            staff.name.isNotEmpty
                ? staff.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        title: Text(staff.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${staff.role.displayName} • ${staff.staffType.displayName}'
              '${staff.classId != null ? ' • ${staff.classId == 'ecda' ? 'ECD A' : 'ECD B'}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: staff.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                staff.status.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: staff.status.color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}