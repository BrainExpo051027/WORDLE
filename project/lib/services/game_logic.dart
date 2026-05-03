import '../models/letter_model.dart';

class GameLogic {
  static List<LetterModel> checkGuess(String guess, String targetWord) {
    List<LetterModel> result = [];
    List<String> targetLetters = targetWord.split('');
    List<String> guessLetters = guess.split('');

    Map<String, int> letterCount = {};
    for (var letter in targetLetters) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
    }

    List<LetterStatus?> statuses = List.filled(5, null);

    for (int i = 0; i < 5; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        statuses[i] = LetterStatus.correct;
        letterCount[guessLetters[i]] = letterCount[guessLetters[i]]! - 1;
      }
    }

    for (int i = 0; i < 5; i++) {
      if (statuses[i] == null) {
        if (letterCount.containsKey(guessLetters[i]) &&
            letterCount[guessLetters[i]]! > 0) {
          statuses[i] = LetterStatus.present;
          letterCount[guessLetters[i]] = letterCount[guessLetters[i]]! - 1;
        } else {
          statuses[i] = LetterStatus.absent;
        }
      }
    }

    for (int i = 0; i < 5; i++) {
      result.add(LetterModel(
        letter: guessLetters[i],
        status: statuses[i]!,
      ));
    }

    return result;
  }

  static bool isWordComplete(String word) {
    return word.length == 5;
  }
}
