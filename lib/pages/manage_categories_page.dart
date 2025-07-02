import 'package:flutter/material.dart';
import 'package:jizhang_app/models/category.dart';
import 'package:jizhang_app/services/database_helper.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  late Future<List<Category>> _expenseCategories;
  late Future<List<Category>> _incomeCategories;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    setState(() {
      _expenseCategories = DatabaseHelper.instance.getCategories(isExpense: true);
      _incomeCategories = DatabaseHelper.instance.getCategories(isExpense: false);
    });
  }

  void _addCategory(BuildContext context, bool isExpense) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加${isExpense ? '支出' : '收入'}分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '分类名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text;
              if (name.isNotEmpty) {
                await DatabaseHelper.instance.insertCategory(
                  Category(name: name, isExpense: isExpense),
                );
                _refreshCategories();
                Navigator.of(context).pop();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    _refreshCategories();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('管理分类'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '支出'),
              Tab(text: '收入'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(true),
            _buildCategoryList(false),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(bool isExpense) {
    return FutureBuilder<List<Category>>(
      future: isExpense ? _expenseCategories : _incomeCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('错误: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('没有分类'));
        }

        final categories = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteCategory(category.id!),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _addCategory(context, isExpense),
                icon: const Icon(Icons.add),
                label: const Text('添加新分类'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
