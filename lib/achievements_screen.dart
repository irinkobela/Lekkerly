// lib/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:lekkerly/models/achievement_model.dart';
import 'package:lekkerly/services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  late Future<List<Achievement>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    _achievementsFuture = _achievementService.getAllAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Achievements'),
      ),
      body: FutureBuilder<List<Achievement>>(
        future: _achievementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No achievements available.'));
          }

          final achievements = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final bool isUnlocked = achievement.isUnlocked;

              return Card(
                elevation: isUnlocked ? 6.0 : 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: isUnlocked
                          ? LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.7),
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isUnlocked ? null : Colors.grey.shade200,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isUnlocked ? achievement.icon : Icons.lock_outline,
                            size: 48,
                            color: isUnlocked
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            achievement.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isUnlocked ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isUnlocked
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
