import 'package:flutter/material.dart';
import 'package:healthcare_app/member_repository.dart';
import 'package:healthcare_app/login_response.dart';
import 'package:healthcare_app/sesson_helper.dart';
class LoginPage extends StatefulWidget {
  final String _title;
  const LoginPage({super.key, required this._title});
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Form(
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ), 
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ), 
            ElevatedButton.icon(
              onPressed: _login,
              label: Text('Login'),
              icon: Icon(Icons.login),
            ), 
            if (_error != null) Text(_error!),
          ],
        ), 
      ), 
    ); 
  }
  void _login() async {
    LoginResponse? response = await MemberRepository.login(
      _emailController.text,
      _passwordController.text,
    );
    if (response != null) {
      if (response.success) {
        await SessonHelper.save(_emailController.text.trim(), response.token!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message?? 'Login Success')),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = response.message;
        });
      }
    } else {
      setState(() {
        _error = "Invalid";
      });
    }
  } 
}