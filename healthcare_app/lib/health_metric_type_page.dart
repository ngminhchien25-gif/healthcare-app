import 'package:flutter/material.dart';
import 'package:healthcare_app/health_helper.dart';
import 'package:healthcare_app/health_metric_type.dart';
import 'package:healthcare_app/health_metric_type_repository.dart';
import 'package:healthcare_app/sesson_helper.dart';

class HealthMetricTypePage extends StatefulWidget {
  final String title;
  const HealthMetricTypePage({super.key, required this.title});

  @override
  State<HealthMetricTypePage> createState() => _HealthMetricTypePageState();
}

class _HealthMetricTypePageState extends State<HealthMetricTypePage> {
  List<HealthMetricType> _list = [];
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
        if (!mounted) return;
        setState(() => _isAdmin = false);
        return;
      }
      var data = await HealthMetricTypeRepository.getMetricTypes();
      if (!mounted) return;
      setState(() {
        _list = data;
        _error = null;
      });
    } catch (ex) {
      if (!mounted) return;
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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, index) {
                HealthMetricType item = _list[index];
                String rangeText = (item.minNormal != null || item.maxNormal != null)
                    ? ' · Ngưỡng chuẩn: ${item.minNormal != null ? HealthHelper.formatNumber(item.minNormal!) : '?'} - ${item.maxNormal != null ? HealthHelper.formatNumber(item.maxNormal!) : '?'} ${item.unit}'
                    : '';
                return Card(
                  child: ListTile(
                    leading: Icon(HealthHelper.metricIcon(item.code), size: 32),
                    title: Text('${item.name} (${item.unit})'),
                    subtitle: Text(
                      'Mã: ${item.code}$rangeText${item.description.isEmpty ? '' : '\n${item.description}'}',
                    ),
                    isThreeLine: item.description.isNotEmpty,
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
        label: const Text('Thêm loại chỉ số'),
      ),
    );
  }

  void _openForm(HealthMetricType? item) async {
    final saved = await Navigator.pushNamed(
      context,
      '/health-metric-type-form',
      arguments: item,
    );
    if (saved == true) _loadData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _delete(HealthMetricType item) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa loại chỉ số'),
        content: Text('Bạn có chắc muốn xóa loại chỉ số "${item.name}"?'),
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
    int ret = await HealthMetricTypeRepository.delete(item.id);
    if (!mounted) return;
    if (ret > 0) {
      _showMessage('Đã xóa loại chỉ số');
      _loadData();
    } else if (ret == -1) {
      _showMessage('Loại chỉ số đã có dữ liệu đo của người dùng, không thể xóa');
    } else if (ret == 0) {
      _showMessage('Loại chỉ số không còn tồn tại');
      _loadData();
    } else {
      _showMessage('Xóa thất bại');
    }
  }
}