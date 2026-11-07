
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class InventoryStorage {
  InventoryStorage._();

  static final InventoryStorage instance = InventoryStorage._();

  static const String _databaseName = 'universal_inventory.db';
  static const String _tableName = 'app_storage';
  static const String _inventoryKey = 'inventory_snapshot';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$_databaseName';

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            storage_key TEXT PRIMARY KEY,
            storage_value TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<void> saveSnapshot(
    Map<String, dynamic> snapshot,
  ) async {
    final db = await database;

    await db.insert(
      _tableName,
      {
        'storage_key': _inventoryKey,
        'storage_value': jsonEncode(snapshot),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loadSnapshot() async {
    final db = await database;

    final results = await db.query(
      _tableName,
      columns: ['storage_value'],
      where: 'storage_key = ?',
      whereArgs: [_inventoryKey],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final savedValue = results.first['storage_value'];

    if (savedValue is! String || savedValue.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(savedValue);

    if (decoded is! Map) {
      throw const FormatException(
        'Saved inventory data has an invalid format.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<void> clearSnapshot() async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'storage_key = ?',
      whereArgs: [_inventoryKey],
    );
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
