import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine_category.dart';
import 'package:healthcare_app/medicine_category_repository.dart';

class MedicineCategoryFormPage extends StatefulWidget {
  final String title;
  const MedicineCategoryFormPage({super.key, required this.title});
  @override
  State<MedicineCategoryFormPage> createState() => _MedicineCategoryFormPageState();
}

class _MedicineCategoryFormPageState extends State<MedicineCategoryFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  MedicineCategory? _item;
  String? _filePath;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _item = ModalRoute.of(context)?.settings.arguments as MedicineCategory?;
    if (_item != null) {
      _nameController.text = _item!.name;
      _descriptionController.text = _item!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? preview;
    if (_filePath != null) {
      preview = Image.file(File(_filePath!), height: 120);
    } else if (_item?.icon != null) {
      preview = Image.network(
        ImageHelper.url('medicinecategories', _item!.icon!),
        height: 120,
        errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, size: 60),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('${_item == null ? 'Thêm' : 'Sửa'} ${widget.title}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên nhóm thuốc'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (preview != null) preview,
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Chọn ảnh'),
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
    if (name.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên nhóm thuốc');
      return;
    }
    String description = _descriptionController.text.trim();
    int ret = _item == null
        ? await MedicineCategoryRepository.add(name, description, _filePath)
        : await MedicineCategoryRepository.edit(_item!.id, name, description, _filePath);
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu nhóm thuốc thành công')),
      );
      Navigator.pop(context, true);
    } else if (ret == -3) {
      setState(() => _error = 'Ảnh không hợp lệ (png, jpg, jpeg, webp, gif, tối đa 5MB)');
    } else if (ret == -2) {
      setState(() => _error = 'Dữ liệu không hợp lệ');
    } else if (ret == 0) {
      setState(() => _error = 'Nhóm thuốc không còn tồn tại');
    } else {
      setState(() => _error = 'Lưu thất bại, vui lòng đăng nhập lại bằng tài khoản Admin');
    }
  }
}