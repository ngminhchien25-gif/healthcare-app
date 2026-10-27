import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/medicine_category.dart';
import 'package:healthcare_app/medicine_category_repository.dart';
import 'package:healthcare_app/medicine_repository.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/sesson_helper.dart';

class MedicineManagePage extends StatefulWidget {
  final String title;
  const MedicineManagePage({super.key, required this.title});
  @override
  State<MedicineManagePage> createState() => _MedicineManagePageState();
}

class _MedicineManagePageState extends State<MedicineManagePage> {
  static const int _pageSize = 10;
  final TextEditingController _keywordController = TextEditingController();
  List<MedicineCategory> _categories = [];
  PagedResult<Medicine>? _result;
  int? _categoryId;
  int _page = 1;
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
      var categories = await MedicineCategoryRepository.getMedicineCategories();
      if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
        _categoryId = null;
      }
      var data = await MedicineRepository.getMedicines(
        _categoryId,
        _keywordController.text.trim(),
        _page,
        _pageSize,
      );
      setState(() {
        _categories = categories;
        _result = data;
        _error = null;
      });
    } catch (ex) {
      setState(() => _error = 'Không tải được dữ liệu, vui lòng thử lại');
      debugPrint(ex.toString());
    }
  }

  String _categoryName(int id) {
    for (var c in _categories) {
      if (c.id == id) return c.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Bạn không có quyền truy cập chức năng này')),
      );
    }
    List<Medicine> items = _result?.items ?? [];
    int totalPages = _result?.totalPages ?? 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _categoryId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tất cả nhóm'),
                      ),
                      ..._categories.map(
                        (c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _categoryId = value;
                        _page = 1;
                      });
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(labelText: 'Tìm tên thuốc'),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
          ),
          if (_error != null) Text(_error!),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                Medicine item = items[index];
                return ListTile(
                  leading: item.imageUrl == null
                      ? const Icon(Icons.medication, size: 48)
                      : Image.network(
                          ImageHelper.url('medicines', item.imageUrl!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image, size: 48),
                        ),
                  title: Text(item.name),
                  subtitle: Text('${_categoryName(item.categoryId)} · ${item.unit}'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _page > 1 ? () => _goto(_page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Trang $_page/$totalPages'),
              IconButton(
                onPressed: _page < totalPages ? () => _goto(_page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm thuốc'),
      ),
    );
  }

  void _search() {
    _page = 1;
    _loadData();
  }

  void _goto(int page) {
    _page = page;
    _loadData();
  }

  void _openForm(Medicine? item) async {
    final saved = await Navigator.pushNamed(context, '/medicine-form', arguments: item);
    if (saved == true) _loadData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _delete(Medicine item) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thuốc'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
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
    int ret = await MedicineRepository.delete(item.id);
    if (!mounted) return;
    if (ret > 0) {
      _showMessage('Đã xóa thuốc');
      if ((_result?.items.length ?? 0) == 1 && _page > 1) _page--;
      _loadData();
    } else if (ret == -1) {
      _showMessage('Thuốc đã có trong đơn thuốc, không thể xóa');
    } else if (ret == 0) {
      _showMessage('Thuốc không còn tồn tại');
      _loadData();
    } else {
      _showMessage('Xóa thất bại');
    }
  }
}