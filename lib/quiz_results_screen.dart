// lib/quiz_results_screen.dart

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lekkerly/models/progress_model.dart';
import 'package:lekkerly/services/progress_service.dart';
import 'package:lekkerly/services/achievement_service.dart';

class QuizResultsScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String categoryName;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.categoryName,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  late ConfettiController _confettiController;
  final ProgressService _progressService = ProgressService();
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    final double percentage = widget.totalQuestions > 0
        ? (widget.score / widget.totalQuestions) * 100
        : 0;
    if (percentage >= 80) {
      _confettiController.play();
    }
    _saveAndCheckAchievements();
  }

  void _saveAndCheckAchievements() async {
    // 1. Save progress. This now ALSO updates the streak automatically.
    final progress = Progress(
      categoryName: widget.categoryName,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      timestamp: DateTime.now(),
    );
    await _progressService.saveProgress(progress);

    // 2. Load all progress to check achievements
    final allProgress = await _progressService.loadProgress();
    final newlyUnlocked =
        await _achievementService.checkQuizAchievements(allProgress);

    // 3. Show notifications for new achievements
    if (newlyUnlocked.isNotEmpty && mounted) {
      for (var achievement in newlyUnlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Row(
              children: [
                Icon(achievement.icon, color: Colors.amberAccent),
                const SizedBox(width: 8),
                Text(
                  'Achievement Unlocked: ${achievement.title}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green.shade700;
    if (percentage >= 50) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  IconData getCelebrationIcon(double percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 50) return Icons.sentiment_satisfied_alt;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = widget.totalQuestions > 0
        ? (widget.score / widget.totalQuestions) * 100
        : 0;
    final scoreColor = getScoreColor(percentage);
    final iconData = getCelebrationIcon(percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, size: 72, color: scoreColor),
                  const SizedBox(height: 16),
                  Text(
                    'Great Effort!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'You Scored',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.score} / ${widget.totalQuestions}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                  ),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.replay),
                        label: const Text('Try Again'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 20),
                      FilledButton.icon(
                        icon: const Icon(Icons.list),
                        label: const Text('Back to Categories'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              maxBlastForce: 20,
              minBlastForce: 8,
              particleDrag: 0.05,
              blastDirection: 3.14 / 2,
              canvas: Size(MediaQuery.of(context).size.width, 100),
            ),
          ),
        ],
      ),
    );
  }
}
