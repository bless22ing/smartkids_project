// This class represents what a specific user is ALLOWED to do
// Separate from their role — because role tells us WHO they are,
// permissions tell us WHAT they can do
class UserPermissions {
  final bool canWriteRecords;      // anecdotes and social development
  final bool canMarkAttendance;    // take register
  final bool canManageFees;        // add/edit fee records
  final bool canViewReports;       // see progress reports

  const UserPermissions({
    this.canWriteRecords = false,
    this.canMarkAttendance = false,
    this.canManageFees = false,
    this.canViewReports = false,
  });

  // All permissions off — used for unknown or restricted users
  const UserPermissions.none()
      : canWriteRecords = false,
        canMarkAttendance = false,
        canManageFees = false,
        canViewReports = false;

  // Full permissions — used for admin
  // Admin can do everything without needing explicit grants
  const UserPermissions.admin()
      : canWriteRecords = true,
        canMarkAttendance = true,
        canManageFees = true,
        canViewReports = true;

  // Default teacher permissions
  // Teachers get these automatically without admin needing to grant them
  const UserPermissions.teacher()
      : canWriteRecords = true,
        canMarkAttendance = true,
        canManageFees = false,
        canViewReports = true;

  // Convert Firestore map into a UserPermissions object
  // This runs when we fetch a user's document from Firestore
  factory UserPermissions.fromMap(Map<String, dynamic> map) {
    return UserPermissions(
      canWriteRecords: map['can_write_records'] ?? false,
      canMarkAttendance: map['can_mark_attendance'] ?? false,
      canManageFees: map['can_manage_fees'] ?? false,
      canViewReports: map['can_view_reports'] ?? false,
    );
  }

  // Convert UserPermissions into a map to SAVE to Firestore
  Map<String, dynamic> toMap() {
    return {
      'can_write_records': canWriteRecords,
      'can_mark_attendance': canMarkAttendance,
      'can_manage_fees': canManageFees,
      'can_view_reports': canViewReports,
    };
  }
}