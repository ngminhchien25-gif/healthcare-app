import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/prescription_line.dart';
import 'package:healthcare_app/prescription_repository.dart';

class PrescriptionCartPage extends StatefulWidget {
  final String title;
  const PrescriptionCartPage({super.key, required this.title});
  @override
  State<PrescriptionCartPage> createState() => _PrescriptionCartPageState();
}

class _PrescriptionCartPageState extends State<PrescriptionCartPage> {
  List<PrescriptionLine> _lines = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      var data = await PrescriptionRepository.getCart();
      setState(() {
        _lines = data;
        _error = null;
      });
    } catch (ex) {
      setState(() => _error = 'Không tải được đơn thuốc, vui lòng thử lại');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (_error != null) Text(_error!),
          Expanded(
            child: _lines.isEmpty
                ? const Center(child: Text('Đơn thuốc đang soạn trống'))
                : ListView.builder(
                    itemCount: _lines.length,
                    itemBuilder: (context, index) {
                      PrescriptionLine line = _lines[index];
                      return ListTile(
                        onTap: () => _editNote(line),
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
                              ? 'Chạm để thêm ghi chú liều dùng'
                              : line.dosageNote!,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: line.quantity > 1
                                  ? () => _changeQuantity(line, -1)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('${line.quantity} ${line.unit}'),
                            IconButton(
                              onPressed: () => _changeQuantity(line, 1),
                              icon: const Icon(Icons.add),
                            ),
                            IconButton(
                              onPressed: () => _remove(line),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _lines.isEmpty ? null : _clear,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Xóa tất cả'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _lines.isEmpty ? null : _checkout,
                  icon: const Icon(Icons.save),
                  label: const Text('Đặt đơn thuốc'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeQuantity(PrescriptionLine line, int delta) async {
    int quantity = line.quantity + delta;
    if (quantity < 1 || quantity > 1000) return;
    int ret = await PrescriptionRepository.updateCart(
      line.medicineId,
      quantity,
      line.dosageNote ?? '',
    );
    if (!mounted) return;
    if (ret > 0) {
      _loadData();
    } else {
      _showMessage('Không cập nhật được số lượng');
    }
  }

  void _editNote(PrescriptionLine line) async {
    final noteController = TextEditingController(text: line.dosageNote ?? '');
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ghi chú liều dùng: ${line.name}'),
        content: TextField(
          controller: noteController,
          maxLength: 128,
          decoration: const InputDecoration(
            labelText: 'Theo chỉ định của bác sĩ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    int ret = await PrescriptionRepository.updateCart(
      line.medicineId,
      line.quantity,
      noteController.text.trim(),
    );
    if (!mounted) return;
    if (ret > 0) {
      _loadData();
    } else {
      _showMessage('Không lưu được ghi chú');
    }
  }

  void _remove(PrescriptionLine line) async {
    int ret = await PrescriptionRepository.removeCart(line.medicineId);
    if (!mounted) return;
    if (ret >= 0) {
      _loadData();
    } else {
      _showMessage('Xóa thất bại');
    }
  }

  void _clear() async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả'),
        content: const Text(
          'Bạn có chắc muốn xóa toàn bộ thuốc trong đơn đang soạn?',
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
    int ret = await PrescriptionRepository.clearCart();
    if (!mounted) return;
    if (ret >= 0) {
      _loadData();
    } else {
      _showMessage('Xóa thất bại');
    }
  }

  void _checkout() async {
    await Navigator.pushNamed(context, '/prescription-checkout');
    if (!mounted) return;
    _loadData();
  }
}
