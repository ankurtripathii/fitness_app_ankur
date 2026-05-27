import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';
import '../services/exercise_api_service.dart';

class LogWorkoutScreen extends StatefulWidget {
  final String userId;
  const LogWorkoutScreen({super.key, required this.userId});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _calsCtrl = TextEditingController();

  String _category = 'chest';
  String _intensity = 'medium';
  List<String> _selectedExercises = [];
  List<ExerciseModel> _availableExercises = [];
  bool _loadingExercises = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _loadingExercises = true);
    _availableExercises =
        await ExerciseApiService.fetchByBodyPart(_category);
    setState(() => _loadingExercises = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final workout = WorkoutModel(
        id: '',
        name: _nameCtrl.text.trim(),
        category: _category,
        durationMinutes: int.tryParse(_durationCtrl.text) ?? 30,
        caloriesBurned: int.tryParse(_calsCtrl.text) ?? 0,
        date: DateTime.now(),
        userId: widget.userId,
        exercises: _selectedExercises,
        intensity: _intensity,
      );
      await context.read<WorkoutProvider>().addWorkout(workout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Workout logged! 💪'),
              backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _calsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF302B63),
        title: const Text('Log Workout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Workout Name'),
              TextFormField(
                controller: _nameCtrl,
                decoration: _deco('e.g. Morning Chest Day', Icons.edit_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 18),
              _sectionLabel('Category'),
              _buildCategoryPicker(),
              const SizedBox(height: 18),
              _sectionLabel('Intensity'),
              _buildIntensityPicker(),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Duration (min)'),
                      TextFormField(
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _deco('30', Icons.timer_outlined),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Calories Burned'),
                      TextFormField(
                        controller: _calsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _deco('250', Icons.local_fire_department_outlined),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionLabel('Exercises (from API)'),
              if (_loadingExercises)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              else
                _buildExerciseSelector(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: _saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final cats = ExerciseApiService.bodyParts;
    final emojis = {'chest': '💪', 'back': '🏋️', 'legs': '🦵', 'shoulders': '🔝', 'cardio': '🏃'};
    final colors = {
      'chest': const Color(0xFFEF4444),
      'back': const Color(0xFF8B5CF6),
      'legs': const Color(0xFF3B82F6),
      'shoulders': const Color(0xFFF59E0B),
      'cardio': const Color(0xFF10B981),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats.map((c) {
        final isSelected = _category == c;
        final color = colors[c]!;
        return GestureDetector(
          onTap: () {
            setState(() {
              _category = c;
              _selectedExercises = [];
            });
            _loadExercises();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(emojis[c]!),
              const SizedBox(width: 6),
              Text(
                c[0].toUpperCase() + c.substring(1),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black54),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntensityPicker() {
    final levels = {'easy': Colors.green, 'medium': Colors.orange, 'hard': Colors.red};
    return Row(
      children: levels.entries.map((e) {
        final isSelected = _intensity == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _intensity = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: e.key != 'hard' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? e.value.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected ? e.value : Colors.grey.shade300,
                    width: 1.5),
              ),
              child: Text(
                e.key[0].toUpperCase() + e.key.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? e.value : Colors.black45),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: _availableExercises.asMap().entries.map((entry) {
          final ex = entry.value;
          final isSelected = _selectedExercises.contains(ex.name);
          return CheckboxListTile(
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedExercises.add(ex.name);
                } else {
                  _selectedExercises.remove(ex.name);
                }
              });
            },
            title: Text(ex.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text('${ex.equipment} • ${ex.target}',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
            activeColor: const Color(0xFF302B63),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
      );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF302B63), width: 1.5)),
      );
}
