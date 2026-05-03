import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import 'letter_tile.dart';

class GameGrid extends StatelessWidget {
  final List<List<LetterModel>> grid;
  final Function(int row, int col)? onTileTap;
  final bool isShaking;
  final int currentRow;
  final int currentCol;

  const GameGrid({
    super.key,
    required this.grid,
    this.onTileTap,
    this.isShaking = false,
    required this.currentRow,
    required this.currentCol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: grid.asMap().entries.map((rowEntry) {
        final row = rowEntry.key;
        final letters = rowEntry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: letters.asMap().entries.map((colEntry) {
              final col = colEntry.key;
              final letterModel = colEntry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: onTileTap != null ? () => onTileTap!(row, col) : null,
                  child: LetterTile(
                    letterModel: letterModel,
                    isShaking: isShaking && row == currentRow,
                    isCursor: row == currentRow && col == currentCol,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
