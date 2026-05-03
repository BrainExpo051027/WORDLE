class GameHistoryModel {
  final int? id;
  final String word;
  final String guess;
  final int attemptNumber;
  final bool isCorrect;
  final int triesUsed;
  final DateTime timestamp;
  final int round;

  GameHistoryModel({
    this.id,
    required this.word,
    required this.guess,
    required this.attemptNumber,
    required this.isCorrect,
    required this.triesUsed,
    required this.timestamp,
    required this.round,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'guess': guess,
      'attempt_number': attemptNumber,
      'is_correct': isCorrect ? 1 : 0,
      'tries_used': triesUsed,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'round': round,
    };
  }

  factory GameHistoryModel.fromMap(Map<String, dynamic> map) {
    return GameHistoryModel(
      id: map['id'],
      word: map['word'],
      guess: map['guess'],
      attemptNumber: map['attempt_number'],
      isCorrect: map['is_correct'] == 1,
      triesUsed: map['tries_used'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      round: map['round'],
    );
  }
}

