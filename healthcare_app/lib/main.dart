import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcare_app/category_page.dart';
import 'package:healthcare_app/register_page.dart';
import 'package:healthcare_app/login_page.dart';
import 'package:healthcare_app/home_page.dart';
import 'package:healthcare_app/details_page.dart';
import 'package:healthcare_app/change_password_page.dart'; 
import 'package:healthcare_app/member_page.dart';
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
        "/": (context) => HomePage(title: 'Trek Bike'),
        "/login": (context) => LoginPage(title: 'Login'),
        "/register": (context) => RegisterPage(title: 'Register'),
        "/logout": (context) => HomePage(title: 'Trek Bike'),
        "/details": (context) => DetailPage(title: 'Details'),
        "/change-password": (context) => ChangePasswordPage(title: 'Đổi mật khẩu'),
        "/members": (context) => MemberPage(title: 'Quản lý thành viên'),
      },
    );
  }
}
