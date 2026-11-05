import 'package:flutter/material.dart';
import 'package:healthcare_app/prescription_helper.dart';
import 'package:healthcare_app/reminder_repository.dart';

class ReminderFromPrescriptionPage extends StatefulWidget {
  final String title;
  const ReminderFromPrescriptionPage({super.key, required this.title});
  @override
  State<ReminderFromPrescriptionPage> createState() =>
      _ReminderFromPrescriptionPageState();
}

class _ReminderFromPrescriptionPageState
    extends State<ReminderFromPrescriptionPage> {
  int? _prescriptionId;
  DateTime _startDate = DateTime.now();
  int _days = 5;
  List<TimeOfDay> _times = [
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
  ];
  String? _error;
  bool _saving = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _prescriptionId = ModalRoute.of(context)!.settings.arguments as int;
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _timeText(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  @override
  Widget build(BuildContext context) {
    DateTime endDate = _startDate.add(Duration(days: _days - 1));
    int total = _days * _times.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Đơn thuốc #$_prescriptionId',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Giờ uống và số ngày do bạn chọn theo chỉ định của bác sĩ hoặc dược sĩ.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bắt đầu từ ngày: ${PrescriptionHelper.date(_startDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Số ngày')),
                  IconButton(
                    onPressed: _days > 1 ? () => setState(() => _days--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$_days'),
                  IconButton(
                    onPressed: _days < 30
                        ? () => setState(() => _days++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Giờ uống trong ngày',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ..._times.map(
                    (t) => InputChip(
                      label: Text(_timeText(t)),
                      onDeleted: _times.length > 1
                          ? () => setState(() => _times.remove(t))
                          : null,
                    ),
                  ),
                  if (_times.length < 6)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm giờ'),
                      onPressed: _addTime,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Sẽ tạo $total nhắc, từ ${PrescriptionHelper.date(_startDate)} đến ${PrescriptionHelper.date(endDate)}.',
              ),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!),
              ElevatedButton.icon(
                onPressed: _saving ? null : _create,
                icon: const Icon(Icons.alarm_add),
                label: const Text('Tạo nhắc uống thuốc'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _addTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked == null) return;
    bool exists = _times.any(
      (t) => t.hour == picked.hour && t.minute == picked.minute,
    );
    if (exists) {
      setState(() => _error = 'Giờ ${_timeText(picked)} đã có trong danh sách');
      return;
    }
    setState(() {
      _error = null;
      _times.add(picked);
      _times.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    });
  }

  void _create() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    int ret = await ReminderRepository.createFromPrescription(
      _prescriptionId!,
      _startDate,
      _days,
      _times.map(_timeText).toList(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ret > 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đã tạo $ret nhắc uống thuốc')));
      Navigator.pushReplacementNamed(context, '/reminders');
    } else if (ret == -4) {
      setState(() => _error = 'Đơn thuốc chưa được dược sĩ xác nhận');
    } else if (ret == 0) {
      setState(() => _error = 'Không tìm thấy đơn thuốc này');
    } else if (ret == -2) {
      setState(() => _error = 'Dữ liệu không hợp lệ');
    } else {
      setState(
        () => _error = 'Tạo nhắc thất bại, vui lòng đăng nhập lại và thử lại',
      );
    }
  }
}
