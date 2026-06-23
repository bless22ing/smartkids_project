import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AnecdoteCategory {
  academic,
  social,
  behavioral,
  milestone;

  String get displayName {
    switch (this) {
      case AnecdoteCategory.academic:
        return 'Academic';
      case AnecdoteCategory.social:
        return 'Social';
      case AnecdoteCategory.behavioral:
        return 'Behavioral';
      case AnecdoteCategory.milestone:
        return 'Milestone';
    }
  }

  IconData get icon {
    switch (this) {
      case AnecdoteCategory.academic:
        return Icons.menu_book_outlined;
      case AnecdoteCategory.social:
        return Icons.groups_outlined;
      case AnecdoteCategory.behavioral:
        return Icons.psychology_outlined;
      case AnecdoteCategory.milestone:
        return Icons.star_outline;
    }
  }

  Color get color {
    switch (this) {
      case AnecdoteCategory.academic:
        return const Color(0xFF42A5F5); // blue
      case AnecdoteCategory.social:
        return const Color(0xFF66BB6A); // green
      case AnecdoteCategory.behavioral:
        return const Color(0xFFFFB74D); // orange
      case AnecdoteCategory.milestone:
        return const Color(0xFFAB47BC); // purple
    }
  }

  static AnecdoteCategory fromString(String value) {
    return AnecdoteCategory.values.firstWhere(
          (e) => e.name == value,
      orElse: () => AnecdoteCategory.academic,
    );
  }
}

class AnecdoteModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final AnecdoteCategory category;
  final String observation;
  final String recordedBy;
  final String recordedByName;
  final DateTime date;

  const AnecdoteModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.category,
    required this.observation,
    required this.recordedBy,
    required this.recordedByName,
    required this.date,
  });

  factory AnecdoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AnecdoteModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      category: AnecdoteCategory.fromString(data['category'] ?? 'academic'),
      observation: data['observation'] ?? '',
      recordedBy: data['recordedBy'] ?? '',
      recordedByName: data['recordedByName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'category': category.name,
      'observation': observation,
      'recordedBy': recordedBy,
      'recordedByName': recordedByName,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}