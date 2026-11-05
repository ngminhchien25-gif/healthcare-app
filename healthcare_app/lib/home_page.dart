import 'package:flutter/material.dart';
import 'package:healthcare_app/medicine_browser.dart';
import 'package:healthcare_app/prescription_repository.dart';
import 'package:healthcare_app/sesson_helper.dart';
import 'package:healthcare_app/local_database.dart';
import 'package:healthcare_app/reminder.dart';
import 'package:healthcare_app/reminder_helper.dart';
import 'package:healthcare_app/reminder_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title}) : _title = title;
  final String _title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _email;
  String? _role;
  int _cartCount = 0;
  List<Reminder> _upcoming = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    String? eml = await SessonHelper.email;
    String? role = await SessonHelper.role;
    int count = eml == null ? 0 : await PrescriptionRepository.countCart();
    if (!mounted) return;
    setState(() {
      _email = eml;
      _role = role;
      _cartCount = count;
    });
    _loadUpcoming();
  }

  void _loadUpcoming() async {
    if (_email == null) {
      setState(() => _upcoming = []);
      return;
    }
    try {
      var data = await ReminderRepository.getUpcoming();
      if (!mounted) return;
      setState(() => _upcoming = data);
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void _doneUpcoming(Reminder item) async {
    await ReminderRepository.setDone(item.id, true);
    _loadUpcoming();
  }

  Widget _menuCard(IconData icon, String title, String route) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.pushNamed(context, route);
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
        actions: [
          if (_email != null)
            IconButton(
              tooltip: 'Đơn thuốc đang soạn',
              onPressed: () async {
                await Navigator.pushNamed(context, '/prescription-cart');
                _loadData();
              },
              icon: Badge(
                label: Text('$_cartCount'),
                isLabelVisible: _cartCount > 0,
                child: const Icon(Icons.assignment),
              ),
            ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            _email == null
                ? 'Chào mừng bạn đến với ứng dụng quản lý sức khỏe'
                : 'Xin chào, $_email',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (_email != null) ...[
            // ===== Module A (Danh): chỉ số cơ thể =====

            // ===== Module B (Bảo): luyện tập =====

            // ===== Module C: thuốc và nhắc nhở =====
            Text(
              'Nhắc sắp tới',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_upcoming.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Chưa có nhắc nhở nào sắp tới'),
              )
            else
              ..._upcoming
                  .take(3)
                  .map(
                    (Reminder r) => ListTile(
                      leading: Icon(ReminderHelper.typeIcon(r.type)),
                      title: Text(r.title),
                      subtitle: Text(
                        '${ReminderHelper.dateTime(r.remindAt)}${ReminderHelper.isOverdue(r) ? ' · Quá hạn' : ''}',
                        style: ReminderHelper.isOverdue(r)
                            ? const TextStyle(color: Colors.red)
                            : null,
                      ),
                      trailing: IconButton(
                        tooltip: 'Đánh dấu đã xong',
                        onPressed: () => _doneUpcoming(r),
                        icon: const Icon(Icons.check_circle_outline),
                      ),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/reminders');
                        _loadUpcoming();
                      },
                    ),
                  ),
            _menuCard(
              Icons.notifications_active,
              'Nhắc nhở của tôi',
              '/reminders',
            ),
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
          ] else
            const Text('Đăng nhập để lưu đơn thuốc và theo dõi sức khỏe'),
          const SizedBox(height: 16),
          const Divider(),
          Text(
            'Danh mục và thuốc',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          MedicineBrowser(onCartChanged: _loadData),
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
                  onPressed: () => _openAdmin('/medicine-categories'),
                  icon: const Icon(Icons.category),
                  label: const Text('Quản lý nhóm thuốc'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAdmin('/medicine-manage'),
                  icon: const Icon(Icons.medication),
                  label: const Text('Quản lý thuốc'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAdmin('/prescription-admin'),
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Quản lý đơn thuốc'),
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

  void _login() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (result == true) {
      _loadData();
    }
  }

  void _register() {
    Navigator.pushNamed(context, '/register');
  }

  void _changePassword() {
    _openAdmin('/change-password');
  }

  void _members() {
    _openAdmin('/members');
  }

  void _openAdmin(String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _logout() async {
    try {
      await LocalDatabase.clearReminders();
    } catch (ex) {
      debugPrint(ex.toString());
    }
    await SessonHelper.delete();
    if (!mounted) return;
    Navigator.pop(context);
    _loadData();
  }
}
