import 'package:flutter/material.dart';
import 'package:healthcare_app/workout_log.dart';
import 'package:healthcare_app/workout_repository.dart';

class WorkoutWeeklyPage extends StatefulWidget {
  const WorkoutWeeklyPage({super.key});
  @override
  State<WorkoutWeeklyPage> createState() => _WorkoutWeeklyPageState();
}

class _WorkoutWeeklyPageState extends State<WorkoutWeeklyPage> {
  DateTime _selected = DateTime.now();
  late Future<WorkoutWeeklyStats> _stats;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _stats = WorkoutRepository.weeklyStats(_selected);
  }

  String _day(DateTime date) =>
      const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][date.weekday - 1];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thống kê luyện tập tuần')),
    body: FutureBuilder<WorkoutWeeklyStats>(
      future: _stats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Không tải được thống kê: ${snapshot.error}'),
          );
        }
        final data = snapshot.data!;
        final maxMinutes = data.days.fold<int>(
          0,
          (m, d) => d.minutes > m ? d.minutes : m,
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _selected = _selected.subtract(const Duration(days: 7));
                    _load();
                  }),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${data.weekStart.day}/${data.weekStart.month} – ${data.weekEnd.day}/${data.weekEnd.month}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _selected = _selected.add(const Duration(days: 7));
                    _load();
                  }),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng quan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Số buổi: ${data.sessions}'),
                    Text('Thời lượng: ${data.minutes} phút'),
                    Text(
                      'Calo ước tính: ${data.calories.toStringAsFixed(2)} kcal',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Theo ngày', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.days.map((WorkoutDayStat day) {
                  final height = maxMinutes == 0
                      ? 0.0
                      : 86.0 * day.minutes / maxMinutes;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${day.minutes}m',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height == 0 ? 2 : height,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_day(day.date)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Theo bài tập',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (data.exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Tuần này chưa có dữ liệu'),
              ),
            ...data.exercises.map(
              (WorkoutExerciseStat e) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.name),
                subtitle: Text('${e.sessions} buổi · ${e.minutes} phút'),
                trailing: Text('${e.calories.toStringAsFixed(2)} kcal'),
              ),
            ),
          ],
        );
      },
    ),
  );
}
