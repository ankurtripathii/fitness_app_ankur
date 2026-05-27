import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;
  String? _userId;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;

  List<WorkoutModel> get recentWorkouts =>
      _workouts.take(5).toList();

  UserStats get stats {
    if (_workouts.isEmpty) {
      return UserStats(
        totalWorkouts: 0,
        totalCalories: 0,
        totalMinutes: 0,
        currentStreak: 0,
        weeklyGoalPercent: 0,
      );
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeek = _workouts.where((w) =>
        w.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();

    // Streak calc
    int streak = 0;
    DateTime check = DateTime(now.year, now.month, now.day);
    while (true) {
      final hasWorkout = _workouts.any((w) {
        final d = DateTime(w.date.year, w.date.month, w.date.day);
        return d == check;
      });
      if (!hasWorkout) break;
      streak++;
      check = check.subtract(const Duration(days: 1));
    }

    return UserStats(
      totalWorkouts: _workouts.length,
      totalCalories: _workouts.fold(0, (s, w) => s + w.caloriesBurned),
      totalMinutes: _workouts.fold(0, (s, w) => s + w.durationMinutes),
      currentStreak: streak,
      weeklyGoalPercent: (thisWeek.length / 5.0).clamp(0.0, 1.0),
    );
  }

  Map<String, int> get weeklyCalories {
    final now = DateTime.now();
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
          [day.weekday - 1];
      final cals = _workouts
          .where((w) =>
              w.date.year == day.year &&
              w.date.month == day.month &&
              w.date.day == day.day)
          .fold(0, (s, w) => s + w.caloriesBurned);
      result[label] = cals;
    }
    return result;
  }

  void setUserId(String uid) {
    _userId = uid;
    _loadWorkouts();
  }

  void _loadWorkouts() {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    _db
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      _workouts =
          snap.docs.map((d) => WorkoutModel.fromFirestore(d)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    await _db
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .add(workout.toMap());
  }

  Future<void> deleteWorkout(String id) async {
    await _db
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .doc(id)
        .delete();
  }

  void clearUser() {
    _workouts = [];
    _userId = null;
    notifyListeners();
  }
}
