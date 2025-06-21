// lib/vocabulary_list_screen.dart

import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/services/favorites_service.dart';
import 'package:lekkerly/services/achievement_service.dart'; // Import Achievement service
import 'package:flutter/material.dart';

class VocabularyListScreen extends StatefulWidget {
  final Category category;

  const VocabularyListScreen({super.key, required this.category});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final AchievementService _achievementService =
      AchievementService(); // Add service instance
  late Set<int> _favoriteIds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoritesService.getFavoriteIds();
    setState(() {
      _favoriteIds = ids.toSet();
      _isLoading = false;
    });
  }

  // UPDATED: Toggle method now checks for achievements
  void _toggleFavorite(int wordId) async {
    final isFavoriting = !_favoriteIds.contains(wordId);

    setState(() {
      if (isFavoriting) {
        _favoriteIds.add(wordId);
        _favoritesService.addFavorite(wordId);
      } else {
        _favoriteIds.remove(wordId);
        _favoritesService.removeFavorite(wordId);
      }
    });

    // Only check for achievement when adding a new favorite
    if (isFavoriting) {
      final allFavoriteIds = await _favoritesService.getFavoriteIds();
      final newlyUnlocked =
          await _achievementService.checkFavoriteAchievements(allFavoriteIds);

      if (newlyUnlocked.isNotEmpty && mounted) {
        for (var achievement in newlyUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              content: Row(
                children: [
                  Icon(achievement.icon, color: Colors.amberAccent),
                  const SizedBox(width: 8),
                  Text('Achievement Unlocked: ${achievement.title}'),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.category.items.length,
              itemBuilder: (context, index) {
                final item = widget.category.items[index];
                final isFavorite = _favoriteIds.contains(item.id);

                return ListTile(
                  title: Text(item.dutchWord),
                  subtitle: Text(item.englishTranslation),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(item.id),
                  ),
                );
              },
            ),
    );
  }
}
