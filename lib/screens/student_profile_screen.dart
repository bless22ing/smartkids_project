import 'package:flutter/material.dart';
import 'package:smartkids_project/core/theme/app_theme.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Student Profile"),
          bottom: const TabBar(
            indicatorColor: AppTheme.maroon,
            tabs: [
              Tab(text: "Profile"),
              Tab(text: "Academic"),
              Tab(text: "Fees"),
              Tab(text: "Social Record"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProfileTab(),
            _AcademicTab(),
            _FeesTab(),
            _SocialTab(),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.maroon,
              child: const Icon(Icons.child_care,
                  size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          _infoTile("Name", "Tariro M."),
          _infoTile("Age", "5 years"),
          _infoTile("Level", "ECDA"),
          _infoTile("Enrollment Status", "Active"),
          _infoTile("Year Enrolled", "2024"),
        ],
      ),
    );
  }
}

class _AcademicTab extends StatelessWidget {
  const _AcademicTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          _RecordCard(
            title: "Term 1 Progress",
            content:
            "Shows good participation in class activities and learning songs.",
          ),
          _RecordCard(
            title: "Term 2 Progress",
            content:
            "Improved recognition of numbers and letters.",
          ),
        ],
      ),
    );
  }
}

class _FeesTab extends StatelessWidget {
  const _FeesTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: const Text("Total Fees"),
              trailing: const Text("\$300"),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Amount Paid"),
              trailing: const Text("\$250"),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Balance"),
              trailing: Text(
                "\$50",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialTab extends StatelessWidget {
  const _SocialTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          _RecordCard(
            title: "Social Interaction",
            content:
            "Plays well with peers and shares toys willingly.",
          ),
          _RecordCard(
            title: "Emotional Development",
            content:
            "Expresses emotions clearly and responds well to guidance.",
          ),
          _RecordCard(
            title: "Teacher Notes",
            content:
            "Responds positively to routine and structured activities.",
          ),
        ],
      ),
    );
  }
}

Widget _infoTile(String label, String value) {
  return Card(
    child: ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class _RecordCard extends StatelessWidget {
  final String title;
  final String content;

  const _RecordCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
