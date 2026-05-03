import 'package:flutter/material.dart';

class KeyboardKey extends StatelessWidget {
  final String letter;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double width;

  const KeyboardKey({
    super.key,
    required this.letter,
    required this.onPressed,
    this.backgroundColor,
    this.width = 43,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final isVerySmallScreen = screenWidth < 360 || screenHeight < 700;
    
    // More aggressive sizing for very small screens to prevent overflow
    // Reduced width to 0.60 and increased height/font for better vertical layout
    final keyWidth = isVerySmallScreen ? width * 0.60 : (isSmallScreen ? width * 0.70 : width);
    final keyHeight = isVerySmallScreen ? 48.0 : (isSmallScreen ? 52.0 : 58.0);
    final fontSize = isVerySmallScreen ? 12.0 : (isSmallScreen ? 13.0 : 14.0);
    
    // Default color for unused keys
    final defaultColor = backgroundColor ?? const Color(0xFFD3D6DA);
    final textColor = (backgroundColor != null && 
                       (backgroundColor == const Color(0xFF6AAA64) || 
                        backgroundColor == const Color(0xFFC9B458) ||
                        backgroundColor == const Color(0xFF787C7E)))
        ? Colors.white
        : Colors.black;
    
    // Reduced padding even more
    final keyPadding = isVerySmallScreen ? 1.0 : 3.0;
    
    return Padding(
      padding: EdgeInsets.all(keyPadding),
      child: SizedBox(
        width: keyWidth,
        height: keyHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: defaultColor,
            foregroundColor: textColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class GameKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
  final Map<String, Color> keyColors;

  const GameKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onEnter,
    required this.onBackspace,
    required this.keyColors,
  });

  @override
  Widget build(BuildContext context) {
    final row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    final row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
    final row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];
    
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmallScreen = screenWidth < 360 || screenHeight < 700;
    final row2Offset = isVerySmallScreen ? 10.0 : 21.5;
    final backspaceWidth = isVerySmallScreen ? 50.0 : 75.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Q-P
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row1.map((letter) {
            return KeyboardKey(
              letter: letter,
              onPressed: () => onKeyPressed(letter),
              backgroundColor: keyColors[letter],
            );
          }).toList(),
        ),
        // Row 2: A-L (with offset)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: row2Offset),
            ...row2.map((letter) {
              return KeyboardKey(
                letter: letter,
                onPressed: () => onKeyPressed(letter),
                backgroundColor: keyColors[letter],
              );
            }),
          ],
        ),
        // Row 3: Z-M + Backspace (no ENTER button)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...row3.map((letter) {
              return KeyboardKey(
                letter: letter,
                onPressed: () => onKeyPressed(letter),
                backgroundColor: keyColors[letter],
              );
            }),
            KeyboardKey(
              letter: '⌫',
              onPressed: onBackspace,
              width: backspaceWidth,
              backgroundColor: const Color(0xFF818384),
            ),
          ],
        ),
        // Row 4: ENTER button (full width)
        const SizedBox(height: 4),
        SizedBox(
          width: screenWidth * 0.9,
          child: ElevatedButton(
            onPressed: onEnter,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6AAA64),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isVerySmallScreen ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'SUBMIT',
              style: TextStyle(
                fontSize: isVerySmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
