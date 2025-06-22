// lib/flashcard_screen.dart

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/services/cloud_tts_service.dart'; // IMPORT the new Cloud TTS service
import 'dart:math';

class FlashcardScreen extends StatefulWidget {
  final List<VocabularyItem> vocabularyItems;

  const FlashcardScreen({super.key, required this.vocabularyItems});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final PageController _controller = PageController();
  // NEW: Instantiate our CloudTtsService
  final CloudTtsService _cloudTtsService = CloudTtsService();
  late List<VocabularyItem> _shuffledItems;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _shuffledItems = List.from(widget.vocabularyItems);
    _shuffleCards();
    // We no longer need to initialize TTS here as the new service handles it.
  }

  void _shuffleCards() {
    setState(() {
      _shuffledItems.shuffle(Random());
      _currentIndex = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    });
  }

  // UPDATED: The speak function now uses our cloud service
  Future<void> _speak(String text) async {
    // This now calls the Google Cloud API
    await _cloudTtsService.speak(text);
  }

  @override
  void dispose() {
    // Dispose of our service's resources
    _cloudTtsService.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (_currentIndex < _shuffledItems.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleCards,
            tooltip: 'Shuffle Cards',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_shuffledItems.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No vocabulary items in this category.'),
              ),
            )
          else
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _shuffledItems.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = _shuffledItems[index];
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FlipCard(
                        front: FlashcardView(
                          text: item.dutchWord,
                          phonetic: item.phonetic,
                          onSpeak: () => _speak(item.dutchWord),
                        ),
                        back: FlashcardView(
                          text: item.englishTranslation,
                          isFront: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_shuffledItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filled(
                    iconSize: 32,
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${_shuffledItems.length}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton.filled(
                    iconSize: 32,
                    onPressed: _currentIndex < _shuffledItems.length - 1
                        ? _nextCard
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FlashcardView extends StatelessWidget {
  final String text;
  final String? phonetic;
  final bool isFront;
  final VoidCallback? onSpeak;

  const FlashcardView({
    super.key,
    required this.text,
    this.phonetic,
    this.isFront = true,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isFront
          ? Theme.of(context).cardColor
          : Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (phonetic != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  phonetic!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ),
            if (isFront)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 40.0,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: onSpeak,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
