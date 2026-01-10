import 'package:flutter/material.dart';
import 'class_details_screen.dart';
import 'students/models/class_model.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final classes = const [
      ClassModel(
        id: "1",
        name: "ECD A ",
        level: "ECD A",
        ageRange: "4–5 years",
        teacherIds: ["t1"],
        assistantIds: ["a1"],
      ),
      ClassModel(
        id: "2",
        name: "ECD B",
        level: "ECD B",
        ageRange: "5–6 years",
        teacherIds: ["t2"],
        assistantIds: ["a2"],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Classes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add class (Admin)
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = classes[index];

          return Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text("${item.level} • ${item.ageRange}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassDetailsScreen(classModel: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
