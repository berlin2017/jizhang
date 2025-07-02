import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jizhang_app/models/transaction.dart' as model;

class StorageService {
  static const String _transactionsKey = 'transactions';

  // 简单的映射，用于根据类别获取图标
  static final Map<String, IconData> _categoryIcons = {
    '餐饮': Icons.fastfood,
    '交通': Icons.directions_bus,
    '购物': Icons.shopping_cart,
    '娱乐': Icons.movie,
    '工资': Icons.work,
    '理财': Icons.attach_money,
    '兼职': Icons.business_center,
    '其他': Icons.category,
  };

  // 保存账单列表到本地
  static Future<void> saveTransactions(List<model.Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data = transactions.map((tx) => {
      'id': tx.id,
      'amount': tx.amount,
      'category': tx.category,
      'date': tx.date.toIso8601String(),
      'isExpense': tx.isExpense,
      'iconCodePoint': tx.icon.codePoint, // 存储 icon 的 codePoint
    }).toList();
    await prefs.setString(_transactionsKey, json.encode(data));
  }

  // 从本地加载账单列表
  static Future<List<model.Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString(_transactionsKey);
    if (transactionsString == null) {
      return [];
    }
    final List<dynamic> data = json.decode(transactionsString);
    return data.map((item) => model.Transaction(
      id: item['id'],
      amount: item['amount'],
      category: item['category'],
      date: DateTime.parse(item['date']),
      isExpense: item['isExpense'],
      icon: _categoryIcons[item['category']] ?? Icons.category, // 根据 category 重新获取 icon
    )).toList();
  }
}
