import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcare_app/register_page.dart';
import 'package:healthcare_app/login_page.dart';
import 'package:healthcare_app/home_page.dart';
import 'package:healthcare_app/change_password_page.dart'; 
import 'package:healthcare_app/member_page.dart';
import 'package:healthcare_app/medicine_category_page.dart'; 
import 'package:healthcare_app/medicine_category_form_page.dart'; 
import 'package:healthcare_app/medicine_manage_page.dart';
import 'package:healthcare_app/medicine_form_page.dart'; 
import 'package:healthcare_app/medicine_page.dart';
import 'package:healthcare_app/medicine_detail_page.dart'; 
import 'package:healthcare_app/prescription_cart_page.dart'; 
import 'package:healthcare_app/prescription_detail_page.dart'; 
void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        "/": (context) => HomePage(title: 'Health Care'),
        "/login": (context) => LoginPage(title: 'Login'),
        "/register": (context) => RegisterPage(title: 'Register'),
        "/logout": (context) => HomePage(title: 'Health Care'),
        "/change-password": (context) => ChangePasswordPage(title: 'Đổi mật khẩu'),
        "/members": (context) => MemberPage(title: 'Quản lý thành viên'),
        // ===== Module C: thuốc và nhắc nhở =====
        "/medicine-categories": (context) => MedicineCategoryPage(title: 'Quản lý nhóm thuốc'),
        "/medicine-category-form": (context) => MedicineCategoryFormPage(title: 'nhóm thuốc'),
        "/medicine-manage": (context) => MedicineManagePage(title: 'Quản lý thuốc'),
        "/medicine-form": (context) => MedicineFormPage(title: 'thuốc'),
        "/medicines": (context) => MedicinePage(title: 'Tra cứu thuốc'),
        "/medicine-detail": (context) => MedicineDetailPage(title: 'Chi tiết thuốc'),
        "/prescription-cart": (context) => PrescriptionCartPage(title: 'Đơn thuốc đang soạn'),
        "/prescription-detail": (context) => PrescriptionDetailPage(title: 'Chi tiết đơn thuốc'),
      },
    );
  }
}