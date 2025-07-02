import 'package:flutter/material.dart';
import 'package:jizhang_app/pages/manage_categories_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('管理分类'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
              );
            },
          ),
          // Add other settings here in the future
        ],
      ),
    );
  }
}
