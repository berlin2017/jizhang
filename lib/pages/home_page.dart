import 'package:flutter/material.dart';
import 'package:jizhang_app/models/transaction.dart' as model;
import 'package:jizhang_app/pages/add_transaction_page.dart'; // 导入添加交易页面
import 'package:jizhang_app/services/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<model.Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper.instance.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  double get _totalIncome => _transactions.where((tx) => !tx.isExpense).fold(0.0, (sum, item) => sum + item.amount);
  double get _totalExpense => _transactions.where((tx) => tx.isExpense).fold(0.0, (sum, item) => sum + item.amount);
  double get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildRecentTransactions(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
          _loadTransactions(); // 从添加交易页面返回后刷新数据
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              '总余额',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '¥${_balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildIncomeExpense('总收入', '¥${_totalIncome.toStringAsFixed(2)}', Colors.blue),
                _buildIncomeExpense('总支出', '¥${_totalExpense.toStringAsFixed(2)}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpense(String title, String amount, Color color) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _transactions.length > 4 ? _transactions.sublist(0, 4) : _transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '近期账单',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        ...recentTransactions.map((tx) => _buildTransactionItem(tx)).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(model.Transaction tx) {
    final color = tx.isExpense ? Colors.red : Colors.green;
    final amountString = '${tx.isExpense ? '-' : '+'} ¥${tx.amount.toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(tx.icon, color: color),
        title: Text(tx.category),
        trailing: Text(
          amountString,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
