import 'package:flutter/material.dart';
import 'package:healthcare_app/image_helper.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/medicine_category_repository.dart';
import 'package:healthcare_app/medicine_repository.dart';
import 'package:healthcare_app/prescription_helper.dart';
import 'package:healthcare_app/prescription_repository.dart';
import 'package:healthcare_app/sesson_helper.dart';

class MedicineDetailPage extends StatefulWidget {
  final String title;
  const MedicineDetailPage({super.key, required this.title});
  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  static const int _relatedPageSize = 4;
  int? _id;
  Medicine? _medicine;
  String _categoryName = '';
  List<Medicine> _related = [];
  int _relatedPage = 1;
  int _relatedTotalPages = 1;
  int _cartCount = 0;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _id = ModalRoute.of(context)!.settings.arguments as int;
    _loadData();
    _loadCartCount();
  }

  void _loadData() async {
    try {
      var item = await MedicineRepository.getMedicine(_id!);
      var categories = await MedicineCategoryRepository.getMedicineCategories();
      String name = '';
      for (var c in categories) {
        if (c.id == item.categoryId) name = c.name;
      }
      setState(() {
        _medicine = item;
        _categoryName = name;
      });
      _loadRelated();
    } catch (ex) {
      setState(() => _error = 'Không tải được thông tin thuốc');
      debugPrint(ex.toString());
    }
  }

  void _loadRelated() async {
    try {
      var data = await MedicineRepository.getRelated(
        _id!,
        _relatedPage,
        _relatedPageSize,
      );
      setState(() {
        _related = _relatedPage == 1
            ? data.items
            : [..._related, ...data.items];
        _relatedTotalPages = data.totalPages;
      });
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void _loadCartCount() async {
    int count = await PrescriptionRepository.countCart();
    if (!mounted) return;
    setState(() => _cartCount = count);
  }

  void _addToCart(Medicine item) async {
    bool ok = await PrescriptionHelper.addToCart(context, item);
    if (ok) _loadCartCount();
  }

  void _openCart() async {
    String? token = await SessonHelper.token;
    if (!mounted) return;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để xem đơn thuốc')),
      );
      return;
    }
    await Navigator.pushNamed(context, '/prescription-cart');
    _loadCartCount();
  }

  @override
  Widget build(BuildContext context) {
    Medicine? item = _medicine;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Đơn thuốc đang soạn',
            onPressed: _openCart,
            icon: Badge(
              label: Text('$_cartCount'),
              isLabelVisible: _cartCount > 0,
              child: const Icon(Icons.assignment),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) Text(_error!),
                if (item != null) ...[
                  Center(
                    child: item.imageUrl == null
                        ? const Icon(Icons.medication, size: 96)
                        : Image.network(
                            ImageHelper.url('medicines', item.imageUrl!),
                            height: 240,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.broken_image, size: 96),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Nhóm thuốc: $_categoryName'),
                  Text('Đơn vị: ${item.unit}'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _addToCart(item),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm vào đơn thuốc'),
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Mô tả chung',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(item.description!),
                  ],
                  if (item.precaution != null &&
                      item.precaution!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Lưu ý chung',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(item.precaution!),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Thông tin chỉ mang tính tham khảo, không thay thế tư vấn của bác sĩ hoặc dược sĩ.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
                if (_related.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Thuốc cùng nhóm',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _related.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisExtent: 200,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      Medicine rel = _related[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _details(rel.id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: rel.imageUrl == null
                                    ? const Icon(Icons.medication, size: 48)
                                    : Image.network(
                                        ImageHelper.url(
                                          'medicines',
                                          rel.imageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 48,
                                            ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  rel.name,
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
                  if (_relatedPage < _relatedTotalPages)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _relatedPage++;
                          _loadRelated();
                        },
                        child: const Text('Xem thêm'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _details(int id) {
    Navigator.pushNamed(context, '/medicine-detail', arguments: id);
  }
}
