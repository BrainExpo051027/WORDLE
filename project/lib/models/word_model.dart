class WordModel {
  final int? id;
  final String word;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WordModel({
    this.id,
    required this.word,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  WordModel copyWith({
    int? id,
    String? word,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

