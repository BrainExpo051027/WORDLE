import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../services/word_service.dart';
import '../services/game_logic.dart';
import '../widgets/game_grid.dart';
import '../widgets/keyboard.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String targetWord;
  late List<List<LetterModel>> grid;
  int currentRow = 0;
  int currentCol = 0;
  bool gameWon = false;
  bool gameLost = false;
  Map<String, Color> keyColors = {};

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    targetWord = WordService.getRandomWord();
    grid = List.generate(
      6,
      (row) => List.generate(
        5,
        (col) => LetterModel(letter: '', status: LetterStatus.empty),
      ),
    );
    currentRow = 0;
    currentCol = 0;
    gameWon = false;
    gameLost = false;
    keyColors = {};
  }

  void _onKeyPressed(String letter) {
    if (gameWon || gameLost) return;
    if (currentCol < 5) {
      setState(() {
        grid[currentRow][currentCol] = LetterModel(
          letter: letter,
          status: LetterStatus.input,
        );
        currentCol++;
      });
    }
  }

  void _onBackspace() {
    if (gameWon || gameLost) return;
    if (currentCol > 0) {
      setState(() {
        currentCol--;
        grid[currentRow][currentCol] = LetterModel(
          letter: '',
          status: LetterStatus.empty,
        );
      });
    }
  }

  void _onEnter() {
    if (gameWon || gameLost) return;
    if (currentCol == 5) {
      String guess = grid[currentRow].map((e) => e.letter).join();

      if (!WordService.isValidWord(guess)) {
        _showMessage('Not in word list');
        return;
      }

      List<LetterModel> result = GameLogic.checkGuess(guess, targetWord);

      setState(() {
        grid[currentRow] = result;

        for (int i = 0; i < 5; i++) {
          String letter = result[i].letter;
          Color newColor;

          switch (result[i].status) {
            case LetterStatus.correct:
              newColor = const Color(0xFF6AAA64);
              break;
            case LetterStatus.present:
              newColor = const Color(0xFFC9B458);
              break;
            case LetterStatus.absent:
              newColor = const Color(0xFF787C7E);
              break;
            default:
              newColor = const Color(0xFFD3D6DA);
          }

          if (!keyColors.containsKey(letter) ||
              (result[i].status == LetterStatus.correct) ||
              (result[i].status == LetterStatus.present &&
                  keyColors[letter] != const Color(0xFF6AAA64))) {
            keyColors[letter] = newColor;
          }
        }
      });

      if (guess == targetWord) {
        setState(() {
          gameWon = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _showMessage('Congratulations! You won!');
        });
      } else if (currentRow == 5) {
        setState(() {
          gameLost = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _showMessage('Game Over! The word was $targetWord');
        });
      } else {
        setState(() {
          currentRow++;
          currentCol = 0;
        });
      }
    } else {
      _showMessage('Not enough letters');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wordle',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFD3D6DA),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: GameGrid(
                grid: grid,
                currentRow: currentRow,
                currentCol: currentCol,
              ),
            ),
          ),
          if (gameWon || gameLost)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6AAA64),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: GameKeyboard(
              onKeyPressed: _onKeyPressed,
              onEnter: _onEnter,
              onBackspace: _onBackspace,
              keyColors: keyColors,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
