import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jizhang_app/models/category.dart';
import 'package:jizhang_app/models/transaction.dart' as model;
import 'package:jizhang_app/services/database_helper.dart';

class EditTransactionPage extends StatefulWidget {
  final model.Transaction transaction;
  final Function(model.Transaction) onUpdateTransaction;

  const EditTransactionPage({
    super.key,
    required this.transaction,
    required this.onUpdateTransaction,
  });

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late bool _isExpense;
  late int _selectedCategoryId;
  late DateTime _selectedDate;

  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _isExpense = widget.transaction.isExpense;
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.date;
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = DatabaseHelper.instance.getCategories(isExpense: _isExpense);
    });
  }

  void _submitData(List<Category> categories) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    final selectedCategory = categories.firstWhere((cat) => cat.id == _selectedCategoryId);

    final updatedTransaction = model.Transaction(
      id: widget.transaction.id,
      amount: enteredAmount,
      categoryId: _selectedCategoryId,
      category: selectedCategory.name,
      date: _selectedDate,
      isExpense: _isExpense,
    );

    widget.onUpdateTransaction(updatedTransaction);
    Navigator.of(context).pop();
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
        title: const Text('编辑账单'),
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('没有可用的分类'));
          }

          final categories = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  _buildTypeSelector(),
                  const SizedBox(height: 20),
                  _buildAmountField(),
                  const SizedBox(height: 20),
                  _buildCategorySelector(categories),
                  const SizedBox(height: 20),
                  _buildDateField(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _submitData(categories),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('保 存'),
                  ),
                ],
              ),
            ),
          );
        },
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
          _selectedCategoryId = -1; // Reset category to force re-selection
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
    // Ensure the selected ID is valid, otherwise default to the first available category
    int? currentSelection = _selectedCategoryId;
    if (!categories.any((c) => c.id == currentSelection)) {
      currentSelection = categories.isNotEmpty ? categories.first.id : null;
      _selectedCategoryId = currentSelection!;
    }

    return DropdownButtonFormField<int>(
      value: currentSelection,
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
          _selectedCategoryId = newValue!;
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
