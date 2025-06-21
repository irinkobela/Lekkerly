// lib/flashcard_screen.dart

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'models/vocabulary_models.dart';
import 'dart:math'; // Import for Random

class FlashcardScreen extends StatefulWidget {
  final List<VocabularyItem> vocabularyItems;

  const FlashcardScreen({super.key, required this.vocabularyItems});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final PageController _controller = PageController();
  final FlutterTts flutterTts = FlutterTts();
  late List<VocabularyItem> _shuffledItems; // NEW: To hold the shuffled list
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the list and shuffle it right away
    _shuffledItems = List.from(widget.vocabularyItems);
    _shuffleCards();
    _initializeTts();
  }

  // NEW: Method to handle shuffling the cards
  void _shuffleCards() {
    setState(() {
      _shuffledItems.shuffle(Random());
      _currentIndex = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    });
  }

  void _initializeTts() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("nl-NL");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
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
        // NEW: Shuffle button in the AppBar
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
          // If the list is empty, show a message
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
                itemCount: _shuffledItems.length, // Use the shuffled list
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = _shuffledItems[index]; // Use the shuffled list
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
          // Hide controls if there are no cards
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
          ? Colors.white
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
                        color: Colors.black54,
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
