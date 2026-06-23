import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/models/student_model.dart';
import '../../auth/services/auth_service.dart';
import '../models/anecdote_model.dart';
import '../services/anecdote_service.dart';

class AddAnecdoteScreen extends ConsumerStatefulWidget {
  final StudentModel student;
  const AddAnecdoteScreen({super.key, required this.student});

  @override
  ConsumerState<AddAnecdoteScreen> createState() =>
      _AddAnecdoteScreenState();
}

class _AddAnecdoteScreenState extends ConsumerState<AddAnecdoteScreen> {
  final _observationCtrl = TextEditingController();
  AnecdoteCategory _category = AnecdoteCategory.academic;
  bool _saving = false;

  @override
  void dispose() {
    _observationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_observationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write an observation')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;

      final anecdote = AnecdoteModel(
        id: '',
        studentId: widget.student.id,
        studentName: widget.student.name,
        classId: widget.student.classId,
        category: _category,
        observation: _observationCtrl.text.trim(),
        recordedBy: user?.uid ?? '',
        recordedByName: user?.name ?? 'Unknown',
        date: DateTime.now(),
      );

      await ref.read(anecdoteServiceProvider).addAnecdote(anecdote);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anecdote saved'),
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
        title: Text('New Anecdote — ${widget.student.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Category', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AnecdoteCategory.values.map((cat) {
              final isSelected = _category == cat;
              return ChoiceChip(
                avatar: Icon(
                  cat.icon,
                  size: 16,
                  color: isSelected ? cat.color : null,
                ),
                label: Text(cat.displayName),
                selected: isSelected,
                onSelected: (_) => setState(() => _category = cat),
                selectedColor: cat.color.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? cat.color : null,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? cat.color : theme.dividerColor,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Text('Observation', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),

          TextField(
            controller: _observationCtrl,
            decoration: InputDecoration(
              hintText:
              'Describe what you observed — be specific and objective...',
              filled: true,
              fillColor:
              theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 8,
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
                  : const Text('Save Anecdote'),
            ),
          ),
        ],
      ),
    );
  }
}