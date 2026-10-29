import 'package:flutter/material.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/prescription.dart';
import 'package:healthcare_app/prescription_helper.dart';
import 'package:healthcare_app/prescription_repository.dart';

class PrescriptionPage extends StatefulWidget {
  final String title;
  const PrescriptionPage({super.key, required this.title});
  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  static const int _pageSize = 8;
  final TextEditingController _keywordController = TextEditingController();
  PagedResult<Prescription>? _result;
  DateTime? _fromDate;
  DateTime? _toDate;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      var data = await PrescriptionRepository.getPrescriptions(
        _keywordController.text.trim(),
        _fromDate,
        _toDate,
        _page,
        _pageSize,
      );
      setState(() {
        _result = data;
        _error = null;
      });
    } catch (ex) {
      setState(() => _error = 'Không tải được danh sách đơn thuốc, vui lòng thử lại');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Prescription> items = _result?.items ?? [];
    int totalPages = _result?.totalPages ?? 1;
    bool hasFilter = _fromDate != null || _toDate != null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(labelText: 'Tìm theo bác sĩ hoặc ghi chú'),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickDate(true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Từ ngày: ${_fromDate == null ? 'tất cả' : PrescriptionHelper.date(_fromDate!)}'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(false),
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Đến ngày: ${_toDate == null ? 'tất cả' : PrescriptionHelper.date(_toDate!)}'),
                ),
                if (hasFilter)
                  TextButton(onPressed: _clearFilter, child: const Text('Xóa lọc ngày')),
              ],
            ),
          ),
          if (_error != null) Text(_error!),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Chưa có đơn thuốc nào'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      Prescription item = items[index];
                      List<String> info = [];
                      if (item.doctorName != null) info.add('Bác sĩ: ${item.doctorName}');
                      if (item.note != null) info.add('Ghi chú: ${item.note}');
                      return Card(
                        child: ListTile(
                          onTap: () => _details(item.id),
                          leading: const Icon(Icons.receipt_long, size: 40),
                          title: Text('Đơn ngày ${PrescriptionHelper.date(item.prescribedDate)}'),
                          subtitle: Text(info.isEmpty ? 'Không có ghi chú' : info.join('\n')),
                          isThreeLine: info.length > 1,
                          trailing: Chip(label: Text(PrescriptionHelper.statusText(item.status))),
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
        onPressed: _newPrescription,
        icon: const Icon(Icons.add),
        label: const Text('Soạn đơn mới'),
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

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _page = 1;
    });
    _loadData();
  }

  void _pickDate(bool isFrom) async {
    DateTime? current = isFrom ? _fromDate : _toDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    DateTime? from = isFrom ? picked : _fromDate;
    DateTime? to = isFrom ? _toDate : picked;
    if (from != null && to != null && from.isAfter(to)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày bắt đầu phải trước hoặc bằng ngày kết thúc')),
      );
      return;
    }
    setState(() {
      _fromDate = from;
      _toDate = to;
      _page = 1;
    });
    _loadData();
  }

  void _details(int id) async {
    await Navigator.pushNamed(context, '/prescription-detail', arguments: id);
    _loadData();
  }

  void _newPrescription() async {
    await Navigator.pushNamed(context, '/medicines');
    _loadData();
  }
}