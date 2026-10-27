import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trekbikes_app/category_page.dart';
import 'package:trekbikes_app/register_page.dart';
import 'package:trekbikes_app/login_page.dart';
import 'package:trekbikes_app/home_page.dart';
import 'package:trekbikes_app/details_page.dart';
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
      },
    );
  }
}
