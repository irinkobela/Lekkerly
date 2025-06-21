// lib/category_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/flashcard_screen.dart';
import 'package:lekkerly/quiz_screen.dart';
import 'package:lekkerly/typing_quiz_screen.dart';
import 'package:lekkerly/vocabulary_list_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;
  final IconData icon;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(icon,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('${category.items.length} words to master',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              LearningModeButton(
                title: 'Word List',
                subtitle: 'Review all words',
                icon: Icons.list_alt_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => VocabularyListScreen(category: category)),
                ),
              ),
              LearningModeButton(
                title: 'Flashcards',
                subtitle: 'Flip and learn',
                icon: Icons.style_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          FlashcardScreen(vocabularyItems: category.items)),
                ),
              ),
              LearningModeButton(
                title: 'Multiple Choice Quiz',
                subtitle: 'Test your knowledge',
                icon: Icons.quiz_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => QuizScreen(category: category)),
                ),
              ),
              LearningModeButton(
                title: 'Typing Quiz (Nl → Eng)',
                subtitle: 'Recall and type the English word',
                icon: Icons.keyboard_alt_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => TypingQuizScreen(
                          category: category,
                          direction: QuizDirection.DutchToEnglish)),
                ),
              ),
              LearningModeButton(
                title: 'Typing Quiz (Eng → Nl)',
                subtitle: 'Recall and type the Dutch word',
                icon: Icons.keyboard_return_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => TypingQuizScreen(
                          category: category,
                          direction: QuizDirection.EnglishToDutch)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const LearningModeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon,
                    size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
