// lib/services/user_content_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lekkerly/models/vocabulary_models.dart';

class UserContentService {
  static const String _userCategoriesKey = 'user_categories';

  // --- Category Management ---

  Future<List<Category>> loadUserCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> categoriesJson =
        prefs.getStringList(_userCategoriesKey) ?? [];
    return categoriesJson.map((jsonString) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final categoryName = jsonMap.keys.first;
      final items = (jsonMap[categoryName] as List)
          .map((item) => VocabularyItem.fromJson(item))
          .toList();
      return Category(name: categoryName, items: items);
    }).toList();
  }

  Future<void> saveUserCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> categoriesJson = categories
        .map((category) => json.encode({
              category.name:
                  category.items.map((item) => item.toJson()).toList()
            }))
        .toList();
    await prefs.setStringList(_userCategoriesKey, categoriesJson);
  }

  Future<void> addCategory(String categoryName) async {
    if (categoryName.isEmpty) return;
    final categories = await loadUserCategories();
    // Prevent duplicate category names
    if (categories
        .any((c) => c.name.toLowerCase() == categoryName.toLowerCase())) return;
    categories.add(Category(name: categoryName, items: []));
    await saveUserCategories(categories);
  }

  Future<void> deleteCategory(String categoryName) async {
    final categories = await loadUserCategories();
    categories.removeWhere((c) => c.name == categoryName);
    await saveUserCategories(categories);
  }

  // --- Word Management ---

  Future<void> addWordToCategory(
      String categoryName, String dutchWord, String englishWord) async {
    if (dutchWord.isEmpty || englishWord.isEmpty) return;

    final categories = await loadUserCategories();
    final categoryIndex = categories.indexWhere((c) => c.name == categoryName);

    if (categoryIndex != -1) {
      final category = categories[categoryIndex];

      // Prevent duplicate words in the same category
      if (category.items.any(
          (item) => item.dutchWord.toLowerCase() == dutchWord.toLowerCase()))
        return;

      // Create a unique ID. Using timestamp is simple and effective for user content.
      final newId = DateTime.now().millisecondsSinceEpoch;
      final newWord = VocabularyItem(
          id: newId, dutchWord: dutchWord, englishTranslation: englishWord);

      category.items.add(newWord);
      await saveUserCategories(categories);
    }
  }

  Future<void> removeWordFromCategory(String categoryName, int wordId) async {
    final categories = await loadUserCategories();
    final categoryIndex = categories.indexWhere((c) => c.name == categoryName);

    if (categoryIndex != -1) {
      categories[categoryIndex].items.removeWhere((item) => item.id == wordId);
      await saveUserCategories(categories);
    }
  }
}
