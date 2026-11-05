import 'package:flutter/material.dart';
import 'package:healthcare_app/reminder.dart';
import 'package:healthcare_app/reminder_helper.dart';
import 'package:healthcare_app/reminder_repository.dart';

class ReminderFormPage extends StatefulWidget {
  final String title;
  const ReminderFormPage({super.key, required this.title});
  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  Reminder? _item;
  int _type = 0;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _item = ModalRoute.of(context)?.settings.arguments as Reminder?;
    if (_item != null) {
      _titleController.text = _item!.title;
      _noteController.text = _item!.note ?? '';
      _type = _item!.type;
      _date = _item!.remindAt;
      _time = TimeOfDay(
        hour: _item!.remindAt.hour,
        minute: _item!.remindAt.minute,
      );
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_item == null ? 'Thêm' : 'Sửa'} ${widget.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              maxLength: 128,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề (ví dụ: Khám tim mạch)',
              ),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _type,
              items: [
                for (int t = 0; t <= 2; t++)
                  DropdownMenuItem<int>(
                    value: t,
                    child: Text(ReminderHelper.typeText(t)),
                  ),
              ],
              onChanged: (value) => setState(() => _type = value ?? 0),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_two(_date.day)}/${_two(_date.month)}/${_date.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text('${_two(_time.hour)}:${_two(_time.minute)}'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _noteController,
              maxLength: 256,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Lưu'),
            ),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tiêu đề');
      return;
    }
    DateTime remindAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    String note = _noteController.text.trim();
    int ret = _item == null
        ? await ReminderRepository.add(title, _type, remindAt, note)
        : await ReminderRepository.edit(
            _item!.id,
            title,
            _type,
            remindAt,
            note,
          );
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lưu nhắc nhở thành công')));
      Navigator.pop(context, true);
    } else if (ret == 0) {
      setState(() => _error = 'Nhắc nhở không còn tồn tại');
    } else if (ret == -2) {
      setState(() => _error = 'Dữ liệu không hợp lệ');
    } else {
      setState(
        () => _error = 'Lưu thất bại, vui lòng đăng nhập lại và thử lại',
      );
    }
  }
}
