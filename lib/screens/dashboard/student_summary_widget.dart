import 'package:flutter/material.dart';
import 'package:smartkids_project/core/theme/app_theme.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: const [
                _SummaryCard(title: "Enrolled", value: "48"),
                SizedBox(width: 16),
                _SummaryCard(title: "Graduated", value: "120"),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Student Records",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: const [
                  _StudentTile(
                    name: "Tariro M.",
                    age: 5,
                    level: "ECD A",
                    balance: 50,
                    active: true,
                  ),
                  _StudentTile(
                    name: "Kudzai N.",
                    age: 7,
                    level: "ECD B",
                    balance: 0,
                    active: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final String name;
  final int age;
  final String level;
  final double balance;
  final bool active;

  const _StudentTile({
    required this.name,
    required this.age,
    required this.level,
    required this.balance,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.maroon,
          child: const Icon(Icons.child_care, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text("Age: $age • Level: $level"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              balance > 0 ? "Balance: \$${balance.toStringAsFixed(0)}" : "Paid",
              style: TextStyle(
                color: balance > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              active ? "Enrolled" : "Graduated",
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.blueGrey : Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Open Student Profile (tabs: Academic | Social | Fees)
        },
      ),
    );
  }
}
