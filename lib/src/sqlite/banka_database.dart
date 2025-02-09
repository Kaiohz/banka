import 'package:banka/src/sqlite/model/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BankaDatabase {
  static const String databaseName = 'banka.db';
  static final BankaDatabase instance = BankaDatabase._privateConstructor();

  Database? _database;

  BankaDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<BankaTransaction>> transactions({String? type}) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = type != null
        ? await db.query(
            'transactions',
            where: 'type = ?',
            whereArgs: [type],
          )
        : await db.query('transactions');

    return transactionMaps.map((map) => BankaTransaction(
      id: map['id'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      paymentDate: map['paymentDate'] as int,
      amount: map['amount'] as int,
    )).toList();
  }

  Future<void> insertTransaction(BankaTransaction transaction) async {
    final db = await database;
    db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDog(BankaTransaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(BankaTransaction transaction) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS transactions('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'type TEXT,'
          'category TEXT, '
          'paymentDate INTEGER, '
          'amount INTEGER)',
        );
      },
      version: 1,
    );
  }
}
