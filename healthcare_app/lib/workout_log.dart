class WorkoutLog {
  final int id;
  final int exerciseId;
  final String exerciseName;
  final DateTime workoutDate;
  final int durationMinutes;
  final double caloriesBurned;
  final String? note;

  const WorkoutLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.workoutDate,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.note,
  });

  factory WorkoutLog.fromMap(Map<String, dynamic> map) => WorkoutLog(
    id: map['workoutLogId'],
    exerciseId: map['exerciseId'],
    exerciseName: map['exerciseName'],
    workoutDate: DateTime.parse(map['workoutDate']),
    durationMinutes: map['durationMinutes'],
    caloriesBurned: (map['caloriesBurned'] as num).toDouble(),
    note: map['note'],
  );
}

class WorkoutLogFormData {
  final int? id;
  final int exerciseId;
  final DateTime workoutDate;
  final int durationMinutes;
  final String? note;

  const WorkoutLogFormData({
    this.id,
    required this.exerciseId,
    required this.workoutDate,
    required this.durationMinutes,
    required this.note,
  });

  Map<String, Object?> toMap() => {
    'workoutLogId': id ?? 0,
    'exerciseId': exerciseId,
    'workoutDate': workoutDate.toIso8601String(),
    'durationMinutes': durationMinutes,
    'note': note,
  };
}

class WorkoutDayStat {
  final DateTime date;
  final int sessions;
  final int minutes;
  final double calories;

  const WorkoutDayStat(this.date, this.sessions, this.minutes, this.calories);
  factory WorkoutDayStat.fromMap(Map<String, dynamic> map) => WorkoutDayStat(
    DateTime.parse(map['workoutDate']),
    map['sessionCount'],
    map['totalMinutes'],
    (map['totalCalories'] as num).toDouble(),
  );
}

class WorkoutExerciseStat {
  final String name;
  final int sessions;
  final int minutes;
  final double calories;

  const WorkoutExerciseStat(
    this.name,
    this.sessions,
    this.minutes,
    this.calories,
  );
  factory WorkoutExerciseStat.fromMap(Map<String, dynamic> map) =>
      WorkoutExerciseStat(
        map['exerciseName'],
        map['sessionCount'],
        map['totalMinutes'],
        (map['totalCalories'] as num).toDouble(),
      );
}

class WorkoutWeeklyStats {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int sessions;
  final int minutes;
  final double calories;
  final List<WorkoutDayStat> days;
  final List<WorkoutExerciseStat> exercises;

  const WorkoutWeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.sessions,
    required this.minutes,
    required this.calories,
    required this.days,
    required this.exercises,
  });

  factory WorkoutWeeklyStats.fromMap(Map<String, dynamic> map) =>
      WorkoutWeeklyStats(
        weekStart: DateTime.parse(map['weekStart']),
        weekEnd: DateTime.parse(map['weekEnd']),
        sessions: map['totalSessions'],
        minutes: map['totalMinutes'],
        calories: (map['totalCalories'] as num).toDouble(),
        days: (map['days'] as List)
            .map((v) => WorkoutDayStat.fromMap(v))
            .toList(),
        exercises: (map['exercises'] as List)
            .map((v) => WorkoutExerciseStat.fromMap(v))
            .toList(),
      );
}
