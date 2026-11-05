class Reminder {
  final int id;
  final String title;
  final int type;
  final DateTime remindAt;
  final String? note;
  final bool isDone;
  final int? medicineId;
  final int? prescriptionId;
  Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.remindAt,
    required this.note,
    required this.isDone,
    required this.medicineId,
    required this.prescriptionId,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['reminderId'],
      title: map['title'],
      type: map['reminderType'],
      remindAt: DateTime.parse(map['remindAt']),
      note: map['note'],
      isDone: map['isDone'] == true || map['isDone'] == 1,
      medicineId: map['medicineId'],
      prescriptionId: map['prescriptionId'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'reminderId': id,
      'title': title,
      'reminderType': type,
      'remindAt': remindAt.toIso8601String(),
      'note': note,
      'isDone': isDone ? 1 : 0,
      'medicineId': medicineId,
      'prescriptionId': prescriptionId,
    };
  }
}
