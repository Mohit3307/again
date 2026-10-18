import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:again/core/models/habit.dart';

class HabitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _habits(String uid) {
    return _db.collection('users').doc(uid).collection('habits');
  }

  Stream<List<Habit>> getHabits(String uid) {
    return _habits(uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Habit.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String> addHabit(String uid, Habit habit) async {
    final doc = await _habits(uid).add(habit.toFirestore());
    return doc.id;
  }

  Future<void> updateHabit(String uid, Habit habit) async {
    final data = habit.toFirestore();
    data.remove('createdAt');

    await _habits(uid).doc(habit.id).update(data);
  }

  Future<void> updateNotes(
    String uid,
    String habitId,
    String? notes,
  ) async {
    await _habits(uid).doc(habitId).update({'notes': notes});
  }

  Future<void> toggleHabit(
    String uid,
    String habitId,
    String date,
    bool completed,
  ) async {
    await _habits(uid).doc(habitId).update({
      'completedDates': completed
          ? FieldValue.arrayUnion([date])
          : FieldValue.arrayRemove([date]),
    });
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await _habits(uid).doc(habitId).delete();
  }
}