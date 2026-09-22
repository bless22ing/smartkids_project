import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../students/services/student_service.dart';
import '../../students/models/student_model.dart';
import '../../fees/services/fee_service.dart';
import '../services/notification_service.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Send'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SendTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

// ================= SEND TAB =================

class _SendTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (students) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Announcement card — sends to ALL parents
            _NotificationTypeCard(
              icon: Icons.campaign_outlined,
              title: 'School Announcement',
              description: 'Send a message to all parents',
              color: Colors.blue,
              onTap: () => _showAnnouncementDialog(context, ref, students),
            ),

            const SizedBox(height: 12),

            Text(
              'Individual Student Notifications',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),

            const SizedBox(height: 8),

            // Per-student notification options
            ...students.map((student) {
              return _StudentNotificationCard(
                student: student,
              );
            }),
          ],
        );
      },
    );
  }

  void _showAnnouncementDialog(
      BuildContext context,
      WidgetRef ref,
      List<StudentModel> students,
      ) {
    final messageCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(
      text: 'Announcement from SmartKids Pre-School',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('School Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final service = ref.read(notificationServiceProvider);
              final user = ref.read(currentUserProvider).value;
              int sent = 0;

              // Send to every unique parent email
              final emails = <String>{};
              for (final student in students) {
                if (student.guardian1.email.isNotEmpty) {
                  emails.add(student.guardian1.email);
                }
                if (student.guardian2.email.isNotEmpty) {
                  emails.add(student.guardian2.email);
                }
              }

              for (final email in emails) {
                await service.sendEmail(
                  toEmail: email,
                  toName: 'Parent/Guardian',
                  subject: subjectCtrl.text.trim(),
                  message: service.announcementMessage(
                    messageCtrl.text.trim(),
                  ),
                  studentName: 'All Students',
                  type: 'announcement',
                  sentBy: user?.uid ?? '',
                );
                sent++;
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Announcement sent to $sent email(s)'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Send to All'),
          ),
        ],
      ),
    );
  }
}

// ================= STUDENT NOTIFICATION CARD =================

class _StudentNotificationCard extends ConsumerWidget {
  final StudentModel student;
  const _StudentNotificationCard({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(student.name, style: theme.textTheme.titleSmall),
        subtitle: Text(student.className),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Absence alert
                _ActionButton(
                  icon: Icons.person_off_outlined,
                  label: 'Absence Alert',
                  color: Colors.red,
                  onTap: () => _sendAbsenceAlert(context, ref),
                ),
                const SizedBox(height: 8),
                // Fee reminder
                _ActionButton(
                  icon: Icons.payments_outlined,
                  label: 'Fee Reminder',
                  color: Colors.orange,
                  onTap: () => _sendFeeReminder(context, ref),
                ),
                const SizedBox(height: 8),
                // Report card ready
                _ActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Report Card Ready',
                  color: Colors.purple,
                  onTap: () => _sendReportCardNotification(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAbsenceAlert(BuildContext context, WidgetRef ref) async {
    final service = ref.read(notificationServiceProvider);
    final user = ref.read(currentUserProvider).value;
    final today =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    final message = service.absenceAlertMessage(student.name, today);

    await _showSendOptions(context, ref, 'Absence Alert', message);
  }

  Future<void> _sendFeeReminder(BuildContext context, WidgetRef ref) async {
    final service = ref.read(notificationServiceProvider);
    // Get latest fee balance — use 0 as fallback
    final message = service.feeReminderMessage(student.name, 0);
    await _showSendOptions(context, ref, 'Fee Reminder', message);
  }

  Future<void> _sendReportCardNotification(
      BuildContext context, WidgetRef ref) async {
    final service = ref.read(notificationServiceProvider);
    final message = service.reportCardMessage(student.name, 'Term');
    await _showSendOptions(context, ref, 'Report Card Ready', message);
  }

  // Shows a dialog with editable message + Email/WhatsApp options
  Future<void> _showSendOptions(
      BuildContext context,
      WidgetRef ref,
      String type,
      String defaultMessage,
      ) async {
    final messageCtrl = TextEditingController(text: defaultMessage);
    final service = ref.read(notificationServiceProvider);
    final user = ref.read(currentUserProvider).value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type — ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable message
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),

            const SizedBox(height: 16),

            Text(
              'Send via:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // WhatsApp button
          if (student.guardian1.contact.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await service.sendWhatsApp(
                    phone: student.guardian1.contact,
                    message: messageCtrl.text.trim(),
                    studentName: student.name,
                    type: type,
                    sentBy: user?.uid ?? '',
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('WhatsApp error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.message, color: Color(0xFF25D366)),
              label: const Text('WhatsApp'),
            ),

          // Email button
          if (student.guardian1.email.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await service.sendEmail(
                    toEmail: student.guardian1.email,
                    toName: student.guardian1.name,
                    subject: '$type — ${student.name}',
                    message: messageCtrl.text.trim(),
                    studentName: student.name,
                    type: type,
                    sentBy: user?.uid ?? '',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email sent successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.email_outlined),
              label: const Text('Email'),
            ),
        ],
      ),
    );
  }
}

// ================= HISTORY TAB =================

class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(notificationsLogProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: theme.disabledColor),
                const SizedBox(height: 16),
                Text('No notifications sent yet',
                    style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: log.channel == 'email'
                      ? Colors.blue.withValues(alpha: 0.1)
                      : const Color(0xFF25D366).withValues(alpha: 0.1),
                  child: Icon(
                    log.channel == 'email'
                        ? Icons.email_outlined
                        : Icons.message,
                    color: log.channel == 'email'
                        ? Colors.blue
                        : const Color(0xFF25D366),
                    size: 20,
                  ),
                ),
                title: Text(log.title,
                    style: theme.textTheme.titleSmall),
                subtitle: Text(
                  '${log.studentName} • ${log.sentTo}',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${log.sentAt.day}/${log.sentAt.month}/${log.sentAt.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ================= REUSABLE WIDGETS =================

class _NotificationTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _NotificationTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(description),
        trailing: Icon(Icons.chevron_right, color: theme.disabledColor),
        onTap: onTap,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 18),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}