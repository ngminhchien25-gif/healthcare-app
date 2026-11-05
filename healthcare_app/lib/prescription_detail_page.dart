import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/prescription_helper.dart';
import 'package:healthcare_app/prescription_info.dart';
import 'package:healthcare_app/prescription_line.dart';
import 'package:healthcare_app/prescription_repository.dart';

class PrescriptionDetailPage extends StatefulWidget {
  final String title;
  const PrescriptionDetailPage({super.key, required this.title});
  @override
  State<PrescriptionDetailPage> createState() => _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
  PrescriptionInfo? _info;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadData(ModalRoute.of(context)!.settings.arguments as int);
  }

  void _loadData(int id) async {
    try {
      var data = await PrescriptionRepository.getPrescription(id);
      setState(() => _info = data);
    } catch (ex) {
      setState(() => _error = 'Không tải được đơn thuốc');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    PrescriptionInfo? info = _info;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (_error != null) Text(_error!),
              if (info != null) ...[
                Text(
                  'Đơn thuốc #${info.prescription.id} - ngày ${PrescriptionHelper.date(info.prescription.prescribedDate)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Trạng thái: ${PrescriptionHelper.statusText(info.prescription.status)}',
                ),
                if (info.prescription.doctorName != null)
                  Text('Bác sĩ kê đơn: ${info.prescription.doctorName}'),
                if (info.prescription.note != null)
                  Text('Ghi chú: ${info.prescription.note}'),
                if (info.prescription.reviewNote != null)
                  Text('Ý kiến dược sĩ: ${info.prescription.reviewNote}'),
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
                const SizedBox(height: 12),
                const Text(
                  'Thông tin chỉ mang tính tham khảo, không thay thế tư vấn của bác sĩ hoặc dược sĩ.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                if (info.prescription.status == 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/reminder-from-prescription',
                        arguments: info.prescription.id,
                      ),
                      icon: const Icon(Icons.alarm_add),
                      label: const Text('Tạo nhắc uống thuốc'),
                    ),
                  )
                else if (info.prescription.status == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Sau khi dược sĩ xác nhận, bạn có thể tạo nhắc uống thuốc cho đơn này.',
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
