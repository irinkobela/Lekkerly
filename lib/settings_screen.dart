// lib/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lekkerly/theme_provider.dart';
import 'package:lekkerly/services/progress_service.dart';
import 'package:lekkerly/services/favorites_service.dart';
import 'package:lekkerly/services/user_content_service.dart';
import 'package:lekkerly/services/achievement_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeToggle(context),
          const Divider(indent: 16, endIndent: 16),
          _buildSectionHeader(context, 'Data Management'),
          _buildResetOption(
            context: context,
            title: 'Reset Progress',
            subtitle:
                'This will delete all your quiz history and daily streak.',
            onConfirm: () async {
              await ProgressService().clearProgress();
            },
          ),
          _buildResetOption(
            context: context,
            title: 'Reset Favorites',
            subtitle: 'This will remove all your favorited words.',
            onConfirm: () async {
              // We need to add a clear function to the service
              await FavoritesService().clearFavorites();
            },
          ),
          _buildResetOption(
            context: context,
            title: 'Reset Achievements',
            subtitle: 'This will lock all your earned achievements.',
            onConfirm: () async {
              // We need to add a clear function to the service
              await AchievementService().clearAchievements();
            },
          ),
          _buildResetOption(
            context: context,
            title: 'Reset Custom Sets',
            subtitle:
                'This will delete all categories and words you have created.',
            onConfirm: () async {
              await UserContentService().saveUserCategories([]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Theme', style: TextStyle(fontSize: 16)),
              ToggleButtons(
                isSelected: [
                  themeProvider.themeMode == ThemeMode.light,
                  themeProvider.themeMode == ThemeMode.system,
                  themeProvider.themeMode == ThemeMode.dark,
                ],
                onPressed: (index) {
                  final mode = ThemeMode.values[index];
                  themeProvider.setThemeMode(mode);
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Icon(Icons.light_mode_outlined),
                  Icon(Icons.settings_system_daydream_outlined),
                  Icon(Icons.dark_mode_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title Successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildResetOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.delete_forever, color: Colors.grey),
      onTap: () => _showConfirmationDialog(
        context: context,
        title: title,
        content: 'Are you sure? This action cannot be undone.',
        onConfirm: onConfirm,
      ),
    );
  }
}
