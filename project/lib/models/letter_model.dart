enum LetterStatus {
  empty,
  correct,
  present,
  absent,
  input,
}

class LetterModel {
  final String letter;
  final LetterStatus status;

  LetterModel({
    required this.letter,
    required this.status,
  });

  LetterModel copyWith({
    String? letter,
    LetterStatus? status,
  }) {
    return LetterModel(
      letter: letter ?? this.letter,
      status: status ?? this.status,
    );
  }
}
