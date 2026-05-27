import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_model.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onDelete;

  const WorkoutCard({super.key, required this.workout, this.onDelete});

  Color get _categoryColor {
    switch (workout.category.toLowerCase()) {
      case 'chest': return const Color(0xFFEF4444);
      case 'back': return const Color(0xFF8B5CF6);
      case 'legs': return const Color(0xFF3B82F6);
      case 'shoulders': return const Color(0xFFF59E0B);
      case 'cardio': return const Color(0xFF10B981);
      default: return const Color(0xFF6366F1);
    }
  }

  String get _categoryEmoji {
    switch (workout.category.toLowerCase()) {
      case 'chest': return '💪';
      case 'back': return '🏋️';
      case 'legs': return '🦵';
      case 'shoulders': return '🔝';
      case 'cardio': return '🏃';
      default: return '⚡';
    }
  }

  Color get _intensityColor {
    switch (workout.intensity) {
      case 'hard': return Colors.red;
      case 'easy': return Colors.green;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _categoryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(_categoryEmoji,
              style: const TextStyle(fontSize: 24))),
        ),
        title: Text(workout.name,
            style: const TextStyle(fontWeight: FontWeight.bold,
                fontSize: 15, color: Colors.black87)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.timer_outlined, size: 13, color: Colors.black45),
              const SizedBox(width: 3),
              Text('${workout.durationMinutes} min',
                  style: const TextStyle(fontSize: 12, color: Colors.black45)),
              const SizedBox(width: 10),
              Icon(Icons.local_fire_department_outlined,
                  size: 13, color: Colors.orange),
              const SizedBox(width: 3),
              Text('${workout.caloriesBurned} kcal',
                  style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _intensityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(workout.intensity.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: _intensityColor,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(DateFormat('MMM d, h:mm a').format(workout.date),
                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ]),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.black26, size: 20),
                onPressed: onDelete)
            : null,
      ),
    );
  }
}
