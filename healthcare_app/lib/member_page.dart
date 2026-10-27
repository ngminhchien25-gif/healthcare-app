import 'package:flutter/material.dart';
import 'package:healthcare_app/member_repository.dart';
import 'package:healthcare_app/member_summary.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/sesson_helper.dart';

class MemberPage extends StatefulWidget {
  final String title;
  const MemberPage({super.key, required this.title});
  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  static const List<String> _roleNames = ['Thành viên', 'Khách hàng', 'Quản trị viên'];
  final TextEditingController _keywordController = TextEditingController();
  PagedResult<MemberSummary>? _result;
  String? _myEmail;
  String? _error;
  bool _isAdmin = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String? role = await SessonHelper.role;
      String? email = await SessonHelper.email;
      if (role != 'Admin') {
        setState(() => _isAdmin = false);
        return;
      }
      var data = await MemberRepository.getMembers(_keywordController.text.trim(), _page, 10);
      setState(() {
        _result = data;
        _myEmail = email;
        _error = null;
      });
    } catch (ex) {
      setState(() => _error = 'Không tải được dữ liệu, vui lòng thử lại');
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Bạn không có quyền truy cập chức năng này')),
      );
    }
    List<MemberSummary> items = _result?.items ?? [];
    int totalPages = _result?.totalPages ?? 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(labelText: 'Tìm theo email hoặc tên'),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
          ),
          if (_error != null) Text(_error!),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                MemberSummary item = items[index];
                bool isMe = _myEmail != null &&
                    item.email.toLowerCase() == _myEmail!.toLowerCase();
                return ListTile(
                  title: Text(item.fullName),
                  subtitle: Text(item.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<int>(
                        value: item.role,
                        items: List.generate(
                          _roleNames.length,
                          (i) => DropdownMenuItem(value: i, child: Text(_roleNames[i])),
                        ),
                        onChanged: isMe
                            ? null
                            : (value) {
                                if (value != null) _setRole(item, value);
                              },
                      ),
                      IconButton(
                        onPressed: isMe ? null : () => _delete(item),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _page > 1 ? () => _goto(_page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Trang $_page/$totalPages'),
              IconButton(
                onPressed: _page < totalPages ? () => _goto(_page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _search() {
    _page = 1;
    _loadData();
  }

  void _goto(int page) {
    _page = page;
    _loadData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setRole(MemberSummary item, int role) async {
    int ret = await MemberRepository.setRole(item.id, role);
    if (!mounted) return;
    if (ret > 0) {
      _showMessage('Đã đổi vai trò, thành viên cần đăng nhập lại để có hiệu lực');
      _loadData();
    } else if (ret == -3) {
      _showMessage('Không thể tự đổi vai trò của chính mình');
    } else {
      _showMessage('Đổi vai trò thất bại');
    }
  }

  void _delete(MemberSummary item) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text('Bạn có chắc muốn xóa ${item.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    int ret = await MemberRepository.deleteMember(item.id);
    if (!mounted) return;
    if (ret > 0) {
      _showMessage('Đã xóa thành viên');
      if ((_result?.items.length ?? 0) == 1 && _page > 1) _page--;
      _loadData();
    } else if (ret == -2) {
      _showMessage('Thành viên đã có dữ liệu liên quan, không thể xóa');
    } else if (ret == -3) {
      _showMessage('Không thể tự xóa chính mình');
    } else {
      _showMessage('Xóa thất bại');
    }
  }
}