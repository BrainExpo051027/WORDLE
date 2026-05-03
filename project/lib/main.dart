import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/loading_screen.dart';
import 'screens/menu_screen.dart';
import 'services/database_service.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Wordle - 5 Tries 1 Word',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF121213),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start database initialization in background
    try {
      await DatabaseService.instance.database;
      debugPrint('Database initialized successfully');
    } catch (e) {
      debugPrint('Database initialization error: $e');
      // Continue even if database fails
    }
    
    // Wait for minimum loading time (1.5 seconds) regardless of database
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingScreen()
        : const MenuScreen();
  }
}
