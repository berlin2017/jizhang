import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:jizhang_app/models/transaction.dart' as model;
import 'package:jizhang_app/models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    // Order is important here: categories must exist before transactions can reference them.
    await _createCategoriesTable(db);
    await _createTransactionsTable(db);
    await _seedCategories(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // For older versions, create categories table and seed it.
      await _createCategoriesTable(db);
      await _seedCategories(db);
    }
    if (oldVersion < 3) {
      // In version 3, we introduced a foreign key to the transactions table.
      // This migration is destructive and will delete existing transactions.
      // A non-destructive migration would be more complex.
      await db.execute('DROP TABLE IF EXISTS transactions');
      await _createTransactionsTable(db);
    }
  }

  Future<void> _createTransactionsTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE transactions ( 
      id $idType, 
      amount $doubleType,
      categoryId $intType,
      date $textType,
      isExpense $boolType,
      notes $textType,
      FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
    )
    ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL UNIQUE';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
    CREATE TABLE categories (
      id $idType,
      name $textType,
      isExpense $boolType
    )
    ''');
  }

  Future<void> _seedCategories(Database db) async {
    final batch = db.batch();
    final List<String> expenseCategories = ['餐饮', '交通', '购物', '娱乐', '其他'];
    final List<String> incomeCategories = ['工资', '理财', '兼职', '其他'];

    for (var cat in expenseCategories) {
      batch.insert('categories', {'name': cat, 'isExpense': 1}, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (var cat in incomeCategories) {
      batch.insert('categories', {'name': cat, 'isExpense': 0}, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit();
  }

  // Category Methods
  Future<List<Category>> getCategories({required bool isExpense}) async {
    final db = await instance.database;
    final maps = await db.query(
      'categories',
      where: 'isExpense = ?',
      whereArgs: [isExpense ? 1 : 0],
      orderBy: 'id',
    );
    return maps.map((json) => Category.fromMap(json)).toList();
  }

  Future<void> insertCategory(Category category) async {
    final db = await instance.database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteCategory(int id) async {
    final db = await instance.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction Methods
  Future<void> insertTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await instance.database;
    // Use a JOIN query to fetch transaction data along with the category name.
    final result = await db.rawQuery('''
      SELECT
        t.id,
        t.amount,
        t.date,
        t.isExpense,
        t.notes,
        t.categoryId,
        c.name as category
      FROM transactions t
      INNER JOIN categories c ON t.categoryId = c.id
      ORDER BY t.date DESC
    ''');

    if (result.isNotEmpty) {
      return result.map((json) => model.Transaction.fromMap(json)).toList();
    } else {
      return [];
    }
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
