import 'package:flutter/material.dart';
import 'package:healthcare_app/health_helper.dart';
import 'package:healthcare_app/health_profile.dart';
import 'package:healthcare_app/health_profile_repository.dart';

class HealthProfilePage extends StatefulWidget {
  final String title;
  const HealthProfilePage({super.key, required this.title});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  final _heightController = TextEditingController();
  final _historyController = TextEditingController();

  DateTime? _dateOfBirth;
  int _gender = 0;
  String? _bloodType;
  String? _error;
  bool _loading = true;

  static const List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      HealthProfile p = await HealthProfileRepository.getProfile();
      if (!mounted) return;
      setState(() {
        if (p.heightCm != null) {
          _heightController.text = HealthHelper.formatNumber(p.heightCm!);
        }
        _dateOfBirth = p.dateOfBirth;
        _gender = p.gender;
        _bloodType = _bloodTypes.contains(p.bloodType) ? p.bloodType : null;
        _historyController.text = p.medicalHistory ?? '';
        _loading = false;
        _error = null;
      });
    } catch (ex) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không tải được hồ sơ sức khỏe, vui lòng thử lại';
      });
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Chiều cao (cm) - dùng để tính BMI',
                      hintText: 'Ví dụ: 170',
                      prefixIcon: Icon(Icons.height),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: [
                      for (int g = 0; g <= 2; g++)
                        DropdownMenuItem<int>(
                          value: g,
                          child: Text(HealthHelper.genderText(g)),
                        ),
                    ],
                    onChanged: (value) => setState(() => _gender = value ?? 0),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickBirthDate,
                    icon: const Icon(Icons.cake),
                    label: Text(
                      _dateOfBirth == null
                          ? 'Chọn ngày sinh'
                          : 'Ngày sinh: ${HealthHelper.date(_dateOfBirth!)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _bloodType,
                    decoration: const InputDecoration(
                      labelText: 'Nhóm máu',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Chưa rõ nhóm máu'),
                      ),
                      for (String b in _bloodTypes)
                        DropdownMenuItem<String?>(value: b, child: Text(b)),
                    ],
                    onChanged: (value) => setState(() => _bloodType = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _historyController,
                    maxLength: 512,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Tiền sử bệnh / Dị ứng thuốc',
                      prefixIcon: Icon(Icons.medical_information),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu hồ sơ sức khỏe'),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
    );
  }

  void _pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    double? heightCm;
    if (_heightController.text.trim().isNotEmpty) {
      heightCm = double.tryParse(
          _heightController.text.trim().replaceAll(',', '.'));
      if (heightCm == null || heightCm < 50 || heightCm > 250) {
        setState(() => _error = 'Chiều cao phải nằm trong khoảng 50 - 250 cm');
        return;
      }
    }

    int ret = await HealthProfileRepository.save(
      heightCm,
      _dateOfBirth,
      _gender,
      _bloodType,
      _historyController.text.trim(),
    );

    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ sức khỏe thành công')),
      );
      Navigator.pop(context, true);
    } else if (ret == -2) {
      setState(() => _error = 'Dữ liệu hồ sơ không hợp lệ');
    } else {
      setState(() => _error = 'Lưu thất bại, vui lòng thử lại');
    }
  }
}