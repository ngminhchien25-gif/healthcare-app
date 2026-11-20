import 'package:flutter/material.dart';
import 'package:healthcare_app/health_helper.dart';
import 'package:healthcare_app/health_metric_type.dart';
import 'package:healthcare_app/health_metric_type_repository.dart';
import 'package:healthcare_app/health_record.dart';
import 'package:healthcare_app/health_record_repository.dart';
import 'package:healthcare_app/paged_result.dart';

class HealthRecordPage extends StatefulWidget {
  final String title;
  const HealthRecordPage({super.key, required this.title});

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  static const int _pageSize = 8;

  List<HealthMetricType> _types = [];
  PagedResult<HealthRecord>? _result;
  BmiSummary? _bmi;
  int? _selectedTypeId;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    try {
      var types = await HealthMetricTypeRepository.getMetricTypes();
      if (!mounted) return;
      setState(() => _types = types);
    } catch (ex) {
      debugPrint(ex.toString());
    }
    _loadData();
  }

  void _loadData() async {
    try {
      var bmi = await HealthRecordRepository.getBmi();
      var data = await HealthRecordRepository.getRecords(
        _selectedTypeId,
        _page,
        _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _bmi = bmi;
        _result = data;
        _error = null;
      });
    } catch (ex) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được dữ liệu chỉ số sức khỏe');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<HealthRecord> items = _result?.items ?? [];
    int totalPages = _result?.totalPages ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Hồ sơ sức khỏe',
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.pushNamed(context, '/health-profile');
              _loadData();
            },
          ),
          IconButton(
            tooltip: 'Biểu đồ chỉ số',
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.pushNamed(context, '/health-chart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thẻ tổng hợp BMI
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: HealthHelper.bmiColor(_bmi?.bmi),
                  child: const Icon(Icons.monitor_weight, color: Colors.white),
                ),
                title: Text(
                  _bmi?.bmi != null
                      ? 'BMI: ${_bmi!.bmi} (${_bmi!.category})'
                      : 'BMI: Chưa đủ dữ liệu',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Chiều cao: ${_bmi?.heightCm != null ? '${HealthHelper.formatNumber(_bmi!.heightCm!)} cm' : 'Chưa nhập'}'
                  ' · Cân nặng: ${_bmi?.weightKg != null ? '${HealthHelper.formatNumber(_bmi!.weightKg!)} kg' : 'Chưa nhập'}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/health-profile');
                    _loadData();
                  },
                  child: const Text('Hồ sơ'),
                ),
              ),
            ),
          ),
          // Thanh lọc theo loại chỉ số + nút xem biểu đồ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedTypeId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tất cả loại chỉ số'),
                      ),
                      for (var t in _types)
                        DropdownMenuItem<int?>(
                          value: t.id,
                          child: Text(t.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTypeId = value;
                        _page = 1;
                      });
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/health-chart'),
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Biểu đồ'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu chỉ số nào'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      HealthRecord item = items[index];
                      bool warning = HealthHelper.isOutOfRange(item);
                      return Card(
                        child: ListTile(
                          onTap: () => _openForm(item),
                          leading: Icon(
                            HealthHelper.metricIcon(item.metricCode),
                            color: warning ? Colors.red : null,
                          ),
                          title: Text(
                            '${item.metricName}: ${HealthHelper.formatRecordValue(item)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: warning ? Colors.red : null,
                            ),
                          ),
                          subtitle: Text(
                            '${HealthHelper.dateTime(item.measuredAt)}'
                            '${warning ? ' · Ngoài ngưỡng chuẩn' : ''}'
                            '${item.note == null ? '' : '\n${item.note}'}',
                          ),
                          isThreeLine: item.note != null,
                          trailing: IconButton(
                            onPressed: () => _delete(item),
                            icon: const Icon(Icons.delete),
                          ),
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
        label: const Text('Nhập chỉ số'),
      ),
    );
  }

  void _goto(int page) {
    _page = page;
    _loadData();
  }

  void _openForm(HealthRecord? item) async {
    final saved = await Navigator.pushNamed(
      context,
      '/health-record-form',
      arguments: item,
    );
    if (saved == true) _loadData();
  }

  void _delete(HealthRecord item) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa chỉ số'),
        content: Text(
          'Bạn có chắc muốn xóa bản ghi ${item.metricName} (${HealthHelper.formatRecordValue(item)})?',
        ),
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
    int ret = await HealthRecordRepository.delete(item.id);
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bản ghi chỉ số')),
      );
      if ((_result?.items.length ?? 0) == 1 && _page > 1) _page--;
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa thất bại')),
      );
    }
  }
}