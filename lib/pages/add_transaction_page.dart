import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jizhang_app/models/category.dart';
import 'package:jizhang_app/models/transaction.dart' as model;
import 'package:jizhang_app/services/database_helper.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isExpense = true;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = DatabaseHelper.instance.getCategories(isExpense: _isExpense);
    });
  }

  void _submitData(List<Category> categories) async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    final selectedCategory = categories.firstWhere((cat) => cat.id == _selectedCategoryId);

    final newTransaction = model.Transaction(
      id: DateTime.now().toString(),
      amount: enteredAmount,
      categoryId: _selectedCategoryId!,
      category: selectedCategory.name,
      date: _selectedDate,
      isExpense: _isExpense,
    );

    await DatabaseHelper.instance.insertTransaction(newTransaction);
    Navigator.pop(context); // 保存成功后返回上一页
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加交易'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Category>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('请先添加分类'));
            }

            final categories = snapshot.data!;
            if (_selectedCategoryId == null || !categories.any((c) => c.id == _selectedCategoryId)) {
              _selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
            }

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(child: _buildTypeSelector()),
                    const SizedBox(height: 20),
                    _buildAmountField(),
                    const SizedBox(height: 20),
                    _buildCategorySelector(categories),
                    const SizedBox(height: 20),
                    _buildDateField(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitData(categories),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('保 存'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<bool>(
      segments: const <ButtonSegment<bool>>[
        ButtonSegment<bool>(value: true, label: Text('支出')),
        ButtonSegment<bool>(value: false, label: Text('收入')),
      ],
      selected: <bool>{_isExpense},
      onSelectionChanged: (Set<bool> newSelection) {
        setState(() {
          _isExpense = newSelection.first;
          _selectedCategoryId = null; // Reset category selection
          _loadCategories();
        });
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: '金额',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入金额';
        }
        if (double.tryParse(value) == null) {
          return '请输入有效的数字';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: '分类',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: categories.map((Category category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategoryId = newValue;
        });
      },
      validator: (value) => value == null ? '请选择一个分类' : null,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '日期',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

