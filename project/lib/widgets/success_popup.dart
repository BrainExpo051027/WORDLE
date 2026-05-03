import 'package:flutter/material.dart';

class SuccessPopup extends StatelessWidget {
  final int tries;
  final VoidCallback onNextRound;
  final VoidCallback? onQuitAndSave;
  final bool isLastRound;

  const SuccessPopup({
    super.key,
    required this.tries,
    required this.onNextRound,
    this.onQuitAndSave,
    this.isLastRound = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Congratulations!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Word guessed in $tries tries',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            if (!isLastRound)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNextRound();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue to Next Word',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onQuitAndSave != null) {
                        onQuitAndSave!();
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      minimumSize: const Size(200, 48),
                    ),
                    child: const Text(
                      'Quit & Save to Leaderboard',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNextRound();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Finish Game',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

