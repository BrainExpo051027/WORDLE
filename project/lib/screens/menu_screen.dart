import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../models/leaderboard_model.dart';
import '../services/database_service.dart';
import 'enhanced_game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  final GameTheme _theme = GameTheme.defaultTheme;
  final DatabaseService _db = DatabaseService.instance;
  int _selectedCategory = 4;
  int _refreshKey = 0;
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLeaderboard();
    }
  }

  void _refreshLeaderboard() {
    if (mounted) {
      setState(() {
        _refreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if route is currently visible and refresh if needed
    final isCurrentlyVisible = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentlyVisible) {
      if (!_wasVisible) {
        // Route just became visible, refresh leaderboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshLeaderboard();
          }
        });
      }
      _wasVisible = true;
    } else {
      _wasVisible = false;
    }
    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Animated Logo - Responsive
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.95, end: 1.05),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                onEnd: () {
                  // Restart animation to create loop
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final logoSize = (screenWidth * 0.35).clamp(100.0, 160.0);
                    
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        _theme.logoAsset,
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          final fontSize = (screenWidth * 0.12).clamp(32.0, 48.0);
                          return Text(
                            'WORDLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Guess the 5-letter word!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Play Button
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedGameScreen(),
                    ),
                  );
                  // Refresh leaderboard when returning from game
                  _refreshLeaderboard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Leaderboard Section
              const Text(
                'LEADERBOARDS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Category Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildCategoryButton('1 Word', 1),
                    const SizedBox(width: 10),
                    _buildCategoryButton('2 Words', 2),
                    const SizedBox(width: 10),
                    _buildCategoryButton('3 Words', 3),
                    const SizedBox(width: 10),
                    _buildCategoryButton('4 Words', 4),
                    const SizedBox(width: 16), // Extra padding at the end
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Leaderboard List
              Expanded(
                child: Container(
                  key: ValueKey(_refreshKey), // Force rebuild when refreshKey changes
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: FutureBuilder<List<LeaderboardEntry>>(
                    key: ValueKey('leaderboard_${_selectedCategory}_$_refreshKey'),
                    future: Future.value(_refreshKey).then((_) => _db.getLeaderboardByWordsCompleted(_selectedCategory)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No entries yet!\nBe the first to complete $_selectedCategory word${_selectedCategory > 1 ? 's' : ''}!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      
                      final entries = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _buildLeaderboardEntry(
                            index + 1,
                            entry.playerName,
                            entry.score,
                            entry.time1,
                            entry.time2,
                            entry.time3,
                            entry.time4,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, int category) {
    final isSelected = _selectedCategory == category;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
          _refreshKey++; // Refresh leaderboard when changing category
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF2196F3)
            : Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmallScreen ? 13 : 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatTime(int? milliseconds) {
    if (milliseconds == null) return '-';
    final seconds = milliseconds / 1000.0;
    return '${seconds.toStringAsFixed(1)}s';
  }

  Widget _buildLeaderboardEntry(
    int rank,
    String name,
    int score,
    int? time1,
    int? time2,
    int? time3,
    int? time4,
  ) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = Colors.white70;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rank <= 3 ? rankColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name and Times
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // Word times
                Row(
                  children: [
                    Text(
                      '1:${_formatTime(time1)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '2:${_formatTime(time2)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '3:${_formatTime(time3)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '4:${_formatTime(time4)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$score pts',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
