import 'package:flutter/material.dart';
import '../models/theme_model.dart';

class LoadingScreen extends StatefulWidget {
  final String? customLogoAsset;
  
  const LoadingScreen({
    super.key,
    this.customLogoAsset,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final GameTheme _theme = GameTheme.defaultTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: widget.customLogoAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                widget.customLogoAsset!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.text_fields,
                                    color: Colors.white,
                                    size: 50,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.text_fields,
                              color: Colors.white,
                              size: 50,
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'WORDLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



