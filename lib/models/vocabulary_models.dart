// lib/models/vocabulary_models.dart

class VocabularyItem {
  final int id;
  final String dutchWord;
  final String englishTranslation;
  final String? phonetic;

  VocabularyItem({
    required this.id,
    required this.dutchWord,
    required this.englishTranslation,
    this.phonetic,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'],
      dutchWord: json['dutch_word'],
      englishTranslation: json['english_translation'],
      phonetic: json['phonetic'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dutch_word': dutchWord,
    'english_translation': englishTranslation,
    'phonetic': phonetic,
  };

  @override
  String toString() =>
      'VocabularyItem(id: $id, dutch: "$dutchWord", english: "$englishTranslation", phonetic: "$phonetic")';
}

class Category {
  final String name;
  final List<VocabularyItem> items;

  Category({required this.name, required this.items});

  factory Category.fromJson(String name, List<dynamic> jsonList) {
    final items = jsonList
        .map((itemJson) => VocabularyItem.fromJson(itemJson))
        .toList();
    return Category(name: name, items: items);
  }

  Map<String, dynamic> toJson() => {
    name: items.map((item) => item.toJson()).toList(),
  };

  @override
  String toString() => 'Category(name: $name, items: ${items.length} words)';
}
