class UserStatsModel {
  final int? id;
  final int totalGames;
  final int gamesWon;
  final int currentWinStreak;
  final int bestWinStreak;
  final double accuracy;
  final int score;
  final DateTime? lastPlayed;

  UserStatsModel({
    this.id,
    required this.totalGames,
    required this.gamesWon,
    required this.currentWinStreak,
    required this.bestWinStreak,
    required this.accuracy,
    required this.score,
    this.lastPlayed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_games': totalGames,
      'games_won': gamesWon,
      'current_win_streak': currentWinStreak,
      'best_win_streak': bestWinStreak,
      'accuracy': accuracy,
      'score': score,
      'last_played': lastPlayed?.millisecondsSinceEpoch,
    };
  }

  factory UserStatsModel.fromMap(Map<String, dynamic> map) {
    return UserStatsModel(
      id: map['id'],
      totalGames: map['total_games'],
      gamesWon: map['games_won'],
      currentWinStreak: map['current_win_streak'],
      bestWinStreak: map['best_win_streak'],
      accuracy: map['accuracy'],
      score: map['score'],
      lastPlayed: map['last_played'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_played'])
          : null,
    );
  }

  UserStatsModel copyWith({
    int? id,
    int? totalGames,
    int? gamesWon,
    int? currentWinStreak,
    int? bestWinStreak,
    double? accuracy,
    int? score,
    DateTime? lastPlayed,
  }) {
    return UserStatsModel(
      id: id ?? this.id,
      totalGames: totalGames ?? this.totalGames,
      gamesWon: gamesWon ?? this.gamesWon,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      accuracy: accuracy ?? this.accuracy,
      score: score ?? this.score,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}

