# Wordle - 5 Tries 1 Word

A beautiful, production-ready Wordle-style mobile game built with Flutter featuring a multi-round word guessing system with full CRUD database capabilities.

## Features

### 🎮 Game Mechanics
- **5 Tries 1 Word**: Guess the word in 5 attempts
- **4-Word Rounds**: Complete 4 words per game session
- **Color-Coded Feedback**:
  - 🟩 Green: Correct letter + correct position
  - 🟦 Blue: Letter exists but wrong position  
  - 🟨 Yellow: Letter not in the word
- **Smart Keyboard**: Visual feedback for guessed letters
- **Smooth Animations**: Beautiful tile transitions and color changes

### 💾 Database Features (CRUD)
- **Words Database**: 
  - Create, Read, Update, Delete words
  - Pre-loaded with 100+ common 5-letter words
- **Game History**: 
  - Track all guesses and attempts
  - Store success/failure status with timestamps
- **User Statistics**:
  - Total games played
  - Win streak tracking
  - Accuracy percentage
  - IQ/Score calculation
- **Offline Storage**: SQLite database for persistent data

### 🎨 User Interface
- Dark blue theme matching modern Wordle designs
- Gift progress indicator showing completed words
- Instructions popup for first-time users
- Success/Failure dialogs with smooth transitions
- Real-time stat updates (IQ, games played)
- Responsive keyboard with rounded buttons

## Project Structure

```
lib/
├── models/
│   ├── letter_model.dart          # Letter status & model
│   ├── word_model.dart            # Word database model
│   ├── game_history_model.dart    # History tracking model
│   ├── user_stats_model.dart      # User statistics model
│   └── app_settings_model.dart    # App settings model
├── services/
│   ├── database_service.dart      # SQLite CRUD operations
│   ├── game_logic.dart            # Word checking logic
│   └── word_service.dart          # Word validation & selection
├── providers/
│   └── game_provider.dart         # State management
├── screens/
│   ├── enhanced_game_screen.dart  # Main game screen
│   └── game_screen.dart           # Legacy screen
├── widgets/
│   ├── game_grid.dart             # Game tile grid
│   ├── keyboard.dart              # On-screen keyboard
│   ├── letter_tile.dart           # Individual letter tile
│   ├── gift_progress.dart         # Progress indicator
│   ├── instructions_popup.dart    # How to play dialog
│   ├── success_popup.dart         # Win dialog
│   └── failed_popup.dart          # Loss dialog
└── main.dart                      # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Wordle/project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For specific device
   flutter devices
   flutter run -d <device-id>
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## How to Play

1. **Start Game**: The game shows instructions on first launch
2. **Guess Words**: Type your 5-letter word guesses
3. **View Feedback**: Tiles change color based on accuracy
4. **Complete 4 Words**: Each game consists of 4 words
5. **Track Progress**: Gift indicators show completion status
6. **View Stats**: Check your IQ score and game history

## Database Operations

### Word Management
The app uses SQLite for offline storage with full CRUD capabilities:

```dart
// Create word
await DatabaseService.instance.createWord(wordModel);

// Read all words
List<WordModel> words = await DatabaseService.instance.getAllWords();

// Update word
await DatabaseService.instance.updateWord(wordModel);

// Delete word
await DatabaseService.instance.deleteWord(wordId);

// Check if word exists
bool exists = await DatabaseService.instance.wordExists(word);
```

### Game History
```dart
// Save game attempt
await DatabaseService.instance.createGameHistory(historyModel);

// Get all history
List<GameHistoryModel> history = await DatabaseService.instance.getAllGameHistory();

// Get history by round
List<GameHistoryModel> roundHistory = 
    await DatabaseService.instance.getGameHistoryByRound(round);
```

### User Statistics
```dart
// Get user stats
UserStatsModel? stats = await DatabaseService.instance.getUserStats();

// Update on win
await DatabaseService.instance.updateStatsOnWin(triesUsed);

// Update on loss
await DatabaseService.instance.updateStatsOnLoss();
```

## Technologies Used

- **Flutter**: UI framework
- **Provider**: State management
- **sqflite**: SQLite database
- **Material Design 3**: UI components

## Color Scheme

- Background: `#121213` (Dark blue)
- Keyboard: `#818384` (Gray)
- Correct: `#6AAA64` (Green)
- Present: `#C9B458` (Yellow)
- Absent: `#787C7E` (Gray)
- Accent: `#2196F3` (Blue)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Future Enhancements

- [ ] Daily challenge mode
- [ ] Multiplayer support
- [ ] Word difficulty levels
- [ ] Custom word lists
- [ ] Share game results
- [ ] Leaderboards
- [ ] Achievements system
- [ ] Sound effects and music

## Troubleshooting

### Database Issues
If you encounter database errors, try clearing the app data or reinstalling:
```bash
flutter clean
flutter pub get
flutter run
```

### Build Issues
For Android build issues:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

For iOS build issues:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## Support

For issues and questions, please open an issue on the repository.

---

**Enjoy playing Wordle! 🎉**
