import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadingRecordScreen extends StatelessWidget {
  final String studentId;

  const ReadingRecordScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final readingRef = FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('reading')
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading Records"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReadingDialog(context, studentId);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: readingRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No reading records yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return _ReadingTile(
                date: data['date'] ?? '',
                bookTitle: data['bookTitle'] ?? '',
                level: data['level'] ?? '',
                comment: data['comment'] ?? '',
              );
            },
          );
        },
      ),
    );
  }

  // ================= ADD READING DIALOG =================

  void _showAddReadingDialog(BuildContext context, String studentId) {
    final dateCtrl = TextEditingController();
    final bookCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    String level = 'Good';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Reading Record"),
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
                  controller: bookCtrl,
                  decoration: const InputDecoration(
                    labelText: "Book Title",
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: level,
                  items: const [
                    DropdownMenuItem(
                        value: 'Excellent', child: Text('Excellent')),
                    DropdownMenuItem(value: 'Good', child: Text('Good')),
                    DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                    DropdownMenuItem(
                        value: 'Needs Support',
                        child: Text('Needs Support')),
                  ],
                  onChanged: (value) {
                    level = value!;
                  },
                  decoration: const InputDecoration(
                    labelText: "Reading Level",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentCtrl,
                  decoration: const InputDecoration(
                    labelText: "Comment",
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
                if (dateCtrl.text.isEmpty || bookCtrl.text.isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(studentId)
                    .collection('reading')
                    .add({
                  'date': dateCtrl.text.trim(),
                  'bookTitle': bookCtrl.text.trim(),
                  'level': level,
                  'comment': commentCtrl.text.trim(),
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

// ================= READING TILE =================

class _ReadingTile extends StatelessWidget {
  final String date;
  final String bookTitle;
  final String level;
  final String comment;

  const _ReadingTile({
    required this.date,
    required this.bookTitle,
    required this.level,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color levelColor() {
      switch (level) {
        case 'Excellent':
          return Colors.green;
        case 'Good':
          return Colors.blue;
        case 'Fair':
          return Colors.orange;
        case 'Needs Support':
          return Colors.red;
        default:
          return theme.disabledColor;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: levelColor().withValues(alpha: 0.15),
          child: Icon(
            Icons.menu_book_outlined,
            color: levelColor(),
          ),
        ),
        title: Text("$bookTitle • $date"),
        subtitle: comment.isNotEmpty ? Text(comment) : null,
        trailing: Text(
          level,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: levelColor(),
          ),
        ),
      ),
    );
  }
}
