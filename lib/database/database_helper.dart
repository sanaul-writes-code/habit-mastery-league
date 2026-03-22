import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_mastery_league.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        target_frequency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completed_date TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE(habit_id, completed_date)
      )
    ''');
  }

  // CRUD methods for habits and habit logs
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertHabitLog(HabitLog log) async {
    final db = await database;
    return await db.insert(
      'habit_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_date DESC',
    );
    return maps.map((map) => HabitLog.fromMap(map)).toList();
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;

    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND completed_date = ?',
      whereArgs: [habitId, today],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> markHabitCompletedToday(int habitId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;

    await db.insert('habit_logs', {
      'habit_id': habitId,
      'completed_date': today,
      'status': 1,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> getHabitStreak(int habitId) async {
    final logs = await getLogsForHabit(habitId);

    if (logs.isEmpty) return 0;

    final completedDates = logs
        .where((log) => log.status)
        .map(
          (log) => DateTime(
            log.completedDate.year,
            log.completedDate.month,
            log.completedDate.day,
          ),
        )
        .toList();

    completedDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    for (final date in completedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (normalizedDate == currentDate ||
          normalizedDate == currentDate.subtract(Duration(days: streak))) {
        streak++;
      } else if (normalizedDate.isBefore(
        currentDate.subtract(Duration(days: streak)),
      )) {
        break;
      }
    }

    return streak;
  }

  Future<int> getTotalCompletedCount(int habitId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM habit_logs
      WHERE habit_id = ? AND status = 1
      ''',
      [habitId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
