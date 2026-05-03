import 'package:flutter/material.dart';

class NameInputDialog extends StatefulWidget {
  final int wordsCompleted;
  final int score;
  final VoidCallback onSaved;

  const NameInputDialog({
    super.key,
    required this.wordsCompleted,
    required this.score,
    required this.onSaved,
  });

  @override
  State<NameInputDialog> createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 60,
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
              'Category: ${widget.wordsCompleted} Word${widget.wordsCompleted > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'You completed ${widget.wordsCompleted} word${widget.wordsCompleted > 1 ? 's' : ''}!',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Score: ${widget.score} points',
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Enter your name for the leaderboard:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              maxLength: 20,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Your Name',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(color: Colors.white38),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSaving ? null : () {
                      Navigator.of(context).pop(null);
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    Navigator.of(context).pop(name);
  }
}
