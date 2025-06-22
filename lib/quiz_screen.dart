// lib/quiz_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/models/quiz_models.dart';
import 'package:lekkerly/quiz_results_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late List<QuizQuestion> _quizQuestions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _pageFadeController;
  late AnimationController _shakeController; // For wrong answer shake
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _quizQuestions = _generateQuiz(widget.category.items, 10);

    _pageFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // A sine-wave like shake animation
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _pageFadeController.forward();
  }

  @override
  void dispose() {
    _pageFadeController.dispose();
    _shakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<QuizQuestion> _generateQuiz(
    List<VocabularyItem> items,
    int questionCount,
  ) {
    if (items.length < 4) {
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

  void _handleAnswer(int selectedIndex) async {
    if (_isAnswered) return;

    final question = _quizQuestions[_currentQuestionIndex];
    final isCorrect = question.options[selectedIndex].isCorrect;

    final soundPath = isCorrect ? 'sounds/correct.wav' : 'sounds/wrong.wav';
    await _audioPlayer.play(AssetSource(soundPath));

    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      } else {
        // Start the shake animation on wrong answer
        _shakeController.forward(from: 0);
      }
    });
  }

  void _nextQuestion() async {
    await _pageFadeController.reverse();

    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
      _pageFadeController.forward();
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
        opacity: _pageFadeController,
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
                return AnswerButton(
                  option: currentQuestion.options[index],
                  isSelected: _selectedOptionIndex == index,
                  isAnswered: _isAnswered,
                  shakeAnimation: _shakeAnimation,
                  onTap: () => _handleAnswer(index),
                );
              }),
              const Spacer(flex: 2),
              if (_isAnswered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

// NEW WIDGET: A dedicated button for answers to handle its own animations
class AnswerButton extends StatefulWidget {
  final QuizOption option;
  final bool isSelected;
  final bool isAnswered;
  final Animation<double> shakeAnimation;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isAnswered,
    required this.shakeAnimation,
    required this.onTap,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnswered && widget.option.isCorrect) {
      // Pulse the correct answer
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? foregroundColor;
    IconData? iconData;

    if (widget.isAnswered) {
      if (widget.option.isCorrect) {
        backgroundColor = Colors.green.shade600;
        foregroundColor = Colors.white;
        iconData = Icons.check_circle;
      } else if (widget.isSelected) {
        backgroundColor = Colors.red.shade600;
        foregroundColor = Colors.white;
        iconData = Icons.cancel;
      } else {
        backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
      }
    }

    Widget button = ScaleTransition(
      scale: _pulseAnimation,
      child: FilledButton.icon(
        onPressed: widget.onTap,
        icon: iconData != null
            ? Icon(iconData, color: foregroundColor)
            : const SizedBox.shrink(),
        label: Text(
          widget.option.text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );

    // Apply shake animation only to the selected wrong answer
    if (widget.isAnswered && widget.isSelected && !widget.option.isCorrect) {
      return AnimatedBuilder(
        animation: widget.shakeAnimation,
        builder: (context, child) {
          final sineValue = sin(2 * pi * widget.shakeAnimation.value);
          return Transform.translate(
            offset: Offset(sineValue * 10, 0),
            child: child,
          );
        },
        child: button,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: button,
    );
  }
}
