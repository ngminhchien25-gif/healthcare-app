import 'package:flutter/material.dart';
import 'package:healthcare_app/sesson_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title}) : _title = title;
  final String _title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _email;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    String? eml = await SessonHelper.email;
    String? role = await SessonHelper.role;
    setState(() {
      _email = eml;
      _role = role;
    });
  }

  Widget _menuCard(IconData icon, String title, String route) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            _email == null
                ? 'Chào mừng bạn đến với ứng dụng quản lý sức khỏe'
                : 'Xin chào, $_email',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_email == null)
            const Text(
              'Vui lòng đăng nhập để sử dụng các chức năng theo dõi sức khỏe',
            )
          else ...[
            // ===== Module A (Danh): chỉ số cơ thể =====

            // ===== Module B (Bảo): luyện tập =====

            // ===== Module C: thuốc và nhắc nhở =====
            _menuCard(Icons.medication, 'Tra cứu thuốc', '/medicines'),
            _menuCard(
              Icons.assignment,
              'Đơn thuốc đang soạn',
              '/prescription-cart',
            ),
            _menuCard(
              Icons.receipt_long,
              'Đơn thuốc của tôi',
              '/prescriptions',
            ),
          ],
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            if (_email == null) ...[
              ElevatedButton.icon(
                onPressed: _login,
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập'),
              ),
              ElevatedButton.icon(
                onPressed: _register,
                icon: const Icon(Icons.add),
                label: const Text('Đăng ký'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock),
                label: const Text('Đổi mật khẩu'),
              ),
              if (_role == 'Admin') ...[
                ElevatedButton.icon(
                  onPressed: _members,
                  icon: const Icon(Icons.people),
                  label: const Text('Quản lý thành viên'),
                ),
                // ===== Menu Admin của Module A =====

                // ===== Menu Admin của Module B =====

                // ===== Menu Admin của Module C =====
                ElevatedButton.icon(
                  onPressed: _prescriptionAdmin,
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Quản lý đơn thuốc'),
                ),
                ElevatedButton.icon(
                  onPressed: _medicineCategories,
                  icon: const Icon(Icons.category),
                  label: const Text('Quản lý nhóm thuốc'),
                ),
                ElevatedButton.icon(
                  onPressed: _medicineManage,
                  icon: const Icon(Icons.medication),
                  label: const Text('Quản lý thuốc'),
                ),
              ],
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _prescriptionAdmin() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/prescription-admin');
  }

  void _medicineManage() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/medicine-manage');
  }

  void _login() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (result == true) {
      _loadData();
    }
  }

  void _medicineCategories() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/medicine-categories');
  }

  void _register() {
    Navigator.pushNamed(context, '/register');
  }

  void _changePassword() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/change-password');
  }

  void _members() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/members');
  }

  void _logout() async {
    await SessonHelper.delete();
    if (!mounted) return;
    Navigator.pop(context);
    _loadData();
  }
}
