enum UserRole {
  admin,
  teacher,
  assistant,
}

UserRole roleFromString(String role) {
  switch (role) {
    case 'admin':
      return UserRole.admin;
    case 'teacher':
      return UserRole.teacher;
    case 'assistant':
      return UserRole.assistant;
    default:
      return UserRole.teacher;
  }
}
