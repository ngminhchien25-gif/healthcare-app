import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/medicine_category.dart';
import 'package:healthcare_app/medicine_category_repository.dart';
import 'package:healthcare_app/medicine_repository.dart';

class MedicineFormPage extends StatefulWidget {
  final String title;
  const MedicineFormPage({super.key, required this.title});
  @override
  State<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends State<MedicineFormPage> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _precautionController = TextEditingController();
  List<MedicineCategory> _categories = [];
  Medicine? _item;
  int? _categoryId;
  String? _filePath;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _item = ModalRoute.of(context)?.settings.arguments as Medicine?;
    if (_item != null) {
      _categoryId = _item!.categoryId;
      _nameController.text = _item!.name;
      _unitController.text = _item!.unit;
      _descriptionController.text = _item!.description ?? '';
      _precautionController.text = _item!.precaution ?? '';
    }
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      var data = await MedicineCategoryRepository.getMedicineCategories();
      setState(() => _categories = data);
    } catch (ex) {
      setState(() => _error = 'Không tải được danh sách nhóm thuốc');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? preview;
    if (_filePath != null) {
      preview = Image.file(File(_filePath!), height: 160);
    } else if (_item?.imageUrl != null) {
      preview = Image.network(
        ImageHelper.url('medicines', _item!.imageUrl!),
        height: 160,
        errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, size: 60),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('${_item == null ? 'Thêm' : 'Sửa'} ${widget.title}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<int>(
              isExpanded: true,
              hint: const Text('Chọn nhóm thuốc'),
              value: _categories.any((c) => c.id == _categoryId) ? _categoryId : null,
              items: _categories
                  .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên thuốc'),
            ),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Đơn vị (viên, gói, ml...)'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả chung'),
              maxLines: 3,
            ),
            TextField(
              controller: _precautionController,
              decoration: const InputDecoration(labelText: 'Lưu ý chung'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (preview != null) preview,
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_item == null ? 'Chọn ảnh (bắt buộc)' : 'Đổi ảnh'),
            ),
            const SizedBox(height: 16),
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

  void _pickImage() async {
    String? path = await ImageHelper.pick();
    if (path != null) {
      setState(() => _filePath = path);
    }
  }

  Future<void> _save() async {
    String name = _nameController.text.trim();
    String unit = _unitController.text.trim();
    if (_categoryId == null) {
      setState(() => _error = 'Vui lòng chọn nhóm thuốc');
      return;
    }
    if (name.isEmpty || unit.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên thuốc và đơn vị');
      return;
    }
    if (_item == null && _filePath == null) {
      setState(() => _error = 'Vui lòng chọn ảnh thuốc');
      return;
    }
    Medicine obj = Medicine(
      id: _item?.id ?? 0,
      categoryId: _categoryId!,
      name: name,
      imageUrl: _item?.imageUrl,
      unit: unit,
      description: _descriptionController.text.trim(),
      precaution: _precautionController.text.trim(),
      createdAt: _item?.createdAt ?? DateTime.now(),
    );
    int ret = _item == null
        ? await MedicineRepository.add(obj, _filePath)
        : await MedicineRepository.edit(obj, _filePath);
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thuốc thành công')),
      );
      Navigator.pop(context, true);
    } else if (ret == -3) {
      setState(() => _error = 'Ảnh không hợp lệ (png, jpg, jpeg, webp, gif, tối đa 5MB)');
    } else if (ret == -2) {
      setState(() => _error = 'Dữ liệu không hợp lệ hoặc nhóm thuốc không tồn tại');
    } else if (ret == 0) {
      setState(() => _error = 'Thuốc không còn tồn tại');
    } else {
      setState(() => _error = 'Lưu thất bại, vui lòng đăng nhập lại bằng tài khoản Admin');
    }
  }
}