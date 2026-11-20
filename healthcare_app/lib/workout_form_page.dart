import 'package:flutter/material.dart';
import 'package:healthcare_app/exercise.dart';
import 'package:healthcare_app/workout_log.dart';
import 'package:healthcare_app/workout_repository.dart';

class WorkoutFormPage extends StatefulWidget {
  const WorkoutFormPage({super.key, this.item});
  final WorkoutLog? item;
  @override
  State<WorkoutFormPage> createState() => _WorkoutFormPageState();
}

class _WorkoutFormPageState extends State<WorkoutFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _minutes = TextEditingController();
  final _note = TextEditingController();
  List<Exercise> _exercises = [];
  int? _exerciseId;
  DateTime _date = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _date = widget.item?.workoutDate ?? DateTime.now();
    _minutes.text = widget.item?.durationMinutes.toString() ?? '';
    _note.text = widget.item?.note ?? '';
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await WorkoutRepository.getExercises();
      if (!mounted) return;
      setState(() {
        _exercises = result.items;
        if (widget.item != null &&
            !_exercises.any((e) => e.id == widget.item!.exerciseId)) {
          _exercises = [
            Exercise(
              id: widget.item!.exerciseId,
              name: widget.item!.exerciseName,
              description: null,
              muscleGroup: null,
              caloriesPerMinute: 0,
              isActive: false,
            ),
            ..._exercises,
          ];
        }
        _exerciseId =
            widget.item?.exerciseId ??
            (_exercises.isEmpty ? null : _exercises.first.id);
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _exerciseId == null) return;
    try {
      final result = await WorkoutRepository.saveLog(
        WorkoutLogFormData(
          id: widget.item?.id,
          exerciseId: _exerciseId!,
          workoutDate: _date,
          durationMinutes: int.parse(_minutes.text),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        ),
      );
      if (!mounted) return;
      if (result > 0) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy bài tập hoặc nhật ký')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.item == null ? 'Ghi buổi tập' : 'Sửa buổi tập'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _exercises.isEmpty
        ? const Center(child: Text('Chưa có bài tập đang hoạt động'))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _exerciseId,
                  decoration: const InputDecoration(labelText: 'Bài tập'),
                  items: _exercises
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _exerciseId = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ngày tập'),
                  subtitle: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Thời lượng (phút)',
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 1 || n > 1440
                        ? 'Nhập thời lượng từ 1 đến 1440 phút'
                        : null;
                  },
                ),
                TextFormField(
                  controller: _note,
                  maxLength: 256,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Calo được ước tính tự động theo bài tập và thời lượng.',
                  ),
                ),
                FilledButton(onPressed: _save, child: const Text('Lưu')),
              ],
            ),
          ),
  );
}
