// lib/services/achievement_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lekkerly/models/achievement_model.dart';
import 'package:lekkerly/models/progress_model.dart';

class AchievementService {
  static const String _unlockedKey = 'unlocked_achievements';

  // A static list of all possible achievements in the app.
  final List<Achievement> _achievements = [
    Achievement(
      id: AchievementId.firstQuiz,
      title: "Quiz Novice",
      description: "Complete your first quiz.",
      icon: Icons.flag_outlined,
    ),
    Achievement(
      id: AchievementId.perfectScore,
      title: "Perfecto!",
      description: "Get a 100% score on any quiz.",
      icon: Icons.star_rounded,
    ),
    Achievement(
      id: AchievementId.tenFavorites,
      title: "Word Explorer",
      description: "Favorite at least 10 words.",
      icon: Icons.explore_outlined,
    ),
    Achievement(
      id: AchievementId.dedicatedLearner,
      title: "Dedicated Learner",
      description: "Complete quizzes on 3 different days.",
      icon: Icons.calendar_month_outlined,
    ),
  ];

  // Gets the master list of achievements with their current unlock status.
  Future<List<Achievement>> getAllAchievements() async {
    final unlockedIds = await _getUnlockedIds();
    for (var achievement in _achievements) {
      achievement.isUnlocked = unlockedIds.contains(achievement.id.name);
    }
    return _achievements;
  }

  // Gets the Set of unlocked achievement ID strings from storage.
  Future<Set<String>> _getUnlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_unlockedKey) ?? []).toSet();
  }

  // Unlocks a new achievement and saves it to storage.
  Future<void> _unlockAchievement(SharedPreferences prefs,
      Set<String> unlockedIds, Achievement achievement) async {
    unlockedIds.add(achievement.id.name);
    await prefs.setStringList(_unlockedKey, unlockedIds.toList());
    achievement.isUnlocked = true;
  }

  // --- Methods to check if achievements should be unlocked ---

  // Checks for achievements related to quiz performance.
  Future<List<Achievement>> checkQuizAchievements(
      List<Progress> allProgress) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = await _getUnlockedIds();
    final newlyUnlocked = <Achievement>[];

    if (allProgress.isEmpty) return newlyUnlocked;

    // Check for "First Quiz"
    final firstQuizAchievement =
        _achievements.firstWhere((a) => a.id == AchievementId.firstQuiz);
    if (!unlockedIds.contains(firstQuizAchievement.id.name)) {
      await _unlockAchievement(prefs, unlockedIds, firstQuizAchievement);
      newlyUnlocked.add(firstQuizAchievement);
    }

    // Check for "Perfect Score"
    final perfectScoreAchievement =
        _achievements.firstWhere((a) => a.id == AchievementId.perfectScore);
    if (!unlockedIds.contains(perfectScoreAchievement.id.name)) {
      bool hasPerfectScore = allProgress
          .any((p) => p.score == p.totalQuestions && p.totalQuestions > 0);
      if (hasPerfectScore) {
        await _unlockAchievement(prefs, unlockedIds, perfectScoreAchievement);
        newlyUnlocked.add(perfectScoreAchievement);
      }
    }

    // Check for "Dedicated Learner" (3 different days)
    final dedicatedLearnerAchievement =
        _achievements.firstWhere((a) => a.id == AchievementId.dedicatedLearner);
    if (!unlockedIds.contains(dedicatedLearnerAchievement.id.name)) {
      final uniqueDays = allProgress
          .map((p) =>
              DateTime(p.timestamp.year, p.timestamp.month, p.timestamp.day))
          .toSet();
      if (uniqueDays.length >= 3) {
        await _unlockAchievement(
            prefs, unlockedIds, dedicatedLearnerAchievement);
        newlyUnlocked.add(dedicatedLearnerAchievement);
      }
    }

    return newlyUnlocked;
  }

  // Checks for achievements related to favoriting words.
  Future<List<Achievement>> checkFavoriteAchievements(
      List<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = await _getUnlockedIds();
    final newlyUnlocked = <Achievement>[];

    final tenFavoritesAchievement =
        _achievements.firstWhere((a) => a.id == AchievementId.tenFavorites);
    if (!unlockedIds.contains(tenFavoritesAchievement.id.name) &&
        favoriteIds.length >= 10) {
      await _unlockAchievement(prefs, unlockedIds, tenFavoritesAchievement);
      newlyUnlocked.add(tenFavoritesAchievement);
    }

    return newlyUnlocked;
  }
}
