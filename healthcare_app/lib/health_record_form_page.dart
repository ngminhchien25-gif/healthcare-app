import 'package:flutter/material.dart';
import 'package:healthcare_app/health_helper.dart';
import 'package:healthcare_app/health_metric_type.dart';
import 'package:healthcare_app/health_metric_type_repository.dart';
import 'package:healthcare_app/health_record.dart';
import 'package:healthcare_app/health_record_repository.dart';

class HealthRecordFormPage extends StatefulWidget {
  final String title;
  const HealthRecordFormPage({super.key, required this.title});

  @override
  State<HealthRecordFormPage> createState() => _HealthRecordFormPageState();
}

class _HealthRecordFormPageState extends State<HealthRecordFormPage> {
  final _valueController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _noteController = TextEditingController();

  List<HealthMetricType> _types = [];
  HealthRecord? _item;
  int? _metricTypeId;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _item = ModalRoute.of(context)?.settings.arguments as HealthRecord?;
    if (_item != null) {
      _metricTypeId = _item!.metricTypeId;
      _valueController.text = HealthHelper.formatNumber(_item!.value);
      if (_item!.secondaryValue != null) {
        _secondaryController.text =
            HealthHelper.formatNumber(_item!.secondaryValue!);
      }
      _noteController.text = _item!.note ?? '';
      _date = _item!.measuredAt;
      _time = TimeOfDay(
        hour: _item!.measuredAt.hour,
        minute: _item!.measuredAt.minute,
      );
    }
    _loadTypes();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _secondaryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadTypes() async {
    try {
      var list = await HealthMetricTypeRepository.getMetricTypes();
      if (!mounted) return;
      setState(() {
        _types = list;
        if (_metricTypeId == null && list.isNotEmpty) {
          _metricTypeId = list.first.id;
        }
      });
    } catch (ex) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được danh mục loại chỉ số');
      debugPrint(ex.toString());
    }
  }

  HealthMetricType? get _selectedType {
    for (var t in _types) {
      if (t.id == _metricTypeId) return t;
    }
    return null;
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    HealthMetricType? currentType = _selectedType;
    bool isBloodPressure =
        currentType?.code.toUpperCase() == 'BLOOD_PRESSURE';

    return Scaffold(
      appBar: AppBar(
        title: Text('${_item == null ? 'Nhập' : 'Sửa'} ${widget.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _metricTypeId,
              decoration: const InputDecoration(labelText: 'Loại chỉ số'),
              items: [
                for (var t in _types)
                  DropdownMenuItem<int>(
                    value: t.id,
                    child: Text('${t.name} (${t.unit})'),
                  ),
              ],
              onChanged: (value) => setState(() => _metricTypeId = value),
            ),
            const SizedBox(height: 12),
            if (isBloodPressure)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Tâm thu (mmHg)',
                        hintText: 'Ví dụ: 120',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _secondaryController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Tâm trương (mmHg)',
                        hintText: 'Ví dụ: 80',
                      ),
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: _valueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText:
                      'Giá trị đo${currentType != null ? ' (${currentType.unit})' : ''}',
                ),
              ),
            if (currentType != null &&
                (currentType.minNormal != null ||
                    currentType.maxNormal != null))
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Mức tham chiếu bình thường: ${currentType.minNormal != null ? HealthHelper.formatNumber(currentType.minNormal!) : '?'} - ${currentType.maxNormal != null ? HealthHelper.formatNumber(currentType.maxNormal!) : '?'} ${currentType.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
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
              decoration: const InputDecoration(
                labelText: 'Ghi chú (ví dụ: Đo buổi sáng trước ăn)',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Lưu chỉ số'),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
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
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
    if (_metricTypeId == null) {
      setState(() => _error = 'Vui lòng chọn loại chỉ số');
      return;
    }

    double? value = double.tryParse(
        _valueController.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) {
      setState(() => _error = 'Vui lòng nhập giá trị đo hợp lệ (> 0)');
      return;
    }

    bool isBloodPressure =
        _selectedType?.code.toUpperCase() == 'BLOOD_PRESSURE';
    double? secondaryValue;
    if (isBloodPressure) {
      secondaryValue = double.tryParse(
          _secondaryController.text.trim().replaceAll(',', '.'));
      if (secondaryValue == null || secondaryValue <= 0) {
        setState(() => _error = 'Vui lòng nhập đầy đủ huyết áp tâm thu và tâm trương');
        return;
      }
    }

    DateTime measuredAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    String note = _noteController.text.trim();

    int ret = _item == null
        ? await HealthRecordRepository.add(
            _metricTypeId!, value, secondaryValue, measuredAt, note)
        : await HealthRecordRepository.edit(
            _item!.id, _metricTypeId!, value, secondaryValue, measuredAt, note);

    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu chỉ số sức khỏe thành công')),
      );
      Navigator.pop(context, true);
    } else if (ret == -2) {
      setState(() => _error = 'Giá trị chỉ số không hợp lệ');
    } else {
      setState(() => _error = 'Lưu thất bại, vui lòng thử lại');
    }
  }
}