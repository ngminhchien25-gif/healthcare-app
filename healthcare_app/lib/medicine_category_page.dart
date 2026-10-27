import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine_category.dart';
import 'package:healthcare_app/medicine_category_repository.dart';
import 'package:healthcare_app/sesson_helper.dart';

class MedicineCategoryPage extends StatefulWidget {
  final String title;
  const MedicineCategoryPage({super.key, required this.title});
  @override
  State<MedicineCategoryPage> createState() => _MedicineCategoryPageState();
}

class _MedicineCategoryPageState extends State<MedicineCategoryPage> {
  List<MedicineCategory> _list = [];
  bool _isAdmin = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String? role = await SessonHelper.role;
      if (role != 'Admin') {
        setState(() => _isAdmin = false);
        return;
      }
      var data = await MedicineCategoryRepository.getMedicineCategories();
      setState(() {
        _list = data;
        _error = null;
      });
    } catch (ex) {
      setState(() => _error = 'Không tải được dữ liệu, vui lòng thử lại');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Bạn không có quyền truy cập chức năng này')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (_error != null) Text(_error!),
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, index) {
                MedicineCategory item = _list[index];
                return ListTile(
                  leading: item.icon == null
                      ? const Icon(Icons.medication, size: 40)
                      : Image.network(
                          ImageHelper.url('medicinecategories', item.icon!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _openForm(item),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _delete(item),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm nhóm thuốc'),
      ),
    );
  }

  void _openForm(MedicineCategory? item) async {
    final saved = await Navigator.pushNamed(
      context,
      '/medicine-category-form',
      arguments: item,
    );
    if (saved == true) _loadData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _delete(MedicineCategory item) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhóm thuốc'),
        content: Text('Bạn có chắc muốn xóa nhóm "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    int ret = await MedicineCategoryRepository.delete(item.id);
    if (!mounted) return;
    if (ret > 0) {
      _showMessage('Đã xóa nhóm thuốc');
      _loadData();
    } else if (ret == -1) {
      _showMessage('Nhóm thuốc còn thuốc bên trong, không thể xóa');
    } else if (ret == 0) {
      _showMessage('Nhóm thuốc không còn tồn tại');
      _loadData();
    } else {
      _showMessage('Xóa thất bại');
    }
  }
}