import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime date;
  final String userId;
  final List<String> exercises;
  final String intensity; // 'easy', 'medium', 'hard'

  WorkoutModel({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.date,
    required this.userId,
    required this.exercises,
    required this.intensity,
  });

  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? 'General',
      durationMinutes: d['durationMinutes'] ?? 0,
      caloriesBurned: d['caloriesBurned'] ?? 0,
      date: (d['date'] as Timestamp).toDate(),
      userId: d['userId'] ?? '',
      exercises: List<String>.from(d['exercises'] ?? []),
      intensity: d['intensity'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'date': Timestamp.fromDate(date),
        'userId': userId,
        'exercises': exercises,
        'intensity': intensity,
      };
}

class ExerciseModel {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String target;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        bodyPart: json['bodyPart'] ?? '',
        equipment: json['equipment'] ?? '',
        gifUrl: json['gifUrl'] ?? '',
        target: json['target'] ?? '',
      );
}

class UserStats {
  final int totalWorkouts;
  final int totalCalories;
  final int totalMinutes;
  final int currentStreak;
  final double weeklyGoalPercent;

  UserStats({
    required this.totalWorkouts,
    required this.totalCalories,
    required this.totalMinutes,
    required this.currentStreak,
    required this.weeklyGoalPercent,
  });
}
