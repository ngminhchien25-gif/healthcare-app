import 'package:flutter/material.dart';
import 'package:trekbikes_app/member_repository.dart';

class ChangePasswordPage extends StatefulWidget {
  final String title;
  const ChangePasswordPage({super.key, required this.title});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _oldController,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
              obscureText: true,
            ),
            TextFormField(
              controller: _newController,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)'),
              obscureText: true,
            ),
            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
              obscureText: true,
            ),
            ElevatedButton.icon(
              onPressed: _save,
              label: const Text('Đổi mật khẩu'),
              icon: const Icon(Icons.save),
            ),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    String oldPassword = _oldController.text;
    String newPassword = _newController.text;
    if (oldPassword.isEmpty) {
      setState(() => _error = 'Vui lòng nhập mật khẩu hiện tại');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _error = 'Mật khẩu mới tối thiểu 6 ký tự');
      return;
    }
    if (newPassword != _confirmController.text) {
      setState(() => _error = 'Mật khẩu nhập lại không khớp');
      return;
    }
    int ret = await MemberRepository.changePassword(oldPassword, newPassword);
    if (!mounted) return;
    if (ret > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công')),
      );
      Navigator.pop(context);
    } else if (ret == -1) {
      setState(() => _error = 'Mật khẩu hiện tại không đúng');
    } else if (ret == -2) {
      setState(() => _error = 'Mật khẩu mới tối thiểu 6 ký tự');
    } else {
      setState(() => _error = 'Đổi mật khẩu thất bại, vui lòng đăng nhập lại');
    }
  }
}