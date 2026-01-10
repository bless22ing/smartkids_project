import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DevelopmentChecklistScreen extends StatelessWidget {
  final String studentId;

  const DevelopmentChecklistScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final checklistRef = FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('development')
        .orderBy('area');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Development Checklist"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: checklistRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No checklist items yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _ChecklistTile(
                docId: doc.id,
                studentId: studentId,
                area: data['area'] ?? '',
                skill: data['skill'] ?? '',
                achieved: data['achieved'] ?? false,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChecklistDialog(context, studentId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= ADD CHECKLIST ITEM =================

  void _showAddChecklistDialog(BuildContext context, String studentId) {
    final areaCtrl = TextEditingController();
    final skillCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Checklist Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: areaCtrl,
                decoration: const InputDecoration(
                  labelText: "Development Area",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skillCtrl,
                decoration: const InputDecoration(
                  labelText: "Skill",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (areaCtrl.text.isEmpty || skillCtrl.text.isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(studentId)
                    .collection('development')
                    .add({
                  'area': areaCtrl.text.trim(),
                  'skill': skillCtrl.text.trim(),
                  'achieved': false,
                  'lastUpdated': Timestamp.now(),
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

// ================= CHECKLIST TILE =================

class _ChecklistTile extends StatelessWidget {
  final String docId;
  final String studentId;
  final String area;
  final String skill;
  final bool achieved;

  const _ChecklistTile({
    required this.docId,
    required this.studentId,
    required this.area,
    required this.skill,
    required this.achieved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: achieved,
        onChanged: (value) async {
          await FirebaseFirestore.instance
              .collection('students')
              .doc(studentId)
              .collection('development')
              .doc(docId)
              .update({
            'achieved': value,
            'lastUpdated': Timestamp.now(),
          });
        },
        title: Text(skill),
        subtitle: Text(area),
        activeColor: theme.colorScheme.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
