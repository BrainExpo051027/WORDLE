class LeaderboardEntry {
  final int? id;
  final String playerName;
  final int wordsCompleted;
  final int score;
  final DateTime timestamp;
  final int? time1; // Time in milliseconds for word 1
  final int? time2; // Time in milliseconds for word 2
  final int? time3; // Time in milliseconds for word 3
  final int? time4; // Time in milliseconds for word 4

  LeaderboardEntry({
    this.id,
    required this.playerName,
    required this.wordsCompleted,
    required this.score,
    required this.timestamp,
    this.time1,
    this.time2,
    this.time3,
    this.time4,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'player_name': playerName,
      'words_completed': wordsCompleted,
      'score': score,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (time1 != null) map['time1'] = time1;
    if (time2 != null) map['time2'] = time2;
    if (time3 != null) map['time3'] = time3;
    if (time4 != null) map['time4'] = time4;
    return map;
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      id: map['id'] as int?,
      playerName: map['player_name'] as String,
      wordsCompleted: map['words_completed'] as int,
      score: map['score'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      time1: map['time1'] as int?,
      time2: map['time2'] as int?,
      time3: map['time3'] as int?,
      time4: map['time4'] as int?,
    );
  }
}
