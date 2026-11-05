import 'package:flutter/material.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/reminder.dart';
import 'package:healthcare_app/reminder_helper.dart';
import 'package:healthcare_app/reminder_repository.dart';

class ReminderPage extends StatefulWidget {
  final String title;
  const ReminderPage({super.key, required this.title});
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  static const int _pageSize = 8;
  final TextEditingController _keywordController = TextEditingController();
  PagedResult<Reminder>? _result;
  bool? _isDone;
  int? _type;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      var data = await ReminderRepository.getReminders(
        _type,
        _isDone,
        _keywordController.text.trim(),
        _page,
        _pageSize,
      );
      setState(() {
        _result = data;
        _error = null;
      });
    } catch (ex) {
      setState(
        () => _error = 'Không tải được danh sách nhắc nhở, vui lòng thử lại',
      );
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Reminder> items = _result?.items ?? [];
    int totalPages = _result?.totalPages ?? 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      labelText: 'Tìm theo tiêu đề hoặc ghi chú',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _isDone == null,
                  onSelected: (_) => _setDone(null),
                ),
                ChoiceChip(
                  label: const Text('Chưa xong'),
                  selected: _isDone == false,
                  onSelected: (_) => _setDone(false),
                ),
                ChoiceChip(
                  label: const Text('Đã xong'),
                  selected: _isDone == true,
                  onSelected: (_) => _setDone(true),
                ),
                DropdownButton<int?>(
                  value: _type,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Mọi loại'),
                    ),
                    for (int t = 0; t <= 2; t++)
                      DropdownMenuItem<int?>(
                        value: t,
                        child: Text(ReminderHelper.typeText(t)),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                      _page = 1;
                    });
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          if (_error != null) Text(_error!),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Chưa có nhắc nhở nào'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      Reminder item = items[index];
                      bool overdue = ReminderHelper.isOverdue(item);
                      return Card(
                        child: ListTile(
                          onTap: () => _openForm(item),
                          leading: Checkbox(
                            value: item.isDone,
                            onChanged: (value) => _toggle(item, value ?? false),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${ReminderHelper.dateTime(item.remindAt)} · ${ReminderHelper.typeText(item.type)}'
                            '${overdue ? ' · Quá hạn' : ''}'
                            '${item.note == null ? '' : '\n${item.note}'}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: overdue
                                ? const TextStyle(color: Colors.red)
                                : null,
                          ),
                          isThreeLine: item.note != null,
                          trailing: IconButton(
                            onPressed: () => _delete(item),
                            icon: const Icon(Icons.delete),
                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm nhắc nhở'),
      ),
    );
  }

  void _search() {
    _page = 1;
    _loadData();
  }

  void _setDone(bool? value) {
    setState(() {
      _isDone = value;
      _page = 1;
    });
    _loadData();
  }

  void _goto(int page) {
    _page = page;
    _loadData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openForm(Reminder? item) async {
    final saved = await Navigator.pushNamed(
      context,
      '/reminder-form',
      arguments: item,
    );
    if (saved == true) _loadData();
  }

  void _toggle(Reminder item, bool value) async {
    int ret = await ReminderRepository.setDone(item.id, value);
    if (!mounted) return;
    if (ret > 0) {
      _loadData();
    } else {
      _showMessage('Không cập nhật được trạng thái');
    }
  }

  void _delete(Reminder item) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhắc nhở'),
        content: Text('Bạn có chắc muốn xóa "${item.title}"?'),
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
    int ret = await ReminderRepository.delete(item.id);
    if (!mounted) return;
    if (ret >= 0) {
      _showMessage('Đã xóa nhắc nhở');
      if ((_result?.items.length ?? 0) == 1 && _page > 1) _page--;
      _loadData();
    } else {
      _showMessage('Xóa thất bại');
    }
  }
}
