import 'package:flutter/material.dart';
import 'package:healthcare_app/exercise.dart';
import 'package:healthcare_app/sesson_helper.dart';
import 'package:healthcare_app/workout_repository.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key, required this.title});
  final String title;
  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  Future<List<Exercise>>? _items;
  bool _admin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
  }

  Future<void> _loadRole() async {
    _admin = await SessonHelper.role == 'Admin';
    if (mounted) _load();
  }

  void _load() {
    setState(() {
      _items = WorkoutRepository.getExercises(includeInactive: _admin)
          .then((result) => result.items);
    });
  }

  Future<void> _edit([Exercise? item]) async {
    final name = TextEditingController(text: item?.name ?? '');
    final group = TextEditingController(text: item?.muscleGroup ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final rate = TextEditingController(text: item?.caloriesPerMinute.toString() ?? '');
    bool active = item?.isActive ?? true;
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setDialog) => AlertDialog(
        title: Text(item == null ? 'Thêm bài tập' : 'Sửa bài tập'),
        content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Tên bài tập'), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên bài tập' : null),
          TextFormField(controller: group, decoration: const InputDecoration(labelText: 'Nhóm cơ')),
          TextFormField(controller: description, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 2),
          TextFormField(controller: rate, decoration: const InputDecoration(labelText: 'Calo ước tính mỗi phút'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => double.tryParse(v ?? '') == null || double.parse(v!) < 0 ? 'Nhập số calo hợp lệ' : null),
          if (item != null) CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Đang hoạt động'), value: active, onChanged: (v) => setDialog(() => active = v ?? true)),
        ]))),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), FilledButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          try {
            int code = await WorkoutRepository.updateExercise(Exercise(id: item?.id ?? 0, name: name.text.trim(), description: description.text.trim().isEmpty ? null : description.text.trim(), muscleGroup: group.text.trim().isEmpty ? null : group.text.trim(), caloriesPerMinute: double.parse(rate.text), isActive: active));
            if (context.mounted) Navigator.pop(context, code > 0);
          } catch (e) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }, child: const Text('Lưu'))],
      ),
    ));
    if (result == true) _load();
  }

  Future<void> _delete(Exercise item) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Xóa bài tập'), content: Text('Xóa "${item.name}"? Bài tập đã được dùng trong nhật ký sẽ không xóa được.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))],
    ));
    if (ok != true) return;
    try {
      final code = await WorkoutRepository.deleteExercise(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(code > 0 ? 'Đã xóa bài tập' : 'Không thể xóa bài tập đã có nhật ký')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title), actions: [if (_admin) IconButton(onPressed: () => _edit(), icon: const Icon(Icons.add), tooltip: 'Thêm bài tập')]),
    body: FutureBuilder<List<Exercise>>(future: _items, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('Không tải được danh mục: ${snapshot.error}'));
      final items = snapshot.data ?? [];
      if (items.isEmpty) return const Center(child: Text('Chưa có bài tập'));
      return ListView.builder(itemCount: items.length, itemBuilder: (context, index) {
        final item = items[index];
        return Card(child: ListTile(
          leading: Icon(item.isActive ? Icons.fitness_center : Icons.pause_circle_outline),
          title: Text(item.name), subtitle: Text('${item.muscleGroup ?? 'Chưa phân nhóm'} · ${item.caloriesPerMinute.toStringAsFixed(2)} kcal/phút${item.isActive ? '' : ' · Đã ẩn'}'),
          trailing: _admin ? PopupMenuButton<String>(onSelected: (v) => v == 'edit' ? _edit(item) : _delete(item), itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Sửa')), PopupMenuItem(value: 'delete', child: Text('Xóa'))]) : null,
        ));
      });
    }),
    floatingActionButton: !_admin ? FloatingActionButton.extended(onPressed: () => Navigator.pushNamed(context, '/workout-form').then((v) { if (v == true && mounted) setState(() {}); }), icon: const Icon(Icons.add), label: const Text('Ghi buổi tập')) : null,
  );
}
