import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../students/models/student_model.dart';

final notificationServiceProvider =
Provider<NotificationService>((ref) => NotificationService());

// Stream all sent notifications for history log
final notificationsLogProvider =
StreamProvider<List<NotificationLog>>((ref) {
  return ref.read(notificationServiceProvider).streamNotifications();
});

// Represents a record of a sent notification
class NotificationLog {
  final String id;
  final String type;
  final String title;
  final String message;
  final String sentTo; // email or phone
  final String studentName;
  final String channel; // 'email' or 'whatsapp'
  final DateTime sentAt;
  final String sentBy;

  const NotificationLog({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.sentTo,
    required this.studentName,
    required this.channel,
    required this.sentAt,
    required this.sentBy,
  });

  factory NotificationLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationLog(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      sentTo: data['sentTo'] ?? '',
      studentName: data['studentName'] ?? '',
      channel: data['channel'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      sentBy: data['sentBy'] ?? '',
    );
  }
}

class NotificationService {
  final _db = FirebaseFirestore.instance;

  // Stream notifications log newest first
  Stream<List<NotificationLog>> streamNotifications() {
    return _db
        .collection('notifications_log')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map(NotificationLog.fromFirestore).toList());
  }

  // Send email via Firebase Trigger Email extension
  // Writing to 'mail' collection triggers the extension automatically
  // Opens device email app with pre-filled message
// No backend needed — admin taps send in their email app
  Future<void> sendEmail({
    required String toEmail,
    required String toName,
    required String subject,
    required String message,
    required String studentName,
    required String type,
    required String sentBy,
  }) async {
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(message);

    final url = Uri.parse(
      'mailto:$toEmail?subject=$encodedSubject&body=$encodedBody',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);

      // Log after opening email app
      await _logNotification(
        type: type,
        title: subject,
        message: message,
        sentTo: toEmail,
        studentName: studentName,
        channel: 'email',
        sentBy: sentBy,
      );
    } else {
      throw Exception('No email app found on this device');
    }
  }

  // Open WhatsApp with pre-filled message
  // No API needed — uses wa.me deep link
  Future<void> sendWhatsApp({
    required String phone,
    required String message,
    required String studentName,
    required String type,
    required String sentBy,
  }) async {
    // Clean phone number — remove spaces, dashes, leading 0
    // Add Zimbabwe country code 263
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '263${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('263')) {
      cleaned = '263$cleaned';
    }

    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleaned?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      // Log the notification after opening WhatsApp
      await _logNotification(
        type: type,
        title: 'WhatsApp: $type',
        message: message,
        sentTo: phone,
        studentName: studentName,
        channel: 'whatsapp',
        sentBy: sentBy,
      );
    } else {
      throw Exception('WhatsApp is not installed on this device');
    }
  }

  Future<void> _logNotification({
    required String type,
    required String title,
    required String message,
    required String sentTo,
    required String studentName,
    required String channel,
    required String sentBy,
  }) async {
    await _db.collection('notifications_log').add({
      'type': type,
      'title': title,
      'message': message,
      'sentTo': sentTo,
      'studentName': studentName,
      'channel': channel,
      'sentAt': FieldValue.serverTimestamp(),
      'sentBy': sentBy,
    });
  }

  // Pre-built message templates for each notification type
  // Admin can edit these before sending

  String absenceAlertMessage(String studentName, String date) =>
      'Dear Parent/Guardian,\n\nThis is to inform you that $studentName '
          'was marked absent from SmartKids Pre-School on $date.\n\n'
          'If this absence was planned, please disregard this message. '
          'If not, please contact the school as soon as possible.\n\n'
          'Regards,\nSmartKids Pre-School';

  String feeReminderMessage(String studentName, double balance) =>
      'Dear Parent/Guardian,\n\nThis is a friendly reminder that '
          '$studentName has an outstanding school fees balance of '
          'USD \$${balance.toStringAsFixed(2)}.\n\n'
          'Please settle this balance at your earliest convenience. '
          'Contact us if you need to discuss a payment arrangement.\n\n'
          'Regards,\nSmartKids Pre-School';

  String reportCardMessage(String studentName, String term) =>
      'Dear Parent/Guardian,\n\nThe ${term} report card for '
          '$studentName is now ready. Please collect it from the '
          'school at your earliest convenience.\n\n'
          'Regards,\nSmartKids Pre-School';

  String announcementMessage(String announcement) =>
      'Dear Parent/Guardian,\n\n$announcement\n\n'
          'Regards,\nSmartKids Pre-School';
}