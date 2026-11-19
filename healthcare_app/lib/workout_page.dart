import 'package:flutter/material.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/workout_log.dart';
import 'package:healthcare_app/workout_repository.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int _page = 1;
  late Future<PagedResult<WorkoutLog>> _data;
  @override
  void initState() { super.initState(); _load(); }
  void _load() { _data = WorkoutRepository.getLogs(page: _page); }

  Future<void> _delete(WorkoutLog item) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Xóa nhật ký'), content: const Text('Bạn có chắc muốn xóa buổi tập này?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))]));
    if (ok != true) return;
    try {
      await WorkoutRepository.deleteLog(item.id);
      if (mounted) setState(_load);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhật ký luyện tập'), actions: [IconButton(onPressed: () => Navigator.pushNamed(context, '/workout-weekly'), icon: const Icon(Icons.bar_chart), tooltip: 'Thống kê tuần')]),
    body: FutureBuilder<PagedResult<WorkoutLog>>(future: _data, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('Không tải được nhật ký: ${snapshot.error}'));
      final items = snapshot.data?.items ?? [];
      if (items.isEmpty) return const Center(child: Text('Chưa có buổi tập nào'));
      return RefreshIndicator(onRefresh: () async { setState(_load); await _data; }, child: ListView(children: [
        ...items.map((item) => Card(child: ListTile(
          leading: const Icon(Icons.fitness_center), title: Text(item.exerciseName),
          subtitle: Text('${item.workoutDate.toLocal().toString().substring(0, 10)} · ${item.durationMinutes} phút · ${item.caloriesBurned.toStringAsFixed(2)} kcal${item.note == null ? '' : '\n${item.note}'}'), isThreeLine: item.note != null,
          onTap: () async { final saved = await Navigator.pushNamed(context, '/workout-form', arguments: item); if (saved == true && mounted) setState(_load); },
          trailing: IconButton(onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline)),
        ))),
        if ((snapshot.data?.totalPages ?? 1) > 1) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(onPressed: _page > 1 ? () => setState(() { _page--; _load(); }) : null, icon: const Icon(Icons.chevron_left)),
          Text('Trang $_page/${snapshot.data!.totalPages}'),
          IconButton(onPressed: _page < snapshot.data!.totalPages ? () => setState(() { _page++; _load(); }) : null, icon: const Icon(Icons.chevron_right)),
        ]),
      ]));
    }),
    floatingActionButton: FloatingActionButton(onPressed: () async { final saved = await Navigator.pushNamed(context, '/workout-form'); if (saved == true && mounted) setState(_load); }, child: const Icon(Icons.add)),
  );
}
