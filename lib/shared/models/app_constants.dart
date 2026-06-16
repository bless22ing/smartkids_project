// Single source of truth for constant values used across the app
// Never type "ecda" as a raw string anywhere else — always use these
// This way if naming ever changes, you change it in ONE place only
class AppConstants {
  // Class IDs — must match exactly what's in Firestore
  static const String classEcdA = 'ecda';
  static const String classEcdB = 'ecdb';

  // Collection names — same idea
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String classesCollection = 'classes';
  static const String attendanceCollection = 'attendance';
  static const String anecdotesCollection = 'anecdotes';
  static const String socialDevCollection = 'social_development';

  // Class display names
  static const String classEcdAName = 'ECD A';
  static const String classEcdBName = 'ECD B';

  // Helper — get display name from class ID
  static String classDisplayName(String classId) {
    switch (classId) {
      case classEcdA:
        return classEcdAName;
      case classEcdB:
        return classEcdBName;
      default:
        return 'Unknown Class';
    }
  }
}