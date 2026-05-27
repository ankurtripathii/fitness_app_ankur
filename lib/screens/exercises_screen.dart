import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../services/exercise_api_service.dart';

class ExercisesScreen extends StatefulWidget {
  final String userId;
  const ExercisesScreen({super.key, required this.userId});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selected = 'chest';
  List<ExerciseModel> _exercises = [];
  bool _loading = false;

  final _colors = {
    'chest': const Color(0xFFEF4444),
    'back': const Color(0xFF8B5CF6),
    'legs': const Color(0xFF3B82F6),
    'shoulders': const Color(0xFFF59E0B),
    'cardio': const Color(0xFF10B981),
  };
  final _emojis = {
    'chest': '💪', 'back': '🏋️', 'legs': '🦵',
    'shoulders': '🔝', 'cardio': '🏃'
  };

  @override
  void initState() {
    super.initState();
    _load('chest');
  }

  Future<void> _load(String bodyPart) async {
    setState(() { _selected = bodyPart; _loading = true; });
    _exercises = await ExerciseApiService.fetchByBodyPart(bodyPart);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Exercise Library',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const Text('Browse exercises by muscle group',
                    style: TextStyle(fontSize: 13, color: Colors.black45)),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ExerciseApiService.bodyParts.map((bp) {
                      final isSelected = _selected == bp;
                      final color = _colors[bp]!;
                      return GestureDetector(
                        onTap: () => _load(bp),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade300),
                            boxShadow: isSelected
                                ? [BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))]
                                : [],
                          ),
                          child: Row(children: [
                            Text(_emojis[bp]!),
                            const SizedBox(width: 6),
                            Text(
                              bp[0].toUpperCase() + bp.substring(1),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54),
                            ),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _exercises.length,
                    itemBuilder: (_, i) {
                      final ex = _exercises[i];
                      return _buildExerciseTile(ex, i);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(ExerciseModel ex, int index) {
    final color = _colors[_selected]!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 80),
      curve: Curves.easeOut,
      builder: (_, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - val)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_emojis[_selected]!,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(ex.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(spacing: 6, children: [
              _chip(ex.equipment, color),
              _chip(ex.target, Colors.grey),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      );
}
