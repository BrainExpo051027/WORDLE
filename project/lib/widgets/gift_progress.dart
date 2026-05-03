import 'package:flutter/material.dart';

class GiftProgress extends StatelessWidget {
  final int currentWord;
  final int totalWords;

  const GiftProgress({
    super.key,
    required this.currentWord,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(totalWords, (index) {
          final giftNumber = (index + 1) * 4;
          final isReached = currentWord > index;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isReached
                          ? const Color(0xFFFFD700)
                          : Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isReached
                            ? const Color(0xFFFFD700)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isReached
                        ? const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 30,
                          )
                        : Center(
                            child: Text(
                              '$giftNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Word ${index + 1}',
                    style: TextStyle(
                      color: isReached
                          ? const Color(0xFFFFD700)
                          : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

