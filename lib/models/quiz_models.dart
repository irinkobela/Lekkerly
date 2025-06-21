// lib/models/quiz_models.dart

import 'dart:math';
import 'package:lekkerly/models/vocabulary_models.dart';

// Defines the types of quiz questions available.
enum QuestionType { multipleChoice, typeAnswer }

// Represents a single option in a multiple-choice question.
class QuizOption {
  final String text;
  final bool isCorrect;

  QuizOption({required this.text, required this.isCorrect});

  @override
  String toString() => 'QuizOption(text: $text, isCorrect: $isCorrect)';
}

// Represents a full quiz question with metadata.
class QuizQuestion {
  final VocabularyItem questionItem;
  final List<QuizOption> options;
  final QuestionType type;

  QuizQuestion({
    required this.questionItem,
    required this.options,
    this.type = QuestionType.multipleChoice,
  });

  // Returns the correct answer text.
  String get correctAnswer => options.firstWhere((o) => o.isCorrect).text;

  // Validates the selected answer.
  bool isCorrect(String selectedText) =>
      options.any((o) => o.text == selectedText && o.isCorrect);

  // Shuffles options randomly (useful for quiz randomization).
  void shuffleOptions() => options.shuffle(Random());

  @override
  String toString() =>
      'QuizQuestion(word: ${questionItem.dutchWord}, correct: $correctAnswer, type: $type)';
}
