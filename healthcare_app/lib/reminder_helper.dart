import 'package:flutter/material.dart';
import 'package:healthcare_app/reminder.dart';

class ReminderHelper {
  static String typeText(int type) {
    switch (type) {
      case 0:
        return 'Uống thuốc';
      case 1:
        return 'Lịch khám';
      default:
        return 'Khác';
    }
  }

  static IconData typeIcon(int type) {
    switch (type) {
      case 0:
        return Icons.medication;
      case 1:
        return Icons.local_hospital;
      default:
        return Icons.event;
    }
  }

  static String dateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  static bool isOverdue(Reminder r) {
    return !r.isDone && r.remindAt.isBefore(DateTime.now());
  }
}
