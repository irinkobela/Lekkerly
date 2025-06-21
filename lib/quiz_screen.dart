// lib/quiz_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'models/vocabulary_models.dart';
import 'models/quiz_models.dart';
import 'quiz_results_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<QuizQuestion> _quizQuestions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _quizQuestions = _generateQuiz(widget.category.items, 10);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<QuizQuestion> _generateQuiz(
    List<VocabularyItem> items,
    int questionCount,
  ) {
    if (items.length < 4) {
      // Not enough items to generate a meaningful quiz
      return [];
    }

    final random = Random();
    final shuffledItems = List<VocabularyItem>.from(items)..shuffle(random);
    final count = min(questionCount, shuffledItems.length);

    return List<QuizQuestion>.generate(count, (index) {
      final questionItem = shuffledItems[index];
      final wrongOptions = List<VocabularyItem>.from(items)
        ..remove(questionItem)
        ..shuffle(random);

      final options = <QuizOption>[
        QuizOption(text: questionItem.englishTranslation, isCorrect: true),
      ];

      for (var i = 0; i < 3 && i < wrongOptions.length; i++) {
        options.add(
          QuizOption(
            text: wrongOptions[i].englishTranslation,
            isCorrect: false,
          ),
        );
      }
      options.shuffle(random);
      return QuizQuestion(questionItem: questionItem, options: options);
    });
  }

  // UPDATED: This method no longer automatically advances to the next question.
  void _handleAnswer(int selectedIndex) async {
    if (_isAnswered) return;

    final question = _quizQuestions[_currentQuestionIndex];
    final isCorrect = question.options[selectedIndex].isCorrect;

    final soundPath = isCorrect ? 'sounds/correct.wav' : 'sounds/wrong.wav';
    await _audioPlayer.play(AssetSource(soundPath));

    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;
      if (isCorrect) _score++;
    });
  }

  // NEW: This method is called when the user taps the 'Next' button.
  void _nextQuestion() async {
    await _animationController.reverse();

    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
      _animationController.forward();
    } else {
      _audioPlayer.play(AssetSource('sounds/endofquiz.wav'));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => QuizResultsScreen(
            score: _score,
            totalQuestions: _quizQuestions.length,
            categoryName: widget.category.name,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  Color _determineButtonColor(int index, bool isCorrectOption) {
    if (!_isAnswered) return Colors.grey.shade200;
    if (isCorrectOption) return Colors.green.shade600;
    if (_selectedOptionIndex == index) return Colors.red.shade600;
    return Colors.grey.shade300;
  }

  Color _determineTextColor(int index, bool isCorrectOption) {
    if (!_isAnswered) return Colors.black87;
    return Colors.white;
  }

  Icon? _determineIcon(int index, bool isCorrectOption) {
    if (!_isAnswered) {
      return null;
    }
    if (isCorrectOption) {
      return const Icon(Icons.check_circle, color: Colors.white);
    }
    if (_selectedOptionIndex == index) {
      return const Icon(Icons.cancel, color: Colors.white);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.name)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Not enough words in this category to start a quiz. You need at least 4 words.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _quizQuestions.length,
            backgroundColor: Colors.grey.shade300,
            color: Theme.of(context).colorScheme.primary,
            minHeight: 6,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_quizQuestions.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              Text(
                'What is the English translation for:',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currentQuestion.questionItem.dutchWord,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              ...List.generate(currentQuestion.options.length, (index) {
                final option = currentQuestion.options[index];
                final color = _determineButtonColor(index, option.isCorrect);
                final textColor = _determineTextColor(index, option.isCorrect);
                final icon = _determineIcon(index, option.isCorrect);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: FilledButton.icon(
                    onPressed: _isAnswered ? null : () => _handleAnswer(index),
                    icon: icon ?? const SizedBox.shrink(),
                    label: Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                );
              }),
              const Spacer(flex: 2),

              // NEW: The "Next" button, which only appears after answering.
              if (_isAnswered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < _quizQuestions.length - 1
                        ? 'Next Question'
                        : 'Finish Quiz',
                    style: const TextStyle(fontSize: 18),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
