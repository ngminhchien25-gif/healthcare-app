import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/medicine_repository.dart';
import 'package:healthcare_app/prescription_repository.dart';
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
  int _cartCount = 0;
  List<Medicine> _latest = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLatest();
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
  }

  void _loadLatest() async {
    try {
      var data = await MedicineRepository.getMedicines(null, '', 1, 8);
      if (!mounted) return;
      setState(() {
        _latest = data.items;
        _error = null;
      });
    } catch (ex) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được danh sách thuốc');
      debugPrint(ex.toString());
    }
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Thuốc mới nhất',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/medicines'),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          if (_error != null) Text(_error!),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _latest.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 200,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              Medicine item = _latest[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/medicine-detail',
                    arguments: item.id,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: item.imageUrl == null
                            ? const Icon(Icons.medication, size: 48)
                            : Image.network(
                                ImageHelper.url('medicines', item.imageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.broken_image, size: 48),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
    await SessonHelper.delete();
    if (!mounted) return;
    Navigator.pop(context);
    _loadData();
  }
}
