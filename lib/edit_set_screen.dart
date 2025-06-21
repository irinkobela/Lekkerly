// lib/edit_set_screen.dart

import 'package:flutter/material.dart';
import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/services/user_content_service.dart';

class EditSetScreen extends StatefulWidget {
  final String categoryName;

  const EditSetScreen({super.key, required this.categoryName});

  @override
  State<EditSetScreen> createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
  final UserContentService _contentService = UserContentService();
  Category? _category;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    setState(() => _isLoading = true);
    final allCategories = await _contentService.loadUserCategories();
    setState(() {
      _category =
          allCategories.firstWhere((c) => c.name == widget.categoryName);
      _isLoading = false;
    });
  }

  void _showAddWordDialog() {
    final dutchController = TextEditingController();
    final englishController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: dutchController,
                decoration: const InputDecoration(labelText: 'Dutch Word')),
            TextField(
                controller: englishController,
                decoration:
                    const InputDecoration(labelText: 'English Translation')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _contentService.addWordToCategory(
                widget.categoryName,
                dutchController.text.trim(),
                englishController.text.trim(),
              );
              Navigator.of(context).pop();
              _loadCategory();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteWord(int wordId) async {
    await _contentService.removeWordFromCategory(widget.categoryName, wordId);
    _loadCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing: ${widget.categoryName}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWordDialog,
        tooltip: 'Add New Word',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _category == null || _category!.items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _category!.items.length,
                  itemBuilder: (context, index) {
                    final word = _category!.items[index];
                    return ListTile(
                      title: Text(word.dutchWord),
                      subtitle: Text(word.englishTranslation),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () => _deleteWord(word.id),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('This set is empty.', style: TextStyle(fontSize: 20)),
          const Text('Tap the "+" button to add your first word.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
