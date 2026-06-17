import 'package:flutter/material.dart';

class AnecdoteRecordsScreen extends StatelessWidget {
  const AnecdoteRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anecdote Records')),
      body: const Center(
        child: Text('Anecdote Records — Coming Soon'),
      ),
    );
  }
}