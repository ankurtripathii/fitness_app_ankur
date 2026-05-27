import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';

class ExerciseApiService {
  // ExerciseDB via RapidAPI - get free key at rapidapi.com/justin-WFnsXH_t6/api/exercisedb
  static const String _baseUrl = 'https://exercisedb.p.rapidapi.com/exercises';
  static const String _apiKey =
      '774cc95807mshd41af7a49655d10p1b4e70jsncc589d9d8ab4';
  static const String _apiHost = 'exercisedb.p.rapidapi.com';

  static final Map<String, List<ExerciseModel>> _cache = {};

  static Future<List<ExerciseModel>> fetchByBodyPart(String bodyPart) async {
    if (_cache.containsKey(bodyPart)) return _cache[bodyPart]!;

    if (_apiKey == 'YOUR_RAPIDAPI_KEY_HERE') {
      return _getMockExercises(bodyPart);
    }

    try {
      final uri = Uri.parse('$_baseUrl/bodyPart/$bodyPart?limit=10');
      final res = await http.get(uri, headers: {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': _apiHost,
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        final exercises = list.map((e) => ExerciseModel.fromJson(e)).toList();
        _cache[bodyPart] = exercises;
        return exercises;
      }
    } catch (_) {}
    return _getMockExercises(bodyPart);
  }

  static List<ExerciseModel> _getMockExercises(String bodyPart) {
    final mock = {
      'chest': [
        ExerciseModel(
            id: '1',
            name: 'Bench Press',
            bodyPart: 'chest',
            equipment: 'barbell',
            gifUrl: '',
            target: 'pectorals'),
        ExerciseModel(
            id: '2',
            name: 'Push-up',
            bodyPart: 'chest',
            equipment: 'body weight',
            gifUrl: '',
            target: 'pectorals'),
        ExerciseModel(
            id: '3',
            name: 'Incline Dumbbell Press',
            bodyPart: 'chest',
            equipment: 'dumbbell',
            gifUrl: '',
            target: 'pectorals'),
        ExerciseModel(
            id: '4',
            name: 'Cable Fly',
            bodyPart: 'chest',
            equipment: 'cable',
            gifUrl: '',
            target: 'pectorals'),
      ],
      'back': [
        ExerciseModel(
            id: '5',
            name: 'Pull-up',
            bodyPart: 'back',
            equipment: 'body weight',
            gifUrl: '',
            target: 'lats'),
        ExerciseModel(
            id: '6',
            name: 'Barbell Row',
            bodyPart: 'back',
            equipment: 'barbell',
            gifUrl: '',
            target: 'upper back'),
        ExerciseModel(
            id: '7',
            name: 'Lat Pulldown',
            bodyPart: 'back',
            equipment: 'cable',
            gifUrl: '',
            target: 'lats'),
        ExerciseModel(
            id: '8',
            name: 'Deadlift',
            bodyPart: 'back',
            equipment: 'barbell',
            gifUrl: '',
            target: 'spine'),
      ],
      'legs': [
        ExerciseModel(
            id: '9',
            name: 'Squat',
            bodyPart: 'upper legs',
            equipment: 'barbell',
            gifUrl: '',
            target: 'quads'),
        ExerciseModel(
            id: '10',
            name: 'Leg Press',
            bodyPart: 'upper legs',
            equipment: 'leverage machine',
            gifUrl: '',
            target: 'quads'),
        ExerciseModel(
            id: '11',
            name: 'Lunges',
            bodyPart: 'upper legs',
            equipment: 'body weight',
            gifUrl: '',
            target: 'quads'),
        ExerciseModel(
            id: '12',
            name: 'Romanian Deadlift',
            bodyPart: 'upper legs',
            equipment: 'barbell',
            gifUrl: '',
            target: 'hamstrings'),
      ],
      'shoulders': [
        ExerciseModel(
            id: '13',
            name: 'Overhead Press',
            bodyPart: 'shoulders',
            equipment: 'barbell',
            gifUrl: '',
            target: 'delts'),
        ExerciseModel(
            id: '14',
            name: 'Lateral Raise',
            bodyPart: 'shoulders',
            equipment: 'dumbbell',
            gifUrl: '',
            target: 'delts'),
        ExerciseModel(
            id: '15',
            name: 'Front Raise',
            bodyPart: 'shoulders',
            equipment: 'dumbbell',
            gifUrl: '',
            target: 'delts'),
        ExerciseModel(
            id: '16',
            name: 'Arnold Press',
            bodyPart: 'shoulders',
            equipment: 'dumbbell',
            gifUrl: '',
            target: 'delts'),
      ],
      'cardio': [
        ExerciseModel(
            id: '17',
            name: 'Running',
            bodyPart: 'cardio',
            equipment: 'body weight',
            gifUrl: '',
            target: 'cardiovascular system'),
        ExerciseModel(
            id: '18',
            name: 'Jump Rope',
            bodyPart: 'cardio',
            equipment: 'rope',
            gifUrl: '',
            target: 'cardiovascular system'),
        ExerciseModel(
            id: '19',
            name: 'Burpees',
            bodyPart: 'cardio',
            equipment: 'body weight',
            gifUrl: '',
            target: 'cardiovascular system'),
        ExerciseModel(
            id: '20',
            name: 'Cycling',
            bodyPart: 'cardio',
            equipment: 'stationary bike',
            gifUrl: '',
            target: 'cardiovascular system'),
      ],
    };
    return mock[bodyPart] ?? mock['chest']!;
  }

  static List<String> get bodyParts =>
      ['chest', 'back', 'legs', 'shoulders', 'cardio'];
}
