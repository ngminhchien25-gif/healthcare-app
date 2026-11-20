class Exercise {
  final int id;
  final String name;
  final String? description;
  final String? muscleGroup;
  final double caloriesPerMinute;
  final bool isActive;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.caloriesPerMinute,
    required this.isActive,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
    id: map['exerciseId'],
    name: map['exerciseName'],
    description: map['description'],
    muscleGroup: map['muscleGroup'],
    caloriesPerMinute: (map['caloriesPerMinute'] as num).toDouble(),
    isActive: map['isActive'] == true || map['isActive'] == 1,
  );

  Map<String, Object?> toMap() => {
    'exerciseId': id,
    'exerciseName': name,
    'description': description,
    'muscleGroup': muscleGroup,
    'caloriesPerMinute': caloriesPerMinute,
    'isActive': isActive,
  };
}
