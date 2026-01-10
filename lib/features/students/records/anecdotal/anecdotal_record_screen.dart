import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnecdotalRecordScreen extends StatelessWidget {
  final String studentId;

  const AnecdotalRecordScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final recordsRef = FirebaseFirestore.instance
        .collection('schools')
        .doc('defaultSchool')
        .collection('students')
        .doc(studentId)
        .collection('anecdotal');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Anecdotal Records"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecordDialog(context, recordsRef);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: recordsRef
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No anecdotal records yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data =
              docs[index].data() as Map<String, dynamic>;

              final timestamp = data['date'] as Timestamp?;
              final date = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                  timestamp.millisecondsSinceEpoch)
                  : null;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['note'] ?? '',
                        style: theme.textTheme.bodyLarge,
                      ),
                      if ((data['followUp'] ?? '').isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 8),
                          child: Text(
                            "Follow-up: ${data['followUp']}",
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                color:
                                theme.hintColor),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        date != null
                            ? "${date.day}/${date.month}/${date.year}"
                            : "",
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= ADD RECORD DIALOG =================

  void _showAddRecordDialog(
      BuildContext context,
      CollectionReference recordsRef,
      ) {
    final noteCtrl = TextEditingController();
    final followCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("New Anecdotal Record"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Observation / Note",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: followCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Follow-up (optional)",
                  ),
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
                if (noteCtrl.text.trim().isEmpty) return;

                await recordsRef.add({
                  'note': noteCtrl.text.trim(),
                  'followUp': followCtrl.text.trim(),
                  'date': FieldValue.serverTimestamp(),
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
