import 'package:smartkids_project/shared/models/user_permissions.dart';

enum UserRole {
  admin,
  teacher,
  assistant;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
          (e) => e.name == role,
      orElse: () => UserRole.teacher,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.assistant:
        return 'Assistant';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isTeacher => this == UserRole.teacher;
  bool get isAssistant => this == UserRole.assistant;

  // Returns the DEFAULT permissions for this role
  // Admin and teachers get permissions automatically
  // Assistants start with none — admin grants them individually
  UserPermissions get defaultPermissions {
    switch (this) {
      case UserRole.admin:
        return const UserPermissions.admin();
      case UserRole.teacher:
        return const UserPermissions.teacher();
      case UserRole.assistant:
        return const UserPermissions.none();
    }
  }
}