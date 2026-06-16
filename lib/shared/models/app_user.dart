import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';
import 'user_permissions.dart';

// This is the complete picture of a logged-in user
// Role + Permissions + Profile info all in one place
// Any widget that needs to know about the current user
// will use this model
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? classId;        // which ECD class they're assigned to
  final UserPermissions permissions;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.classId,
    required this.permissions,
  });

  // Build an AppUser from a Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = UserRole.fromString(data['role'] ?? 'assistant');

    // If the user has custom permissions in Firestore, use those
    // Otherwise fall back to the default permissions for their role
    // This is how admin-granted permissions work —
    // admin writes to the permissions map in Firestore,
    // and next time this user logs in, they get those permissions
    final UserPermissions permissions;
    if (data['permissions'] != null) {
      permissions = UserPermissions.fromMap(
        Map<String, dynamic>.from(data['permissions']),
      );
    } else {
      permissions = role.defaultPermissions;
    }

    return AppUser(
      uid: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      role: role,
      classId: data['classId'],
      permissions: permissions,
    );
  }

  // Quick helpers — use these in your UI
  // Instead of checking role AND permissions separately,
  // you call one clean method
  bool get canWriteRecords =>
      role.isAdmin || permissions.canWriteRecords;

  bool get canMarkAttendance =>
      role.isAdmin || role.isTeacher || permissions.canMarkAttendance;

  bool get canManageFees =>
      role.isAdmin || permissions.canManageFees;

  bool get canViewReports =>
      role.isAdmin || permissions.canViewReports;
}