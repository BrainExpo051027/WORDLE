import 'package:flutter/material.dart';
import '../models/letter_model.dart';

class LetterTile extends StatefulWidget {
  final LetterModel letterModel;
  final bool isShaking;
  final bool isCursor;

  const LetterTile({
    super.key,
    required this.letterModel,
    this.isShaking = false,
    this.isCursor = false,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.letterModel.status) {
      case LetterStatus.correct:
        return const Color(0xFF6AAA64);
      case LetterStatus.present:
        return const Color(0xFFC9B458);
      case LetterStatus.absent:
        return const Color(0xFF787C7E);
      case LetterStatus.input:
        return Colors.white;
      case LetterStatus.empty:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    if (widget.isCursor && widget.letterModel.status == LetterStatus.empty) {
      return const Color(0xFF2196F3); // Blue cursor indicator
    }
    switch (widget.letterModel.status) {
      case LetterStatus.input:
        return const Color(0xFF878A8C);
      case LetterStatus.empty:
        return const Color(0xFFD3D6DA);
      default:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.letterModel.status) {
      case LetterStatus.correct:
      case LetterStatus.present:
      case LetterStatus.absent:
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final borderColor = _getBorderColor();
    final textColor = _getTextColor();
    final hasColor = widget.letterModel.status != LetterStatus.empty &&
                     widget.letterModel.status != LetterStatus.input;

    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final tileSize = isSmallScreen ? 50.0 : 62.0;
    final fontSize = isSmallScreen ? 28.0 : 32.0;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.isShaking ? (_shakeAnimation.value - 0.5) * 10 : 0,
            0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              child: hasColor
                  ? TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Text(widget.letterModel.letter),
                    )
                  : Text(widget.letterModel.letter),
            ),
          ),
        );
      },
    );
  }
}
