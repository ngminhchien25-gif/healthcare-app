import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/medicine_category.dart';
import 'package:healthcare_app/medicine_category_repository.dart';
import 'package:healthcare_app/medicine_repository.dart';
import 'package:healthcare_app/paged_result.dart';
import 'package:healthcare_app/prescription_helper.dart';

class MedicineBrowser extends StatefulWidget {
  final VoidCallback? onCartChanged;
  const MedicineBrowser({super.key, this.onCartChanged});
  @override
  State<MedicineBrowser> createState() => _MedicineBrowserState();
}

class _MedicineBrowserState extends State<MedicineBrowser> {
  static const int _pageSize = 8;
  final TextEditingController _keywordController = TextEditingController();
  List<MedicineCategory> _categories = [];
  PagedResult<Medicine>? _result;
  int? _categoryId;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadMedicines();
  }

  void _loadCategories() async {
    try {
      var data = await MedicineCategoryRepository.getMedicineCategories();
      if (!mounted) return;
      setState(() => _categories = data);
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void _loadMedicines() async {
    try {
      var data = await MedicineRepository.getMedicines(
        _categoryId,
        _keywordController.text.trim(),
        _page,
        _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _result = data;
        _error = null;
      });
    } catch (ex) {
      if (!mounted) return;
      setState(
        () => _error = 'Không tải được danh sách thuốc, vui lòng thử lại',
      );
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Medicine> items = _result?.items ?? [];
    int totalPages = _result?.totalPages ?? 1;
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _categoryId == null,
                  onSelected: (_) => _selectCategory(null),
                ),
              ),
              ..._categories.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(c.name),
                    avatar: c.icon == null
                        ? null
                        : Image.network(
                            ImageHelper.url('medicinecategories', c.icon!),
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.medication, size: 20),
                          ),
                    selected: _categoryId == c.id,
                    onSelected: (_) => _selectCategory(c.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  decoration: const InputDecoration(
                    labelText: 'Tìm thuốc theo tên hoặc mô tả',
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              IconButton(onPressed: _search, icon: const Icon(Icons.search)),
            ],
          ),
        ),
        if (_error != null) Text(_error!),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Không có thuốc phù hợp'),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: 270,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              Medicine item = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _details(item.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: item.imageUrl == null
                            ? const Icon(Icons.medication, size: 64)
                            : Image.network(
                                ImageHelper.url('medicines', item.imageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.broken_image, size: 64),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Đơn vị: ${item.unit}'),
                            TextButton.icon(
                              onPressed: () => _addToCart(item),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm vào đơn'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
    );
  }

  void _selectCategory(int? id) {
    setState(() {
      _categoryId = id;
      _page = 1;
    });
    _loadMedicines();
  }

  void _search() {
    _page = 1;
    _loadMedicines();
  }

  void _goto(int page) {
    _page = page;
    _loadMedicines();
  }

  void _details(int id) {
    Navigator.pushNamed(context, '/medicine-detail', arguments: id);
  }

  void _addToCart(Medicine item) async {
    bool ok = await PrescriptionHelper.addToCart(context, item);
    if (ok) widget.onCartChanged?.call();
  }
}
