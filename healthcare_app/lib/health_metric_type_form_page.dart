import 'package:flutter/material.dart';
import 'package:healthcare_app/health_helper.dart';
import 'package:healthcare_app/health_metric_type.dart';
import 'package:healthcare_app/health_metric_type_repository.dart';

class HealthMetricTypeFormPage extends StatefulWidget {
  final String title;
  const HealthMetricTypeFormPage({super.key, required this.title});

  @override
  State<HealthMetricTypeFormPage> createState() =>
      _HealthMetricTypeFormPageState();
}

class _HealthMetricTypeFormPageState extends State<HealthMetricTypeFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  final _descriptionController = TextEditingController();

  HealthMetricType? _item;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _item = ModalRoute.of(context)?.settings.arguments as HealthMetricType?;
    if (_item != null) {
      _codeController.text = _item!.code;
      _nameController.text = _item!.name;
      _unitController.text = _item!.unit;
      if (_item!.minNormal != null) {
        _minController.text = HealthHelper.formatNumber(_item!.minNormal!);
      }
      if (_item!.maxNormal != null) {
        _maxController.text = HealthHelper.formatNumber(_item!.maxNormal!);
      }
      _descriptionController.text = _item!.description;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_item == null ? 'Thêm' : 'Sửa'} ${widget.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              maxLength: 32,
              decoration: const InputDecoration(
                labelText: 'Mã chỉ số (ví dụ: WEIGHT, BLOOD_PRESSURE)',
              ),
            ),
            TextField(
              controller: _nameController,
              maxLength: 64,
              decoration: const InputDecoration(
                labelText: 'Tên loại chỉ số (ví dụ: Cân nặng)',
              ),
            ),
            TextField(
              controller: _unitController,
              maxLength: 32,
              decoration: const InputDecoration(
                labelText: 'Đơn vị đo (ví dụ: kg, mmHg, bpm, mmol/L)',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Ngưỡng dưới chuẩn',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Ngưỡng trên chuẩn',
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _descriptionController,
              maxLength: 256,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Lưu'),
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

  Future<void> _save() async {
    String code = _codeController.text.trim().toUpperCase();
    String name = _nameController.text.trim();
    String unit = _unitController.text.trim();
    if (code.isEmpty || name.isEmpty || unit.isEmpty) {
      setState(() => _error = 'Vui lòng nhập đầy đủ mã, tên và đơn vị đo');
      return;
    }

    double? minNormal = _minController.text.trim().isEmpty
        ? null
        : double.tryParse(_minController.text.trim().replaceAll(',', '.'));
    double? maxNormal = _maxController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxController.text.trim().replaceAll(',', '.'));

    if ((_minController.text.trim().isNotEmpty && minNormal == null) ||
        (_maxController.text.trim().isNotEmpty && maxNormal == null)) {
      setState(() => _error = 'Ngưỡng chuẩn phải là số hợp lệ');
      return;
    }

    String description = _descriptionController.text.trim();
    int ret = _item == null
        ? await HealthMetricTypeRepository.add(
            code, name, unit, minNormal, maxNormal, description)
        : await HealthMetricTypeRepository.edit(
            _item!.id, code, name, unit, minNormal, maxNormal, description);

    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu loại chỉ số thành công')),
      );
      Navigator.pop(context, true);
    } else if (ret == -2) {
      setState(() => _error = 'Dữ liệu không hợp lệ hoặc mã chỉ số đã tồn tại');
    } else {
      setState(() => _error = 'Lưu thất bại, vui lòng đăng nhập lại bằng tài khoản Admin');
    }
  }
}