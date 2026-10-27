import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trekbikes_app/bike.dart';
import 'package:trekbikes_app/bike_repository.dart';
import 'package:trekbikes_app/category.dart';
import 'package:trekbikes_app/category_repository.dart';
import 'package:trekbikes_app/login_page.dart';
import 'package:trekbikes_app/register_page.dart';
import 'package:trekbikes_app/sesson_helper.dart';
import 'package:trekbikes_app/sub_category.dart';
import 'package:trekbikes_app/sub_category_repository.dart';
import 'package:trekbikes_app/details_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title}) : _title = title;
  final String _title;
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  List<Bike> _bikes = [];
  int? _categoryId;
  String? _email;
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCategories();
    _loadSubCategories();
    _loadBikes();
  }
  void _loadBikes() async {
    var data = await BikeRepository.getBikes();
    setState((){
      _bikes = data;
    });
  }
  void _loadSubCategories() async {
    try {
    var data = _categoryId !=null
      ? await SubCategoryRepository.getSubCategoriesByCategory(_categoryId!)
      : await SubCategoryRepository.getSubCategories();
    setState((){
      _subCategories = data;
    });
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }
  void _loadCategories() async {
    var data = await CategoryRepository.getCategories();
    setState(() {
      _categories = data;
    });
  }
  void _loadData() async {
    String? eml = await SessonHelper.email;
    setState(() {
      _email = eml;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.network('${dotenv.env["API_URL"]}/trek.png', width: 32),
        title: Row(
          children: _categories.map<Widget>((p) {
            return ChoiceChip(
              label: Text(p.name),
              avatar: Image.network(
                '${dotenv.env["API_URL"]}/categories/${p.icon}',
                width: 32,
              ),
              selected: _categoryId != null && _categoryId == p.id,
              onSelected: (selected) {
                setState(() {
                  _categoryId = selected ? p.id : null;
                });
                _loadSubCategories();
              },
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          Wrap(
            children: _subCategories.map<Widget>((p){
              return FilterChip(label: Text(p.name), onSelected: (val){});
            }).toList(),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: _bikes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index){
                Bike item = _bikes[index];
                return Column(
                  children: [
                    Text(item.name),
                    Image.network(
                      '${dotenv.env['API_URL']}/bikes/${item.imageUrl}',
                      width: 128,
                    ),
                    Text('Price: ${item.price}'),
                    ElevatedButton.icon(
                      onPressed: () => _details(item.id),
                      label: Text('Details'),
                    ),
                  ],
                );
              },
            ),
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
              label: const Text('Login'),
            ),
            ElevatedButton.icon(
              onPressed: _register,
              icon: const Icon(Icons.add),
              label: const Text('Register'),
            ),
            ] else ...[
            ElevatedButton.icon(
              onPressed: _profile,
              icon: const Icon(Icons.person),
              label: const Text('Profile'),
            ),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
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
  void _details(int id){
    Navigator.pushNamed(context, '/details', arguments: id);
  }
  void _logout() async {
  await SessonHelper.delete();
  _loadData();
  }
  void _profile() {}
  void _register() {
    Navigator.pushNamed(context, '/register');
  }
}