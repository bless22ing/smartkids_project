import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student_model.dart';
import '../../auth/services/auth_service.dart';
import '../models/social_development_model.dart';
import '../services/social_development_service.dart';

class AddSocialRecordScreen extends ConsumerStatefulWidget {
  final StudentModel student;
  const AddSocialRecordScreen({super.key, required this.student});

  @override
  ConsumerState<AddSocialRecordScreen> createState() =>
      _AddSocialRecordScreenState();
}

class _AddSocialRecordScreenState
    extends ConsumerState<AddSocialRecordScreen> {
  // Map of skill key -> selected rating
  final Map<String, SkillRating> _ratings = {};
  final _commentCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Require at least one skill rated
    if (_ratings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate at least one skill'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;

      final record = SocialDevelopmentRecord(
        id: '',
        studentId: widget.student.id,
        studentName: widget.student.name,
        classId: widget.student.classId,
        recordedBy: user?.uid ?? '',
        recordedByName: user?.name ?? 'Unknown',
        date: DateTime.now(),
        // Convert SkillRating map to int map for storage
        ratings: _ratings.map((key, rating) =>
            MapEntry(key, rating.value)),
        comment: _commentCtrl.text.trim(),
      );

      await ref.read(socialDevServiceProvider).addRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rate ${widget.student.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rate each skill you observed today. '
                        'You can skip skills you did not observe.',
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Generate a rating card for each skill in SocialSkills.all
          // This is why we made SocialSkills.all a list —
          // adding a new skill later means it appears here automatically
          ...SocialSkills.all.map((skillKey) {
            return _SkillRatingCard(
              skillName: SocialSkills.displayNames[skillKey]!,
              selectedRating: _ratings[skillKey],
              onRatingSelected: (rating) {
                setState(() => _ratings[skillKey] = rating);
              },
            );
          }),

          const SizedBox(height: 16),

          // Comment field
          TextField(
            controller: _commentCtrl,
            decoration: InputDecoration(
              labelText: 'Additional Comments (optional)',
              hintText: 'Any specific observations or context...',
              filled: true,
              fillColor:
              theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 4,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Save Record'),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SKILL RATING CARD =================

class _SkillRatingCard extends StatelessWidget {
  final String skillName;
  final SkillRating? selectedRating;
  final ValueChanged<SkillRating> onRatingSelected;

  const _SkillRatingCard({
    required this.skillName,
    required this.selectedRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(skillName, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),

            // Rating buttons — one per SkillRating value
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SkillRating.values.map((rating) {
                final isSelected = selectedRating == rating;
                return ChoiceChip(
                  label: Text(rating.displayName),
                  selected: isSelected,
                  onSelected: (_) => onRatingSelected(rating),
                  selectedColor: rating.color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? rating.color : null,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? rating.color
                        : theme.dividerColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}