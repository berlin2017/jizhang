import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jizhang_app/models/transaction.dart' as model;
import 'package:collection/collection.dart';

class TransactionsPage extends StatelessWidget {
  final List<model.Transaction> transactions;
  final Function(String) onDeleteTransaction;
  final Function(model.Transaction) onEditTransaction;

  const TransactionsPage({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
    required this.onEditTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = groupBy<model.Transaction, String>(
      transactions,
      (tx) => DateFormat('yyyy-MM-dd').format(tx.date),
    );

    return Scaffold(
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                '没有账单记录',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                final date = groupedTransactions.keys.elementAt(index);
                final transactionsOnDate = groupedTransactions[date]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSection(date),
                    ...transactionsOnDate.map((tx) => _buildTransactionItem(context, tx)).toList(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDateSection(String date) {
    String title = date;
    if (date == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      title = '今天';
    } else if (date == DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)))) {
      title = '昨天';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, model.Transaction tx) {
    final color = tx.isExpense ? Colors.red : Colors.green;
    final amountString = '${tx.isExpense ? '-' : '+'} ¥${tx.amount.toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(tx.icon, color: color),
        title: Text(tx.category),
        subtitle: Text(DateFormat('HH:mm').format(tx.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountString,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _confirmDelete(context, tx.id),
            ),
          ],
        ),
        onTap: () => onEditTransaction(tx), // Add this line to handle tap
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('您确定要删除这条账单记录吗？'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('删除'),
            onPressed: () {
              onDeleteTransaction(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
