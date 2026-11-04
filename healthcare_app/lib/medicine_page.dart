import 'package:flutter/material.dart';
import 'package:healthcare_app/medicine_browser.dart';
import 'package:healthcare_app/prescription_repository.dart';
import 'package:healthcare_app/sesson_helper.dart';

class MedicinePage extends StatefulWidget {
  final String title;
  const MedicinePage({super.key, required this.title});
  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  void _loadCartCount() async {
    int count = await PrescriptionRepository.countCart();
    if (!mounted) return;
    setState(() => _cartCount = count);
  }

  void _openCart() async {
    String? token = await SessonHelper.token;
    if (!mounted) return;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để xem đơn thuốc')),
      );
      return;
    }
    await Navigator.pushNamed(context, '/prescription-cart');
    _loadCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Đơn thuốc đang soạn',
            onPressed: _openCart,
            icon: Badge(
              label: Text('$_cartCount'),
              isLabelVisible: _cartCount > 0,
              child: const Icon(Icons.assignment),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: MedicineBrowser(onCartChanged: _loadCartCount),
      ),
    );
  }
}
