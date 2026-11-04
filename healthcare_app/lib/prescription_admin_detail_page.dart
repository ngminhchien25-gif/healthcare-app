import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/prescription_admin_info.dart';
import 'package:healthcare_app/prescription_admin_repository.dart';
import 'package:healthcare_app/prescription_helper.dart';
import 'package:healthcare_app/prescription_line.dart';
import 'package:healthcare_app/prescription_summary.dart';

class PrescriptionAdminDetailPage extends StatefulWidget {
  final String title;
  const PrescriptionAdminDetailPage({super.key, required this.title});
  @override
  State<PrescriptionAdminDetailPage> createState() =>
      _PrescriptionAdminDetailPageState();
}

class _PrescriptionAdminDetailPageState
    extends State<PrescriptionAdminDetailPage> {
  PrescriptionAdminInfo? _info;
  int? _id;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _id = ModalRoute.of(context)!.settings.arguments as int;
    _loadData();
  }

  void _loadData() async {
    try {
      var data = await PrescriptionAdminRepository.getPrescription(_id!);
      setState(() => _info = data);
    } catch (ex) {
      setState(() => _error = 'Không tải được đơn thuốc');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    PrescriptionAdminInfo? info = _info;
    PrescriptionSummary? p = info?.prescription;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (_error != null) Text(_error!),
              if (info != null && p != null) ...[
                Text(
                  'Đơn thuốc ngày ${PrescriptionHelper.date(p.prescribedDate)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Thành viên: ${p.memberName} (${p.memberEmail})'),
                Text('Trạng thái: ${PrescriptionHelper.statusText(p.status)}'),
                if (p.doctorName != null)
                  Text('Bác sĩ kê đơn: ${p.doctorName}'),
                if (p.note != null) Text('Ghi chú: ${p.note}'),
                if (p.reviewNote != null)
                  Text('Ý kiến dược sĩ: ${p.reviewNote}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: p.status == 1 ? null : () => _review(1),
                      icon: const Icon(Icons.check),
                      label: const Text('Xác nhận'),
                    ),
                    OutlinedButton.icon(
                      onPressed: p.status == 2 ? null : () => _review(2),
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Danh sách thuốc',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...info.lines.map((PrescriptionLine line) {
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _review(int status) async {
    final noteController = TextEditingController(
      text: _info?.prescription.reviewNote ?? '',
    );
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 1 ? 'Xác nhận đơn thuốc' : 'Từ chối đơn thuốc'),
        content: TextField(
          controller: noteController,
          maxLength: 256,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: status == 1
                ? 'Ý kiến dược sĩ (không bắt buộc)'
                : 'Lý do từ chối (bắt buộc)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(status == 1 ? 'Xác nhận' : 'Từ chối'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    String note = noteController.text.trim();
    if (status == 2 && note.isEmpty) {
      _showMessage('Vui lòng nhập lý do từ chối');
      return;
    }
    int ret = await PrescriptionAdminRepository.review(_id!, status, note);
    if (!mounted) return;
    if (ret > 0) {
      _showMessage(
        status == 1 ? 'Đã xác nhận đơn thuốc' : 'Đã từ chối đơn thuốc',
      );
      _loadData();
    } else if (ret == -3) {
      _showMessage('Vui lòng nhập lý do từ chối');
    } else {
      _showMessage('Cập nhật thất bại, vui lòng thử lại');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
