// lib/models/achievement_model.dart

import 'package:flutter/material.dart';

// Using an enum for achievement IDs provides type safety and autocompletion.
enum AchievementId {
  firstQuiz,
  perfectScore,
  tenFavorites,
  dedicatedLearner,
  categoryConqueror, // A placeholder for a future, more complex achievement
}

class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final IconData icon;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}
