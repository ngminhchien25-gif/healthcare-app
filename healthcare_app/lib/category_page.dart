import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcare_app/category.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:healthcare_app/category_repository.dart';
class CategoryPage extends StatefulWidget {
  final String title;
  const CategoryPage({super.key, required this.title});
  @override
  State<StatefulWidget> createState() => _CategoryPageState();
}
class _CategoryPageState extends State<CategoryPage> {
  List<Category> list = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var data = await CategoryRepository.getCategories();
    setState(() {
      list = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: GridView.builder(
        itemCount: list.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemBuilder: (context, index) {
          Category item = list[index];
          return Row(children: [Text(item.name)]);
        },
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _add,
        icon: Icon(Icons.add),
        label: Text('Add')
      )
    );
  }
    void _add() async {
      final _nameController = TextEditingController();
      final _titleController = TextEditingController();
      final _descriptionController = TextEditingController();
      final _iconController = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _iconController,
                decoration: InputDecoration(labelText: 'Icon'),
              ),
              ElevatedButton.icon(
                onPressed: (){
                  var obj = Category(
                    id: 0,
                    name: _nameController.text,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    icon: _iconController.text
                  );
                  _saveAdd(obj);
                  
                },
                label: Text('Save')
              )
            ],  
          ),
        ),
      );
    }
    void _saveAdd(Category obj) async {
      int ret = await CategoryRepository.add(obj);
      if (!mounted) return;
      if (ret > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insert success')));
        Navigator.pop(context, true);
        _loadData();
      }
    }
  }

