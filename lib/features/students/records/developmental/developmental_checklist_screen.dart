import 'package:flutter/material.dart';

enum SkillStatus { achieved, developing, needsSupport }

class DevelopmentalChecklistScreen extends StatelessWidget {
  const DevelopmentalChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Developmental Checklist"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DomainSection(
            title: "Physical Development",
            skills: [
              "Gross motor coordination",
              "Fine motor control",
              "Balance and posture",
            ],
          ),
          SizedBox(height: 16),
          _DomainSection(
            title: "Cognitive Development",
            skills: [
              "Problem solving",
              "Memory recall",
              "Attention span",
            ],
          ),
          SizedBox(height: 16),
          _DomainSection(
            title: "Social & Emotional Development",
            skills: [
              "Works well with peers",
              "Manages emotions",
              "Shows confidence",
            ],
          ),
        ],
      ),
    );
  }
}

class _DomainSection extends StatelessWidget {
  final String title;
  final List<String> skills;

  const _DomainSection({
    required this.title,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...skills.map((skill) => _SkillRow(skill: skill)),
          ],
        ),
      ),
    );
  }
}

class _SkillRow extends StatefulWidget {
  final String skill;

  const _SkillRow({required this.skill});

  @override
  State<_SkillRow> createState() => _SkillRowState();
}

class _SkillRowState extends State<_SkillRow> {
  SkillStatus status = SkillStatus.developing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(widget.skill),
          ),
          _statusChip(
            label: "Achieved",
            selected: status == SkillStatus.achieved,
            onTap: () => setState(() => status = SkillStatus.achieved),
            context: context,
          ),
          const SizedBox(width: 6),
          _statusChip(
            label: "Developing",
            selected: status == SkillStatus.developing,
            onTap: () => setState(() => status = SkillStatus.developing),
            context: context,
          ),
          const SizedBox(width: 6),
          _statusChip(
            label: "Needs Support",
            selected: status == SkillStatus.needsSupport,
            onTap: () => setState(() => status = SkillStatus.needsSupport),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? theme.colorScheme.primary
                : theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
