import 'package:flutter/material.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/prescription_repository.dart';
import 'package:healthcare_app/sesson_helper.dart';

class PrescriptionHelper {
  static String statusText(int status) {
    switch (status) {
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Từ chối';
      default:
        return 'Chờ xác nhận';
    }
  }

  static String date(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  static Future<bool> addToCart(BuildContext context, Medicine item) async {
    String? token = await SessonHelper.token;
    if (token == null) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập để thêm thuốc vào đơn'),
          action: SnackBarAction(
            label: 'Đăng nhập',
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return false;
    }
    final quantityController = TextEditingController(text: '1');
    final noteController = TextEditingController();
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm "${item.name}" vào đơn thuốc'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng (${item.unit})',
                ),
              ),
              TextField(
                controller: noteController,
                maxLength: 128,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú liều dùng (theo chỉ định của bác sĩ)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return false;
    int? quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null || quantity < 1 || quantity > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng không hợp lệ (từ 1 đến 1000)')),
      );
      return false;
    }
    int ret = await PrescriptionRepository.addCart(
      item.id,
      quantity,
      noteController.text.trim(),
    );
    if (!context.mounted) return false;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "${item.name}" vào đơn thuốc'),
          action: SnackBarAction(
            label: 'Xem đơn',
            onPressed: () => Navigator.pushNamed(context, '/prescription-cart'),
          ),
        ),
      );
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thêm được, vui lòng thử lại')),
    );
    return false;
  }
}
