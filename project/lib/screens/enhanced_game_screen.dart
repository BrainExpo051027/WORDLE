import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/keyboard.dart';
import '../widgets/word_path_progress.dart';
import '../widgets/instructions_popup.dart';
import '../widgets/success_popup.dart';
import '../widgets/failed_popup.dart';
import '../widgets/name_input_dialog.dart';
import '../models/theme_model.dart';
import '../models/leaderboard_model.dart';
import '../services/database_service.dart';

class EnhancedGameScreen extends StatefulWidget {
  const EnhancedGameScreen({super.key});

  @override
  State<EnhancedGameScreen> createState() => _EnhancedGameScreenState();
}

class _EnhancedGameScreenState extends State<EnhancedGameScreen> {
  bool _showInstructions = false;
  final GameTheme _theme = GameTheme.defaultTheme;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Show instructions on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showInstructions = true;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleEnter() async {
    final game = context.read<GameProvider>();
    await game.onEnter();
    
    if (game.lastMessage != null) {
      _showSnackBar(game.lastMessage!);
    }

    if (game.gameWon || game.gameLost) {
      // Trigger confetti for win
      if (game.gameWon) {
        _confettiController.play();
      }
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        _showGameResultDialog();
      }
    }
  }

  void _showGameResultDialog() {
    if (!mounted) return;
    
    final game = context.read<GameProvider>();
    final bool isLastRound = game.currentRound == game.totalRounds;
    final navigator = Navigator.of(context);
    
    // Helper function to safely show snackbar
    void showSafeSnackBar(String message, {bool isError = false}) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    // Helper function to safely navigate
    Future<void> navigateToMenu() async {
      if (!mounted) return;
      navigator.popUntil((route) => route.isFirst);
    }
    
    if (game.gameWon) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => SuccessPopup(
          tries: game.currentRow + 1,
          onQuitAndSave: () async {
            // User chose to quit and save to leaderboard
            final String? playerName = await showDialog<String>(
              context: dialogContext,
              barrierDismissible: false,
              builder: (context) => NameInputDialog(
                wordsCompleted: game.currentRound,
                score: game.score,
                onSaved: () {},
              ),
            );
            
              if (playerName != null && playerName.trim().isNotEmpty) {
                try {
                  // Save to leaderboard
                  final entry = LeaderboardEntry(
                    playerName: playerName.trim(),
                    wordsCompleted: game.currentRound,
                    score: game.score,
                    timestamp: DateTime.now(),
                    time1: game.wordTimes[0],
                    time2: game.wordTimes[1],
                    time3: game.wordTimes[2],
                    time4: game.wordTimes[3],
                  );
                  final result = await DatabaseService.instance.addLeaderboardEntry(entry);
                  
                  if (mounted) {
                    if (result > 0) {
                      showSafeSnackBar('Saved to leaderboard!');
                    } else {
                      showSafeSnackBar('Failed to save to leaderboard. Please try again.', isError: true);
                    }
                    
                    // Navigate back to menu after short delay
                    await Future.delayed(const Duration(milliseconds: 500));
                    await navigateToMenu();
                  }
                } catch (e) {
                  if (mounted) {
                    showSafeSnackBar('Error saving to leaderboard: $e', isError: true);
                  }
                }
              } else {
                // User skipped, navigate back to menu
                await navigateToMenu();
              }
          },
          onNextRound: () async {
            if (isLastRound) {
              // SuccessPopup already closed itself, now show name input dialog
              // Use currentRound which should be 4 when all words are completed
              final wordsCompleted = game.currentRound;
              debugPrint('Game completed: currentRound=$wordsCompleted, totalRounds=${game.totalRounds}');
              
              final String? playerName = await showDialog<String>(
                context: dialogContext,
                barrierDismissible: false,
                builder: (context) => NameInputDialog(
                  wordsCompleted: wordsCompleted,
                  score: game.score,
                  onSaved: () {},
                ),
              );
              
              if (playerName != null && playerName.trim().isNotEmpty) {
                try {
                  // Save to leaderboard
                  final entry = LeaderboardEntry(
                    playerName: playerName.trim(),
                    wordsCompleted: wordsCompleted,
                    score: game.score,
                    timestamp: DateTime.now(),
                    time1: game.wordTimes[0],
                    time2: game.wordTimes[1],
                    time3: game.wordTimes[2],
                    time4: game.wordTimes[3],
                  );
                  
                  debugPrint('Saving leaderboard entry: name=${entry.playerName}, wordsCompleted=$wordsCompleted, score=${entry.score}');
                  
                  final result = await DatabaseService.instance.addLeaderboardEntry(entry);
                  
                  debugPrint('Database insert result: $result');
                  
                  if (mounted) {
                    if (result > 0) {
                      showSafeSnackBar('Saved to leaderboard! (Category: $wordsCompleted word${wordsCompleted > 1 ? 's' : ''})');
                      
                      // Give time for the snackbar to show, then navigate
                      await Future.delayed(const Duration(milliseconds: 1500));
                    } else {
                      showSafeSnackBar('Failed to save to leaderboard. Please try again.', isError: true);
                      await Future.delayed(const Duration(milliseconds: 1000));
                    }
                    
                    // Navigate back to menu
                    await navigateToMenu();
                  }
                } catch (e, stackTrace) {
                  debugPrint('Error saving to leaderboard: $e');
                  debugPrint('Stack trace: $stackTrace');
                  if (mounted) {
                    showSafeSnackBar('Error saving to leaderboard: $e', isError: true);
                    await Future.delayed(const Duration(milliseconds: 1000));
                    await navigateToMenu();
                  }
                }
              } else {
                // User skipped, navigate back to menu
                await navigateToMenu();
              }
            } else if (game.canStartNextRound) {
              game.startNextRound();
            } else {
              // Can't continue, navigate back to menu
              await navigateToMenu();
            }
          },
          isLastRound: isLastRound,
        ),
      );
    } else if (game.gameLost) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => FailedPopup(
          correctWord: game.roundWords[game.currentRound - 1],
          onNextRound: () async {
            // When you lose a word, you can't continue. Go back to menu.
            // Save game data before resetting
            final completedRounds = game.roundResults.where((r) => r).length;
            final savedScore = game.score;
            final savedTime1 = game.wordTimes[0];
            final savedTime2 = game.wordTimes[1];
            final savedTime3 = game.wordTimes[2];
            final savedTime4 = game.wordTimes[3];
            
            if (completedRounds > 0) {
              // Player completed at least one word, offer to save to leaderboard
              Navigator.pop(dialogContext); // Close failed popup
              final String? playerName = await showDialog<String>(
                context: dialogContext,
                barrierDismissible: false,
                builder: (context) => NameInputDialog(
                  wordsCompleted: completedRounds,
                  score: savedScore,
                  onSaved: () {},
                ),
              );
              
              if (playerName != null && playerName.trim().isNotEmpty) {
                try {
                  // Save to leaderboard
                  final entry = LeaderboardEntry(
                    playerName: playerName.trim(),
                    wordsCompleted: completedRounds,
                    score: savedScore,
                    timestamp: DateTime.now(),
                    time1: savedTime1,
                    time2: savedTime2,
                    time3: savedTime3,
                    time4: savedTime4,
                  );
                  final result = await DatabaseService.instance.addLeaderboardEntry(entry);
                  
                  if (mounted) {
                    if (result > 0) {
                      showSafeSnackBar('Saved to leaderboard!');
                    } else {
                      showSafeSnackBar('Failed to save to leaderboard. Please try again.', isError: true);
                    }
                    
                    // Navigate back to menu after short delay
                    await Future.delayed(const Duration(milliseconds: 500));
                    game.resetGame(); // Reset game state
                    await navigateToMenu();
                  }
                } catch (e) {
                  if (mounted) {
                    showSafeSnackBar('Error saving to leaderboard: $e', isError: true);
                    await Future.delayed(const Duration(milliseconds: 500));
                    game.resetGame(); // Reset game state
                    await navigateToMenu();
                  }
                }
              } else {
                // User skipped, navigate back to menu
                game.resetGame(); // Reset game state
                await navigateToMenu();
              }
            } else {
              // No rounds completed, just exit to menu
              Navigator.pop(dialogContext); // Close failed popup
              game.resetGame(); // Reset game state
              await navigateToMenu();
            }
          },
          isLastRound: isLastRound,
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade300,
      ),
    );
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const InstructionsPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive spacing based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final verticalSpacing = isSmallScreen ? 4.0 : 16.0;
    final topPadding = isSmallScreen ? 2.0 : 8.0;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _theme.backgroundColor,
              image: _theme.backgroundImageAsset != null
                  ? DecorationImage(
                      image: AssetImage(_theme.backgroundImageAsset!),
                      fit: BoxFit.cover,
                      opacity: 0.8,
                    )
                  : null,
            ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, child) {
              if (_showInstructions) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _showInstructions = false;
                  });
                  _showInstructionsDialog();
                });
              }

              return Column(
                children: [
                  // Header with stats and instructions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: topPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1E3A5F),
                                title: const Text(
                                  'Exit Game?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Your current progress will be lost. Are you sure?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Exit game
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Exit'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        // Stats
                        if (game.userStats != null)
                          Row(
                            children: [
                              _buildStatItem('IQ', '${game.userStats!.score}'),
                              const SizedBox(width: 16),
                              _buildStatItem('${game.userStats!.totalGames}', 'games'),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                        
                        // Help button
                        IconButton(
                          icon: const Icon(Icons.help_outline, color: Colors.white),
                          onPressed: _showInstructionsDialog,
                        ),
                      ],
                    ),
                  ),
                  
                  // Word counter
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Word ${game.currentRound}/${game.totalRounds}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: verticalSpacing),
                  
                  // Word path progress
                  WordPathProgress(
                    currentWord: game.currentRound,
                    totalWords: game.totalRounds,
                  ),
                  
                  SizedBox(height: verticalSpacing),
                  
                  // Game grid - scrollable area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: GameGrid(
                          grid: game.grid,
                          onTileTap: game.onTileTap,
                          isShaking: game.isShaking,
                          currentRow: game.currentRow,
                          currentCol: game.currentCol,
                        ),
                      ),
                    ),
                  ),
                  
                  // Keyboard - stays at bottom
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 2.0 : 8.0,
                      vertical: isSmallScreen ? 0.0 : 8.0,
                    ),
                    child: GameKeyboard(
                      onKeyPressed: game.onKeyPressed,
                      onEnter: _handleEnter,
                      onBackspace: game.onBackspace,
                      keyColors: game.keyColors,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 2.0 : 10.0),
                ],
              );
            },
          ),
        ),
      ),
          
          // Confetti widget overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              numberOfParticles: 30,
              gravity: 0.3,
            ),
          ),
          
          // Mocking overlay - Responsive for all screen sizes
          Consumer<GameProvider>(
            builder: (context, game, _) {
              if (!game.showMockOverlay) return const SizedBox.shrink();
              
              final images = [
                'assets/images/image1.png',
                'assets/images/image2.png',
                'assets/images/image3.png',
              ];
              
              // Get screen dimensions for responsive layout
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              
              // Scale sizes based on screen width
              final imageSize = (screenWidth * 0.15).clamp(50.0, 80.0);
              final maxTextWidth = (screenWidth * 0.4).clamp(120.0, 200.0);
              final fontSize = (screenWidth * 0.04).clamp(12.0, 16.0);
              final padding = (screenWidth * 0.03).clamp(8.0, 16.0);
              
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                left: game.mockFromLeft ? (game.showMockOverlay ? 0 : -screenWidth) : null,
                right: !game.mockFromLeft ? (game.showMockOverlay ? 0 : -screenWidth) : null,
                top: screenHeight * 0.4,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.85, // Never exceed 85% of screen width
                  ),
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    margin: EdgeInsets.only(
                      left: game.mockFromLeft ? 8 : 16,
                      right: !game.mockFromLeft ? 8 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (game.mockFromLeft) ...[
                          Image.asset(
                            images[game.mockImageIndex],
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.sentiment_dissatisfied,
                              color: Colors.red,
                              size: imageSize,
                            ),
                          ),
                          SizedBox(width: padding * 0.75),
                        ],
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: maxTextWidth),
                            child: Text(
                              game.mockPhrase,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        if (!game.mockFromLeft) ...[
                          SizedBox(width: padding * 0.75),
                          Image.asset(
                            images[game.mockImageIndex],
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.sentiment_dissatisfied,
                              color: Colors.red,
                              size: imageSize,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

