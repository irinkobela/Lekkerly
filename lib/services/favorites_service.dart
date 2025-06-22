// lib/services/favorites_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_words';

  Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIdStrings =
        prefs.getStringList(_favoritesKey) ?? [];
    return favoriteIdStrings.map((id) => int.parse(id)).toList();
  }

  Future<void> addFavorite(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> favoriteIds = await getFavoriteIds();
    if (!favoriteIds.contains(wordId)) {
      favoriteIds.add(wordId);
      await _saveFavorites(favoriteIds, prefs);
    }
  }

  Future<void> removeFavorite(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> favoriteIds = await getFavoriteIds();
    if (favoriteIds.contains(wordId)) {
      favoriteIds.remove(wordId);
      await _saveFavorites(favoriteIds, prefs);
    }
  }

  // NEW: Function to clear all favorites
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  Future<void> _saveFavorites(List<int> ids, SharedPreferences prefs) async {
    final List<String> favoriteIdStrings =
        ids.map((id) => id.toString()).toList();
    await prefs.setStringList(_favoritesKey, favoriteIdStrings);
  }
}
