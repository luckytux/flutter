import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'companies.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE companies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT,
            city TEXT,
            province TEXT
          )
        ''');
      },
    );
  }

  // Insert or Replace company data
  Future<void> insertCompany(Map<String, dynamic> company) async {
    try {
      final db = await database;
      await db.insert(
        'companies',
        company,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting company: $e');
    }
  }

  // Update company data
  Future<void> updateCompany(Map<String, dynamic> company) async {
    if (!company.containsKey('id')) {
      throw Exception('ID is required for updating a company');
    }

    try {
      final db = await database;
      await db.update(
        'companies',
        company,
        where: 'id = ?',
        whereArgs: [company['id']],
      );
    } catch (e) {
      throw Exception('Error updating company: $e');
    }
  }

  // Delete a company by ID
  Future<void> deleteCompany(int id) async {
    try {
      final db = await database;
      await db.delete(
        'companies',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting company: $e');
    }
  }

  // Fetch company data by name
  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    try {
      final db = await database;
      return db.query(
        'companies',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
    } catch (e) {
      throw Exception('Error searching companies: $e');
    }
  }

  // Fetch all companies
  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    try {
      final db = await database;
      return db.query('companies');
    } catch (e) {
      throw Exception('Error fetching companies: $e');
    }
  }
}
