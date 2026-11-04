import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/prescription_helper.dart';
import 'package:healthcare_app/prescription_line.dart';
import 'package:healthcare_app/prescription_repository.dart';

class PrescriptionCheckoutPage extends StatefulWidget {
  final String title;
  const PrescriptionCheckoutPage({super.key, required this.title});
  @override
  State<PrescriptionCheckoutPage> createState() =>
      _PrescriptionCheckoutPageState();
}

class _PrescriptionCheckoutPageState extends State<PrescriptionCheckoutPage> {
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();
  List<PrescriptionLine> _lines = [];
  DateTime _date = DateTime.now();
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      var data = await PrescriptionRepository.getCart();
      setState(() => _lines = data);
    } catch (ex) {
      setState(() => _error = 'Không tải được đơn đang soạn');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Thông tin đơn thuốc',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ngày kê đơn: ${PrescriptionHelper.date(_date)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
              TextField(
                controller: _doctorController,
                maxLength: 64,
                decoration: const InputDecoration(
                  labelText: 'Bác sĩ kê đơn (nếu có)',
                ),
              ),
              TextField(
                controller: _noteController,
                maxLength: 256,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
              const SizedBox(height: 16),
              Text(
                'Danh sách thuốc (${_lines.length} loại)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_lines.isEmpty) const Text('Đơn thuốc đang soạn trống'),
              ..._lines.map((PrescriptionLine line) {
                return ListTile(
                  leading: line.imageUrl == null
                      ? const Icon(Icons.medication, size: 48)
                      : Image.network(
                          ImageHelper.url('medicines', line.imageUrl!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image, size: 48),
                        ),
                  title: Text(line.name),
                  subtitle: Text(
                    (line.dosageNote == null || line.dosageNote!.isEmpty)
                        ? 'Không có ghi chú liều dùng'
                        : line.dosageNote!,
                  ),
                  trailing: Text('${line.quantity} ${line.unit}'),
                );
              }),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!),
              ElevatedButton.icon(
                onPressed: (_lines.isEmpty || _saving) ? null : _checkout,
                icon: const Icon(Icons.check),
                label: const Text('Đặt đơn thuốc'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đơn sẽ ở trạng thái "Chờ xác nhận" cho đến khi dược sĩ kiểm tra.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _checkout() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    int ret = await PrescriptionRepository.checkout(
      _date,
      _doctorController.text.trim(),
      _noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt đơn thuốc thành công, mã đơn #$ret')),
      );
      Navigator.pushReplacementNamed(
        context,
        '/prescription-detail',
        arguments: ret,
      );
    } else if (ret == 0) {
      setState(() => _error = 'Đơn thuốc đang soạn trống');
      _loadData();
    } else if (ret == -2) {
      setState(
        () => _error = 'Dữ liệu không hợp lệ (ngày kê không được ở tương lai)',
      );
    } else {
      setState(
        () => _error = 'Đặt đơn thất bại, vui lòng đăng nhập lại và thử lại',
      );
    }
  }
}
