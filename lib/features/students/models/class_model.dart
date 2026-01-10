class ClassModel {
  final String id;
  final String name;
  final String level;
  final String ageRange;
  final List<String> teacherIds;
  final List<String> assistantIds;

  const ClassModel({
    required this.id,
    required this.name,
    required this.level,
    required this.ageRange,
    required this.teacherIds,
    required this.assistantIds,
  });
}
