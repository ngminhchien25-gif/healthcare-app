import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:healthcare_app/medicine.dart';
import 'package:healthcare_app/medicine_category.dart';
import 'package:healthcare_app/paged_result.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    Directory dir = await getApplicationSupportDirectory();
    String path = p.join(dir.path, 'healthcare.db');
    debugPrint('SQLite: $path');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE MedicineCategory ('
          'medicineCategoryId INTEGER PRIMARY KEY, '
          'medicineCategoryName TEXT NOT NULL, '
          'description TEXT, '
          'icon TEXT)',
        );
        await db.execute(
          'CREATE TABLE Medicine ('
          'medicineId INTEGER PRIMARY KEY, '
          'medicineCategoryId INTEGER NOT NULL, '
          'medicineName TEXT NOT NULL, '
          'imageUrl TEXT, '
          'unit TEXT NOT NULL, '
          'description TEXT, '
          'precaution TEXT, '
          'createdAt TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  // ===== Nhóm thuốc =====
  static Future<void> saveCategories(List<MedicineCategory> list) async {
    Database db = await _open();
    await db.transaction((txn) async {
      await txn.delete('MedicineCategory');
      for (var c in list) {
        await txn.insert(
          'MedicineCategory',
          c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<List<MedicineCategory>> getCategories() async {
    Database db = await _open();
    var rows = await db.query(
      'MedicineCategory',
      orderBy: 'medicineCategoryName',
    );
    return rows.map((r) => MedicineCategory.fromMap(r)).toList();
  }

  // ===== Thuốc =====
  static Future<void> saveMedicines(List<Medicine> list) async {
    Database db = await _open();
    await db.transaction((txn) async {
      for (var m in list) {
        await txn.insert(
          'Medicine',
          m.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<Medicine?> getMedicine(int id) async {
    Database db = await _open();
    var rows = await db.query(
      'Medicine',
      where: 'medicineId = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Medicine.fromMap(rows.first);
  }

  static Future<PagedResult<Medicine>> getMedicines(
    int? categoryId,
    String keyword,
    int page,
    int pageSize,
  ) async {
    Database db = await _open();
    List<String> conditions = [];
    List<Object?> args = [];
    if (categoryId != null) {
      conditions.add('medicineCategoryId = ?');
      args.add(categoryId);
    }
    if (keyword.isNotEmpty) {
      conditions.add('(medicineName LIKE ? OR description LIKE ?)');
      args.add('%$keyword%');
      args.add('%$keyword%');
    }
    String where = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';
    int total =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Medicine $where', args),
        ) ??
        0;
    var rows = await db.rawQuery(
      'SELECT * FROM Medicine $where ORDER BY createdAt DESC, medicineId DESC LIMIT ? OFFSET ?',
      [...args, pageSize, (page - 1) * pageSize],
    );
    return PagedResult<Medicine>(
      items: rows.map((r) => Medicine.fromMap(r)).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
      totalPages: (total / pageSize).ceil(),
    );
  }
}
