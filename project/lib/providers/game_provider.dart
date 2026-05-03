import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../models/user_stats_model.dart';
import '../models/game_history_model.dart';
import '../services/game_logic.dart';
import '../services/database_service.dart';
import '../services/word_service.dart';

class GameProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  // Game state
  List<List<LetterModel>> grid = [];
  int currentRow = 0;
  int currentCol = 0;
  bool gameWon = false;
  bool gameLost = false;
  Map<String, Color> keyColors = {};
  bool isShaking = false;
  
  // Per-word timing (milliseconds)
  DateTime? _currentWordStartTime;
  final List<int?> wordTimes = [null, null, null, null];
  
  // Mocking overlay system
  bool showMockOverlay = false;
  bool mockFromLeft = true;
  String mockPhrase = '';
  int mockImageIndex = 0;
  int consecutiveWrongGuesses = 0;
  
  // 5-word rounds system
  int currentRound = 1;
  int totalRounds = 4;
  List<String> roundWords = [];
  List<bool> roundResults = [];
  int score = 0;

  // User stats
  UserStatsModel? userStats;

  GameProvider() {
    _initializeGame();
    _loadUserStats();
    _currentWordStartTime = DateTime.now();
  }

  void _initializeGame() {
    // Initialize grid for 5 attempts
    grid = List.generate(
      5,
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
    isShaking = false;
    currentRound = 1;
    roundWords = [];
    roundResults = [];
    score = 0;
    // Reset all word times
    for (int i = 0; i < wordTimes.length; i++) {
      wordTimes[i] = null;
    }
    _generateRoundWords();
    _currentWordStartTime = DateTime.now();
    consecutiveWrongGuesses = 0;
    showMockOverlay = false;
  }

  void _generateRoundWords() {
    roundWords.clear();
    for (int i = 0; i < totalRounds; i++) {
      roundWords.add(WordService.getRandomWord().toUpperCase());
    }
  }

  Future<void> _loadUserStats() async {
    userStats = await _db.getUserStats();
    notifyListeners();
  }

  void onKeyPressed(String letter) {
    if (gameWon || gameLost) return;
    
    // Always find the first empty position to ensure no gaps
    int targetCol = -1;
    for (int i = 0; i < 5; i++) {
      if (grid[currentRow][i].letter.isEmpty) {
        targetCol = i;
        break;
      }
    }
    
    // If all positions filled, replace the last one
    if (targetCol == -1) {
      targetCol = 4;
    }
    
    // Place letter at target column
    if (targetCol < 5) {
      grid[currentRow][targetCol] = LetterModel(
        letter: letter,
        status: LetterStatus.input,
      );
      
      // Move cursor to next empty position or end
      // After inserting, check if row is complete and set cursor accordingly
      if (_isRowComplete()) {
        // All positions filled, set cursor to end
        currentCol = 5;
      } else {
        // Move cursor to next empty position or stay at inserted position + 1
        currentCol = targetCol + 1;
        if (currentCol >= 5) {
          currentCol = 5;
        }
      }
      
      notifyListeners();
    }
  }

  void onBackspace() {
    if (gameWon || gameLost) return;
    if (currentCol > 0) {
      currentCol--;
      grid[currentRow][currentCol] = LetterModel(
        letter: '',
        status: LetterStatus.empty,
      );
      notifyListeners();
    }
  }

  void onTileTap(int row, int col) {
    // Only allow tapping on current row
    if (gameWon || gameLost || row != currentRow) return;
    
    // If tapping on a filled tile, remove it and set cursor to that position
    if (grid[row][col].letter.isNotEmpty) {
      grid[row][col] = LetterModel(
        letter: '',
        status: LetterStatus.empty,
      );
      currentCol = col; // Set cursor to the removed position
      notifyListeners();
      return;
    }
    
    // If tapping on an empty tile, move cursor there
    currentCol = col;
    notifyListeners();
  }

  String? _lastMessage;

  String? get lastMessage => _lastMessage;

  bool _isRowComplete() {
    // Check if all 5 positions in the current row are filled
    for (int i = 0; i < 5; i++) {
      if (grid[currentRow][i].letter.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> onEnter() async {
    _lastMessage = null;
    if (gameWon || gameLost) return;
    // Check if all 5 positions are filled, not just if cursor is at position 5
    if (_isRowComplete()) {
      String guess = grid[currentRow].map((e) => e.letter).join();

      if (!WordService.isValidWord(guess)) {
        _lastMessage = 'Not in word list';
        isShaking = true;
        notifyListeners();
        
        // Stop shaking after animation
        Future.delayed(const Duration(milliseconds: 500), () {
          isShaking = false;
          notifyListeners();
        });
        return;
      }

      String currentWord = roundWords[currentRound - 1];
      List<LetterModel> result = GameLogic.checkGuess(guess, currentWord);

      grid[currentRow] = result;

      // Update keyboard colors
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

      // Save game history in background (non-blocking)
      _db.createGameHistory(GameHistoryModel(
        word: currentWord,
        guess: guess,
        attemptNumber: currentRow + 1,
        isCorrect: guess == currentWord,
        triesUsed: currentRow + 1,
        timestamp: DateTime.now(),
        round: currentRound,
      )).then((_) => null).catchError((error) {
        // Silently handle errors, game continues
        return null;
      });

      if (guess == currentWord) {
        gameWon = true;
        roundResults.add(true);
        score += (5 - currentRow) * 10;
        
        // Record time for this word
        if (_currentWordStartTime != null) {
          final duration = DateTime.now().difference(_currentWordStartTime!).inMilliseconds;
          final idx = currentRound - 1;
          if (idx >= 0 && idx < wordTimes.length) {
            wordTimes[idx] = duration;
          }
        }
        
        consecutiveWrongGuesses = 0; // Reset on win
        // Update stats in background (non-blocking)
        _db.updateStatsOnWin(currentRow + 1).then((_) => _loadUserStats());
        _lastMessage = 'Win';
      } else if (currentRow == 4) {
        gameLost = true;
        roundResults.add(false);
        // Update stats in background (non-blocking)
        _db.updateStatsOnLoss().then((_) => _loadUserStats());
        _lastMessage = 'Loss';
        _showMockingOverlay();
      } else {
        currentRow++;
        currentCol = 0;
        _showMockingOverlay();
      }
      notifyListeners();
    } else {
      _lastMessage = 'Not enough letters';
      isShaking = true;
      notifyListeners();
      
      // Stop shaking after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        isShaking = false;
        notifyListeners();
      });
    }
  }

  Future<void> startNextRound() async {
    if (currentRound < totalRounds) {
      currentRound++;
      // Reset grid for new round
      grid = List.generate(
        5,
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
      isShaking = false;
      _currentWordStartTime = DateTime.now();
      consecutiveWrongGuesses = 0;
      showMockOverlay = false;
      notifyListeners();
    }
  }

  void resetGame() {
    _initializeGame();
    notifyListeners();
  }

  bool get canStartNextRound => currentRound < totalRounds && gameWon; // Only proceed if won
  
  bool get hasCompletedAllRounds => currentRound == totalRounds && (gameWon || gameLost);
  
  void _showMockingOverlay() {
    consecutiveWrongGuesses++;
    mockFromLeft = consecutiveWrongGuesses % 2 == 1;
    mockImageIndex = (consecutiveWrongGuesses - 1) % 3; // Cycle through 0, 1, 2
    
    // Cycle through phrases
    final phrases = [
      'Nice try... but nope! 😏',
      'Pataka ra',
      'Maybe think harder?',
      'Bobo,amp!',
      'Ano na!!? 😅',
    ];
    mockPhrase = phrases[consecutiveWrongGuesses % phrases.length];
    
    showMockOverlay = true;
    notifyListeners();
    
    // Hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      showMockOverlay = false;
      notifyListeners();
    });
  }
}

