// lib/my_sets_screen.dart

import 'package:flutter/material.dart';
import 'package:lekkerly/models/vocabulary_models.dart';
import 'package:lekkerly/services/user_content_service.dart';
import 'package:lekkerly/edit_set_screen.dart';

class MySetsScreen extends StatefulWidget {
  const MySetsScreen({super.key});

  @override
  State<MySetsScreen> createState() => _MySetsScreenState();
}

class _MySetsScreenState extends State<MySetsScreen> {
  final UserContentService _contentService = UserContentService();
  List<Category> _userCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSets();
  }

  Future<void> _loadUserSets() async {
    setState(() => _isLoading = true);
    final categories = await _contentService.loadUserCategories();
    setState(() {
      _userCategories = categories;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Set'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _contentService.addCategory(controller.text.trim());
              Navigator.of(context).pop();
              _loadUserSets();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String categoryName) async {
    await _contentService.deleteCategory(categoryName);
    _loadUserSets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Custom Sets'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        tooltip: 'Add New Set',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userCategories.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadUserSets,
                  child: ListView.builder(
                    itemCount: _userCategories.length,
                    itemBuilder: (context, index) {
                      final category = _userCategories[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(category.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${category.items.length} words'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () => _deleteCategory(category.name),
                          ),
                          onTap: () => Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                    builder: (_) => EditSetScreen(
                                        categoryName: category.name)),
                              )
                              .then((_) => _loadUserSets()),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.create_new_folder_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No custom sets yet.', style: TextStyle(fontSize: 20)),
          const Text('Tap the "+" button to create your first set.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
