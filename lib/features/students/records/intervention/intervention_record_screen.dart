import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InterventionRecordScreen extends StatelessWidget {
  final String studentId;
  final String type; // remedial | extension

  const InterventionRecordScreen({
    super.key,
    required this.studentId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final interventionsRef = FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('interventions')
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == 'remedial'
              ? "Remedial Records"
              : "Extension Records",
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddInterventionDialog(context, studentId, type);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: interventionsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No records yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return _InterventionTile(
                date: data['date'] ?? '',
                subject: data['subject'] ?? '',
                focus: data['focus'] ?? '',
                outcome: data['outcome'] ?? '',
                type: type,
              );
            },
          );
        },
      ),
    );
  }

  // ================= ADD DIALOG =================

  void _showAddInterventionDialog(
      BuildContext context,
      String studentId,
      String type,
      ) {
    final dateCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final focusCtrl = TextEditingController();
    final strategyCtrl = TextEditingController();
    final outcomeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            type == 'remedial'
                ? "Add Remedial Record"
                : "Add Extension Record",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(
                    labelText: "Date (YYYY-MM-DD)",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: "Subject",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: focusCtrl,
                  decoration: const InputDecoration(
                    labelText: "Focus Area",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: strategyCtrl,
                  decoration: const InputDecoration(
                    labelText: "Strategy Used",
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: outcomeCtrl,
                  decoration: const InputDecoration(
                    labelText: "Outcome",
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dateCtrl.text.isEmpty ||
                    subjectCtrl.text.isEmpty ||
                    focusCtrl.text.isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(studentId)
                    .collection('interventions')
                    .add({
                  'type': type,
                  'date': dateCtrl.text.trim(),
                  'subject': subjectCtrl.text.trim(),
                  'focus': focusCtrl.text.trim(),
                  'strategy': strategyCtrl.text.trim(),
                  'outcome': outcomeCtrl.text.trim(),
                  'createdAt': Timestamp.now(),
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

// ================= TILE =================

class _InterventionTile extends StatelessWidget {
  final String date;
  final String subject;
  final String focus;
  final String outcome;
  final String type;

  const _InterventionTile({
    required this.date,
    required this.subject,
    required this.focus,
    required this.outcome,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color =
    type == 'remedial' ? Colors.red : Colors.green;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            type == 'remedial'
                ? Icons.build_outlined
                : Icons.star_outline,
            color: color,
          ),
        ),
        title: Text("$subject • $date"),
        subtitle: Text(focus),
        trailing: outcome.isNotEmpty
            ? Text(
          outcome,
          style: theme.textTheme.labelSmall,
        )
            : null,
      ),
    );
  }
}
