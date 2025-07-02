import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final double amount;
  final int categoryId; // Changed from category
  final String category; // Keep for display purposes
  final DateTime date;
  final bool isExpense;
  final String? notes;

  IconData get icon {
    const Map<String, IconData> categoryIcons = {
      '餐饮': Icons.fastfood,
      '交通': Icons.directions_bus,
      '购物': Icons.shopping_cart,
      '娱乐': Icons.movie,
      '工资': Icons.work,
      '理财': Icons.attach_money,
      '兼职': Icons.business_center,
      '其他': Icons.category,
    };
    return categoryIcons[category] ?? Icons.category;
  }

  Transaction({
    required this.id,
    required this.amount,
    required this.categoryId, // Changed from category
    required this.category,
    required this.date,
    required this.isExpense,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId, // Changed from category
      'date': date.toIso8601String(),
      'isExpense': isExpense ? 1 : 0,
      'notes': notes ?? '',
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      categoryId: map['categoryId'], // Changed from category
      category: map['category'],
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'] == 1,
      notes: map['notes'],
    );
  }
}
