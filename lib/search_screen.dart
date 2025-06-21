// lib/search_screen.dart

import 'package:flutter/material.dart';
import 'models/vocabulary_models.dart';
import 'services/favorites_service.dart';

class SearchScreen extends StatefulWidget {
  final List<VocabularyItem> allItems;

  const SearchScreen({super.key, required this.allItems});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  late Set<int> _favoriteIds;
  List<VocabularyItem> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoritesService.getFavoriteIds();
    setState(() {
      _favoriteIds = ids.toSet();
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = widget.allItems.where((item) {
        final dutchMatch = item.dutchWord.toLowerCase().contains(query);
        final englishMatch =
            item.englishTranslation.toLowerCase().contains(query);
        return dutchMatch || englishMatch;
      }).toList();
    });
  }

  void _toggleFavorite(int wordId) {
    setState(() {
      if (_favoriteIds.contains(wordId)) {
        _favoriteIds.remove(wordId);
        _favoritesService.removeFavorite(wordId);
      } else {
        _favoriteIds.add(wordId);
        _favoritesService.addFavorite(wordId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search Dutch or English...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'Start typing to search'
                        : 'No results found',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
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
