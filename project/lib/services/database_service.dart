import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word_model.dart';
import '../models/game_history_model.dart';
import '../models/user_stats_model.dart';
import '../models/app_settings_model.dart';
import '../models/leaderboard_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wordle_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add leaderboard table
      await db.execute('''
        CREATE TABLE leaderboard (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          player_name TEXT NOT NULL,
          words_completed INTEGER NOT NULL,
          score INTEGER NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add per-word time tracking columns
      await db.execute('ALTER TABLE leaderboard ADD COLUMN time1 INTEGER');
      await db.execute('ALTER TABLE leaderboard ADD COLUMN time2 INTEGER');
      await db.execute('ALTER TABLE leaderboard ADD COLUMN time3 INTEGER');
      await db.execute('ALTER TABLE leaderboard ADD COLUMN time4 INTEGER');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      // Words table
      await db.execute('''
        CREATE TABLE words_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL UNIQUE,
          created_at INTEGER NOT NULL,
          updated_at INTEGER
        )
      ''');

      // Game history table
      await db.execute('''
        CREATE TABLE game_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          guess TEXT NOT NULL,
          attempt_number INTEGER NOT NULL,
          is_correct INTEGER NOT NULL,
          tries_used INTEGER NOT NULL,
          timestamp INTEGER NOT NULL,
          round INTEGER NOT NULL
        )
      ''');

      // User stats table
      await db.execute('''
        CREATE TABLE user_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          total_games INTEGER NOT NULL DEFAULT 0,
          games_won INTEGER NOT NULL DEFAULT 0,
          current_win_streak INTEGER NOT NULL DEFAULT 0,
          best_win_streak INTEGER NOT NULL DEFAULT 0,
          accuracy REAL NOT NULL DEFAULT 0.0,
          score INTEGER NOT NULL DEFAULT 0,
          last_played INTEGER
        )
      ''');

      // App settings table
      await db.execute('''
        CREATE TABLE app_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL UNIQUE,
          value TEXT NOT NULL,
          updated_at INTEGER
        )
      ''');

      // Leaderboard table
      await db.execute('''
        CREATE TABLE leaderboard (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          player_name TEXT NOT NULL,
          words_completed INTEGER NOT NULL,
          score INTEGER NOT NULL,
          timestamp INTEGER NOT NULL,
          time1 INTEGER,
          time2 INTEGER,
          time3 INTEGER,
          time4 INTEGER
        )
      ''');

      // Initialize user stats
      await db.insert('user_stats', UserStatsModel(
        totalGames: 0,
        gamesWon: 0,
        currentWinStreak: 0,
        bestWinStreak: 0,
        accuracy: 0.0,
        score: 0,
      ).toMap());

      // Insert initial words using batch for better performance
      final initialWords = [
        'APPLE', 'BRAIN', 'CHAIR', 'DANCE', 'EARTH',
        'FIELD', 'GRACE', 'HAPPY', 'IMAGE', 'JOLLY',
        'KNIFE', 'LAUGH', 'MAGIC', 'NOBLE', 'OCEAN',
        'PEACE', 'QUEEN', 'RIVER', 'SMILE', 'TRUTH',
        'UNITY', 'VOICE', 'WORLD', 'YOUNG', 'ZEBRA',
        'BREAD', 'CLOUD', 'DREAM', 'FLAME', 'GRAND',
        'HEART', 'INPUT', 'JUICE', 'LIGHT', 'MOUNT',
        'NIGHT', 'PIANO', 'QUICK', 'RADIO', 'STONE',
        'TIGER', 'ULTRA', 'VIVID', 'WATCH', 'YACHT',
        'ABOUT', 'ABUSE', 'ACTOR', 'ACUTE', 'ADMIT',
        'ADOPT', 'ADULT', 'AFTER', 'AGAIN', 'AGENT',
        'AGREE', 'AHEAD', 'ALARM', 'ALBUM', 'ALERT',
        'ALIEN', 'ALIVE', 'ALLOW', 'ALONE', 'ALONG',
      ];
      
      // Use batch insert for better performance
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      for (final word in initialWords) {
        batch.insert('words_table', {
          'word': word,
          'created_at': now,
          'updated_at': null,
        });
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      // Log error but don't throw - allow app to continue
      // Database will be created on next access attempt
      print('Error creating database: $e');
      rethrow;
    }
  }

  // ============ WORDS CRUD ============

  Future<int> createWord(WordModel word) async {
    final db = await database;
    return await db.insert('words_table', word.toMap());
  }

  Future<List<WordModel>> getAllWords() async {
    final db = await database;
    final result = await db.query('words_table', orderBy: 'word');
    return result.map((map) => WordModel.fromMap(map)).toList();
  }

  Future<WordModel?> getWordById(int id) async {
    final db = await database;
    final result = await db.query(
      'words_table',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return WordModel.fromMap(result.first);
  }

  Future<WordModel?> getRandomWord() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT * FROM words_table ORDER BY RANDOM() LIMIT 1',
    );
    if (result.isEmpty) return null;
    return WordModel.fromMap(result.first);
  }

  Future<bool> wordExists(String word) async {
    final db = await database;
    final result = await db.query(
      'words_table',
      where: 'word = ?',
      whereArgs: [word.toUpperCase()],
    );
    return result.isNotEmpty;
  }

  Future<int> updateWord(WordModel word) async {
    final db = await database;
    return await db.update(
      'words_table',
      word.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete(
      'words_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ GAME HISTORY CRUD ============

  Future<int> createGameHistory(GameHistoryModel history) async {
    final db = await database;
    return await db.insert('game_history', history.toMap());
  }

  Future<List<GameHistoryModel>> getAllGameHistory() async {
    final db = await database;
    final result = await db.query(
      'game_history',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => GameHistoryModel.fromMap(map)).toList();
  }

  Future<List<GameHistoryModel>> getGameHistoryByRound(int round) async {
    final db = await database;
    final result = await db.query(
      'game_history',
      where: 'round = ?',
      whereArgs: [round],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => GameHistoryModel.fromMap(map)).toList();
  }

  Future<int> deleteGameHistory(int id) async {
    final db = await database;
    return await db.delete(
      'game_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ USER STATS CRUD ============

  Future<UserStatsModel?> getUserStats() async {
    final db = await database;
    final result = await db.query('user_stats', limit: 1);
    if (result.isEmpty) return null;
    return UserStatsModel.fromMap(result.first);
  }

  Future<int> updateUserStats(UserStatsModel stats) async {
    final db = await database;
    return await db.update(
      'user_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  Future<void> updateStatsOnWin(int triesUsed) async {
    final stats = await getUserStats();
    if (stats == null) return;

    final totalGames = stats.totalGames + 1;
    final gamesWon = stats.gamesWon + 1;
    final currentWinStreak = stats.currentWinStreak + 1;
    final bestWinStreak = currentWinStreak > stats.bestWinStreak
        ? currentWinStreak
        : stats.bestWinStreak;
    final accuracy = (gamesWon / totalGames * 100);
    final score = stats.score + (6 - triesUsed) * 10;

    await updateUserStats(UserStatsModel(
      id: stats.id,
      totalGames: totalGames,
      gamesWon: gamesWon,
      currentWinStreak: currentWinStreak,
      bestWinStreak: bestWinStreak,
      accuracy: accuracy,
      score: score,
      lastPlayed: DateTime.now(),
    ));
  }

  Future<void> updateStatsOnLoss() async {
    final stats = await getUserStats();
    if (stats == null) return;

    final totalGames = stats.totalGames + 1;
    final accuracy = (stats.gamesWon / totalGames * 100);

    await updateUserStats(UserStatsModel(
      id: stats.id,
      totalGames: totalGames,
      gamesWon: stats.gamesWon,
      currentWinStreak: 0,
      bestWinStreak: stats.bestWinStreak,
      accuracy: accuracy,
      score: stats.score,
      lastPlayed: DateTime.now(),
    ));
  }

  // ============ APP SETTINGS CRUD ============

  Future<int> createSetting(AppSettingsModel setting) async {
    final db = await database;
    return await db.insert('app_settings', setting.toMap());
  }

  Future<AppSettingsModel?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AppSettingsModel.fromMap(result.first);
  }

  Future<int> updateSetting(AppSettingsModel setting) async {
    final db = await database;
    return await db.update(
      'app_settings',
      setting.toMap(),
      where: 'key = ?',
      whereArgs: [setting.key],
    );
  }

  Future<int> deleteSetting(String key) async {
    final db = await database;
    return await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // ============ UTILITY ============

  Future<void> closeDB() async {
    final db = await database;
    await db.close();
  }

  // ============ LEADERBOARD CRUD ============

  Future<int> addLeaderboardEntry(LeaderboardEntry entry) async {
    final db = await database;
    final map = entry.toMap();
    print('DatabaseService: Inserting leaderboard entry: $map');
    final result = await db.insert('leaderboard', map);
    print('DatabaseService: Insert result ID: $result');
    return result;
  }

  Future<List<LeaderboardEntry>> getLeaderboardByWordsCompleted(int wordsCompleted) async {
    final db = await database;
    print('DatabaseService: Querying leaderboard for wordsCompleted=$wordsCompleted');
    final result = await db.query(
      'leaderboard',
      where: 'words_completed = ?',
      whereArgs: [wordsCompleted],
      orderBy: 'score DESC, timestamp ASC',
      limit: 10,
    );
    print('DatabaseService: Found ${result.length} entries for wordsCompleted=$wordsCompleted');
    if (result.isNotEmpty) {
      print('DatabaseService: First entry: ${result.first}');
    }
    return result.map((map) => LeaderboardEntry.fromMap(map)).toList();
  }

  Future<List<LeaderboardEntry>> getAllLeaderboard() async {
    final db = await database;
    final result = await db.query(
      'leaderboard',
      orderBy: 'words_completed DESC, score DESC',
    );
    return result.map((map) => LeaderboardEntry.fromMap(map)).toList();
  }
}

