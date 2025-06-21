// lib/typing_quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/vocabulary_models.dart';
import 'quiz_results_screen.dart';

// NEW: Enum to define the direction of the quiz
enum QuizDirection { DutchToEnglish, EnglishToDutch }

class TypingQuizScreen extends StatefulWidget {
  final Category category;
  final QuizDirection direction; // NEW: Add direction property

  const TypingQuizScreen({
    super.key,
    required this.category,
    required this.direction, // Make it required
  });

  @override
  State<TypingQuizScreen> createState() => _TypingQuizScreenState();
}

class _TypingQuizScreenState extends State<TypingQuizScreen> {
  late List<VocabularyItem> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool? _isCorrect;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _questions = (List<VocabularyItem>.from(widget.category.items)..shuffle())
        .take(10)
        .toList();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_isAnswered) return;

    final userInput = _textController.text.trim().toLowerCase();

    // UPDATED: Check answer based on quiz direction
    final String correctAnswer;
    if (widget.direction == QuizDirection.DutchToEnglish) {
      correctAnswer =
          _questions[_currentQuestionIndex].englishTranslation.toLowerCase();
    } else {
      correctAnswer = _questions[_currentQuestionIndex].dutchWord.toLowerCase();
    }

    final isCorrect = userInput == correctAnswer;

    final soundPath = isCorrect ? 'sounds/correct.wav' : 'sounds/wrong.wav';
    _audioPlayer.play(AssetSource(soundPath));

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });
    _focusNode.unfocus();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _isCorrect = null;
        _textController.clear();
      });
      _focusNode.requestFocus();
    } else {
      _audioPlayer.play(AssetSource('sounds/endofquiz.wav'));
      if (!mounted) return;

      // UPDATED: Pass a more descriptive category name to results
      final resultsCategoryName =
          '${widget.category.name} (Typing ${widget.direction == QuizDirection.DutchToEnglish ? "Nl → Eng" : "Eng → Nl"})';

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            score: _score,
            totalQuestions: _questions.length,
            categoryName: resultsCategoryName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.category.name} (Typing)')),
        body: const Center(
          child: Text('Not enough words for a typing quiz.',
              style: TextStyle(fontSize: 18)),
        ),
      );
    }

    // UPDATED: Determine texts based on direction
    final bool isDutchToEnglish =
        widget.direction == QuizDirection.DutchToEnglish;
    final currentQuestion = _questions[_currentQuestionIndex];
    final String questionWord = isDutchToEnglish
        ? currentQuestion.dutchWord
        : currentQuestion.englishTranslation;
    final String promptText = isDutchToEnglish
        ? 'What is the English translation for:'
        : 'What is the Dutch translation for:';
    final String appBarTitle =
        '${widget.category.name} (Typing ${isDutchToEnglish ? "Nl → Eng" : "Eng → Nl"})';
    final String correctAnswerText = isDutchToEnglish
        ? currentQuestion.englishTranslation
        : currentQuestion.dutchWord;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade300,
            color: Theme.of(context).colorScheme.primary,
            minHeight: 6,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1),
            Text(
              promptText,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              questionWord,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              autocorrect: false,
              enabled: !_isAnswered,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            const SizedBox(height: 16),
            if (_isAnswered)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _isCorrect! ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isCorrect!
                      ? 'Correct!'
                      : 'Correct answer: $correctAnswerText',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isCorrect!
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            const Spacer(flex: 2),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isAnswered ? _nextQuestion : _checkAnswer,
                child: Text(
                  _isAnswered
                      ? (_currentQuestionIndex < _questions.length - 1
                          ? 'Next'
                          : 'Finish')
                      : 'Check',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
