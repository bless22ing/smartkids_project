import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anecdote_model.dart';

final anecdoteServiceProvider =
Provider<AnecdoteService>((ref) => AnecdoteService());

final studentAnecdotesProvider =
StreamProvider.family<List<AnecdoteModel>, String>((ref, studentId) {
  return ref.read(anecdoteServiceProvider).streamStudentAnecdotes(studentId);
});

class AnecdoteService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _anecdotes => _db.collection('anecdotes');

  Stream<List<AnecdoteModel>> streamStudentAnecdotes(String studentId) {
    return _anecdotes
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map(AnecdoteModel.fromFirestore).toList());
  }

  Future<void> addAnecdote(AnecdoteModel anecdote) async {
    await _anecdotes.add(anecdote.toMap());
  }

  Future<void> deleteAnecdote(String id) async {
    await _anecdotes.doc(id).delete();
  }
}