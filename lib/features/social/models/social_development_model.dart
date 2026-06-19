import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

// Rating scale — 1 to 4
enum SkillRating {
  needsSupport,
  developing,
  proficient,
  advanced;

  String get displayName {
    switch (this) {
      case SkillRating.needsSupport:
        return 'Needs Support';
      case SkillRating.developing:
        return 'Developing';
      case SkillRating.proficient:
        return 'Proficient';
      case SkillRating.advanced:
        return 'Advanced';
    }
  }

  // Numeric value 1-4 — stored in Firestore
  int get value {
    switch (this) {
      case SkillRating.needsSupport:
        return 1;
      case SkillRating.developing:
        return 2;
      case SkillRating.proficient:
        return 3;
      case SkillRating.advanced:
        return 4;
    }
  }

  // Convert numeric value back to enum
  static SkillRating fromValue(int value) {
    switch (value) {
      case 1:
        return SkillRating.needsSupport;
      case 2:
        return SkillRating.developing;
      case 3:
        return SkillRating.proficient;
      case 4:
        return SkillRating.advanced;
      default:
        return SkillRating.developing;
    }
  }

  Color get color {
    switch (this) {
      case SkillRating.needsSupport:
        return const Color(0xFFEF5350); // red
      case SkillRating.developing:
        return const Color(0xFFFFB74D); // orange
      case SkillRating.proficient:
        return const Color(0xFF66BB6A); // green
      case SkillRating.advanced:
        return const Color(0xFF42A5F5); // blue
    }
  }
}

// The list of skills we track — easy to extend later
// This is the single source of truth for skill names
class SocialSkills {
  static const sharing = 'sharing';
  static const communication = 'communication';
  static const emotionalRegulation = 'emotionalRegulation';
  static const independence = 'independence';
  static const peerInteraction = 'peerInteraction';
  static const followingInstructions = 'followingInstructions';
  static const empathy = 'empathy';
  static const conflictResolution = 'conflictResolution';

  // Display names for each skill
  static const Map<String, String> displayNames = {
    sharing: 'Sharing & Cooperation',
    communication: 'Communication Skills',
    emotionalRegulation: 'Emotional Regulation',
    independence: 'Independence / Self-Help',
    peerInteraction: 'Peer Interaction',
    followingInstructions: 'Following Instructions',
    empathy: 'Empathy & Kindness',
    conflictResolution: 'Conflict Resolution',
  };

  // All skill keys — used to generate the rating form
  // Adding a new skill later means just adding it here
  static const List<String> all = [
    sharing,
    communication,
    emotionalRegulation,
    independence,
    peerInteraction,
    followingInstructions,
    empathy,
    conflictResolution,
  ];
}

// A single record — one observation entry for a student
class SocialDevelopmentRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String recordedBy; // uid of teacher/admin
  final String recordedByName;
  final DateTime date;

  // Map of skill key -> rating value (1-4)
  final Map<String, int> ratings;

  // Optional comment
  final String comment;

  const SocialDevelopmentRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.recordedBy,
    required this.recordedByName,
    required this.date,
    required this.ratings,
    this.comment = '',
  });

  // Get rating for a specific skill — returns null if not rated
  SkillRating? ratingFor(String skillKey) {
    final value = ratings[skillKey];
    if (value == null) return null;
    return SkillRating.fromValue(value);
  }

  factory SocialDevelopmentRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SocialDevelopmentRecord(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      recordedBy: data['recordedBy'] ?? '',
      recordedByName: data['recordedByName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      ratings: Map<String, int>.from(data['ratings'] ?? {}),
      comment: data['comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'recordedBy': recordedBy,
      'recordedByName': recordedByName,
      'date': Timestamp.fromDate(date),
      'ratings': ratings,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}