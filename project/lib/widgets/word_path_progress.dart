import 'package:flutter/material.dart';

class WordPathProgress extends StatelessWidget {
  final int currentWord;
  final int totalWords;

  const WordPathProgress({
    super.key,
    required this.currentWord,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalWords, (index) {
          final wordNumber = index + 1;
          final isCompleted = wordNumber < currentWord;
          final isCurrent = wordNumber == currentWord;
          
          return Row(
            children: [
              // Word indicator circle
              _buildWordIndicator(
                wordNumber: wordNumber,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              ),
              
              // Path line (don't show after last word)
              if (index < totalWords - 1)
                _buildPathLine(isCompleted: isCompleted),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWordIndicator({
    required int wordNumber,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (isCompleted) {
      backgroundColor = const Color(0xFF6AAA64); // Green for completed
      borderColor = const Color(0xFF6AAA64);
      textColor = Colors.white;
      icon = Icons.check;
    } else if (isCurrent) {
      backgroundColor = const Color(0xFF2196F3); // Blue for current
      borderColor = const Color(0xFF2196F3);
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white.withOpacity(0.2);
      borderColor = Colors.white.withOpacity(0.4);
      textColor = Colors.white70;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: textColor, size: 28)
            : Text(
                '$wordNumber',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildPathLine({required bool isCompleted}) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF6AAA64)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
