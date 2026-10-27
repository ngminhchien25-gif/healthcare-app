import 'package:flutter/material.dart';
import 'package:healthcare_app/member.dart';
import 'package:healthcare_app/member_repository.dart';
class RegisterPage extends StatefulWidget {
  final String title;
  const RegisterPage({super.key, required this.title});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  String? _error;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _givenNameController,
                decoration: const InputDecoration(labelText: 'GivenName'),
              ),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Surname'),
              ),
              ElevatedButton.icon(
                onPressed: _register,
                label: const Text('Register'),
                icon: const Icon(Icons.save),
              ),
              if (_error != null ) Text(_error!),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _register() async {
    var obj = Member(
      id: null,
      email: _emailController.text,
      password: _passwordController.text,
      givenName: _givenNameController.text,
      surname: _surnameController.text,
      role: 0,
    );
    int ret = await MemberRepository.save(obj);
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register Success')),
      );
    } else {
      setState(() {
        _error = 'Register Failed';
      });
    }
  }
}