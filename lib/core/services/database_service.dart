import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import '../models/transfer_task.dart';

/// Database service for transfer history
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  /// Initialize database
  Future<void> initialize() async {
    if (_database != null) return;

    try {
      // Initialize FFI for Windows
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final dbPath = await getDatabasesPath();
      final dbFile = path.join(dbPath, 'flashdrop.db');

      _database = await openDatabase(
        dbFile,
        version: 1,
        onCreate: _createDatabase,
      );

      debugPrint('✅ [DatabaseService] Database initialized: $dbFile');
    } catch (e) {
      debugPrint('❌ [DatabaseService] Failed to initialize: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transfer_history (
        id TEXT PRIMARY KEY,
        fileName TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        mimeType TEXT NOT NULL,
        direction TEXT NOT NULL,
        status TEXT NOT NULL,
        bytesTransferred INTEGER NOT NULL,
        speed REAL NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        errorMessage TEXT,
        savePath TEXT
      )
    ''');

    debugPrint('✅ [DatabaseService] Database tables created');
  }

  /// Save transfer task to history
  Future<void> saveTransferTask(TransferTask task) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.insert(
        'transfer_history',
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('💾 [DatabaseService] Saved task: ${task.fileMetadata.name}');
    } catch (e) {
      debugPrint('❌ [DatabaseService] Failed to save task: $e');
    }
  }

  /// Get all transfer history
  Future<List<TransferTask>> getTransferHistory() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'transfer_history',
        orderBy: 'startTime DESC',
      );

      return maps.map((map) => TransferTask.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ [DatabaseService] Failed to get history: $e');
      return [];
    }
  }

  /// Get transfer history by direction
  Future<List<TransferTask>> getTransferHistoryByDirection(
    TransferDirection direction,
  ) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'transfer_history',
        where: 'direction = ?',
        whereArgs: [direction.name],
        orderBy: 'startTime DESC',
      );

      return maps.map((map) => TransferTask.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ [DatabaseService] Failed to get history: $e');
      return [];
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.delete('transfer_history');
      debugPrint('🗑️ [DatabaseService] History cleared');
    } catch (e) {
      debugPrint('❌ [DatabaseService] Failed to clear history: $e');
    }
  }

  /// Close database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
